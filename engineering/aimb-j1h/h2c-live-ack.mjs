/** H2-C staging-only fixture execution, lost ACK, idempotence. Never seeds D1 or touches production. */
import {createPrivateKey,createPublicKey,createHash} from 'node:crypto';
import {readFileSync} from 'node:fs';
import {StageHarness,BASE,DEVICE,CHANNELS,requireStagingUrl} from './src/e2e-windows-runner.mjs';
import {SupervisorV07,SAFE_ACTIONS} from './src/supervisor-v07.mjs';
const PIN='3a98cf5776bf8b243f7c6a423c505015e45a7870d002512c38eed85b8e3a5dbb',SECONDS=180;
function fail(s){throw Error(s)}
function check(v,s){if(!v)fail(s)}
function readKey(){
 const p=process.env.AIMB_J1H_PRIVATE_KEY_PATH;if(!p)fail('FIXTURE_KEY_PATH_REQUIRED');
 const k=createPrivateKey(readFileSync(p)),j=createPublicKey(k).export({format:'jwk'});
 const h=createHash('sha256').update(JSON.stringify({e:j.e,kty:j.kty,n:j.n})).digest('hex');
 if(h!==PIN)fail('FIXTURE_RSA_PIN_MISMATCH');return k;
}
function handlers(counts){
 return Object.fromEntries(Object.entries(SAFE_ACTIONS).map(([ch,a])=>[ch,{[a]:async ({jobId})=>{
  const n=counts.get(jobId)||0;counts.set(jobId,n+1);
  if(n!==0)fail('DUPLICATE_FIXTURE_EXECUTION');
  return {ok:true,fixture_only:true,job_id:jobId,source:'j1h-h2c-supervisor'};
 }}]));
}
async function main(){
 check(process.argv.length===2,'NO_ARGUMENTS');
 requireStagingUrl();
 const key=readKey();
 const res=await fetch(BASE+'/health',{signal:AbortSignal.timeout(12000)}),h=await res.json();
 check(res.status===200&&h.production===false&&h.d1===true&&h.do_bound===true,'STAGING_BOUNDARY_FAILED');
 const api=new StageHarness(key),req=api.request.bind(api);let lost=false;
 api.request=async(path,opt)=>{
  const r=await req(path,opt);
  // Drop first successful remote result ACK at client boundary, AFTER remote persistence.
  if(path==='/agent/batch/result'&&!lost&&r.status===200&&r.body?.received===true){
   lost=true;throw Error('SIMULATED_ACK_LOSS_AFTER_SAVE');
  }
  return r;
 };
 const counts=new Map();
 const agent=new SupervisorV07({harness:api,durationSec:SECONDS,handlers:handlers(counts)});
 agent.on('evidence',e=>{
  if(e.type==='websocket_connected')console.log('J1H_H2C_WEBSOCKET_READY');
  if(e.type==='batch_error')console.log('J1H_H2C_BATCH_ERROR');
 });
 console.log('J1H_H2C_READY staging_only five_synthetic_jobs TTL_110s');
 const start=Date.now(),report=await agent.run(),m=report.metrics||{};
 check(Date.now()-start>=SECONDS*1000-3000,'NOT_180_SEC_WALL_CLOCK');
 check(report.stage===BASE&&report.production_touched===false&&report.task_scheduler_modified===false,'STAGING_BOUNDARY_VIOLATION');
 check(m.websocketConnections>=1&&m.websocketErrors===0&&m.networkErrors===1&&m.violations===0,'NETWORK_OR_POLICY_FAILURE');
 check(m.leases===5&&m.resultsSaved===4&&m.statusRecovery===1&&lost,'FIVE_LEASES_OR_ACK_RECOVERY_FAILED');
 check(counts.size===5&&[...counts.values()].every(n=>n===1),'EXECUTION_NOT_EXACTLY_ONCE');
 const rows=report.receipts||[];
 check(rows.length===5&&new Set(rows.map(r=>r.channel)).size===5&&rows.filter(r=>r.result==='recovered').length===1,'RECEIPTS_INVALID');
 const by=Object.fromEntries(rows.map(x=>[x.channel,x]));
 for(const ch of CHANNELS){
  const row=by[ch];
  check(row?.id&&SAFE_ACTIONS[ch],'RECEIPT_MISSING');
  const p={agent_version:'0.7.0',device_id:DEVICE,channel:ch,job_id:row.id,action:SAFE_ACTIONS[ch]};
  const value={ok:true,fixture_only:true,job_id:row.id,source:'j1h-h2c-supervisor'};
  const st=await req('/agent/batch/result-status',{payload:{...p,purpose:'result_status'}});
  check(st.status===200&&st.body?.status==='done'&&JSON.stringify(st.body?.result)===JSON.stringify(value),'RESULT_NOT_PERSISTED');
  const retry=await req('/agent/batch/result',{payload:{...p,purpose:'batch_result',result:value}});
  check(retry.status===200&&retry.body?.already_received===true,'RESULT_NOT_IDEMPOTENT');
 }
 const r=by.commands;
 const conflict=await req('/agent/batch/result',{payload:{agent_version:'0.7.0',device_id:DEVICE,
  channel:'commands',job_id:r.id,action:SAFE_ACTIONS.commands,purpose:'batch_result',
  result:{ok:true,fixture_only:true,source:'deliberately_conflicting_result'}}});
 check(conflict.status===409,'RESULT_CONFLICT_NOT_REJECTED');
 const idle=await req('/agent/batch/poll',{payload:{agent_version:'0.7.0',device_id:DEVICE,purpose:'batch_poll',channels:CHANNELS}});
 check(idle.status===200&&idle.body?.ok===true&&CHANNELS.every(ch=>idle.body.channels?.[ch]?.command===null),'QUEUES_NOT_DRAINED');
 console.log('J1H_H2C_PASS '+JSON.stringify({stage:'staging_only',channels:5,fixtureExecutions:5,
  duplicatedExecutions:0,ackLossSimulated:1,statusRecovered:1,persistedResults:5,idempotentRetries:5,
  conflictRejected:true,queuesEmpty:true,expectedInjectedNetworkErrors:1,unexpectedNetworkErrors:0,violations:0,productionTouched:false,windowsTasksChanged:false}));
}
main().catch(e=>{console.error('J1H_H2C_NO_GO '+String(e?.message||'unexpected').slice(0,100));process.exitCode=1});