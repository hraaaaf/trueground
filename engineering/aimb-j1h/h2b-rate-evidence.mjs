/**
 * J1-H H2-B live-staging wake evidence, deliberately PURE and fail-closed.
 * This does not connect, read credentials, create fixture jobs or authorize prod.
 */
import {BASE,DEVICE} from './src/e2e-windows-runner.mjs';
export const MIN_BATCH_GAP_MS = 15000;
export const MAX_WAKE_LATENCY_MS = 17000;
function requireCondition(ok,code){if(!ok)throw Error(code)}
export function verifyBoundedWake({report,sent,wallClockSeconds,elapsedMs}){
 requireCondition(report?.stage===BASE && report.production_touched===false &&
   report.task_scheduler_modified===false,'STAGING_BOUNDARY_VIOLATION');
 requireCondition(Number.isFinite(elapsedMs) && elapsedMs >= wallClockSeconds*1000 - 3000 &&
   wallClockSeconds===70,'WALL_CLOCK_DURATION_NOT_PROVEN');
 requireCondition(sent?.delivered===1 && sent?.replayRejected===true,
   'SIGNED_NOTIFICATION_REPLAY_NOT_PROVEN');
 const m=report.metrics;
 requireCondition(m && m.websocketConnections===1 && m.websocketWakeups===1 &&
   m.pollReasons?.wakeup===1 && m.websocketErrors===0 && m.networkErrors===0 &&
   m.violations===0 && m.shortPollIntervals===0 && m.batchPolls>=2,
   'SIGNED_SESSION_METRICS_INVALID');
 requireCondition(m.wakeupPollLatencyMs?.length===1,'WAKEUP_LATENCY_MISSING');
 const latency=m.wakeupPollLatencyMs[0];
 requireCondition(Number.isFinite(latency) && latency>=0 && latency<=MAX_WAKE_LATENCY_MS,
   'WAKEUP_LATENCY_EXCEEDS_BOUNDED_CADENCE');
 const trace=report.pollTrace;
 requireCondition(Array.isArray(trace) && trace.length===m.batchPolls,
   'TRACE_COUNT_MISMATCH');
 const wake=trace.filter(p=>p.reason==='wakeup');
 requireCondition(wake.length===1 && wake[0].status==='ok' &&
   Number.isSafeInteger(wake[0].wakeId) && wake[0].wakeId>=1 &&
   wake[0].wakeupToPollMs===latency,'WAKEUP_TRACE_INVALID');
 for(let i=1;i<trace.length;i++){
   const a=trace[i-1], b=trace[i];
   requireCondition(Number.isFinite(a.startedMonotonicMs) &&
     Number.isFinite(b.startedMonotonicMs) && b.startedMonotonicMs > a.startedMonotonicMs &&
     b.intervalMs===b.startedMonotonicMs-a.startedMonotonicMs &&
     b.intervalMs>=MIN_BATCH_GAP_MS,'BATCH_CADENCE_VIOLATION');
 }
 return Object.freeze({stage:'staging_only',device:DEVICE,wallClockSeconds,
   elapsedMs,websocketConnections:1,websocketWakeups:1,wakeupPolls:1,
   wakeupToPollMs:latency,minBatchGapMs:MIN_BATCH_GAP_MS,batchPolls:m.batchPolls,
   notificationDelivered:1,replayRejected:true,networkErrors:0,violations:0,
   productionTouched:false,windowsTasksChanged:false,fixtureJobsExecuted:0,
   ackRecoveryNotTested:true});
}
