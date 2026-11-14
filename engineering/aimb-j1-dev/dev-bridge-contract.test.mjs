import {test} from 'node:test';
import assert from 'node:assert/strict';
import {promises as fs} from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {createHash,generateKeyPairSync,sign} from 'node:crypto';
import {DevFixture} from './dev-local.mjs';
import {createOfflineDevBridge,DEV_TOOL_NAMES} from './dev-bridge-contract.mjs';

const sha=x=>createHash('sha256').update(x).digest('hex');
async function withBridge(fn){
 const base=await fs.mkdtemp(path.join(os.tmpdir(),'aimb-dev-contract-')),root=path.join(base,'project'),state=path.join(base,'state');await fs.mkdir(root);await fs.mkdir(state);
 const keys=generateKeyPairSync('ed25519'),source="import {test} from 'node:test'; test('allowlisted fixture',()=>{});";
 await fs.writeFile(path.join(root,'main.txt'),'safe content\n');await fs.writeFile(path.join(root,'main.test.mjs'),source);
 const fixture=await new DevFixture({root,state,publicKey:keys.publicKey,allowlistedTests:{unit:{file:'main.test.mjs',sha256:sha(source)}}}).init();
 const bridge=createOfflineDevBridge({fixture,verifyAuthorization:async(token,claims)=>token==='mock-token'&&claims.scope==='dev:project'&&claims.projectId==='bridge-agent'});
 try{await fn({bridge,fixture,root,state,keys})}finally{fixture.close?.();await fs.rm(base,{recursive:true,force:true,maxRetries:12,retryDelay:100})}
}
function approval(f,d,key){const approval={expires:Date.now()+60000,nonce:'human-approved-fixture-12345'};const p={purpose:'commit_project_patch',draftId:d.id,root:f.root,file:d.file,before:d.before,after:d.after,...approval};return {approval,signature:sign(null,Buffer.from(JSON.stringify(p)),key).toString('base64url')}}

test('offline bridge exposes exactly five allowlisted developer tools',()=>{
 assert.deepEqual(DEV_TOOL_NAMES,['list_dev_project_files','read_dev_project_file','prepare_project_patch','commit_project_patch','run_allowlisted_tests']);
});
test('authenticated mock read and patch preview are confined and prepare does not write',()=>withBridge(async({bridge,root})=>{
 const auth={authorization:'mock-token'};const list=await bridge.call({...auth,tool:'list_dev_project_files',input:{project_id:'bridge-agent'}});assert.ok(list.files.includes('main.txt'));
 const read=await bridge.call({...auth,tool:'read_dev_project_file',input:{project_id:'bridge-agent',path:'main.txt'}});assert.equal(read.content,'safe content\n');
 const draft=await bridge.call({...auth,tool:'prepare_project_patch',input:{project_id:'bridge-agent',path:'main.txt',expected_sha256:read.sha256,old_text:'content',new_text:'draft'}});assert.equal(await fs.readFile(path.join(root,'main.txt'),'utf8'),'safe content\n');assert.equal(draft.before,read.sha256);
}));
test('authorization, project identity and closed input schemas reject before dispatch',()=>withBridge(async({bridge})=>{
 await assert.rejects(bridge.call({authorization:'bad',tool:'list_dev_project_files',input:{project_id:'bridge-agent'}}),/AUTH_REQUIRED/);
 await assert.rejects(bridge.call({authorization:'mock-token',tool:'read_dev_project_file',input:{project_id:'other',path:'main.txt'}}),/PROJECT_ID_NOT_ALLOWLISTED/);
 await assert.rejects(bridge.call({authorization:'mock-token',tool:'read_dev_project_file',input:{project_id:'bridge-agent',path:'main.txt',system_path:'C:/Windows'}}),/INPUT_SCHEMA_INVALID/);
 await assert.rejects(bridge.call({authorization:'mock-token',tool:'powershell',input:{project_id:'bridge-agent',command:'whoami'}}),/TOOL_NOT_ALLOWLISTED/);
}));
test('human signed commit and pinned test ID use local fixture only',()=>withBridge(async({bridge,fixture,root,keys})=>{
 const auth={authorization:'mock-token'};const read=await bridge.call({...auth,tool:'read_dev_project_file',input:{project_id:'bridge-agent',path:'main.txt'}});
 const d=await bridge.call({...auth,tool:'prepare_project_patch',input:{project_id:'bridge-agent',path:'main.txt',expected_sha256:read.sha256,old_text:'content',new_text:'changed'}});
 const a=approval(fixture,d,keys.privateKey);const out=await bridge.call({...auth,tool:'commit_project_patch',input:{project_id:'bridge-agent',draft_id:d.id},...a});assert.equal(out.sha256,d.after);assert.equal(await fs.readFile(path.join(root,'main.txt'),'utf8'),'safe changed\n');
 const tests=await bridge.call({...auth,tool:'run_allowlisted_tests',input:{project_id:'bridge-agent',test_id:'unit'}});assert.equal(tests.exitCode,0);
 await assert.rejects(bridge.call({...auth,tool:'run_allowlisted_tests',input:{project_id:'bridge-agent',test_id:'arbitrary'}}),/TEST_NOT_ALLOWLISTED/);
}));
test('non-allowlisted project cannot be registered by configuration',()=>withBridge(async({fixture})=>{
 assert.throws(()=>createOfflineDevBridge({fixture,projectId:'C:/Users',verifyAuthorization:async()=>true}),/PROJECT_ID_NOT_ALLOWLISTED/);
}));
