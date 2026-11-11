import {test} from 'node:test';
import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
import {EventEmitter} from 'node:events';
import {SupervisorV07,validateEnv,validDuration,parseSupervisorArgs,allowlistedJob,SAFE_ACTIONS} from './supervisor-v07.mjs';
import {BASE,DEVICE,CHANNELS} from './e2e-windows-runner.mjs';
function mock({jobs={},brokenAck=false,wsFails=true}={}){
 const call=[],done=new Map(),counts={};
 const harness={base:BASE,async request(path,{payload}){
  call.push({path,payload});
  if(path==='/agent/batch/poll'){
   const channels={};for(const ch of CHANNELS){channels[ch]={ok:true,command:jobs[ch]??null}};
   return {status:200,body:{ok:true,channels}};
  }
  if(path==='/agent/batch/result'){
   counts[payload.job_id]=(counts[payload.job_id]||0)+1;
   done.set(payload.job_id,payload.result);
   if(brokenAck&&counts[payload.job_id]===1)throw Error('TCP_ACK_LOST');
   return {status:200,body:{ok:true,received:true}};
  }
  if(path==='/agent/batch/result-status')return {status:200,body:{ok:true,status:done.has(payload.job_id)?'done':'leased',result:done.get(payload.job_id)}};
  throw Error('UNEXPECTED_PATH');
 }};
 const connect=async()=>{if(wsFails)throw Error('WS_OFFLINE');const socket=new EventEmitter();socket.destroy=()=>socket.emit('close');return {listeners:[],socket,close:()=>socket.destroy()}};
 return {harness,connect,call,done,counts};
}
function make({...p}={}){const m=mock(p);return {supervisor:new SupervisorV07({harness:m.harness,connect:m.connect,durationSec:70}),...m}}
const mkJob=action=>({id:randomUUID(),action});
test('staging-only endpoint enforced',()=>{assert.ok(validateEnv());assert.throws(()=>validateEnv({url:'https://production.example'}));assert.throws(()=>validateEnv({device:'my-pc'}));assert.throws(()=>validateEnv({interval:5000}))});
test('duration bounded',()=>{assert.equal(validDuration(70),70);assert.equal(validDuration(86400),86400);for(const x of [0,60,86401,1.5,NaN])assert.throws(()=>validDuration(x))});
test('CLI scope',()=>{assert.equal(parseSupervisorArgs([]).durationSec,180);assert.equal(parseSupervisorArgs(['--duration-sec','120']).durationSec,120);assert.throws(()=>parseSupervisorArgs(['--endpoint','https://prod.test']));assert.throws(()=>parseSupervisorArgs(['--duration-sec','20']))});
test('only fixture actions supported',()=>{assert.equal(Object.keys(SAFE_ACTIONS).length,5);assert.throws(()=>allowlistedJob('workspace',mkJob('create_workspace_text')));assert.throws(()=>allowlistedJob('commands',mkJob('powershell')));assert.throws(()=>allowlistedJob('unknown',mkJob('get_system_info')))});
test('expired jobs fail closed',()=>assert.throws(()=>allowlistedJob('commands',{id:randomUUID(),action:'get_system_info',expires_at:10})));
test('transport only fixture: no shell, no admin, no file write',async()=>{const {supervisor,call}=make({jobs:{commands:mkJob('get_system_info')}});await supervisor.handleBatch(false);assert.ok(call.every(x=>x.path.includes('/agent/batch/')));assert.equal(supervisor.metrics.leases,1);assert.equal(supervisor.metrics.resultsSaved,1);assert.equal(supervisor.receipts[0].result,'ack')});
test('five channels combined in one network poll',async()=>{const jobs=Object.fromEntries(Object.entries(SAFE_ACTIONS).map(([ch,act])=>[ch,mkJob(act)]));const {supervisor,call}=make({jobs});await supervisor.handleBatch(false);assert.equal(supervisor.metrics.batchPolls,1);assert.equal(supervisor.metrics.leases,5);assert.equal(supervisor.metrics.resultsSaved,5);assert.equal(call.filter(x=>x.path==='/agent/batch/poll').length,1)});
test('lost ACK recovered by status without redoing handler',async()=>{const job=mkJob('get_system_info');let runCount=0;const m=make({jobs:{commands:job},brokenAck:true});m.supervisor.handlers.commands.get_system_info=async()=>{runCount++;return {ok:true,fixture_only:true}};await m.supervisor.handleBatch(false);assert.equal(runCount,1);assert.equal(m.supervisor.metrics.statusRecovery,1);assert.equal(m.supervisor.pendingOutputs.size,0);await m.supervisor.handleBatch(true);assert.equal(runCount,1)});
test('network failure never results in invented ACK',async()=>{const m=make({jobs:{commands:mkJob('get_system_info')}});m.harness.request=async()=>{throw Error('network_offline')};await assert.rejects(m.supervisor.handleBatch(false));assert.equal(m.supervisor.metrics.resultsSaved,0)});
test('non-fixture remote action never executes',async()=>{const m=make({jobs:{files:mkJob('read_authorized_text')}});await assert.rejects(m.supervisor.handleBatch(false),/NON_FIXTURE_ACTION_DENIED/);assert.equal(m.supervisor.metrics.violations,1);assert.equal(m.supervisor.metrics.leases,0)});
test('recovery after status unavailable preserves exact result and never reexecutes',async()=>{
 const job=mkJob('get_system_info');let calls=0,runs=0;const m=make({jobs:{commands:job}});
 m.supervisor.handlers.commands.get_system_info=async()=>{runs++;return {ok:true,fixture_only:true}};
 const original=m.harness.request;
 m.harness.request=async(path,args)=>{if(path==='/agent/batch/result'||path==='/agent/batch/result-status'){calls++;if(calls<=2)throw Error('NO_NETWORK')}return original(path,args)};
 await assert.rejects(m.supervisor.handleBatch(false),/RESULT_ACK_UNCONFIRMED/);assert.equal(runs,1);assert.equal(m.supervisor.pendingOutputs.size,1);
 await m.supervisor.handleBatch(true);assert.equal(runs,1);assert.equal(m.supervisor.pendingOutputs.size,0);assert.equal(m.supervisor.metrics.resultsSaved,1);
});
test('empty batch counted once',async()=>{const m=make();await m.supervisor.handleBatch(true);assert.equal(m.supervisor.metrics.emptyBatches,1);assert.equal(m.supervisor.metrics.batchPolls,1)});
test('websocket wake uses one shared batch scheduler',async()=>{const m=make({wsFails:false});await m.supervisor.setupWebSocket(0);assert.ok(m.supervisor.ws);const handlers=m.supervisor.ws.listeners;handlers.forEach(fn=>fn({type:'pending',channel:'projects'}));assert.equal(m.supervisor.metrics.websocketWakeups,1);m.supervisor.stop()});
test('websocket reconnect after close',async()=>{const m=make({wsFails:false});await m.supervisor.setupWebSocket(0);const first=m.supervisor.ws;first.close();assert.equal(m.supervisor.ws,null);m.supervisor.wsNextAttempt=0;await m.supervisor.setupWebSocket(m.supervisor.localTime());assert.equal(m.supervisor.metrics.websocketConnections,2);assert.equal(m.supervisor.metrics.websocketReconnects,1);m.supervisor.stop()});
test('websocket offline will not prevent polling',async()=>{const m=make({wsFails:true});await m.supervisor.tick(0);assert.equal(m.supervisor.metrics.websocketErrors,1);assert.equal(m.supervisor.metrics.batchPolls,1);m.supervisor.stop()});
test('stop never modifies Windows scheduled tasks',()=>{const m=make();m.supervisor.stop();assert.equal(m.supervisor.report().task_scheduler_modified,false);assert.equal(m.supervisor.report().production_touched,false)});

test('offline polling uses 60s backoff to protect D1 quota',async()=>{const m=make({wsFails:true});m.harness.request=async()=>{throw Error('network_down')};await m.supervisor.tick(m.supervisor.localTime());const next=m.supervisor.scheduler.state().due-m.supervisor.localTime();assert.ok(next>=59000&&next<=60000);assert.equal(m.supervisor.metrics.networkErrors,1);m.supervisor.stop()});
