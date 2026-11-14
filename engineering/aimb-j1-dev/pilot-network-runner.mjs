import {createPrivateKey,randomBytes,sign,constants,createHash} from 'node:crypto';
import {readFileSync,statSync} from 'node:fs';
import {request as httpsRequest} from 'node:https';
import {spawn} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import {assertStagingFixtureKey,DEVICE_ID,projectPollBody,projectResultBody,projectStatusBody,signStagingRequest,validatePilotJob,STAGING_ORIGIN,STAGING_WORKER_VERSION,STAGING_D1_UUID,PILOT_PUBLIC_JWK_THUMBPRINT} from './staging-read-signer.mjs';
import {validateForegroundConfig} from './foreground-session.mjs';

export const MAX_PILOT_MS=300_000;
export const MAX_PILOT_JOBS=2;
export const POLL_FALLBACK_MS=60_000;
const NEED=(ok,code)=>{if(!ok)throw Error(code)};

function parseFrame(buf){
 if(buf.length<2)return null;let n=buf[1]&127,head=2;if(n===126){if(buf.length<4)return null;n=buf.readUInt16BE(2);head=4;}else if(n===127){if(buf.length<10)return null;const x=buf.readBigUInt64BE(2);NEED(x<=1048576n,'WS_FRAME_TOO_LARGE');n=Number(x);head=10;}
 NEED((buf[1]&128)===0,'WS_SERVER_MASKED_FRAME');NEED(n<=1048576,'WS_FRAME_TOO_LARGE');if(buf.length<head+n)return null;return {op:buf[0]&15,data:buf.subarray(head,head+n),taken:head+n};
}
function signedWebSocket({base=STAGING_ORIGIN,privateKey}){
 return new Promise((resolve,reject)=>{
  const url=new URL(base),nonce=randomBytes(18).toString('base64url'),timestamp=String(Math.floor(Date.now()/1000)),headers=signPilotWebSocket({privateKey,nonce,timestamp}),wsKey=randomBytes(16).toString('base64');let done=false;
  const req=httpsRequest({hostname:url.hostname,port:443,path:'/agent/realtime',method:'GET',headers:{...headers,Upgrade:'websocket',Connection:'Upgrade','Sec-WebSocket-Version':'13','Sec-WebSocket-Key':wsKey},timeout:12000});
  const fail=e=>{if(done)return;done=true;req.destroy();reject(e);};
  req.on('upgrade',(res,socket,head)=>{const expected=createHash('sha1').update(wsKey+'258EAFA5-E914-47DA-95CA-C5AB0DC85B11').digest('base64');if(res.statusCode!==101||res.headers['sec-websocket-accept']!==expected){socket.destroy();return fail(Error('WEBSOCKET_UPGRADE_REJECTED'));}done=true;let buffer=Buffer.alloc(0),handler=null;
   let closeHandler=null;const ws={set onmessage(fn){handler=fn;},set onclose(fn){closeHandler=fn;},close(){socket.end();}};
   socket.on('data',chunk=>{buffer=Buffer.concat([buffer,chunk]);for(;;){const frame=parseFrame(buffer);if(!frame)break;buffer=buffer.subarray(frame.taken);if(frame.op===1){try{handler?.({data:frame.data.toString('utf8')});}catch{}}else if(frame.op===8){socket.end();}}});socket.on('error',()=>{closeHandler?.();});socket.on('close',()=>{closeHandler?.();});if(head?.length)socket.emit('data',head);resolve(ws);
  });
  req.on('response',res=>{res.resume();fail(Error(`WEBSOCKET_HTTP_${res.statusCode}`));});req.on('timeout',()=>fail(Error('WEBSOCKET_CONNECT_TIMEOUT')));req.on('error',e=>fail(e));req.end();
 });
}

export function loadPinnedPilotKey(path,{expectedThumbprint}={}){
 NEED(typeof path==='string'&&path.length>0,'PILOT_KEY_PATH_REQUIRED');
 const st=statSync(path,{throwIfNoEntry:false});NEED(st?.isFile(),'PILOT_KEY_NOT_REGULAR_FILE');
 const key=createPrivateKey(readFileSync(path));
 NEED(key.asymmetricKeyType==='rsa'&&key.asymmetricKeyDetails?.modulusLength>=2048,'RSA_KEY_POLICY');
 if(expectedThumbprint)assertStagingFixtureKey(key,expectedThumbprint);
 return key;
}

export function signPilotWebSocket({privateKey,timestamp=String(Math.floor(Date.now()/1000)),nonce=randomBytes(18).toString('base64url')}){
 NEED(/^\d{10,12}$/.test(timestamp),'SIGNATURE_TIMESTAMP_INVALID');NEED(/^[A-Za-z0-9_-]{16,64}$/.test(nonce),'SIGNATURE_NONCE_INVALID');
 const canonical=`${timestamp}\n${nonce}\nGET /agent/realtime\n${DEVICE_ID}`;
 return Object.freeze({'x-bridge-timestamp':timestamp,'x-bridge-nonce':nonce,'x-bridge-signature':sign('RSA-SHA256',Buffer.from(canonical,'utf8'),{key:privateKey,padding:constants.RSA_PKCS1_PADDING}).toString('base64url')});
}

export class PowerShellFixtureAgent{
 constructor({fixtureRoot,powershell,agentScript}){this.fixtureRoot=fixtureRoot;this.powershell=powershell;this.agentScript=agentScript;this.child=null;this.pending=[];this.buffer='';this.closed=false;}
 start(){NEED(!this.child,'FOREGROUND_AGENT_ALREADY_STARTED');this.child=spawn(this.powershell,['-NoProfile','-NonInteractive','-File',this.agentScript,'-FixtureRoot',this.fixtureRoot],{shell:false,windowsHide:true,stdio:['pipe','pipe','ignore']});this.child.stdout.setEncoding('utf8');this.child.stdout.on('data',chunk=>{this.buffer+=chunk;for(;;){const i=this.buffer.indexOf('\n');if(i<0)break;const line=this.buffer.slice(0,i).trim();this.buffer=this.buffer.slice(i+1);const pending=this.pending.shift();if(pending){try{const value=JSON.parse(line);if(value.ok!==true)pending.reject(Error(value.error||'FOREGROUND_READ_FAILED'));else pending.resolve(value);}catch(e){pending.reject(e);}}}});this.child.on('error',()=>this.#failAll(Error('FOREGROUND_AGENT_START_FAILED')));this.child.on('exit',()=>{this.closed=true;this.#failAll(Error('FOREGROUND_AGENT_EXITED'));});}
 #failAll(error){for(const p of this.pending.splice(0))p.reject(error);}
 execute({action,args,signal}){NEED(['list_project_files','read_project_text'].includes(action),'PROJECT_ACTION_NOT_ALLOWLISTED');NEED(this.child&&!this.closed,'FOREGROUND_AGENT_NOT_RUNNING');if(signal?.aborted)return Promise.reject(Error('FOREGROUND_AGENT_ABORTED'));return new Promise((resolve,reject)=>{const p={resolve,reject};this.pending.push(p);const onAbort=()=>{this.pending=this.pending.filter(x=>x!==p);reject(Error('FOREGROUND_AGENT_ABORTED'));};signal?.addEventListener('abort',onAbort,{once:true});p.resolve=value=>{signal?.removeEventListener('abort',onAbort);resolve(value);};p.reject=error=>{signal?.removeEventListener('abort',onAbort);reject(error);};const input=action==='list_project_files'?{type:'list',offset:Number(args.offset??0),limit:Number(args.limit??100)}:{type:'read',path:args.path};this.child.stdin.write(JSON.stringify(input)+'\n',e=>{if(e){this.pending=this.pending.filter(x=>x!==p);p.reject(Error('FOREGROUND_AGENT_WRITE_FAILED'));}});});}
 close(){if(!this.child||this.closed)return;this.closed=true;try{this.child.stdin.end();this.child.kill();}catch{}this.#failAll(Error('FOREGROUND_AGENT_STOPPED'));}
}

export class PilotNetworkRunner{
 constructor({privateKey,transport=fetch,agent,webSocketFactory=null,clock=()=>performance.now(),unixNow=()=>Math.floor(Date.now()/1000),wallClock=()=>Date.now(),setTimer=setTimeout,clearTimer=clearTimeout,base=STAGING_ORIGIN,workerVersion=STAGING_WORKER_VERSION,d1Uuid=STAGING_D1_UUID,maxDurationMs=MAX_PILOT_MS,fallbackMs=POLL_FALLBACK_MS}){
  NEED(base===STAGING_ORIGIN,'STAGING_ORIGIN_PIN_FAILED');NEED(workerVersion===STAGING_WORKER_VERSION,'STAGING_VERSION_PIN_FAILED');NEED(d1Uuid===STAGING_D1_UUID,'STAGING_D1_PIN_FAILED');
  NEED(Number.isInteger(maxDurationMs)&&maxDurationMs>0&&maxDurationMs<=MAX_PILOT_MS,'PILOT_DURATION_INVALID');NEED(Number.isInteger(fallbackMs)&&fallbackMs>=10_000&&fallbackMs<=POLL_FALLBACK_MS,'FALLBACK_INTERVAL_INVALID');
  NEED(privateKey?.asymmetricKeyType==='rsa'&&privateKey.asymmetricKeyDetails?.modulusLength>=2048,'RSA_KEY_POLICY');NEED(typeof transport==='function','TRANSPORT_REQUIRED');NEED(agent&&typeof agent.execute==='function','FOREGROUND_AGENT_REQUIRED');
  this.key=privateKey;this.transport=transport;this.agent=agent;this.wsFactory=webSocketFactory;this.clock=clock;this.unixNow=unixNow;this.wallClock=wallClock;this.setTimer=setTimer;this.clearTimer=clearTimer;this.base=base;this.duration=maxDurationMs;this.fallback=fallbackMs;this.completed=new Map();this.requests=[];this.started=false;this.stopped=false;this.wakeResolve=null;this.ws=null;this.abort=null;
 }
 async #request(route,rawBody){
  const signed=signStagingRequest({privateKey:this.key,route,rawBody,nowSec:this.unixNow()});
  const started=this.clock();
  try{
   const response=await this.transport(this.base+route,{method:'POST',headers:{'content-type':'application/json',...signed},body:rawBody,signal:this.abort?.signal});
   let body;try{body=await response.json()}catch{body={}}
   this.requests.push({route,method:'POST',status:response.status,timestamp:signed['x-bridge-timestamp'],test_nonce:signed['x-bridge-nonce'],latency_ms:Math.round((this.clock()-started)*100)/100});return {status:response.status,body};
  }catch(error){this.requests.push({route,method:'POST',status:null,timestamp:signed['x-bridge-timestamp'],test_nonce:signed['x-bridge-nonce'],latency_ms:Math.round((this.clock()-started)*100)/100,error:String(error?.message||'NETWORK_ERROR').slice(0,80)});throw error;}
 }
 async #connectWs(){
  if(this.ws)return true;
  try{this.ws=await (this.wsFactory?this.wsFactory({url:this.base.replace(/^https:/,'wss:')+'/agent/realtime',headers:signPilotWebSocket({privateKey:this.key})}):signedWebSocket({base:this.base,privateKey:this.key}));
   this.ws.onmessage=(event)=>{try{const m=JSON.parse(typeof event.data==='string'?event.data:'');if(m.type==='pending'&&m.channel==='projects')this.#wake();}catch{}};
   const active=this.ws;this.ws.onclose=()=>{if(this.ws===active)this.ws=null;this.#wake();};return true;
  }catch{this.ws=null;return false;}
 }
 #wake(){this.wakePending=true;if(this.wakeResolve){const r=this.wakeResolve;this.wakeResolve=null;r();}}
 async #waitNext(){
  if(this.wakePending||this.abort.signal.aborted)return;
  await new Promise(resolve=>{
   let settled=false;const finish=()=>{if(settled)return;settled=true;this.clearTimer(timer);this.wakeResolve=null;resolve();};
   const timer=this.setTimer(()=>{this.wakePending=true;finish();},Math.min(this.fallback,Math.max(0,this.deadline-this.clock())));this.wakeResolve=finish;
   this.abort.signal.addEventListener('abort',finish,{once:true});
  });
 }
 async #execute(command){
  NEED(command&&typeof command==='object','PROJECT_COMMAND_MISSING');
  const job=validatePilotJob({id:command.id,action:command.action,expires_at:Number(command.expires_at)},{now:this.unixNow()});
  NEED(this.completed.size<MAX_PILOT_JOBS,'PILOT_JOB_LIMIT_REACHED');
  NEED(!this.completed.has(job.id),'DUPLICATE_PROJECT_EXECUTION');
  let args;try{args=JSON.parse(command.args_json)}catch{throw Error('PROJECT_ARGS_INVALID');}
  NEED(args&&typeof args==='object'&&!Array.isArray(args),'PROJECT_ARGS_INVALID');
  const deadlineError=new Promise((_,reject)=>this.abort.signal.addEventListener('abort',()=>reject(Error('PILOT_STOPPED_DURING_LOCAL_READ')),{once:true}));
  const result=await Promise.race([this.agent.execute({action:job.action,args,expiresAt:job.expires_at,signal:this.abort.signal}),deadlineError]);
  NEED(result&&typeof result==='object'&&!Array.isArray(result),'PROJECT_RESULT_INVALID');
  const marker={action:job.action,result};this.completed.set(job.id,marker);
  const raw=projectResultBody({jobId:job.id,action:job.action,result});
  let ack;
  try{ack=await this.#request('/agent/batch/result',raw);}catch{ack=null;}
  if(ack?.status===200&&ack.body.received===true)return {id:job.id,status:'acknowledged'};
  const statusRaw=projectStatusBody({jobId:job.id,action:job.action});
  const recovered=await this.#request('/agent/batch/result-status',statusRaw);
  NEED(recovered.status===200&&recovered.body.status==='done'&&JSON.stringify(recovered.body.result)===JSON.stringify(result),'RESULT_ACK_RECOVERY_FAILED');
  return {id:job.id,status:'recovered'};
 }
 async #poll(){
  const raw=projectPollBody();const response=await this.#request('/agent/batch/poll',raw);
  NEED(response.status!==401&&response.status!==409,'STAGING_SIGNATURE_OR_REPLAY_REJECTED');NEED(response.status===200&&response.body.ok===true,'PROJECT_POLL_FAILED');
  const command=response.body.channels?.projects?.command;
  if(command)await this.#execute(command);
  return Boolean(command);
 }
 async run(){
  NEED(!this.started,'RUNNER_ALREADY_STARTED');this.started=true;this.abort=new AbortController();this.startedAt=this.clock();this.deadline=this.startedAt+this.duration;
  const timer=this.setTimer(()=>this.abort.abort(Error('PILOT_HARD_DEADLINE')),this.duration);
  const report={outcome:'NO_GO',stagingOnly:true,workerVersion:STAGING_WORKER_VERSION,d1Uuid:STAGING_D1_UUID,deviceId:DEVICE_ID,startedAtUtc:new Date(this.wallClock()).toISOString(),maxDurationMs:this.duration,websocketConnected:false,polls:0,executions:[],requests:this.requests,errors:[]};
  try{
   report.websocketConnected=await this.#connectWs();
   let first=true;
   while(!this.abort.signal.aborted&&this.clock()<this.deadline){
   if(first||this.wakePending){first=false;this.wakePending=false;if(!this.ws)report.websocketConnected=(await this.#connectWs())||report.websocketConnected;try{const had=await this.#poll();report.polls++;if(had){/* each claimed job has exactly one execution path */}}catch(e){const code=String(e?.message||'NETWORK_ERROR');report.errors.push(code);if(['STAGING_SIGNATURE_OR_REPLAY_REJECTED','DUPLICATE_PROJECT_EXECUTION','RESULT_ACK_RECOVERY_FAILED','TTL_MARGIN_TOO_SHORT','TTL_OVER_POLICY','JOB_ID_INVALID','PROJECT_ACTION_INVALID','PROJECT_ARGS_INVALID','PROJECT_COMMAND_MISSING','PILOT_JOB_LIMIT_REACHED','FOREGROUND_AGENT_ABORTED','FOREGROUND_READ_FAILED'].includes(code))this.abort.abort(Error(code));}}
    if(this.clock()<this.deadline)await this.#waitNext();
   }
   report.outcome=this.abort.signal.aborted&&this.clock()>=this.deadline?'STOPPED_AT_HARD_DEADLINE':'STOPPED';
  }finally{
   this.clearTimer(timer);this.stopped=true;try{this.ws?.close?.();}catch{}this.ws=null;try{this.agent.close?.();}catch{}
   report.finishedAtUtc=new Date(this.wallClock()).toISOString();report.executions=[...this.completed].map(([id,x])=>({id,action:x.action}));report.privateKeyLogged=false;
  }
  if(report.outcome==='STOPPED_AT_HARD_DEADLINE'&&report.errors.length===0&&report.executions.length===MAX_PILOT_JOBS)report.outcome='PASS_TWO_READS';else if(report.outcome==='STOPPED_AT_HARD_DEADLINE')report.outcome='NO_GO_INCOMPLETE_PILOT';
  return report;
 }
 stop(){if(!this.stopped)this.abort?.abort(Error('PILOT_STOP_REQUESTED'));try{this.ws?.close?.();}catch{}this.ws=null;}
}

export async function main(argv=process.argv.slice(2)){
 let fixtureRoot,seconds=300;for(let i=0;i<argv.length;i++){if(argv[i]==='--fixture-root'&&!fixtureRoot&&argv[i+1])fixtureRoot=argv[++i];else if(argv[i]==='--session-seconds'&&argv[i+1])seconds=Number(argv[++i]);else throw Error('BAD_ARGUMENTS');}
 NEED(fixtureRoot,'FIXTURE_ROOT_REQUIRED');const cfg=validateForegroundConfig({fixtureRoot,seconds});const key=loadPinnedPilotKey(process.env.AIMB_J1H_PRIVATE_KEY_PATH,{expectedThumbprint:PILOT_PUBLIC_JWK_THUMBPRINT});
 const agent=new PowerShellFixtureAgent({fixtureRoot:cfg.fixtureRoot,powershell:cfg.powershell,agentScript:fileURLToPath(new URL('./foreground-readonly-agent.ps1',import.meta.url))});agent.start();
 const runner=new PilotNetworkRunner({privateKey:key,agent,maxDurationMs:seconds*1000});process.once('SIGINT',()=>runner.stop());process.once('SIGTERM',()=>runner.stop());
 const report=await runner.run();process.stdout.write(JSON.stringify(report,null,2)+'\n');return report.outcome==='PASS_TWO_READS'?0:1;
}

if(process.argv[1]&&fileURLToPath(import.meta.url).toLowerCase()===process.argv[1].toLowerCase())main().then(code=>{process.exitCode=code;}).catch(e=>{process.stderr.write(`NO_GO ${e?.message||'RUNNER_FAILED'}\n`);process.exitCode=1;});
