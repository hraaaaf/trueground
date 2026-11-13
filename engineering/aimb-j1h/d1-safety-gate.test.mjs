import test from 'node:test';
import assert from 'node:assert/strict';
import {assessResumeGate, projected24hBudget, LEGACY_TASKS} from './d1-safety-gate.mjs';
const NOW=Date.parse('2026-11-13T10:00:00Z');
const sample=()=>({
  target:'new-bounded-readonly-agent',
  taskStates:Object.fromEntries([...LEGACY_TASKS.map(n=>[n,'Disabled']), ['AI-Machine-Bridge-Presence','Enabled']]),
  proofs:{signedStagingE2E:true,idempotentAckRecovery:true,replayRejected:true,
    windowsIsolation:true,readOnlyAllowlist:true,securityReview:true,humanApproval:true},
  sourceSha256:'a'.repeat(64),
  quota:{observedAt:'2026-11-13T09:55:00Z',sampleHours:24,sampleComplete:true,sampled:false,
    otherReads24h:1000,otherWrites24h:200,batches24h:1440,
    readsPerBatch:3,writesPerBatch:1,resultCalls24h:10,readsPerResult:1,writesPerResult:1,
    readLimit24h:100000,writeLimit24h:10000}
});
test('missing input fails closed',()=>assert.equal(assessResumeGate(null,NOW).status,'NO_GO'));
test('healthy measured 24h only reaches HUMAN gate, never starts tasks',()=>{
 const g=assessResumeGate(sample(),NOW);
 assert.equal(g.status,'READY_FOR_HUMAN_REVIEW');
 assert.equal(g.mayEnableLegacyTasks,false);
 assert.equal(g.productionAuthorized,false);
 assert.equal(g.taskSchedulerModified,false);
});
test('existing legacy poller enabled blocks candidate',()=>{
 for(const name of LEGACY_TASKS){const x=sample();x.taskStates[name]='Enabled';
  assert.ok(assessResumeGate(x,NOW).reasons.includes('LEGACY_TASK_MUST_STAY_DISABLED:'+name));}
});
test('unknown legacy state fails closed',()=>{const x=sample();delete x.taskStates[LEGACY_TASKS[0]];assert.equal(assessResumeGate(x,NOW).status,'NO_GO')});
test('old pollers cannot be approved as a replacement',()=>{const x=sample();x.target='legacy-polling';assert.equal(assessResumeGate(x,NOW).status,'NO_GO')});
test('every critical proof is mandatory',()=>{
 for(const key of Object.keys(sample().proofs)){const x=sample();x.proofs[key]=false;assert.equal(assessResumeGate(x,NOW).status,'NO_GO',key)}
});
test('source must be SHA pinned',()=>{const x=sample();x.sourceSha256='';assert.equal(assessResumeGate(x,NOW).status,'NO_GO')});
test('quota observation must be recent and not in future',()=>{
 for(const date of ['2026-11-13T02:00:00Z','2026-11-13T11:00:00Z','bad']){
  const x=sample();x.quota.observedAt=date;assert.equal(assessResumeGate(x,NOW).status,'NO_GO');}
});
test('no 24h measurement or sampled data fails closed',()=>{
 const x=sample();x.quota.sampleHours=2;assert.equal(assessResumeGate(x,NOW).status,'NO_GO');
 x.quota.sampleHours=24;x.quota.sampled=true;assert.equal(assessResumeGate(x,NOW).status,'NO_GO');
});
test('unknown Cloudflare limits fail closed',()=>{
 const x=sample();delete x.quota.readLimit24h;assert.equal(assessResumeGate(x,NOW).status,'NO_GO');
});
test('exceeding read or write headroom blocks',()=>{
 const x=sample();x.quota.otherWrites24h=9000;assert.ok(assessResumeGate(x,NOW).reasons.includes('D1_WRITE_BUDGET_EXCEEDED'));
 x.quota.otherWrites24h=200;x.quota.otherReads24h=90000;assert.ok(assessResumeGate(x,NOW).reasons.includes('D1_READ_BUDGET_EXCEEDED'));
});
test('24h projections include other project load and ACKs',()=>{
 const p=projected24hBudget(sample().quota);
 assert.equal(p.projectedReads,1000+1440*3+10);
 assert.equal(p.projectedWrites,200+1440+10);
});
test('overflow & malformed numbers rejected',()=>{
 const x=sample();x.quota.batches24h=Number.MAX_SAFE_INTEGER;
 assert.equal(assessResumeGate(x,NOW).status,'NO_GO');
 x.quota.batches24h=-1;assert.equal(assessResumeGate(x,NOW).status,'NO_GO');
});
