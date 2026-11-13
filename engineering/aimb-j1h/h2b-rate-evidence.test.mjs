import {test} from 'node:test';
import assert from 'node:assert/strict';
import {verifyBoundedWake,MIN_BATCH_GAP_MS} from './h2b-rate-evidence.mjs';
import {BASE} from './src/e2e-windows-runner.mjs';
const mk=()=>({
 report:{stage:BASE,production_touched:false,task_scheduler_modified:false,
  metrics:{websocketConnections:1,websocketWakeups:1,websocketErrors:0,
   networkErrors:0,violations:0,shortPollIntervals:0,batchPolls:2,
   pollReasons:{startup:1,wakeup:1,fallback:0,retry:0},wakeupPollLatencyMs:[12500]},
  pollTrace:[{reason:'startup',status:'ok',startedMonotonicMs:0,intervalMs:null},
   {reason:'wakeup',status:'ok',startedMonotonicMs:15000,intervalMs:15000,wakeId:1,wakeupToPollMs:12500}]},
 sent:{delivered:1,replayRejected:true},wallClockSeconds:70,elapsedMs:70500
});
test('valid signed 70s rate-limited wake is reviewable, never production authorization',()=>{
 const res=verifyBoundedWake(mk());assert.equal(res.minBatchGapMs,MIN_BATCH_GAP_MS);
 assert.equal(res.ackRecoveryNotTested,true);assert.equal(res.productionTouched,false);
});
test('legacy 250ms or 5.1s wake explicitly rejected',()=>{
 for(const n of [250,5100,14999]){const x=mk();x.report.pollTrace[1].startedMonotonicMs=n;
 x.report.pollTrace[1].intervalMs=n;assert.throws(()=>verifyBoundedWake(x),/BATCH_CADENCE_VIOLATION/);}
});
test('inconsistent synthetic trace rejected',()=>{
 const x=mk();x.report.pollTrace[1].intervalMs=18000;
 assert.throws(()=>verifyBoundedWake(x),/BATCH_CADENCE_VIOLATION/);
});
test('zero WebSocket or missing signed notification is no-go',()=>{
 const x=mk();x.report.metrics.websocketConnections=0;assert.throws(()=>verifyBoundedWake(x));
 const y=mk();y.sent.delivered=0;assert.throws(()=>verifyBoundedWake(y));
 const z=mk();z.sent.replayRejected=false;assert.throws(()=>verifyBoundedWake(z));
});
test('extra unsolicited wakeups and repeated polls rejected',()=>{
 const x=mk();x.report.metrics.websocketWakeups=2;assert.throws(()=>verifyBoundedWake(x));
 const y=mk();y.report.metrics.pollReasons.wakeup=2;assert.throws(()=>verifyBoundedWake(y));
 const z=mk();z.report.metrics.batchPolls=3;assert.throws(()=>verifyBoundedWake(z),/TRACE_COUNT_MISMATCH/);
});
test('overlong wake latency rejected',()=>{
 const x=mk();x.report.metrics.wakeupPollLatencyMs=[18000];x.report.pollTrace[1].wakeupToPollMs=18000;
 assert.throws(()=>verifyBoundedWake(x),/WAKEUP_LATENCY_EXCEEDS/);
});
test('network errors, unauthorized action and short polling reject',()=>{
 for(const k of ['websocketErrors','networkErrors','violations','shortPollIntervals']){
 const x=mk();x.report.metrics[k]=1;assert.throws(()=>verifyBoundedWake(x));}
});
test('no wall clock evidence or staging/Windows integrity fails closed',()=>{
 const x=mk();x.elapsedMs=4000;assert.throws(()=>verifyBoundedWake(x),/WALL_CLOCK_DURATION/);
 const y=mk();y.report.production_touched=true;assert.throws(()=>verifyBoundedWake(y),/STAGING_BOUNDARY/);
 const z=mk();z.report.task_scheduler_modified=true;assert.throws(()=>verifyBoundedWake(z),/STAGING_BOUNDARY/);
});
test('missing trace or malformed/mismatched wake identifier fails closed',()=>{
 const x=mk();x.report.pollTrace=[];assert.throws(()=>verifyBoundedWake(x));
 const y=mk();y.report.pollTrace[1].wakeId=null;assert.throws(()=>verifyBoundedWake(y));
 const z=mk();z.report.pollTrace[1].wakeupToPollMs=1;assert.throws(()=>verifyBoundedWake(z));
});
