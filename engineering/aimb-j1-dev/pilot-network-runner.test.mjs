import {test} from 'node:test';
import assert from 'node:assert/strict';
import {generateKeyPairSync,verify,constants} from 'node:crypto';
import {PilotNetworkRunner,signPilotWebSocket,MAX_PILOT_MS,loadPinnedPilotKey} from './pilot-network-runner.mjs';
import {STAGING_ORIGIN,STAGING_D1_UUID,STAGING_WORKER_VERSION} from './staging-read-signer.mjs';

const {privateKey,publicKey}=generateKeyPairSync('rsa',{modulusLength:2048});
const id='f20b9291-7a39-4854-a21c-cc7b9a240001';
const command={id,action:'list_project_files',args_json:'{"offset":0,"limit":20}',expires_at:Math.floor(Date.now()/1000)+100};
function response(status,body){return {status,json:async()=>body};}
function runnerFor({transport,agent,wsFactory,setTimer,clearTimer,clock,unixNow,maxDurationMs=30_000,fallbackMs=10_000}={}){
 return new PilotNetworkRunner({privateKey,transport:transport||(()=>response(200,{ok:true,channels:{projects:{command:null}}})),agent:agent||{execute:async()=>({ok:true,files:['sample-a.txt']})},webSocketFactory:wsFactory??(async()=>({close(){}})),maxDurationMs,fallbackMs,setTimer,clearTimer,clock,unixNow});
}

test('pins staging identifiers and refuses longer than five minutes',()=>{
 assert.equal(MAX_PILOT_MS,300000);
 assert.throws(()=>new PilotNetworkRunner({privateKey,agent:{execute(){}},base:'https://example.invalid'}),/STAGING_ORIGIN_PIN_FAILED/);
 assert.throws(()=>new PilotNetworkRunner({privateKey,agent:{execute(){}},d1Uuid:'production'}),/STAGING_D1_PIN_FAILED/);
 assert.throws(()=>new PilotNetworkRunner({privateKey,agent:{execute(){}},workerVersion:'V6'}),/STAGING_VERSION_PIN_FAILED/);
 assert.throws(()=>new PilotNetworkRunner({privateKey,agent:{execute(){}},maxDurationMs:300001}),/PILOT_DURATION_INVALID/);
});

test('WebSocket canonical matches the V7 signed GET protocol',()=>{
 const timestamp=String(Math.floor(Date.now()/1000)),nonce='abcdefghijklmnopQRSTUV';
 const headers=signPilotWebSocket({privateKey,timestamp,nonce});
 const canonical=`${timestamp}\n${nonce}\nGET /agent/realtime\nfixture-device-example`;
 assert.equal(verify('RSA-SHA256',Buffer.from(canonical),{key:publicKey,padding:constants.RSA_PKCS1_PADDING},Buffer.from(headers['x-bridge-signature'],'base64url')),true);
});

test('a single WSS projects wake triggers one grouped projects poll and a signed result',async()=>{
 let runner,wsMessage,polls=0,execs=0,results=0;const calls=[];
 const transport=async(url,init)=>{calls.push({url,init});const b=JSON.parse(init.body);if(url.endsWith('/agent/batch/poll')){polls++;assert.deepEqual(b.channels,['projects']);if(polls===1){queueMicrotask(()=>wsMessage?.({data:JSON.stringify({type:'pending',channel:'projects'})}));return response(200,{ok:true,channels:{projects:{command:null}}});}return response(200,{ok:true,channels:{projects:{command}}});}if(url.endsWith('/agent/batch/result')){results++;runner.stop();return response(200,{received:true});}throw Error('UNEXPECTED_ROUTE');};
 const wsFactory=async({url,headers})=>{assert.equal(url,STAGING_ORIGIN.replace(/^https:/,'wss:')+'/agent/realtime');assert.ok(headers['x-bridge-signature']);return {set onmessage(fn){wsMessage=fn;},close(){}};};
 runner=runnerFor({transport,wsFactory,agent:{execute:async ({action,args})=>{execs++;assert.equal(action,'list_project_files');assert.equal(args.limit,20);return {ok:true,files:['sample-a.txt']};}}});
 const proof=await runner.run();assert.equal(proof.websocketConnected,true);assert.equal(proof.polls,2);assert.equal(execs,1);assert.equal(results,1);assert.equal(proof.executions[0].id,id);
 for(const c of calls){const nonce=c.init.headers['x-bridge-nonce'],ts=c.init.headers['x-bridge-timestamp'],route=new URL(c.url).pathname,canonical=`${ts}\n${nonce}\nPOST ${route}\n${c.init.body}`;assert.equal(verify('RSA-SHA256',Buffer.from(canonical),{key:publicKey,padding:constants.RSA_PKCS1_PADDING},Buffer.from(c.init.headers['x-bridge-signature'],'base64url')),true);}
});

test('ambiguous result ACK is recovered with signed status without executing twice',async()=>{
 let execs=0,statusCalls=0,runner;const transport=async(url,init)=>{const b=JSON.parse(init.body);if(url.endsWith('/agent/batch/poll'))return response(200,{ok:true,channels:{projects:{command}}});if(url.endsWith('/agent/batch/result'))throw Error('simulated-lost-ack');if(url.endsWith('/agent/batch/result-status')){statusCalls++;assert.equal(b.purpose,'result_status');runner.stop();return response(200,{status:'done',result:{ok:true,files:['sample-a.txt']}});}throw Error('UNEXPECTED_ROUTE');};
 runner=runnerFor({transport,agent:{execute:async()=>{execs++;return {ok:true,files:['sample-a.txt']};}}});const proof=await runner.run();assert.equal(execs,1);assert.equal(statusCalls,1);assert.equal(proof.executions.length,1);assert.deepEqual(proof.errors,[]);assert.deepEqual(proof.requests.map(x=>x.route),['/agent/batch/poll','/agent/batch/result','/agent/batch/result-status']);assert.ok(proof.requests.every(x=>/^[A-Za-z0-9_-]{16,64}$/.test(x.test_nonce)&&!('x-bridge-signature'in x)));
});

test('expired project job is rejected before touching the fixture agent',async()=>{
 let execs=0,runner;const expired={...command,expires_at:Math.floor(Date.now()/1000)+10};const transport=async(url)=>{if(url.endsWith('/agent/batch/poll'))return response(200,{ok:true,channels:{projects:{command:expired}}});runner.stop();return response(200,{received:true});};
 runner=runnerFor({transport,agent:{execute:async()=>{execs++;return {ok:true};}}});const proof=await runner.run();assert.equal(execs,0);assert.ok(proof.errors.includes('TTL_MARGIN_TOO_SHORT'));
});

test('temporary poll network failure is recorded and fallback continues without rapid retry',async()=>{
 const ticks=[];let runner,calls=0;
 const transport=async()=>{calls++;if(calls===1)throw Error('ECONNRESET');runner.stop();return response(200,{ok:true,channels:{projects:{command:null}}});};
 const setTimer=(fn,ms)=>{const x={fn,ms};ticks.push(x);if(ticks.length===2)queueMicrotask(()=>runner.stop());return x;};
 runner=runnerFor({transport,setTimer,clearTimer:()=>{},agent:{execute:async()=>({})}});const proof=await runner.run();assert.equal(calls,1);assert.deepEqual(proof.errors,['ECONNRESET']);assert.ok(ticks.some(x=>x.ms===10000));
});

test('idle path issues one grouped fallback poll at the configured 60-second cap',async()=>{
 const timers=[];let runner,polls=0;
 const setTimer=(fn,ms)=>{const t={fn,ms};timers.push(t);if(timers.length===2)queueMicrotask(fn);return t;};
 const transport=async()=>{polls++;if(polls===2)runner.stop();return response(200,{ok:true,channels:{projects:{command:null}}});};
 runner=runnerFor({transport,setTimer,clearTimer:()=>{},maxDurationMs:120_000,fallbackMs:60_000,agent:{execute:async()=>({})}});const proof=await runner.run();
 assert.equal(polls,2);assert.equal(proof.polls,2);assert.equal(timers[1].ms,60_000);assert.equal(proof.errors.length,0);
});

test('pinned key loader rejects a missing key file without leaking path contents',()=>{
 assert.equal(typeof loadPinnedPilotKey,'function');
 assert.throws(()=>loadPinnedPilotKey('C:\\nonexistent.pem',{expectedThumbprint:'0'.repeat(64)}),/PILOT_KEY_NOT_REGULAR_FILE/);
});
