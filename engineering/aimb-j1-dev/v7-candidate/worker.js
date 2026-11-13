import {handleReadResult} from './staging-result.mjs';
import {makeHandler} from '../minimal-mcp.mjs';
import fixture from '../fixture.mjs';
const J1_DEV_MCP = makeHandler({fixture});

const J1H_QUEUE=Object.freeze({
 commands:{table:'commands',columns:'id,action',allow:['get_system_info']},
 files:{table:'file_jobs',columns:'id,action,filename',allow:['list_authorized_files','read_authorized_text']},
 maintenance:{table:'maintenance_jobs',columns:'id,action,argument',allow:['get_pc_resources','get_bridge_tasks','inspect_windows_service']},
 workspace:{table:'workspace_jobs',columns:'id,action,filename',allow:['list_workspace_files','read_workspace_text']},
 projects:{table:'project_jobs',columns:'id,action,args_json',allow:['list_project_files','read_project_text']}
});
async function j1hText(req){
 if(!req.body)throw Error('missing_body');
 const reader=req.body.getReader(),chunks=[];let n=0;
 try{for(;;){const {done,value}=await reader.read();if(done)break;n+=value.byteLength;if(n>4096){await reader.cancel();throw Error('too_large')}chunks.push(value)}}finally{reader.releaseLock()}
 const a=new Uint8Array(n);let p=0;for(const v of chunks){a.set(v,p);p+=v.length}
 return new TextDecoder('utf-8',{fatal:true}).decode(a);
}
async function j1hClaim(db,channel,id,now,recover){
 const q=J1H_QUEUE[channel];const allowed=' AND action IN ('+q.allow.map(()=>'?').join(',')+')';
 if(recover){
  const old=await db.prepare('SELECT '+q.columns+' FROM '+q.table+" WHERE device_id=? AND status='leased' AND expires_at>?"+allowed+' ORDER BY created_at LIMIT 1').bind(id,now,...q.allow).first();
  if(old)return{ok:true,command:old};
 }
 const c=await db.prepare('SELECT '+q.columns+' FROM '+q.table+" WHERE device_id=? AND status='pending' AND expires_at>?"+allowed+' ORDER BY created_at LIMIT 1').bind(id,now,...q.allow).first();
 if(!c)return{ok:true,command:null};
 const cas=await db.prepare('UPDATE '+q.table+" SET status='leased' WHERE id=? AND device_id=? AND status='pending' AND expires_at>?"+allowed).bind(c.id,id,now,...q.allow).run();
 return{ok:true,command:cas.meta?.changes===1?c:null};
}
async function j1hBatch(req,env){
 if(req.method!=='POST')return json({error:'method_not_allowed'},405);
 if(!(req.headers.get('content-type')||'').startsWith('application/json'))return json({error:'bad_media_type'},415);
 if(!env.STAGING_DB||!env.STAGING_PUB_JWK)return json({error:'not_provisioned'},503);
 let raw,x;try{raw=await j1hText(req);x=JSON.parse(raw)}catch{return json({error:'invalid_body'},400)}
 if(!x||typeof x!=='object'||Array.isArray(x))return json({error:'invalid_shape'},400);
 const shape=Object.keys(x).sort().join(',');
 if(!['agent_version,channels,device_id,purpose','agent_version,channels,device_id,purpose,recovery_mode'].includes(shape)||
    x.agent_version!=='0.7.0'||x.device_id!=='j1h-staging-fixture'||x.purpose!=='batch_poll'||
    x.recovery_mode!==undefined&&x.recovery_mode!=='leased_first'||
    !Array.isArray(x.channels)||x.channels.length<1||x.channels.length>5||new Set(x.channels).size!==x.channels.length||
    !x.channels.every(y=>typeof y==='string'&&Object.hasOwn(J1H_QUEUE,y)))return json({error:'invalid_shape'},400);
 const t=req.headers.get('x-bridge-timestamp')||'',n=req.headers.get('x-bridge-nonce')||'',sig=req.headers.get('x-bridge-signature')||'',now=Math.floor(Date.now()/1000);
 if(!/^[0-9]{10,12}$/.test(t)||!re.test(n)||!/^[A-Za-z0-9_-]{200,1000}$/.test(sig)||Math.abs(now-Number(t))>90)return json({error:'bad_signature'},401);
 try{
  const key=await crypto.subtle.importKey('jwk',JSON.parse(env.STAGING_PUB_JWK),{name:'RSASSA-PKCS1-v1_5',hash:'SHA-256'},false,['verify']);
  const s=sig.replace(/-/g,'+').replace(/_/g,'/');const bytes=Uint8Array.from(atob(s+'='.repeat((4-s.length%4)%4)),c=>c.charCodeAt(0));
  if(!await crypto.subtle.verify('RSASSA-PKCS1-v1_5',key,bytes,enc.encode(t+'\n'+n+'\nPOST /agent/batch/poll\n'+raw)))return json({error:'bad_signature'},401);
 }catch{return json({error:'bad_signature'},401)}
 if(!env.STAGING_DO||!env.STAGE_INTERNAL)return json({error:'nonce_unavailable'},503);
 let gate;try{
  const stub=env.STAGING_DO.get(env.STAGING_DO.idFromName(x.device_id));
  gate=await stub.fetch('https://internal/consume-poll',{method:'POST',headers:{'x-stage-internal':env.STAGE_INTERNAL,'x-stage-nonce':n}});
 }catch{return json({error:'nonce_unavailable'},503)}
 if(gate.status===409)return json({error:'replay'},409);
 if(gate.status!==200)return json({error:'nonce_unavailable'},503);
 const channels={};for(const name of x.channels){try{channels[name]=await j1hClaim(env.STAGING_DB,name,x.device_id,now,x.recovery_mode==='leased_first')}catch{channels[name]={ok:false,error:'channel_unavailable'}}}
 if(now%3600<60){try{await env.STAGING_DB.prepare('DELETE FROM agent_nonces WHERE seen_at < ?').bind(now-600).run()}catch{}}
 return json({ok:true,channels});
}

const enc=new TextEncoder();const json=(x,s=200)=>new Response(JSON.stringify(x),{status:s,headers:{'content-type':'application/json','cache-control':'no-store'}});const re=/^[A-Za-z0-9_-]{16,64}$/;const device='j1h-staging-fixture';async function auth(req,env){const t=req.headers.get('x-bridge-timestamp')||'',n=req.headers.get('x-bridge-nonce')||'',sig=req.headers.get('x-bridge-signature')||'';if(!/^\d{10,12}$/.test(t)||!re.test(n)||!/^[A-Za-z0-9_-]{200,1000}$/.test(sig)||Math.abs(Date.now()/1000-Number(t))>90)return null;try{const key=await crypto.subtle.importKey('jwk',JSON.parse(env.STAGING_PUB_JWK),{name:'RSASSA-PKCS1-v1_5',hash:'SHA-256'},false,['verify']);const data=t+'\n'+n+'\n'+req.method+' '+new URL(req.url).pathname+'\n'+device;const raw=Uint8Array.from(atob(sig.replace(/-/g,'+').replace(/_/g,'/')),c=>c.charCodeAt(0));return await crypto.subtle.verify('RSASSA-PKCS1-v1_5',key,raw,enc.encode(data))?n:null}catch{return null}}export class StageSocket{constructor(state,env){this.state=state;this.env=env}async fetch(req){if(req.headers.get('x-stage-internal')!==this.env.STAGE_INTERNAL)return json({error:'unauthorized'},401);const path=new URL(req.url).pathname;if(path==='/consume-poll'){
 if(req.method!=='POST')return json({error:'method'},405);
 const nonce=req.headers.get('x-stage-nonce');if(!re.test(nonce||''))return json({error:'nonce'},400);
 try{
  const db=this.state.storage.sql,now=Math.floor(Date.now()/1000);
  db.exec('CREATE TABLE IF NOT EXISTS poll_nonces(nonce TEXT PRIMARY KEY,seen_at INTEGER NOT NULL)');
  const changed=db.exec('INSERT OR IGNORE INTO poll_nonces(nonce,seen_at) VALUES (?,?) RETURNING nonce',nonce,now).toArray();
  if(changed.length!==1)return json({error:'replay'},409);
  if(now%3600<60)db.exec('DELETE FROM poll_nonces WHERE seen_at<?',now-240);
  return json({ok:true});
 }catch{return json({error:'nonce_unavailable'},503)}
}if(path==='/connect'){const nonce=req.headers.get('x-stage-nonce');if(!re.test(nonce||''))return json({error:'nonce'},400);const seen=await this.state.storage.get('seen')||[];const recent=seen.filter(x=>Date.now()-x.t<180000);if(recent.some(x=>x.n===nonce))return json({error:'replay'},409);recent.push({n:nonce,t:Date.now()});await this.state.storage.put('seen',recent.slice(-256));for(const s of this.state.getWebSockets())s.close(4001,'replaced');const pair=new WebSocketPair();const [client,server]=Object.values(pair);this.state.acceptWebSocket(server);return new Response(null,{status:101,webSocket:client})}if(path==='/notify'){const nonce=req.headers.get('x-stage-nonce');if(!re.test(nonce||''))return json({error:'nonce'},400);const seen=await this.state.storage.get('notify_nonces')||[];const recent=seen.filter(x=>Date.now()-x.t<180000);if(recent.some(x=>x.n===nonce))return json({error:'replay'},409);recent.push({n:nonce,t:Date.now()});await this.state.storage.put('notify_nonces',recent.slice(-256));let delivered=0;for(const s of this.state.getWebSockets()){if(s.readyState===1){s.send(JSON.stringify({type:'pending',channel:'projects'}));delivered++}}return json({ok:true,delivered})}return json({error:'not_found'},404)}webSocketMessage(ws,m){if(m==='ping')ws.send('pong');else ws.close(1008,'unsupported')}webSocketClose(ws,c,r){try{ws.close(c,r)}catch{}}}export default{async fetch(req,env){const u=new URL(req.url);if(u.pathname==='/mcp'||u.pathname==='/.well-known/oauth-protected-resource')return J1_DEV_MCP(req,env);if(req.method==='GET'&&u.pathname==='/health'){const r=await env.STAGING_DB.prepare('SELECT 1 AS ok').first();return json({stage:'j1h-isolated',d1:r?.ok===1,do_bound:!!env.STAGING_DO,production:false})}if(u.pathname==='/agent/batch/poll')return j1hBatch(req,env);if(['/agent/batch/result','/agent/batch/result-status'].includes(u.pathname))return handleReadResult(req,env,u.pathname);if(!['/agent/realtime','/staging/notify'].includes(u.pathname))return json({error:'not_found'},404);if(u.pathname==='/agent/realtime'&&(req.method!=='GET'||req.headers.get('upgrade')?.toLowerCase()!=='websocket'))return json({error:'upgrade_required'},426);if(u.pathname==='/staging/notify'&&req.method!=='POST')return json({error:'method'},405);const nonce=await auth(req,env);if(!nonce)return json({error:'unauthorized'},401);const stub=env.STAGING_DO.get(env.STAGING_DO.idFromName(device));if(u.pathname==='/agent/realtime')return stub.fetch('https://internal/connect',{headers:{upgrade:'websocket','x-stage-internal':env.STAGE_INTERNAL,'x-stage-nonce':nonce}});return stub.fetch('https://internal/notify',{method:'POST',headers:{'x-stage-internal':env.STAGE_INTERNAL,'x-stage-nonce':nonce}})}}