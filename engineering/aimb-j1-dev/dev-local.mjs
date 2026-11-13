// Offline fixture prototype only. Never expose these exports as remote tools.
// Node path checks cannot close Windows reparse-point/rename races: native gate required.
import {promises as fs,constants as fc} from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import {createHash,randomUUID,verify} from 'node:crypto';
import {spawn} from 'node:child_process';

const MAX_FILE=128*1024,MAX_OUTPUT=64*1024,MAX_LIST=100;
const hash=x=>createHash('sha256').update(x).digest('hex');
const equalPath=(a,b)=>process.platform==='win32'?a.toLowerCase()===b.toLowerCase():a===b;
function ensure(x,code){if(!x)throw Error(code)}
async function checkComponents(full){
 const parsed=path.parse(full);let cur=parsed.root;
 for(const part of full.slice(parsed.root.length).split(path.sep).filter(Boolean)){
  cur=path.join(cur,part);const st=await fs.lstat(cur);ensure(!st.isSymbolicLink(),'REPARSE_DENIED');
 }
 const actual=await fs.realpath(full);ensure(equalPath(path.resolve(actual),path.resolve(full)),'REALPATH_MISMATCH');
}
function child(root,relative){
 ensure(typeof relative==='string'&&relative.length>0&&relative.length<=240&&!path.isAbsolute(relative)&&!relative.includes('\\')&&!relative.includes(':')&&!relative.split('/').some(x=>!x||x==='.'||x==='..'||x.toLowerCase()==='.git'),'UNSAFE_PATH');
 const target=path.resolve(root,...relative.split('/'));ensure(target.startsWith(root+path.sep),'OUTSIDE_ROOT');return target;
}
async function safeRead(root,relative){
 const target=child(root,relative);await checkComponents(target);const st=await fs.lstat(target);
 ensure(st.isFile()&&st.nlink===1&&st.size<=MAX_FILE,'UNSAFE_FILE');
 const h=await fs.open(target,fc.O_RDONLY|(fc.O_NOFOLLOW||0));
 try{const opened=await h.stat();ensure(opened.isFile()&&opened.nlink===1&&opened.dev===st.dev&&opened.ino===st.ino,'FILE_CHANGED');const b=await h.readFile();ensure(b.length<=MAX_FILE,'FILE_TOO_LARGE');return {target,bytes:b,sha256:hash(b)}}finally{await h.close()}
}
export class DevFixture {
 constructor({root,state,publicKey,allowlistedTests={},maxApprovalReceipts=10000,maxBackups=1000}){
  ensure(Number.isSafeInteger(maxApprovalReceipts)&&maxApprovalReceipts>0&&maxApprovalReceipts<=10000,'APPROVAL_CAPACITY_INVALID');
  ensure(Number.isSafeInteger(maxBackups)&&maxBackups>0&&maxBackups<=1000,'BACKUP_CAPACITY_INVALID');
  this.root=path.resolve(root);this.state=path.resolve(state);this.publicKey=publicKey;this.allowlistedTests=allowlistedTests;this.drafts=new Map();this.busy=false;
  this.maxApprovalReceipts=maxApprovalReceipts;this.maxBackups=maxBackups;
  const tmp=path.resolve(os.tmpdir());ensure(this.root.startsWith(tmp+path.sep)&&this.state.startsWith(tmp+path.sep)&&this.root!==this.state&&!this.state.startsWith(this.root+path.sep),'FIXTURE_TEMP_ROOT_REQUIRED');
 }
 async init(){await checkComponents(this.root);await checkComponents(this.state);return this}
 async list_dev_project_files({offset=0,limit=50}={}){
  ensure(Number.isInteger(offset)&&offset>=0&&Number.isInteger(limit)&&limit>0&&limit<=MAX_LIST,'BAD_PAGE');await checkComponents(this.root);
  const entries=await fs.readdir(this.root,{withFileTypes:true});const names=entries.filter(x=>x.isFile()&&x.name!=='.git').map(x=>x.name).sort();return {files:names.slice(offset,offset+limit),next:offset+limit<names.length?offset+limit:null};
 }
 async read_dev_project_file({file}){const x=await safeRead(this.root,file);return {content:x.bytes.toString('utf8'),sha256:x.sha256,size:x.bytes.length}}
 async prepare_project_patch({file,expectedSha256,oldText,newText}){
  ensure(typeof oldText==='string'&&oldText.length>0&&typeof newText==='string'&&Buffer.byteLength(newText)<=MAX_FILE,'INVALID_PATCH');
  const x=await safeRead(this.root,file);ensure(x.sha256===expectedSha256,'SHA_MISMATCH');const original=x.bytes.toString('utf8');
  ensure(Buffer.from(original).equals(x.bytes),'NON_UTF8_DENIED');const index=original.indexOf(oldText);ensure(index>=0&&original.indexOf(oldText,index+1)<0,'PATCH_NOT_UNIQUE');
  const next=original.slice(0,index)+newText+original.slice(index+oldText.length);ensure(Buffer.byteLength(next)<=MAX_FILE,'FILE_TOO_LARGE');
  const draft={id:randomUUID(),file,before:x.sha256,after:hash(Buffer.from(next)),root:this.root};this.drafts.set(draft.id,{...draft,next});return {...draft,diff:{oldText,newText}};
 }
 async commit_project_patch({draftId,approval,signature,simulateFailure=false}){
  ensure(!this.busy,'OPERATION_BUSY');this.busy=true;
  let lockHandle;
  try{
   await checkComponents(this.state);
   try{lockHandle=await fs.open(path.join(this.state,'.commit.lock'),'wx',0o600)}catch(e){if(e.code==='EEXIST')throw Error('COMMIT_BUSY_OR_STALE_LOCK');throw e}
   await lockHandle.sync();
   const draft=this.drafts.get(draftId);ensure(draft,'DRAFT_NOT_FOUND');
   const payload={purpose:'commit_project_patch',draftId,root:this.root,file:draft.file,before:draft.before,after:draft.after,expires:approval?.expires,nonce:approval?.nonce};
   ensure(Number.isSafeInteger(payload.expires)&&payload.expires>=Date.now()&&payload.expires<=Date.now()+300000&&typeof payload.nonce==='string'&&/^[a-zA-Z0-9_-]{16,64}$/.test(payload.nonce),'APPROVAL_INVALID');
   ensure(verify(null,Buffer.from(JSON.stringify(payload)),this.publicKey,Buffer.from(signature||'','base64url')),'APPROVAL_DENIED');
   const current=await safeRead(this.root,draft.file);ensure(current.sha256===draft.before,'CONCURRENT_CHANGE');await checkComponents(this.state);
   const nonceHash=hash(Buffer.from(payload.nonce,'utf8')),noncePath=path.join(this.state,`approval-${nonceHash}.used`);
   const stateNames=await fs.readdir(this.state);ensure(stateNames.filter(x=>/^approval-[a-f0-9]{64}\.used$/.test(x)).length<this.maxApprovalReceipts,'APPROVAL_RECEIPT_CAPACITY');
   ensure(stateNames.filter(x=>x.endsWith('.bak')).length<this.maxBackups,'BACKUP_CAPACITY');
   let nonceHandle;try{nonceHandle=await fs.open(noncePath,'wx',0o600)}catch(e){if(e.code==='EEXIST')throw Error('APPROVAL_REPLAY');throw e}
   try{await nonceHandle.writeFile(JSON.stringify({draftId,before:draft.before,after:draft.after,expires:payload.expires,nonceHash}));await nonceHandle.sync()}finally{await nonceHandle.close()}
   const backup=path.join(this.state,`${draft.id}.bak`),tmp=current.target+'.fixture-'+randomUUID();let wrote=false;
   await fs.writeFile(backup,current.bytes,{flag:'wx'});
   try{
    await fs.writeFile(tmp,draft.next,{flag:'wx'});const again=await safeRead(this.root,draft.file);ensure(again.sha256===draft.before,'CONCURRENT_CHANGE');
    await fs.rename(tmp,current.target);wrote=true;if(simulateFailure)throw Error('SIMULATED_AFTER_RENAME');
    const after=await safeRead(this.root,draft.file);ensure(after.sha256===draft.after,'POST_WRITE_MISMATCH');this.drafts.delete(draft.id);
    return {draftId,sha256:after.sha256,backup,rollback:false};
   }catch(e){
    await fs.unlink(tmp).catch(()=>{});
    if(wrote){const after=await safeRead(this.root,draft.file);ensure(after.sha256===draft.after,'ROLLBACK_CONFLICT');const restore=current.target+'.fixture-'+randomUUID();await fs.writeFile(restore,current.bytes,{flag:'wx'});await fs.rename(restore,current.target);ensure((await safeRead(this.root,draft.file)).sha256===draft.before,'ROLLBACK_FAILED')}
    throw e;
   }
  }finally{
   if(lockHandle){await lockHandle.close().catch(()=>{});await fs.unlink(path.join(this.state,'.commit.lock')).catch(()=>{})}
   this.busy=false
  }
 }
 async run_allowlisted_tests({id,timeoutMs=5000}){
  ensure(!this.busy,'OPERATION_BUSY');ensure(Number.isInteger(timeoutMs)&&timeoutMs>=100&&timeoutMs<=30000,'TIMEOUT_INVALID');const spec=this.allowlistedTests[id];ensure(spec&&/^[0-9a-f]{64}$/.test(spec.sha256),'TEST_NOT_ALLOWLISTED');
  const f=await safeRead(this.root,spec.file);ensure(f.sha256===spec.sha256,'TEST_HASH_MISMATCH');this.busy=true;
  try{return await new Promise((resolve,reject)=>{
    const proc=spawn(process.execPath,['--test',f.target],{cwd:this.root,shell:false,windowsHide:true,env:{PATH:process.env.PATH||'',SystemRoot:process.env.SystemRoot||''}});let out='',err='',timedOut=false,overflow=false,treeKillPromise=null;
    const stopTree=()=>{
     if(treeKillPromise)return treeKillPromise;
     if(process.platform!=='win32'){proc.kill('SIGKILL');treeKillPromise=Promise.resolve({attempted:false,ok:true,method:'direct-child'});return treeKillPromise}
     const systemRoot=process.env.SystemRoot||'C:\\Windows',taskkill=path.join(systemRoot,'System32','taskkill.exe');
     treeKillPromise=new Promise(resolve=>{
      let killer;try{killer=spawn(taskkill,['/PID',String(proc.pid),'/T','/F'],{cwd:systemRoot,shell:false,windowsHide:true,stdio:'ignore'})}catch{proc.kill();resolve({attempted:true,ok:false,method:'taskkill'});return}
      const deadline=setTimeout(()=>{killer.kill();proc.kill()},5000);
      killer.once('error',()=>{clearTimeout(deadline);proc.kill();resolve({attempted:true,ok:false,method:'taskkill'})});
      killer.once('close',code=>{clearTimeout(deadline);if(proc.exitCode===null)proc.kill();resolve({attempted:true,ok:code===0,method:'taskkill',exitCode:code})});
     });return treeKillPromise;
    };
    const timer=setTimeout(()=>{timedOut=true;void stopTree()},timeoutMs);
    const append=(v,s)=>{if(Buffer.byteLength(out)+Buffer.byteLength(err)+v.length>MAX_OUTPUT){overflow=true;void stopTree();return}if(s==='out')out+=v.toString();else err+=v.toString()};
    proc.stdout.on('data',x=>append(x,'out'));proc.stderr.on('data',x=>append(x,'err'));proc.on('error',e=>{clearTimeout(timer);reject(e)});proc.on('close',async code=>{clearTimeout(timer);const treeKill=treeKillPromise?await treeKillPromise:{attempted:false,ok:true,method:'not-needed'};resolve({exitCode:code,timedOut,overflow,treeKill,stdout:out,stderr:err})});
  })}finally{this.busy=false}
 }
}
