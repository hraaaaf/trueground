import {simulate,ZERO,retryPlan} from './quota-model.mjs';
const eight=[...Array(192).fill('batch'),...Array(96).fill('read'),...Array(8).fill('patch'),...Array(8).fill('test')];
const scenarios={
 idle_24h:simulate([]),
 eight_hour_development_24h:simulate(eight),
 multiple_reads_and_patches:simulate([...Array(10).fill('read'),...Array(2).fill('patch')]),
 network_outage_and_recovery:{...simulate(Array(3).fill('retry')),retry:retryPlan({active:true,results:['error','error','ok']})},
 d1_limit_reached:simulate(['patch'],{used:{...ZERO(),d1write:899}}),
 worker_quota_error:{...simulate(['retry']),retry:retryPlan({active:true,results:['quota']})},
 oversized_output:simulate(['test']),
 path_escape_rejected_locally:simulate([]),
 rollback_local:simulate([]),
 test_timeout:simulate(['test'])
};
console.log(JSON.stringify({model:'Offline illustrative event counts; no account metering',eventCosts:{batch:{worker:1,d1read:3,d1write:2,doRequests:1},read:{worker:1,d1read:2,d1write:1,doRequests:1},patch:{worker:2,d1read:4,d1write:4,doRequests:2},test:{worker:2,d1read:4,d1write:3,doRequests:2},retry:{worker:1,d1read:1,d1write:0,doRequests:1}},scenarios},null,2));
