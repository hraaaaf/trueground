/**
 * J1-H live staging gate for an approved Windows runner.
 * No fixture generation, no cloud deployment, no database migration, no real device work.
 * An already authorized RSA fixture key must be injected by protected GitHub Environment.
 * DO NOT print raw supervisor output or the contents of the key file.
 */
import {createPrivateKey,createPublicKey,createHash} from 'node:crypto';
import {readFileSync,statSync} from 'node:fs';
import {spawn} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import {dirname,join} from 'node:path';
import {BASE,requireStagingUrl} from './src/e2e-windows-runner.mjs';

const THUMBPRINT='3a98cf5776bf8b243f7c6a423c505015e45a7870d002512c38eed85b8e3a5dbb';
const HERE=dirname(fileURLToPath(import.meta.url));
const SUPERVISOR=join(HERE,'src','supervisor-v07.mjs');
const durations=[70,180];
function fail(code){throw Error(code)}
function assertKeyMatch(){
 const p=process.env.AIMB_J1H_PRIVATE_KEY_PATH;
 if(!p || !statSync(p,{throwIfNoEntry:false})?.isFile())fail('AUTHORIZED_FIXTURE_KEY_FILE_MISSING');
 const jwk=createPublicKey(createPrivateKey(readFileSync(p))).export({format:'jwk'});
 const data=JSON.stringify({e:jwk.e,kty:jwk.kty,n:jwk.n});
 const digest=createHash('sha256').update(data).digest('hex');
 if(digest!==THUMBPRINT)fail('FIXTURE_KEY_DOES_NOT_MATCH_LIVE_STAGING');
 console.log('PIN_CHECK_OK: private key matches pinned staging public RSA key fingerprint; key not logged.');
}
async function preflight(){
 requireStagingUrl();
 const r=await fetch(BASE+'/health',{signal:AbortSignal.timeout(12000)});
 if(r.status!==200)fail('STAGING_NOT_READY_HTTP_'+r.status);
 const data=await r.json();
 if(data.production!==false||data.d1!==true||data.do_bound!==true)fail('STAGING_BOUNDARIES_NOT_READY');
 console.log('STAGING_PREFLIGHT_OK: production=false, D1 and DO ready.');
}
function launch(seconds){
 return new Promise((resolve,reject)=>{
  const started=Date.now();
  const child=spawn(process.execPath,[SUPERVISOR,'--duration-sec',String(seconds)],{
   cwd:join(HERE,'src'),env:{...process.env},stdio:['ignore','pipe','pipe'],windowsHide:true
  });
  let out='',err='',finished=false;
  const limit=4*1024*1024;
  const timeout=setTimeout(()=>{child.kill();end(Error('SUPERVISOR_HARD_DEADLINE_'+seconds))},(seconds+45)*1000);
  function end(e,value){
   if(finished)return;finished=true;clearTimeout(timeout);
   if(e)reject(e);else resolve(value);
  }
  child.stdout.on('data',c=>{out+=c.toString('utf8');if(out.length>limit){child.kill();end(Error('SUPERVISOR_LOG_SIZE_LIMIT'))}});
  child.stderr.on('data',c=>{err+=c.toString('utf8');if(err.length>limit){child.kill();end(Error('SUPERVISOR_ERROR_LOG_SIZE_LIMIT'))}});
  child.on('error',()=>end(Error('SUPERVISOR_SPAWN_FAILED')));
  child.on('close',code=>{
   if(finished)return;
   const elapsedMs=Date.now()-started;
   const boot=out.includes('STAGE_BOOT');
   const events=out.split(/\r?\n/).filter(x=>x.startsWith('STAGE_EVENT ')).map(x=>{
    try{return JSON.parse(x.slice('STAGE_EVENT '.length))}catch{return {type:'invalid_event'}}
   });
   const summaryIndex=out.lastIndexOf('\n{\n  "goal":');
   let report=null;
   if(summaryIndex>=0)try{report=JSON.parse(out.slice(summaryIndex+1).trim())}catch{}
   if(code!==0) return end(Error('SUPERVISOR_EXIT_NONZERO_'+seconds));
   if(!boot||!report) return end(Error('SUPERVISOR_BOOT_OR_REPORT_MISSING_'+seconds));
   if(elapsedMs < seconds*1000-3000) return end(Error('NOT_REAL_WALL_CLOCK_'+seconds));
   if(report.stage!==BASE||report.production_touched!==false||report.task_scheduler_modified!==false)
     return end(Error('SUPERVISOR_SCOPE_VIOLATION_'+seconds));
   const metrics=report.metrics||{};
   const eventNames=events.map(e=>e.type);
   if(!eventNames.includes('supervisor_started')||!eventNames.includes('websocket_connected')
     ||!eventNames.includes('poll_started')||!eventNames.includes('poll_finished')
     ||metrics.websocketConnections<1||metrics.batchPolls<1||metrics.violations!==0)
     return end(Error('SIGNED_WEBSOCKET_OR_POLL_EVIDENCE_MISSING_'+seconds));
   const diagnostics={
    phase:'staging_live',wallClockSeconds:seconds,wallClockElapsedMs:elapsedMs,
    websocketConnections:metrics.websocketConnections,
    websocketWakeups:metrics.websocketWakeups,
    websocketErrors:metrics.websocketErrors,
    batchPolls:metrics.batchPolls,
    pollReasons:metrics.pollReasons,
    shortPollIntervals:metrics.shortPollIntervals,
    wakeupLatencyCount:metrics.wakeupPollLatencyMs?.length||0,
    statusRecovery:metrics.statusRecovery,
    networkErrors:metrics.networkErrors,
    eventsCount:events.length,
    productionTouched:false,windowsTasksChanged:false
   };
   return end(null,diagnostics);
  });
 });
}
async function main(){
 if(process.argv.length!==2)fail('NO_ARGUMENTS_ALLOWED');
 assertKeyMatch();
 await preflight();
 for(const seconds of durations){
  const result=await launch(seconds);
  console.log('J1H_LIVE_SUMMARY '+JSON.stringify(result));
 }
 console.log('J1H_LIVE_TEST_PASS: signed staging WSS, 70s + 180s real wall-clock.');
}
main().catch(e=>{console.error('NO_GO '+String(e?.message||e).slice(0,90));process.exitCode=1});
