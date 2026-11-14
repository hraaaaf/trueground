#!/usr/bin/env node
// P0 local CLI only: no MCP registration, no task control, no network or worker access.
import path from 'node:path';
import { homedir } from 'node:os';
import { pathToFileURL } from 'node:url';
import { inspectCadence, planCadence, applyCadence, verifyCadence, rollbackCadence } from './cadence-core.mjs';

function fail(code){throw new Error(code);}
function optionsFrom(argv){
 const m=new Map();
 if(argv.length%2!==0)fail('INVALID_ARGUMENTS');
 for(let i=0;i<argv.length;i+=2){
  if(!argv[i].startsWith('--')||!argv[i+1]||argv[i+1].startsWith('--')||m.has(argv[i]))fail('INVALID_ARGUMENTS');
  m.set(argv[i],argv[i+1]);
 }
 return m;
}
export async function cli(argv,env=process.env){
 if(process.platform!=='win32'&&env.AIMB_SELF_REPAIR_FIXTURE_TEST!=='1')fail('WINDOWS_ONLY');
 const action=argv[0];
 if(!['inspect','plan','apply','verify','rollback'].includes(action))fail('UNKNOWN_ACTION');
 const o=optionsFrom(argv.slice(1)),allowed=new Set(['--target','--expected-sha256','--to','--approve-plan','--plan-id']);
 for(const k of o.keys())if(!allowed.has(k))fail('UNKNOWN_OPTION');
 const target=o.get('--target');if(!target)fail('TARGET_REQUIRED');
 const home=env.USERPROFILE||homedir();
 const agentRoot=env.AIMB_SELF_REPAIR_FIXTURE_TEST==='1'&&env.AIMB_SELF_REPAIR_FIXTURE_AGENT_ROOT?env.AIMB_SELF_REPAIR_FIXTURE_AGENT_ROOT:path.join(home,'AI_Machine_Bridge_Agent');
 const stateRoot=env.AIMB_SELF_REPAIR_FIXTURE_TEST==='1'&&env.AIMB_SELF_REPAIR_FIXTURE_STATE_ROOT?env.AIMB_SELF_REPAIR_FIXTURE_STATE_ROOT:path.join(home,'AI_Machine_Bridge_SelfRepair_State');
 const base={agentRoot,target};
 switch(action){
 case 'inspect':return inspectCadence(base);
 case 'plan':return planCadence({...base,expectedSha256:o.get('--expected-sha256'),toSeconds:Number(o.get('--to'))});
 case 'apply':return applyCadence({...base,stateRoot,expectedSha256:o.get('--expected-sha256'),toSeconds:Number(o.get('--to')),approvedPlanId:o.get('--approve-plan')});
 case 'verify':return verifyCadence({...base,expectedSha256:o.get('--expected-sha256')});
 case 'rollback':return rollbackCadence({...base,stateRoot,planId:o.get('--plan-id'),approvedPlanId:o.get('--approve-plan')});
 }
}
if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href){
 cli(process.argv.slice(2)).then(result=>{process.stdout.write(JSON.stringify(result,null,2)+'\n');}).catch(error=>{process.stderr.write('NO_GO: '+error.message+'\n');process.exitCode=1;});
}
