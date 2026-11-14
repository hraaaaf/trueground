import {test} from 'node:test';
import assert from 'node:assert/strict';
import {promises as fs} from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {generateKeyPairSync,sign,createHash,randomUUID} from 'node:crypto';
import {DevFixture} from './dev-local.mjs';
import {BUDGET,ZERO,quotaDecision,simulate,retryPlan} from './quota-model.mjs';
const sha=x=>createHash('sha256').update(x).digest('hex');
async function fixture(fn){
 const base=await fs.mkdtemp(path.join(os.tmpdir(),'aimb-dev-fixture-')),root=path.join(base,'project'),state=path.join(base,'state');await fs.mkdir(root);await fs.mkdir(state);
 const keys=generateKeyPairSync('ed25519');await fs.writeFile(path.join(root,'main.txt'),'hello world\n');
 const f=await new DevFixture({root,state,publicKey:keys.publicKey}).init();try{await fn({f,root,state,keys})}finally{await fs.rm(base,{recursive:true,force:true})}
}
function approve(f,d,key,nonce='fixture_approval_123456789'){const approval={expires:Date.now()+60000,nonce};const p={purpose:'commit_project_patch',draftId:d.id,root:f.root,file:d.file,before:d.before,after:d.after,...approval};return {approval,signature:sign(null,Buffer.from(JSON.stringify(p)),key).toString('base64url')}}
test('list/read pagination and SHA, patch preview does not write',()=>fixture(async({f,root})=>{
 assert.deepEqual((await f.list_dev_project_files()).files,['main.txt']);const r=await f.read_dev_project_file({file:'main.txt'});const d=await f.prepare_project_patch({file:'main.txt',expectedSha256:r.sha256,oldText:'world',newText:'fixture'});assert.equal(d.before,r.sha256);assert.equal(await fs.readFile(path.join(root,'main.txt'),'utf8'),'hello world\n');
}));
test('signed fixture approval applies patch, writes backup, prevents replay',()=>fixture(async({f,root,keys})=>{
 const r=await f.read_dev_project_file({file:'main.txt'}),d=await f.prepare_project_patch({file:'main.txt',expectedSha256:r.sha256,oldText:'world',newText:'fixture'}),a=approve(f,d,keys.privateKey);const out=await f.commit_project_patch({draftId:d.id,...a});assert.equal(await fs.readFile(out.backup,'utf8'),'hello world\n');assert.equal(await fs.readFile(path.join(root,'main.txt'),'utf8'),'hello fixture\n');await assert.rejects(f.commit_project_patch({draftId:d.id,...a}));
}));
test('approval receipts and backups have hard local capacity ceilings',()=>fixture(async({root,state,keys})=>{
 const limitedReceipts=await new DevFixture({root,state,publicKey:keys.publicKey,maxApprovalReceipts:1,maxBackups:10}).init();
 const r=await limitedReceipts.read_dev_project_file({file:'main.txt'}),d=await limitedReceipts.prepare_project_patch({file:'main.txt',expectedSha256:r.sha256,oldText:'world',newText:'first'});await limitedReceipts.commit_project_patch({draftId:d.id,...approve(limitedReceipts,d,keys.privateKey)});
  const r2=await limitedReceipts.read_dev_project_file({file:'main.txt'}),d2=await limitedReceipts.prepare_project_patch({file:'main.txt',expectedSha256:r2.sha256,oldText:'first',newText:'second'});await assert.rejects(limitedReceipts.commit_project_patch({draftId:d2.id,...approve(limitedReceipts,d2,keys.privateKey,randomUUID())}),/APPROVAL_RECEIPT_CAPACITY/);
 const root2=path.join(path.dirname(root),'project-backup-limit'),state2=path.join(path.dirname(root),'state-backup-limit');await fs.mkdir(root2);await fs.mkdir(state2);await fs.writeFile(path.join(root2,'main.txt'),'hello world\n');
 const limitedBackups=await new DevFixture({root:root2,state:state2,publicKey:keys.publicKey,maxApprovalReceipts:10,maxBackups:1}).init();const rb=await limitedBackups.read_dev_project_file({file:'main.txt'}),db=await limitedBackups.prepare_project_patch({file:'main.txt',expectedSha256:rb.sha256,oldText:'world',newText:'first'});await limitedBackups.commit_project_patch({draftId:db.id,...approve(limitedBackups,db,keys.privateKey,'backup_approval_nonce_12345')});
 const rb2=await limitedBackups.read_dev_project_file({file:'main.txt'}),db2=await limitedBackups.prepare_project_patch({file:'main.txt',expectedSha256:rb2.sha256,oldText:'first',newText:'second'});await assert.rejects(limitedBackups.commit_project_patch({draftId:db2.id,...approve(limitedBackups,db2,keys.privateKey,'backup_approval_nonce_67890')}),/BACKUP_CAPACITY/);
}));
test('approval nonce remains single-use after draft and fixture reconstruction',()=>fixture(async({f,root,state,keys})=>{
 const r=await f.read_dev_project_file({file:'main.txt'}),d=await f.prepare_project_patch({file:'main.txt',expectedSha256:r.sha256,oldText:'world',newText:'one'});await f.commit_project_patch({draftId:d.id,...approve(f,d,keys.privateKey)});
 const after=await new DevFixture({root,state,publicKey:keys.publicKey}).init();const r2=await after.read_dev_project_file({file:'main.txt'}),d2=await after.prepare_project_patch({file:'main.txt',expectedSha256:r2.sha256,oldText:'one',newText:'two'});await assert.rejects(after.commit_project_patch({draftId:d2.id,...approve(after,d2,keys.privateKey)}),/APPROVAL_REPLAY/);assert.equal(await fs.readFile(path.join(root,'main.txt'),'utf8'),'hello one\n');
}));
test('stale cross-process commit lock fails closed and is preserved',()=>fixture(async({f,root,state,keys})=>{
 const r=await f.read_dev_project_file({file:'main.txt'}),d=await f.prepare_project_patch({file:'main.txt',expectedSha256:r.sha256,oldText:'world',newText:'fixture'});await fs.writeFile(path.join(state,'.commit.lock'),'previous-process',{flag:'wx'});
 await assert.rejects(f.commit_project_patch({draftId:d.id,...approve(f,d,keys.privateKey)}),/COMMIT_BUSY_OR_STALE_LOCK/);assert.equal(await fs.readFile(path.join(root,'main.txt'),'utf8'),'hello world\n');assert.equal(await fs.readFile(path.join(state,'.commit.lock'),'utf8'),'previous-process');
}));
test('separate fixture instances serialize commits through the shared filesystem lock',()=>fixture(async({f,root,state,keys})=>{
 const second=await new DevFixture({root,state,publicKey:keys.publicKey}).init();
 const before=await f.read_dev_project_file({file:'main.txt'}),a=await f.prepare_project_patch({file:'main.txt',expectedSha256:before.sha256,oldText:'world',newText:'first'}),b=await second.prepare_project_patch({file:'main.txt',expectedSha256:before.sha256,oldText:'world',newText:'second'});
 const results=await Promise.allSettled([f.commit_project_patch({draftId:a.id,...approve(f,a,keys.privateKey)}),second.commit_project_patch({draftId:b.id,...approve(second,b,keys.privateKey)})]);
 assert.equal(results.filter(x=>x.status==='fulfilled').length,1);assert.equal(results.filter(x=>x.status==='rejected').length,1);
 const final=await fs.readFile(path.join(root,'main.txt'),'utf8');assert.ok(final==='hello first\n'||final==='hello second\n');assert.equal((await fs.readdir(state)).filter(x=>x.endsWith('.bak')).length,1);
}));
test('invalid signature and concurrent edits do not apply patch',()=>fixture(async({f,root,keys})=>{
 const r=await f.read_dev_project_file({file:'main.txt'}),d=await f.prepare_project_patch({file:'main.txt',expectedSha256:r.sha256,oldText:'world',newText:'fixture'});await assert.rejects(f.commit_project_patch({draftId:d.id,approval:{expires:Date.now()+60000,nonce:'fixture_approval_123456789'},signature:'a'}),/APPROVAL_DENIED/);const a=approve(f,d,keys.privateKey);await fs.writeFile(path.join(root,'main.txt'),'external');await assert.rejects(f.commit_project_patch({draftId:d.id,...a}),/CONCURRENT_CHANGE/);assert.equal(await fs.readFile(path.join(root,'main.txt'),'utf8'),'external');
}));
test('expired correctly signed approval is rejected before receipt or project writes',()=>fixture(async({f,root,state,keys})=>{
 const before=await f.read_dev_project_file({file:'main.txt'}),d=await f.prepare_project_patch({file:'main.txt',expectedSha256:before.sha256,oldText:'world',newText:'expired'});
 const approval={expires:Date.now()-1,nonce:'expired_fixture_nonce_123456'};
 const payload={purpose:'commit_project_patch',draftId:d.id,root:f.root,file:d.file,before:d.before,after:d.after,...approval};
 const signature=sign(null,Buffer.from(JSON.stringify(payload)),keys.privateKey).toString('base64url');
 await assert.rejects(f.commit_project_patch({draftId:d.id,approval,signature}),/APPROVAL_INVALID/);
 assert.equal((await f.read_dev_project_file({file:'main.txt'})).sha256,before.sha256);assert.deepEqual(await fs.readdir(state),[]);
}));
test('approval beyond the five minute validity window is rejected',()=>fixture(async({f,keys})=>{
 const before=await f.read_dev_project_file({file:'main.txt'}),d=await f.prepare_project_patch({file:'main.txt',expectedSha256:before.sha256,oldText:'world',newText:'too-far'});
 const approval={expires:Date.now()+310001,nonce:'future_fixture_nonce_123456'};
 const payload={purpose:'commit_project_patch',draftId:d.id,root:f.root,file:d.file,before:d.before,after:d.after,...approval};
 const signature=sign(null,Buffer.from(JSON.stringify(payload)),keys.privateKey).toString('base64url');
 await assert.rejects(f.commit_project_patch({draftId:d.id,approval,signature}),/APPROVAL_INVALID/);
}));
test('post-rename failure rolls back while retaining backup',()=>fixture(async({f,root,state,keys})=>{
 const r=await f.read_dev_project_file({file:'main.txt'}),d=await f.prepare_project_patch({file:'main.txt',expectedSha256:r.sha256,oldText:'world',newText:'fixture'});await assert.rejects(f.commit_project_patch({draftId:d.id,...approve(f,d,keys.privateKey),simulateFailure:true}),/SIMULATED_AFTER_RENAME/);assert.equal(await fs.readFile(path.join(root,'main.txt'),'utf8'),'hello world\n');assert.equal(await fs.readFile(path.join(state,d.id+'.bak'),'utf8'),'hello world\n');
}));
test('traversal and hardlinks denied',()=>fixture(async({f,root,state})=>{
 await assert.rejects(f.read_dev_project_file({file:'../state/out'}),/UNSAFE_PATH/);await fs.writeFile(path.join(state,'outside'),'outside');await fs.link(path.join(state,'outside'),path.join(root,'hard'));await assert.rejects(f.read_dev_project_file({file:'hard'}),/UNSAFE_FILE/);
}));
test('oversize file refused',()=>fixture(async({f,root})=>{await fs.writeFile(path.join(root,'large'),Buffer.alloc(131073));await assert.rejects(f.read_dev_project_file({file:'large'}),/UNSAFE_FILE/)}));
test('only pinned predefined test runs and timeout is bounded',()=>fixture(async({f,root})=>{
 const source="import {test} from 'node:test'; test('fixture',async()=>new Promise(r=>setTimeout(r,5000)));";await fs.writeFile(path.join(root,'test.mjs'),source);f.allowlistedTests={slow:{file:'test.mjs',sha256:sha(source)}};await assert.rejects(f.run_allowlisted_tests({id:'shell'}),/TEST_NOT_ALLOWLISTED/);const r=await f.run_allowlisted_tests({id:'slow',timeoutMs:300});assert.equal(r.timedOut,true);
}));
test('Windows timeout terminates the complete test process tree',async t=>fixture(async({f,root})=>{
 if(process.platform!=='win32'){t.skip('Windows process-tree behavior');return}
 const marker=path.join(root,'grandchild-survived.txt');
 const grandchild=`setTimeout(()=>require('node:fs').writeFileSync(${JSON.stringify(marker)},'survived'),1500)`;
 const source=`import {test} from 'node:test'; import {spawn} from 'node:child_process'; test('spawn child',()=>{spawn(process.execPath,['-e',${JSON.stringify(grandchild)}],{stdio:'ignore'});return new Promise(r=>setTimeout(r,10000))});`;
 await fs.writeFile(path.join(root,'tree.test.mjs'),source);f.allowlistedTests={tree:{file:'tree.test.mjs',sha256:sha(source)}};
 const r=await f.run_allowlisted_tests({id:'tree',timeoutMs:300});assert.equal(r.timedOut,true);assert.equal(r.treeKill.attempted,true);assert.equal(r.treeKill.ok,true);await new Promise(resolve=>setTimeout(resolve,1800));await assert.rejects(fs.stat(marker),{code:'ENOENT'});
}));
test('quotas block remote operations when global state unavailable, but local cache stays readable',()=>{assert.equal(quotaDecision({used:ZERO(),cost:ZERO(),globalUsage:null}).allow,false);assert.equal(quotaDecision({used:ZERO(),cost:ZERO(),globalUsage:null,localCached:true}).allow,true);assert.equal(quotaDecision({used:ZERO(),cost:ZERO(),globalUsage:{reliable:true,ratio:0.9}}).allow,false)});
test('quota 70/80/90 thresholds and D1 limits',()=>{for(const [ratio,level] of [[0.7,'ALERT'],[0.8,'SLOW'],[0.9,'STOP']]){const used={...ZERO(),d1write:BUDGET.d1write*ratio};assert.equal(quotaDecision({used,cost:ZERO(),globalUsage:{reliable:true,ratio:0.1}}).level,level)}});
test('idle day has no requests or writes',()=>assert.deepEqual(simulate([]).consumed,ZERO()));
test('8h illustrated day is finite and under internal budgets',()=>{const events=[...Array(192).fill('batch'),...Array(96).fill('read'),...Array(8).fill('patch'),...Array(8).fill('test')];const r=simulate(events);assert.deepEqual(r.consumed,{worker:320,d1read:832,d1write:536,doRequests:320});assert.equal(r.counts.rejected,0)});
test('bounded network retries and quota exhaustion stop new work',()=>{const r=simulate(Array(3).fill('retry'));assert.equal(r.consumed.worker,3);const blocked=simulate(['patch'],{used:{...ZERO(),d1write:899}});assert.equal(blocked.counts.rejected,1)});
test('offline retry model stops on quota and never polls while inactive',()=>{assert.deepEqual(retryPlan({active:false,results:['error']}),{attempts:0,backoffMs:[],status:'IDLE'});assert.deepEqual(retryPlan({active:true,results:['error','error','ok']}),{attempts:3,backoffMs:[5000,10000],status:'OK'});assert.equal(retryPlan({active:true,results:['error','quota','ok']}).status,'QUOTA_STOP')});
test('oversized test output terminates and is not returned unbounded',()=>fixture(async({f,root})=>{const source="import {test} from 'node:test'; test('large',()=>console.log('x'.repeat(90000)));";await fs.writeFile(path.join(root,'output.test.mjs'),source);f.allowlistedTests={large:{file:'output.test.mjs',sha256:sha(source)}};const r=await f.run_allowlisted_tests({id:'large',timeoutMs:5000});assert.equal(r.overflow,true);assert.ok(Buffer.byteLength(r.stdout)+Buffer.byteLength(r.stderr)<=65536)}));
test('symbolic link in project is rejected when Windows permits fixture link creation',async t=>fixture(async({f,root,state})=>{
 await fs.writeFile(path.join(state,'witness'),'unchanged');try{await fs.symlink(path.join(state,'witness'),path.join(root,'link'));}catch(e){if(['EPERM','EACCES'].includes(e.code)){t.skip('fixture symlink privilege unavailable');return}throw e}
 await assert.rejects(f.read_dev_project_file({file:'link'}),/REPARSE_DENIED/);assert.equal(await fs.readFile(path.join(state,'witness'),'utf8'),'unchanged');
}));
test('junction parent is rejected when supported',async t=>fixture(async({f,root,state})=>{
 if(process.platform!=='win32'){t.skip('Windows junction test');return}await fs.writeFile(path.join(state,'witness'),'unchanged');
 try{await fs.symlink(state,path.join(root,'junction'),'junction')}catch(e){if(['EPERM','EACCES'].includes(e.code)){t.skip('junction creation unavailable');return}throw e}
 await assert.rejects(f.read_dev_project_file({file:'junction/witness'}),/REPARSE_DENIED/);assert.equal(await fs.readFile(path.join(state,'witness'),'utf8'),'unchanged');
}));
