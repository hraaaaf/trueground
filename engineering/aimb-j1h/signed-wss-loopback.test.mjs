/**
 * J1-H hermetic signed TLS/WebSocket integration.
 * All keys and the local certificate are freshly generated on the runner.
 * No production or Cloudflare staging mutations; time is simulated.
 */
import {test} from 'node:test';
import assert from 'node:assert/strict';
import {createServer,request as httpsRequest} from 'node:https';
import {generateKeyPairSync,randomBytes,randomUUID,verify,createHash} from 'node:crypto';
import {mkdtempSync,readFileSync,rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {execFileSync} from 'node:child_process';
import {setTimeout as delay} from 'node:timers/promises';
import {BASE,DEVICE,CHANNELS,signRequest,RawWS} from './src/e2e-windows-runner.mjs';
import {SupervisorV07,SAFE_ACTIONS} from './src/supervisor-v07.mjs';

function opensslExe(){
 const choices=process.platform==='win32' ? [
  join(process.env.ProgramFiles||'C:\\Program Files','Git','usr','bin','openssl.exe'),
  join(process.env.ProgramFiles||'C:\\Program Files','Git','mingw64','bin','openssl.exe'),
  'openssl.exe'
 ] : ['openssl'];
 for(const exe of choices)try{execFileSync(exe,['version'],{stdio:'ignore',timeout:4000});return exe}catch{}
 throw Error('OPENSSL_REQUIRED_FOR_EPHEMERAL_TLS');
}
function generateCert(dir){
 const keyfile=join(dir,'tls.key'),certfile=join(dir,'tls.crt');
 execFileSync(opensslExe(),['req','-x509','-newkey','rsa:2048','-nodes',
 '-keyout',keyfile,'-out',certfile,'-days','1','-subj','/CN=localhost',
 '-addext','subjectAltName=DNS:localhost,IP:127.0.0.1'],{stdio:'ignore',timeout:20000});
 return {key:readFileSync(keyfile),cert:readFileSync(certfile)};
}
function signed(headers,method,path,raw,publicKey){
 const t=String(headers['x-bridge-timestamp']||'');
 const n=String(headers['x-bridge-nonce']||'');
 const s=String(headers['x-bridge-signature']||'');
 if(!/^\d{10,12}$/.test(t)||!/^[A-Za-z0-9_-]{16,64}$/.test(n)||!s||Math.abs(Date.now()/1000-Number(t))>30)return false;
 const canonical=[t,n,method+' '+path,method==='GET'?DEVICE:raw].join('\n');
 try{return verify('RSA-SHA256',Buffer.from(canonical),publicKey,Buffer.from(s,'base64url'))}catch{return false}
}
function response(res,status,obj){res.writeHead(status,{'content-type':'application/json'});res.end(JSON.stringify(obj))}
function deny(socket,status,text){socket.end('HTTP/1.1 '+status+' '+text+'\r\nContent-Length: 0\r\nConnection: close\r\n\r\n')}
function frame(obj){const bytes=Buffer.from(JSON.stringify(obj));assert.ok(bytes.length<126);return Buffer.concat([Buffer.from([0x81,bytes.length]),bytes])}
async function startFixture(cert,publicKey){
 const used=new Set(),sockets=new Set();
 const job={id:randomUUID(),action:SAFE_ACTIONS.commands,expires_at:Math.floor(Date.now()/1000)+300};
 const metrics={wss:0,wake:0,results:0,replay:0,unauthorized:0,signedHttp:0};
 let stored=null,notified=false;
 const server=createServer(cert,async(req,res)=>{
  let raw='';for await(const part of req){raw+=part;if(raw.length>16000){response(res,413,{ok:false});return}}
  const path=(req.url||'').split('?')[0];
  if(!signed(req.headers,req.method,path,raw,publicKey)){response(res,401,{ok:false});return}
  const nonce=req.headers['x-bridge-nonce'];
  if(used.has(nonce)){metrics.replay++;response(res,409,{ok:false});return}
  used.add(nonce);metrics.signedHttp++;
  if(req.method!=='POST'){response(res,405,{ok:false});return}
  if(path==='/agent/batch/poll'){
   response(res,200,{ok:true,channels:Object.fromEntries(CHANNELS.map(ch=>[ch,{ok:true,command:ch==='commands'&&!stored?job:null}]))});
   if(!notified){notified=true;setTimeout(()=>{for(const socket of sockets)if(!socket.destroyed){socket.write(frame({type:'pending',channel:'projects'}));metrics.wake++}},10)}
  }else if(path==='/agent/batch/result'){
   const p=JSON.parse(raw);
   if(p.channel!=='commands'||p.job_id!==job.id||p.action!==SAFE_ACTIONS.commands||p.result?.fixture_only!==true){response(res,400,{ok:false});return}
   if(stored){response(res,200,{received:true,already_received:true});return}
   stored=p.result;metrics.results++;response(res,200,{received:true});
  }else if(path==='/agent/batch/result-status'){
   response(res,200,stored?{status:'done',result:stored}:{status:'pending'});
  }else response(res,404,{ok:false});
 });
 server.on('upgrade',(req,socket)=>{
  if(req.url!=='/agent/realtime'||!signed(req.headers,'GET','/agent/realtime','',publicKey)){
   metrics.unauthorized++;deny(socket,401,'Unauthorized');return
  }
  if(used.has(req.headers['x-bridge-nonce'])){metrics.replay++;deny(socket,409,'Conflict');return}
  used.add(req.headers['x-bridge-nonce']);
  const wsKey=req.headers['sec-websocket-key'];
  if(req.headers.upgrade!=='websocket'||typeof wsKey!=='string'){deny(socket,400,'Bad Request');return}
  const accept=createHash('sha1').update(wsKey+'258EAFA5-E914-47DA-95CA-C5AB0DC85B11').digest('base64');
  socket.write('HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Accept: '+accept+'\r\n\r\n');
  metrics.wss++;sockets.add(socket);socket.on('close',()=>sockets.delete(socket));
 });
 await new Promise((resolve,reject)=>{server.once('error',reject);server.listen(0,'127.0.0.1',resolve)});
 return {port:server.address().port,metrics,close:async()=>{for(const socket of sockets)socket.destroy();await new Promise(resolve=>server.close(resolve))}};
}
function requestLocal({port,cert,path,headers={},payload=null}){
 const body=payload===null?'':JSON.stringify(payload);
 return new Promise((resolve,reject)=>{
  const req=httpsRequest({hostname:'127.0.0.1',servername:'localhost',port,method:'POST',path,ca:cert.cert,rejectUnauthorized:true,headers:{...headers,'content-type':'application/json'},timeout:8000},res=>{
   let raw='';res.on('data',d=>raw+=d);res.on('end',()=>{try{resolve({status:res.statusCode,body:JSON.parse(raw)})}catch(e){reject(e)}});
  });
  req.on('timeout',()=>req.destroy(Error('LOCAL_TLS_TIMEOUT')));req.on('error',reject);req.end(body);
 });
}
function connectLocal({port,cert,privateKey,authenticated=true}){
 const path='/agent/realtime',nonce=randomBytes(18).toString('base64url'),key=randomBytes(16).toString('base64');
 const headers=authenticated?signRequest(privateKey,path,'',{method:'GET',websocket:true,nonce}):{};
 return new Promise((resolve,reject)=>{
  let completed=false;
  const req=httpsRequest({hostname:'127.0.0.1',servername:'localhost',port,path,method:'GET',ca:cert.cert,rejectUnauthorized:true,timeout:8000,headers:{...headers,Upgrade:'websocket',Connection:'Upgrade','Sec-WebSocket-Version':'13','Sec-WebSocket-Key':key}},res=>{
   res.resume();finish(null,{status:res.statusCode});
  });
  function finish(error,value){if(completed)return;completed=true;clearTimeout(timer);if(error)reject(error);else resolve(value)}
  const timer=setTimeout(()=>req.destroy(Error('LOCAL_WSS_DEADLINE')),10000);
  req.on('upgrade',(res,socket,head)=>{
   const accept=createHash('sha1').update(key+'258EAFA5-E914-47DA-95CA-C5AB0DC85B11').digest('base64');
   if(res.statusCode!==101||res.headers['sec-websocket-accept']!==accept){socket.destroy();finish(Error('WSS_BAD_UPGRADE'));return}
   const ws=new RawWS(socket);if(head?.length)ws.feed(head);finish(null,{status:101,ws});
  });
  req.on('timeout',()=>req.destroy(Error('LOCAL_WSS_TIMEOUT')));req.on('error',finish);req.end();
 });
}
async function scenario(seconds){
 const dir=mkdtempSync(join(tmpdir(),'aimb-local-wss-'));
 let local;
 try{
  const cert=generateCert(dir);
  const {privateKey,publicKey}=generateKeyPairSync('rsa',{modulusLength:2048});
  local=await startFixture(cert,publicKey);
  const anonymous=await connectLocal({port:local.port,cert,privateKey,authenticated:false});
  assert.equal(anonymous.status,401);
  let virtualMs=0,lost=false;
  const harness={base:BASE,request:async(path,{payload})=>{
   const headers=signRequest(privateKey,path,JSON.stringify(payload));
   const r=await requestLocal({port:local.port,cert,path,headers,payload});
   if(path==='/agent/batch/result'&&!lost){lost=true;throw Error('SIMULATED_ACK_LOSS_AFTER_SERVER_COMMIT')}
   return r;
  }};
  const s=new SupervisorV07({harness,durationSec:seconds,
   connect:async()=>{const r=await connectLocal({port:local.port,cert,privateKey});assert.equal(r.status,101);return r.ws},
   sleep:async()=>{virtualMs+=1000;await delay(5)}});
  s.localTime=()=>virtualMs;
  const report=await s.run();
  assert.ok(report.metrics.websocketConnections>=1);
  assert.ok(report.metrics.batchPolls>=2);
  assert.equal(report.metrics.statusRecovery,1);
  assert.equal(local.metrics.results,1);
  assert.ok(report.metrics.pollReasons.fallback>=1);
  assert.ok(report.metrics.websocketWakeups>=1);
  assert.ok(local.metrics.wake>=1);
  assert.equal(report.metrics.violations,0);
  console.log(JSON.stringify({test:'ephemeral signed TLS+WSS loopback',simulatedSeconds:seconds,
   signedWss:local.metrics.wss,websocketWakeups:report.metrics.websocketWakeups,
   signedPolls:report.metrics.batchPolls,statusRecovered:report.metrics.statusRecovery,
   fallbackPolls:report.metrics.pollReasons.fallback,
   realStaging:false,productionTouched:false,keysPersisted:false}));
 }finally{await local?.close();rmSync(dir,{recursive:true,force:true})}
}
test('hermetic signed TLS/WSS supervisor, virtual 70s',{timeout:30000},()=>scenario(70));
test('hermetic signed TLS/WSS supervisor, virtual 180s',{timeout:30000},()=>scenario(180));
