/** H2-B: signed staging WSS notification-to-poll proof. No fixture writes or real PC access. */
import {createPrivateKey,createPublicKey,createHash} from 'node:crypto';
import {readFileSync} from 'node:fs';
import {spawn} from 'node:child_process';
import {dirname,join} from 'node:path';
import {fileURLToPath} from 'node:url';
import {BASE,requireStagingUrl,signRequest} from './src/e2e-windows-runner.mjs';
import {verifyBoundedWake} from './h2b-rate-evidence.mjs';

const ROOT=dirname(fileURLToPath(import.meta.url));
const SUPERVISOR=join(ROOT,'src','supervisor-v07.mjs');
const EXPECTED='3a98cf5776bf8b243f7c6a423c505015e45a7870d002512c38eed85b8e3a5dbb';
const DURATION=70;
function fail(code){throw Error(code)}
function key(){
 const path=process.env.AIMB_J1H_PRIVATE_KEY_PATH;
 if(!path)fail('NO_FIXTURE_KEY_PATH');
 const privateKey=createPrivateKey(readFileSync(path));
 const jwk=createPublicKey(privateKey).export({format:'jwk'});
 const fingerprint=createHash('sha256').update(JSON.stringify({e:jwk.e,kty:jwk.kty,n:jwk.n})).digest('hex');
 if(fingerprint!==EXPECTED)fail('WRONG_STAGING_FIXTURE_KEY');
 return privateKey;
}
async function notify(privateKey){
 const path='/staging/notify';
 const headers=signRequest(privateKey,path,'',{method:'POST',websocket:true});
 const invoke=()=>fetch(BASE+path,{method:'POST',headers:{...headers,'content-type':'application/json'},body:'{}',signal:AbortSignal.timeout(10000)});
 const a=await invoke();let body={};try{body=await a.json()}catch{}
 if(a.status!==200||body.ok!==true||body.delivered!==1)fail('SIGNED_NOTIFICATION_NOT_DELIVERED_ONCE');
 const b=await invoke();
 if(b.status!==409)fail('SIGNED_NOTIFICATION_REPLAY_NOT_REJECTED');
 return {delivered:body.delivered,replayRejected:true};
}
function parseReport(raw){
 const at=raw.lastIndexOf('\n{\n  "goal":');
 if(at<0)fail('SUPERVISOR_REPORT_MISSING');
 try{return JSON.parse(raw.slice(at+1).trim())}catch{fail('SUPERVISOR_REPORT_INVALID')}
}
async function run(){
 requireStagingUrl();
 if(process.argv.length!==2)fail('NO_ARGUMENTS_ALLOWED');
 const privateKey=key();
 const r=await fetch(BASE+'/health',{signal:AbortSignal.timeout(10000)});
 if(r.status!==200)fail('STAGING_HEALTH_NOT_OK');
 const health=await r.json();
 if(health.production!==false||health.d1!==true||health.do_bound!==true)fail('STAGING_SCOPE_FAILED');
 const child=spawn(process.execPath,[SUPERVISOR,'--duration-sec',String(DURATION)],{
   cwd:join(ROOT,'src'),env:{...process.env},stdio:['ignore','pipe','pipe'],windowsHide:true
 });
 const start=Date.now();let output='',tail='',stderr='',started=false,sendPromise=null,finished=false,excess=false;
 const timeout=setTimeout(()=>child.kill(),(DURATION+45)*1000);
 function processLine(line){
   if(!line.startsWith('STAGE_EVENT '))return;
   let event;try{event=JSON.parse(line.slice(12))}catch{return}
   if(event.type==='websocket_connected'&&!started){
     started=true;
     sendPromise=new Promise((resolve,reject)=>setTimeout(()=>notify(privateKey).then(resolve,reject),2500));
   }
 }
 child.stdout.on('data',chunk=>{
   if(finished)return;
   const t=chunk.toString('utf8');output+=t;tail+=t;
   if(output.length>2000000){excess=true;child.kill();return}
   const lines=tail.split(/\r?\n/);tail=lines.pop()??'';
   for(const line of lines)processLine(line);
 });
 child.stderr.on('data',chunk=>{stderr+=chunk.toString('utf8');if(stderr.length>100000){excess=true;child.kill()}});
 const code=await new Promise((resolve,reject)=>{child.once('error',reject);child.once('close',resolve)});
 finished=true;clearTimeout(timeout);
 if(excess)fail('SUPERVISOR_LOG_LIMIT');
 if(!sendPromise)fail('SIGNED_WSS_SESSION_NEVER_CONNECTED');
 const sent=await sendPromise;
 if(code!==0)fail('SUPERVISOR_EXIT_FAILURE');
 const report=parseReport(output);
 const summary=verifyBoundedWake({report,sent,wallClockSeconds:DURATION,elapsedMs:Date.now()-start});
 console.log('J1H_H2B_PASS '+JSON.stringify(summary));
}
run().catch(e=>{console.error('J1H_H2B_NO_GO '+String(e?.message||'unexpected').slice(0,100));process.exitCode=1});
