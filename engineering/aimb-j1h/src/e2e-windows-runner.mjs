/**
 * AI Machine Bridge J1-H, Windows E2E staging-only harness.
 * Never deploy, write SQL, or access the production Worker.
 * No external packages; Node >= 22. Does not depend on a root environment variable.
 */
import {readFileSync, statSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
import {createPrivateKey, createHash, randomBytes, sign, verify, randomUUID} from 'node:crypto';
import {request as httpsRequest} from 'node:https';
import {setTimeout as delay} from 'node:timers/promises';
import {resolve} from 'node:path';

export const BASE='https://ai-machine-bridge-j1h-staging.benmoussa-achraf.workers.dev';
export const DEVICE='j1h-staging-fixture';
export const CHANNELS=Object.freeze(['commands','files','maintenance','workspace','projects']);
export const ACTIONS=Object.freeze({commands:['get_system_info'],files:['list_authorized_files','read_authorized_text'],maintenance:['get_pc_resources','get_bridge_tasks','inspect_windows_service'],workspace:['list_workspace_files','read_workspace_text'],projects:['list_project_files','read_project_text']});
export const CANONICAL_ROUTE=Object.freeze({poll:'/agent/batch/poll',result:'/agent/batch/result',status:'/agent/batch/result-status'});
const UUID=/^[a-f0-9]{8}-(?:[a-f0-9]{4}-){3}[a-f0-9]{12}$/i;
const CH_MAP=Object.fromEntries(CHANNELS.map(x=>[x,x]));
const moduleDir=fileURLToPath(new URL('.',import.meta.url));

export function requireStagingUrl(url=BASE){
 const parsed=new URL(url);
 if(parsed.origin!==BASE || parsed.protocol!=='https:' || parsed.username || parsed.password || parsed.search || parsed.hash || parsed.pathname!=='/')throw Error('STAGING_URL_PIN_FAILED');
 return parsed.origin;
}
export function b64url(buf){return Buffer.from(buf).toString('base64url');}
export function signRequest(key,path,body,{nonce=b64url(randomBytes(18)),timestamp=String(Math.floor(Date.now()/1000)),method='POST',websocket=false}={}){
 if(!/^\/[a-z0-9/-]+$/.test(path)||!/^\d{10,12}$/.test(timestamp)||!/^[A-Za-z0-9_-]{16,64}$/.test(nonce))throw Error('INVALID_SIGNATURE_INPUT');
 let canonical;
 if(websocket) canonical=`${timestamp}\n${nonce}\n${method} ${path}\n${DEVICE}`;
 else canonical=`${timestamp}\n${nonce}\n${method} ${path}\n${body}`;
 const signature=b64url(sign('RSA-SHA256',Buffer.from(canonical,'utf8'),key));
 return {'x-bridge-timestamp':timestamp,'x-bridge-nonce':nonce,'x-bridge-signature':signature};
}
export function loadKey(keyPath=process.env.AIMB_J1H_PRIVATE_KEY_PATH){
 if(!keyPath || typeof keyPath!=='string')throw Error('FIXTURE_PRIVATE_KEY_PATH_REQUIRED');
 const file=resolve(keyPath),st=statSync(file,{throwIfNoEntry:false});
 if(!st?.isFile())throw Error('FIXTURE_PRIVATE_KEY_NOT_REGULAR_FILE');
 // Never log or serialize key material.
 return createPrivateKey(readFileSync(file));
}
export function validateManifest(input,now=Math.floor(Date.now()/1000),margin=48){
 if(!input || typeof input!=='object' || Array.isArray(input))throw Error('MANIFEST_OBJECT_REQUIRED');
 if(input.device_id!==DEVICE || Object.keys(input).sort().join(',')!=='device_id,jobs,staging_worker_version')throw Error('MANIFEST_SCOPE_INVALID');
 if(input.staging_worker_version!=='605a258b-580e-4f32-b9b0-4e0bd8d0efcd')throw Error('STAGING_VERSION_MISMATCH');
 if(!input.jobs || Object.keys(input.jobs).sort().join(',')!==[...CHANNELS].sort().join(','))throw Error('EXACT_FIVE_CHANNELS_REQUIRED');
 const ids=new Set();
 for(const ch of CHANNELS){
  const row=input.jobs[ch];
  if(!row || Object.keys(row).sort().join(',')!=='action,expires_at,id' || !UUID.test(row.id) || !ACTIONS[ch].includes(row.action) || !Number.isInteger(row.expires_at))throw Error(`INVALID_FIXTURE_${ch}`);
  if(row.expires_at<=now+margin)throw Error(`TTL_MARGIN_TOO_SHORT_${ch}`);
  if(row.expires_at>now+120)throw Error('STAGING_TTL_OVER_120_SECONDS');
  if(ids.has(row.id))throw Error('DUPLICATE_JOB_ID');
  ids.add(row.id);
 }
 return input;
}
export function percentile(values,p){
 if(!values.length)return null;
 const sorted=[...values].sort((a,b)=>a-b),i=Math.max(0,Math.min(sorted.length-1,Math.ceil(p/100*sorted.length)-1));
 return Math.round(sorted[i]*100)/100;
}
export function parseArgs(args){
 let phase=null,manifest=null;
 for(let i=0;i<args.length;i++){
  const a=args[i];
  if(a==='--phase' && !phase && args[i+1])phase=args[++i];
  else if(a==='--manifest' && !manifest && args[i+1])manifest=args[++i];
  else if(a==='--help' && args.length===1)return {help:true};
  else throw Error('BAD_CLI_ARGUMENTS');
 }
 if(!['preflight','websocket','cadence','batch'].includes(phase))throw Error('PHASE_REQUIRED');
 if(phase==='batch'&&!manifest)throw Error('BATCH_NEEDS_MANIFEST');
 if(phase!=='batch'&&manifest)throw Error('MANIFEST_ONLY_FOR_BATCH');
 return {phase,manifest};
}
function makeBody(purpose,more={}){return {agent_version:'0.7.0',device_id:DEVICE,purpose,...more};}
function unsignedPath(path){if(!['/health','/agent/batch/poll','/agent/batch/result','/agent/batch/result-status','/staging/notify'].includes(path))throw Error('PATH_NOT_ALLOWLISTED');return path;}
export class StageHarness{
 constructor(privateKey,{base=BASE,timeoutMs=12500}={}){this.base=requireStagingUrl(base);this.key=privateKey;this.latencies=[];this.calls=[];this.timeoutMs=timeoutMs;}
 async request(path,{method='POST',payload=null,signed=true,wsAuth=false,wrongSignature=false}={}){
  unsignedPath(path);
  const raw=payload===null?'':JSON.stringify(payload);
  const headers={};if(method==='POST')headers['content-type']='application/json';
  if(signed){Object.assign(headers,signRequest(this.key,path,raw,{method,websocket:wsAuth}));if(wrongSignature)headers['x-bridge-signature']='A'.repeat(342)}
  const start=performance.now(),r=await fetch(this.base+path,{method,headers,...(method==='POST'?{body:raw}:{}),signal:AbortSignal.timeout(this.timeoutMs)}),duration=performance.now()-start;
  let content;try{content=await r.json()}catch{content={non_json:true}}
  this.latencies.push(duration);this.calls.push({path,method,status:r.status,ms:Math.round(duration*100)/100,...(headers['x-bridge-nonce']?{test_nonce:headers['x-bridge-nonce']}:{} )});
  return {status:r.status,body:content};
 }
 report(phase,detail={}){
  return {phase,outcome:'PASS',timestamp_utc:new Date().toISOString(),target:this.base,production_touched:false,private_key_logged:false,requests:this.calls,latency_ms:{p50:percentile(this.latencies,50),p95:percentile(this.latencies,95)},...detail};
 }
}
function assert(ok,code){if(!ok)throw Error(code);}
export async function preflight(h){
 const health=await h.request('/health',{method:'GET',signed:false});assert(health.status===200&&health.body.production===false&&health.body.d1===true&&health.body.do_bound===true,'HEALTH_NOT_READY');
 const route=await h.request('/agent/batch/result-status',{method:'GET',signed:false});assert(route.status===405,'RESULT_STATUS_ROUTE_NOT_READY');
 const payload=makeBody('batch_poll',{channels:CHANNELS});
 const unsigned=await h.request('/agent/batch/poll',{payload,signed:false});assert(unsigned.status===401,'UNSIGNED_POLL_NOT_REJECTED');
 const invalid=await h.request('/agent/batch/poll',{payload,wrongSignature:true});assert(invalid.status===401,'INVALID_RSA_NOT_REJECTED');
 const raw=JSON.stringify(payload),signedHeaders=signRequest(h.key,'/agent/batch/poll',raw);
 const start=performance.now();const attempt=()=>fetch(h.base+'/agent/batch/poll',{method:'POST',headers:{'content-type':'application/json',...signedHeaders},body:raw,signal:AbortSignal.timeout(h.timeoutMs)});
 const first=await attempt();let obj={};try{obj=await first.json()}catch{}h.calls.push({path:'/agent/batch/poll',method:'POST',status:first.status,test_nonce:signedHeaders['x-bridge-nonce'],ms:Math.round((performance.now()-start)*100)/100});
 assert(first.status===200&&obj.ok===true&&CHANNELS.every(ch=>obj.channels?.[ch]?.command===null),'STAGING_NOT_EMPTY_OR_RSA_MISMATCH');
 const replay=await attempt();h.calls.push({path:'/agent/batch/poll',method:'POST',status:replay.status,test_nonce:signedHeaders['x-bridge-nonce'],exact_replay:true});assert(replay.status===409,'REPLAY_NOT_REJECTED');
 return h.report('preflight',{health:health.body,empty_batch:true,invalid_signature_rejected:true,replay_rejected:true});
}
export async function runFixtures(h,manifest){
 const now=Math.floor(Date.now()/1000);validateManifest(manifest,now,48);
 const poll=makeBody('batch_poll',{channels:CHANNELS});
 const leased=await h.request('/agent/batch/poll',{payload:poll});assert(leased.status===200,'BATCH_HTTP_FAILURE');
 for(const ch of CHANNELS)assert(leased.body.channels?.[ch]?.command?.id===manifest.jobs[ch].id,`BATCH_LEASE_MISMATCH_${ch}`);
 const recovery=await h.request('/agent/batch/poll',{payload:{...poll,recovery_mode:'leased_first'}});
 assert(recovery.status===200,'RECOVERY_HTTP_FAILURE');
 for(const ch of CHANNELS)assert(recovery.body.channels?.[ch]?.command?.id===manifest.jobs[ch].id,`RECOVERY_MISMATCH_${ch}`);
 const proofId=randomUUID();const resultSummary={};
 for(const ch of CHANNELS){
  const row=manifest.jobs[ch],value={ok:true,test_marker:'j1h-e2e-'+proofId+'-'+ch};
  const payload=makeBody('batch_result',{channel:ch,job_id:row.id,action:row.action,result:value});
  const acknowledged=await h.request('/agent/batch/result',{payload});
  // First result receipt deliberately ignored as the simulated lost ACK for 'commands'.
  if(ch!=='commands')assert(acknowledged.status===200&&acknowledged.body.received===true,`RESULT_REJECTED_${ch}`);
  const statusPayload=makeBody('result_status',{channel:ch,job_id:row.id,action:row.action});
  const status=await h.request('/agent/batch/result-status',{payload:statusPayload});
  assert(status.status===200&&status.body.status==='done'&&JSON.stringify(status.body.result)===JSON.stringify(value),`ACK_RECOVERY_FAILED_${ch}`);
  resultSummary[ch]={id:row.id,stored:true,verified_after_ack:true};
 }
 const row=manifest.jobs.commands;const same=makeBody('batch_result',{channel:'commands',job_id:row.id,action:row.action,result:{ok:true,test_marker:'j1h-e2e-'+proofId+'-commands'}});
 const duplicate=await h.request('/agent/batch/result',{payload:same});assert(duplicate.status===200&&duplicate.body.already_received===true,'IDEMPOTENT_RETRY_FAILED');
 const conflict=await h.request('/agent/batch/result',{payload:{...same,result:{ok:true,test_marker:'CONFLICT_'+proofId}}});assert(conflict.status===409,'CONFLICT_NOT_REJECTED');
 const empty=await h.request('/agent/batch/poll',{payload:poll});assert(empty.status===200&&CHANNELS.every(ch=>empty.body.channels?.[ch]?.command===null),'JOB_STILL_PENDING');
 return h.report('batch',{five_readonly_leases:true,recovery_leased_first:true,result_ack_status_count:5,idempotent_ack:true,conflict_rejected:true,simulated_lost_ack:true,manifest_ids:Object.fromEntries(CHANNELS.map(ch=>[ch,manifest.jobs[ch].id])),resultSummary});
}
function wsFrame(data){
 if(data.length<2)return null;let length=data[1]&127,head=2;
 if(length===126){if(data.length<4)return null;length=data.readUInt16BE(2);head=4;}
 else if(length===127){if(data.length<10)return null;const big=data.readBigUInt64BE(2);if(big>BigInt(1<<20))throw Error('WS_FRAME_TOO_LARGE');length=Number(big);head=10;}
 const isMasked=(data[1]&128)!==0;if(isMasked)throw Error('WS_SERVER_MASKED_FRAME');
 if(length>1<<20)throw Error('WS_FRAME_TOO_LARGE');if(data.length<head+length)return null;
 return {op:data[0]&15,fin:(data[0]&128)!==0,data:data.subarray(head,head+length),taken:head+length};
}
export class RawWS{
 constructor(socket){this.socket=socket;this.buffer=Buffer.alloc(0);this.listeners=[];this.items=[];this.closed=false;this.closeCode=null;this.closedWaiters=[];socket.on('data',b=>this.feed(b));socket.on('close',()=>{this.closed=true;for(const w of this.closedWaiters)w()});socket.on('error',e=>{this.socketError=String(e.message);this.closed=true;for(const w of this.closedWaiters)w()});}
 feed(chunk){this.buffer=Buffer.concat([this.buffer,chunk]);for(;;){const frame=wsFrame(this.buffer);if(!frame)break;this.buffer=this.buffer.subarray(frame.taken);if(frame.op===8){this.closeCode=frame.data.length>=2?frame.data.readUInt16BE(0):null;this.socket.end();}else if(frame.op===1){try{const msg=JSON.parse(frame.data.toString('utf8'));this.items.push(msg);for(const l of this.listeners)l(msg)}catch{this.items.push({text:frame.data.toString('utf8')})}}else if(frame.op===9){/* server ping; no data required for test */}}
 }
 async untilMessage(predicate,ms=7000){const found=this.items.find(predicate);if(found)return found;return new Promise((resolve,reject)=>{let done=false;const handler=m=>{if(!done&&predicate(m)){done=true;clearTimeout(timer);resolve(m)}};this.listeners.push(handler);const timer=setTimeout(()=>{if(!done){done=true;reject(Error('WS_MESSAGE_TIMEOUT'))}},ms);timer.unref?.()})}
 async untilClosed(ms=7000){if(this.closed)return this.closeCode;await Promise.race([new Promise(resolve=>this.closedWaiters.push(resolve)),delay(ms).then(()=>{throw Error('WS_CLOSE_TIMEOUT')})]);return this.closeCode;}
 close(){this.socket.destroy();}
}
export async function wsConnect(h){
 const url=new URL(h.base);const route='/agent/realtime',nonce=b64url(randomBytes(18)),ts=String(Math.floor(Date.now()/1000));
 const headers=signRequest(h.key,route,'',{method:'GET',nonce,timestamp:ts,websocket:true});
 const wsKey=randomBytes(16).toString('base64');
 return await new Promise((resolve,reject)=>{
  const request=httpsRequest({hostname:url.hostname,port:443,path:route,method:'GET',headers:{...headers,'Upgrade':'websocket','Connection':'Upgrade','Sec-WebSocket-Version':'13','Sec-WebSocket-Key':wsKey},timeout:10000});
  let finished=false;
  const deadline=setTimeout(()=>fail(Error('WEBSOCKET_HARD_DEADLINE_12S')),12000);
  function fail(e){if(finished)return;finished=true;clearTimeout(deadline);reject(e);request.destroy()}
  request.on('upgrade',(res,socket,head)=>{
   const expected=createHash('sha1').update(wsKey+'258EAFA5-E914-47DA-95CA-C5AB0DC85B11').digest('base64');
   if(res.statusCode!==101||res.headers['sec-websocket-accept']!==expected){socket.destroy();return fail(Error('WEBSOCKET_UPGRADE_REJECTED'))}
   finished=true;clearTimeout(deadline);h.calls.push({path:route,method:'GET',status:101,test_nonce:nonce});const ws=new RawWS(socket);if(head?.length)ws.feed(head);resolve(ws);
  });
  request.on('response',res=>{res.resume();fail(Error('WEBSOCKET_HTTP_'+res.statusCode))});
  request.on('timeout',()=>fail(Error('WEBSOCKET_CONNECT_TIMEOUT')));
  request.on('error',e=>{if(!finished)fail(e)});request.end();
 });
}
export async function wsPhase(h){
 const one=await wsConnect(h);let two;
 try{
  two=await wsConnect(h);
  const code=await one.untilClosed();assert(code===4001,'WS_SUPERSESSION_CLOSE_CODE');
  const notify=await h.request('/staging/notify',{payload:{},wsAuth:true});
  assert(notify.status===200&&notify.body.ok===true&&notify.body.delivered>=1,'WS_NOTIFY_FAILED');
  const msg=await two.untilMessage(x=>x.type==='pending'&&x.channel==='projects');
  assert(msg.type==='pending','WS_PENDING_MESSAGE_MISSING');
  return h.report('websocket',{ws_accepted:2,superseded_first_close_code:code,notify_delivered:notify.body.delivered,wake_message_received:true});
 }finally{one.close();two?.close();}
}
export async function cadencePhase(h){
 const times=[];
 for(let i=0;i<2;i++){
  if(i===1){const target=times[0]+60000;const wait=Math.max(0,target-Date.now());await delay(wait);}
  const at=Date.now();const r=await h.request('/agent/batch/poll',{payload:makeBody('batch_poll',{channels:CHANNELS})});
  assert(r.status===200&&CHANNELS.every(ch=>r.body.channels?.[ch]?.command===null),'CADENCE_NOT_IDLE');times.push(at);
 }
 const span=times[1]-times[0];assert(span>=59700&&span<=65000,'FALLBACK_CADENCE_OUT_OF_RANGE');
 return h.report('cadence',{grouped_polls:2,interval_ms:span,limitation:'Harness cadence only: not evidence of the actual Windows background supervisor.'});
}
export async function main(args=process.argv.slice(2)){
 const config=parseArgs(args);
 if(config.help){console.log('Usage: node e2e-windows-runner.mjs --phase preflight|websocket|cadence|batch [--manifest fixtures.json]\nSet AIMB_J1H_PRIVATE_KEY_PATH to a local fixture private key file. No other root path variable is needed.');return 0;}
 requireStagingUrl();const key=loadKey();const h=new StageHarness(key);
 const meta={phase:config.phase,started_at:new Date().toISOString(),origin:h.base,fixture_key_material_emitted:false,repo_module_dir:moduleDir,production_touched:false};
 try{
  let proof;
  if(config.phase==='preflight')proof=await preflight(h);
  if(config.phase==='websocket')proof=await wsPhase(h);
  if(config.phase==='cadence')proof=await cadencePhase(h);
  if(config.phase==='batch'){
   const path=resolve(config.manifest);const st=statSync(path,{throwIfNoEntry:false});if(!st?.isFile())throw Error('MANIFEST_NOT_FOUND');
   const manifest=validateManifest(JSON.parse(readFileSync(path,'utf8')));
   proof=await runFixtures(h,manifest);
  }
  console.log(JSON.stringify({goal:'J1-H staging E2E',success:true,proof,meta},null,2));return 0;
 }catch(e){console.error('NO_GO',e?.message??String(e));console.log(JSON.stringify({goal:'J1-H staging E2E',success:false,phase:config.phase,code:e?.message??'unexpected',requests:h.calls,meta},null,2));return 1;}
}
if(process.argv[1] && resolve(process.argv[1])===fileURLToPath(import.meta.url))process.exitCode=await main();
