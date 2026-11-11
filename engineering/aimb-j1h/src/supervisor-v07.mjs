/**
 * AI Machine Bridge J1-H — Windows staging v0.7 transport supervisor candidate.
 * Only a staging fixture device. NO production route, task/service installation, shell, or real PC operations.
 * Signed RSA with a user-supplied, locally held fixture private key.
 */
import {EventEmitter} from 'node:events';
import {performance} from 'node:perf_hooks';
import {setTimeout as delay} from 'node:timers/promises';
import {randomUUID} from 'node:crypto';
import {fileURLToPath} from 'node:url';
import {resolve} from 'node:path';
import {StageHarness, loadKey, wsConnect, CHANNELS, ACTIONS, BASE, DEVICE} from './e2e-windows-runner.mjs';
import {PollScheduler, FALLBACK_MS} from './poll-scheduler.mjs';

export const SAFE_ACTIONS = Object.freeze({
  commands:'get_system_info',
  files:'list_authorized_files',
  maintenance:'get_bridge_tasks',
  workspace:'list_workspace_files',
  projects:'list_project_files'
});
const fixtureHandlers=Object.freeze(Object.fromEntries(Object.entries(SAFE_ACTIONS).map(([channel,action])=>[
  channel,Object.freeze({[action]:async ({jobId})=>({ok:true,fixture_only:true,job_id:jobId,source:'j1h-staging-supervisor-v07'})})
])));

export function validDuration(v){if(!Number.isInteger(v)||v<70||v>86400)throw Error('INVALID_DURATION_SECONDS');return v;}
export function validateEnv({url=BASE,device=DEVICE,interval=FALLBACK_MS}={}){
 if(url!==BASE||device!==DEVICE)throw Error('STAGING_SCOPE_REQUIRED');
 if(interval!==60000)throw Error('POLL_INTERVAL_MUST_BE_60_SECONDS');
 return true;
}
export function allowlistedJob(channel,job,nowSec=Math.floor(Date.now()/1000)){
 if(!CHANNELS.includes(channel)||!job||typeof job!=='object'||Array.isArray(job))throw Error('INVALID_JOB');
 if(!/^[a-f0-9]{8}-(?:[a-f0-9]{4}-){3}[a-f0-9]{12}$/i.test(job.id))throw Error('INVALID_JOB_ID');
 if(job.action!==SAFE_ACTIONS[channel])throw Error('NON_FIXTURE_ACTION_DENIED');
 if(job.expires_at!==undefined && (!Number.isInteger(job.expires_at)||job.expires_at<=nowSec))throw Error('EXPIRED_JOB');
 return job;
}
export function parseSupervisorArgs(argv){
 let sec=180,help=false;
 for(let i=0;i<argv.length;i++){
  if(argv[i]==='--duration-sec'&&argv[i+1]){sec=Number(argv[++i]);}
  else if(argv[i]==='--help'&&argv.length===1)help=true;
  else throw Error('INVALID_CLI');
 }
 if(!help)validDuration(sec);
 return {durationSec:sec,help};
}
const fixtures=()=>Object.fromEntries(Object.entries(fixtureHandlers).map(([channel,actions])=>[channel,{...actions}]));

export class SupervisorV07 extends EventEmitter{
 constructor({harness,key,connect=wsConnect,sleep=delay,durationSec=180,now=()=>Date.now(),handlers=fixtures()}={}){
  super();validDuration(durationSec);
  this.h=harness??(key?new StageHarness(key):null);if(!this.h)throw Error('STAGING_RSA_REQUIRED');
  if(this.h.base!==BASE)throw Error('STAGING_SCOPE_REQUIRED');
  this.connect=connect;this.sleep=sleep;this.durationMs=durationSec*1000;this.now=now;
  this.handlers=handlers;
  this.scheduler=new PollScheduler({fallbackMs:60000,minTtlMs:80000});
  this.running=false;this.stopRequested=false;this.startAt=0;this.ws=null;
  this.metrics={pollReasons:{startup:0,wakeup:0,fallback:0,retry:0},shortPollIntervals:0,wakeupPollLatencyMs:[],websocketConnections:0,websocketReconnects:0,websocketWakeups:0,websocketErrors:0,batchPolls:0,emptyBatches:0,leases:0,resultsSaved:0,statusRecovery:0,networkErrors:0,violations:0,finishedAt:null,startedAt:null};
  this.pollTrace=[];this.wakeSeq=0;this.lastWake=null;this.lastPollAt=null;this.receipts=[];this.leasedIds=new Set();this.pendingOutputs=new Map();this.wsNextAttempt=0;this.wsReconnect=0;this.abortController=new AbortController();
 }
 localTime(){return Math.round(performance.now());}
 report(){return {goal:'J1-H isolated Windows supervisor v0.7.3 observability',stage:BASE,device:DEVICE,production_touched:false,task_scheduler_modified:false,metrics:{...this.metrics,pollReasons:{...this.metrics.pollReasons},wakeupPollLatencyMs:[...this.metrics.wakeupPollLatencyMs]},pollTrace:[...this.pollTrace],receipts:[...this.receipts]};}
 emitEvidence(type,detail={}){this.emit('evidence',{type,at:new Date().toISOString(),...detail});}
 stop(){this.stopRequested=true;this.abortController.abort();this.ws?.close();this.ws=null;}
 async setupWebSocket(nowMs){
  if(this.stopRequested||this.ws||nowMs<this.wsNextAttempt)return;
  try{
   const ws=await this.connect(this.h);
   if(this.stopRequested){ws.close();return}
   this.ws=ws;this.metrics.websocketConnections++;
   if(this.metrics.websocketConnections>1)this.metrics.websocketReconnects++;
   this.wsReconnect=0;
   ws.listeners.push(m=>{
    if(m?.type==='pending' && CHANNELS.includes(m.channel)){
     this.metrics.websocketWakeups++;
     const atMs=this.localTime();const wakeId=++this.wakeSeq;this.lastWake={wakeId,atMs,channel:m.channel};
     this.scheduler.wake(atMs);
     this.emitEvidence('websocket_wakeup',{channel:m.channel,wakeId,monotonicMs:atMs,scheduledCause:this.scheduler.state().dueCause});
    }
   });
   ws.socket?.once?.('close',()=>{if(this.ws===ws){this.ws=null;this.wsNextAttempt=this.localTime()+5000;this.emitEvidence('websocket_closed');}});
   ws.socket?.once?.('error',()=>{if(this.ws===ws){this.ws=null;this.wsNextAttempt=this.localTime()+5000;this.emitEvidence('websocket_error');}});
   this.emitEvidence('websocket_connected');
  }catch(e){
   this.metrics.websocketErrors++;
   this.wsReconnect=Math.min(6,this.wsReconnect+1);
   this.wsNextAttempt=this.localTime()+Math.min(60000,5000*2**(this.wsReconnect-1));
   this.emitEvidence('websocket_connect_failure',{code:String(e?.message??e).slice(0,80)});
  }
 }
 async req(path,payload){
  const r=await this.h.request(path,{payload});
  if(!Number.isInteger(r.status))throw Error('INVALID_RESPONSE');
  return r;
 }
 async submitResult(channel,job,value){
  const base={agent_version:'0.7.0',device_id:DEVICE,channel,job_id:job.id,action:job.action};
  const statusBody={...base,purpose:'result_status'};
  const resultBody={...base,purpose:'batch_result',result:value};
  let answer;
  try{answer=await this.req('/agent/batch/result',resultBody)}catch(e){
   this.metrics.networkErrors++;answer=null;
  }
  if(answer?.status===200&&answer.body?.received===true){this.metrics.resultsSaved++;this.pendingOutputs.delete(job.id);this.receipts.push({channel,id:job.id,result:'ack'});return}
  // Status recovery is required after a lost HTTP result ACK; never blindly re-execute the handler.
  try{
   const status=await this.req('/agent/batch/result-status',statusBody);
   if(status.status===200&&status.body?.status==='done'&&JSON.stringify(status.body.result)===JSON.stringify(value)){
    this.metrics.statusRecovery++;this.pendingOutputs.delete(job.id);this.receipts.push({channel,id:job.id,result:'recovered'});return;
   }
  }catch(e){this.metrics.networkErrors++;}
  throw Error('RESULT_ACK_UNCONFIRMED');
 }
 async handleBatch(recovery){
  const payload={agent_version:'0.7.0',device_id:DEVICE,purpose:'batch_poll',channels:[...CHANNELS],...(recovery?{recovery_mode:'leased_first'}:{})};
  const r=await this.req('/agent/batch/poll',payload);
  this.metrics.batchPolls++;
  if(r.status!==200||r.body?.ok!==true||!r.body.channels)throw Error('POLL_NOT_OK');
  let count=0;
  for(const channel of CHANNELS){
   const item=r.body.channels[channel];if(!item?.ok)throw Error('CHANNEL_BAD_'+channel);
   const job=item.command;
   if(!job)continue;
   count++;
   try{allowlistedJob(channel,job)}catch(e){this.metrics.violations++;throw e}
   if(this.leasedIds.has(job.id)){
    // An ambiguous result ACK must be checked, never executed a second time.
    const previous=this.pendingOutputs.get(job.id);
    if(previous)await this.submitResult(channel,job,previous);
    continue;
   }
   const fn=this.handlers?.[channel]?.[job.action];
   if(typeof fn!=='function')throw Error('MISSING_ALLOWLIST_HANDLER');
   this.leasedIds.add(job.id);this.metrics.leases++;
   const value=await fn({channel,jobId:job.id,action:job.action});
   if(!value||typeof value!=='object'||value.fixture_only!==true)throw Error('FIXTURE_RESULT_REQUIRED');
   this.pendingOutputs.set(job.id,value);
   await this.submitResult(channel,job,value);
  }
  if(count===0)this.metrics.emptyBatches++;
  this.emitEvidence('batch_complete',{count,recovery});
 }
 async tick(nowMs){
  await this.setupWebSocket(nowMs);
  const startedMs=this.localTime();
  if(!this.scheduler.step(startedMs))return false;
  const schedule=this.scheduler.state();
  const reason=schedule.lastCause;
  if(!Object.hasOwn(this.metrics.pollReasons,reason))throw Error('UNKNOWN_POLL_CAUSE');
  const previousPollAt=this.lastPollAt;
  const intervalMs=previousPollAt===null?null:startedMs-previousPollAt;
  this.lastPollAt=startedMs;
  if(intervalMs!==null&&intervalMs<1000)this.metrics.shortPollIntervals++;
  this.metrics.pollReasons[reason]++;
  const wake=this.lastWake&&reason==='wakeup'?this.lastWake:null;
  const latencyMs=wake?startedMs-wake.atMs:null;
  if(wake){this.metrics.wakeupPollLatencyMs.push(latencyMs);if(this.metrics.wakeupPollLatencyMs.length>1440)this.metrics.wakeupPollLatencyMs.shift();this.lastWake=null;}
  const pollId=randomUUID();
  const recovery=this.metrics.batchPolls===0;
  const trace={pollId,reason,recovery,startedMonotonicMs:startedMs,intervalMs,wakeId:wake?.wakeId??null,wakeupToPollMs:latencyMs,status:'inflight'};
  this.pollTrace.push(trace);if(this.pollTrace.length>2000)this.pollTrace.shift();
  this.emitEvidence('poll_started',trace);
  try{
   await this.handleBatch(recovery); // recover prior leased tasks on initial poll.
   this.scheduler.complete(this.localTime(),{ok:true});
   trace.status='ok';trace.durationMs=this.localTime()-startedMs;
   this.emitEvidence('poll_finished',{pollId,reason,status:'ok',durationMs:trace.durationMs});
   return true;
  }catch(e){
   this.metrics.networkErrors++;
   // Do not spam signed D1 nonces during a network outage: stay on 60s fallback,
   // rather than the scheduler's rapid 5s retry path. Recovery is explicit on next poll.
   this.scheduler.complete(this.localTime(),{ok:true});
   trace.status='error';trace.durationMs=this.localTime()-startedMs;
   this.emitEvidence('poll_finished',{pollId,reason,status:'error',durationMs:trace.durationMs});
   this.emitEvidence('batch_error',{code:String(e?.message??e).slice(0,100),pollId});
   return false;
  }
 }
 async run(){
  if(this.running)throw Error('ALREADY_RUNNING');
  this.running=true;this.metrics.startedAt=new Date().toISOString();this.startAt=this.localTime();
  this.emitEvidence('supervisor_started',{monotonicMs:this.startAt,durationSec:this.durationMs/1000,stagingOnly:true});
  try{
   while(!this.stopRequested){
    const now=this.localTime();if(now-this.startAt>=this.durationMs)break;
    await this.tick(now);
    if(this.stopRequested)break;
    const due=this.scheduler.state().due;
    const wait=Math.max(20,Math.min(500,Math.max(0,due-this.localTime()),Math.max(0,this.wsNextAttempt-this.localTime())||500));
    try{await this.sleep(wait,undefined,{signal:this.abortController.signal})}catch(e){if(!this.stopRequested)throw e}
   }
  }finally{
   this.stop();this.metrics.finishedAt=new Date().toISOString();this.running=false;
  }
  return this.report();
 }
}

export async function main(argv=process.argv.slice(2)){
 const {help,durationSec}=parseSupervisorArgs(argv);
 if(help){console.log('Usage: node supervisor-v07.mjs --duration-sec 180 (70..86400). Local private RSA key path: AIMB_J1H_PRIVATE_KEY_PATH. STAGING ONLY.');return 0}
 validateEnv();
 console.log('STAGE_BOOT',JSON.stringify({event:'initializing_fixture_key',at:new Date().toISOString(),stagingOnly:true}));
 const key=loadKey();
 const supervisor=new SupervisorV07({key,durationSec});
 supervisor.on('evidence',entry=>{const out=entry.type==='batch_error'||entry.type==='websocket_connect_failure'?console.error:console.log;out('STAGE_EVENT',JSON.stringify(entry))});
 const onSig=()=>supervisor.stop();process.once('SIGINT',onSig);process.once('SIGTERM',onSig);
 try{const result=await supervisor.run();console.log(JSON.stringify(result,null,2));if(result.metrics.websocketConnections<1||result.metrics.batchPolls<1){console.error('NO_GO','SUPERVISOR_CONNECTIVITY_NOT_PROVEN');return 1;}return 0}
 finally{process.off('SIGINT',onSig);process.off('SIGTERM',onSig)}
}
if(process.argv[1]&&resolve(process.argv[1])===fileURLToPath(import.meta.url))process.exitCode=await main();
