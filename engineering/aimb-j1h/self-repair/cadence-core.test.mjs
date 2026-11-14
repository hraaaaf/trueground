import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, mkdir, readFile, rm, symlink, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { inspectCadence, planCadence, applyCadence, rollbackCadence, verifyCadence, sha256, PATCH_TARGETS } from './cadence-core.mjs';

const scripts={commands:'command-agent.ps1',files:'file-agent.ps1',workspace:'workspace-agent.ps1'};
async function fixture(target,seconds,{crlf=false,bom=false}={}){
  const base=await mkdtemp(path.join(tmpdir(),'aimb-p0-'));
  const agentRoot=path.join(base,'agent'),stateRoot=path.join(base,'state');
  await mkdir(agentRoot);
  const file=path.join(agentRoot,scripts[target]);
  const nl=crlf?'\r\n':'\n';
  const source=(bom?'\uFEFF':'')+"$ErrorActionPreference='Stop'"+nl+'while($true){'+nl+'  # synthetic fixture'+nl+'  Start-Sleep -Seconds '+seconds+nl+'}'+nl;
  const bytes=Buffer.from(source);
  await writeFile(file,bytes);
  return {base,file,agentRoot,stateRoot,bytes,hash:sha256(bytes),cleanup:()=>rm(base,{recursive:true,force:true})};
}
test('only three recognized agent targets; no path traversal',async()=>{
  assert.deepEqual(PATCH_TARGETS,['commands','files','workspace']);
  const f=await fixture('commands',4);
  try{
    await assert.rejects(inspectCadence({agentRoot:f.agentRoot,target:'../../config.json'}),/TARGET_NOT_ALLOWLISTED/);
    await assert.rejects(inspectCadence({agentRoot:f.agentRoot,target:'admin'}),/TARGET_NOT_ALLOWLISTED/);
  }finally{await f.cleanup();}
});
for(const [target,from,to] of [['commands',4,15],['files',4,60],['workspace',8,60]]){
  for(const [crlf,bom] of [[false,false],[true,true]]){
    test(target+' '+(crlf?'CRLF BOM':'LF')+' byte-exact plan/apply/verify/rollback',async()=>{
      const f=await fixture(target,from,{crlf,bom});
      try{
        const p=await planCadence({agentRoot:f.agentRoot,target,expectedSha256:f.hash,toSeconds:to});
        assert.equal(p.line,4);
        assert.equal(p.beforeSha256,f.hash);
        assert.equal((await readFile(f.file)).equals(f.bytes),true);
        await assert.rejects(applyCadence({agentRoot:f.agentRoot,stateRoot:f.stateRoot,target,expectedSha256:f.hash,toSeconds:to,approvedPlanId:f.hash}),/HUMAN_APPROVAL_PLAN_MISMATCH/);
        assert.equal((await readFile(f.file)).equals(f.bytes),true);
        const applied=await applyCadence({agentRoot:f.agentRoot,stateRoot:f.stateRoot,target,expectedSha256:f.hash,toSeconds:to,approvedPlanId:p.planId});
        assert.equal(applied.status,'applied_not_restarted');
        assert.equal(sha256(await readFile(f.file)),p.afterSha256);
        assert.equal((await verifyCadence({agentRoot:f.agentRoot,target,expectedSha256:p.afterSha256})).seconds,to);
        await assert.rejects(applyCadence({agentRoot:f.agentRoot,stateRoot:f.stateRoot,target,expectedSha256:f.hash,toSeconds:to,approvedPlanId:p.planId}),/SOURCE_SHA_MISMATCH/);
        await assert.rejects(rollbackCadence({agentRoot:f.agentRoot,stateRoot:f.stateRoot,target,planId:p.planId,approvedPlanId:f.hash}),/HUMAN_APPROVAL_PLAN_MISMATCH/);
        const rolled=await rollbackCadence({agentRoot:f.agentRoot,stateRoot:f.stateRoot,target,planId:p.planId,approvedPlanId:p.planId});
        assert.equal(rolled.status,'rolled_back_not_restarted');
        assert.equal((await readFile(f.file)).equals(f.bytes),true);
        await assert.rejects(rollbackCadence({agentRoot:f.agentRoot,stateRoot:f.stateRoot,target,planId:p.planId,approvedPlanId:p.planId}),/ALREADY_ROLLED_BACK/);
      }finally{await f.cleanup();}
    });
  }
}
test('bad SHA and forbidden cadence transitions are rejected',async()=>{
 const f=await fixture('workspace',8);
 try{
   await assert.rejects(planCadence({agentRoot:f.agentRoot,target:'workspace',expectedSha256:'0'.repeat(64),toSeconds:60}),/SOURCE_SHA_MISMATCH/);
   await assert.rejects(planCadence({agentRoot:f.agentRoot,target:'workspace',expectedSha256:f.hash,toSeconds:15}),/TRANSITION_NOT_ALLOWLISTED/);
   await assert.rejects(planCadence({agentRoot:f.agentRoot,target:'workspace',expectedSha256:f.hash,toSeconds:1}),/TRANSITION_NOT_ALLOWLISTED/);
 }finally{await f.cleanup();}
});
test('double sleep, extra code after sleep and invalid UTF-8 fail closed',async()=>{
 const f=await fixture('files',4);
 try{
   await writeFile(f.file,'while($true){\nStart-Sleep -Seconds 4\nStart-Sleep -Seconds 4\n}\n');
   await assert.rejects(planCadence({agentRoot:f.agentRoot,target:'files',expectedSha256:sha256(await readFile(f.file)),toSeconds:60}),/EXPECTED_EXACTLY_ONE_SLEEP_LINE/);
   await writeFile(f.file,"while($true){\nStart-Sleep -Seconds 4\nWrite-Host 'other'\n}\n");
   await assert.rejects(planCadence({agentRoot:f.agentRoot,target:'files',expectedSha256:sha256(await readFile(f.file)),toSeconds:60}),/SLEEP_NOT_TERMINAL_LOOP/);
   await writeFile(f.file,Buffer.from([255,254,128]));
   await assert.rejects(planCadence({agentRoot:f.agentRoot,target:'files',expectedSha256:sha256(await readFile(f.file)),toSeconds:60}),/INVALID_UTF8/);
 }finally{await f.cleanup();}
});
test('already corrected state is read-only; no noop patch',async()=>{
 const f=await fixture('files',60);
 try{
  assert.equal((await inspectCadence({agentRoot:f.agentRoot,target:'files'})).seconds,60);
  await assert.rejects(planCadence({agentRoot:f.agentRoot,target:'files',expectedSha256:f.hash,toSeconds:60}),/TRANSITION_NOT_ALLOWLISTED/);
 }finally{await f.cleanup();}
});
test('symlink target cannot be patched',async()=>{
 const f=await fixture('commands',4);
 try{
  const other=path.join(f.base,'other.ps1');await writeFile(other,f.bytes);
  await rm(f.file);await symlink(other,f.file,'file');
  await assert.rejects(inspectCadence({agentRoot:f.agentRoot,target:'commands'}),/UNSAFE_TARGET_FILE/);
 }finally{await f.cleanup();}
});
test('rollback never overwrites a post-apply user edit',async()=>{
 const f=await fixture('commands',4);
 try{
   const p=await planCadence({agentRoot:f.agentRoot,target:'commands',expectedSha256:f.hash,toSeconds:15});
   await applyCadence({agentRoot:f.agentRoot,stateRoot:f.stateRoot,target:'commands',expectedSha256:f.hash,toSeconds:15,approvedPlanId:p.planId});
   await writeFile(f.file,(await readFile(f.file)).toString('utf8')+'# changed by someone else\n');
   await assert.rejects(rollbackCadence({agentRoot:f.agentRoot,stateRoot:f.stateRoot,target:'commands',planId:p.planId,approvedPlanId:p.planId}),/ROLLBACK_SOURCE_CHANGED/);
 }finally{await f.cleanup();}
});
