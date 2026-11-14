import {handleReadResult,verifyStagingAgentSignature} from './staging-result.mjs';
import {createStagingMcpWorker,stagingIdentityPreflight} from './staging-mcp-worker.mjs';

const J1H_QUEUE=Object.freeze({
 commands:{table:'commands',columns:'id,action',allow:['get_system_info']},
 files:{table:'file_jobs',columns:'id,action,filename',allow:['list_authorized_files','read_authorized_text']},
 maintenance:{table:'maintenance_jobs',columns:'id,action,argument',allow:['get_pc_resources','get_bridge_tasks','inspect_windows_service']},
 workspace:{table:'workspace_jobs',columns:'id,action,filename',allow:['list_workspace_files','read_workspace_text']},
 projects:{table:'project_jobs',columns:'id,action,args_json',allow:['list_project_files','read_project_text']}
});
const PILOT_STAGE_D1='00000000-0000-4000-8000-000000000008';
const PILOT_STAGE_VERSION='00000000-0000-4000-8000-000000000007';
const PILOT_STAGE_RELEASE='staging-j1dev-read-v1';
const PILOT_STAGE_ORIGIN='https://staging-worker.example.invalid';
function pilotStageMatches(env){return env.AIMB_STAGING_D1_UUID===PILOT_STAGE_D1&&env.AIMB_STAGING_BASELINE_VERSION===PILOT_STAGE_VERSION&&env.AIMB_STAGE_RELEASE_ID===PILOT_STAGE_RELEASE;}
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
    x.agent_version!=='0.7.0'||x.device_id!=='fixture-device-example'||x.purpose!=='batch_poll'||
    x.recovery_mode!==undefined&&x.recovery_mode!=='leased_first'||
    !Array.isArray(x.channels)||x.channels.length<1||x.channels.length>5||new Set(x.channels).size!==x.channels.length||
    !x.channels.every(y=>typeof y==='string'&&Object.hasOwn(J1H_QUEUE,y)))return json({error:'invalid_shape'},400);
 const t=req.headers.get('x-bridge-timestamp')||'',n=req.headers.get('x-bridge-nonce')||'',sig=req.headers.get('x-bridge-signature')||'',now=Math.floor(Date.now()/1000);
 if(!/^[0-9]{10,12}$/.test(t)||!re.test(n)||!/^[A-Za-z0-9_-]{200,1000}$/.test(sig)||Math.abs(now-Number(t))>90)return json({error:'bad_signature'},401);
 const role=await verifyStagingAgentSignature(req,env,t+'\n'+n+'\nPOST /agent/batch/poll\n'+raw);
 if(!role)return json({error:'bad_signature'},401);
 if(role==='pilot'&&!pilotStageMatches(env))return json({error:'pilot_stage_identity_mismatch'},503);
 if(role==='pilot'&&(x.channels.length!==1||x.channels[0]!=='projects'))return json({error:'pilot_scope_rejected'},403);
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

const json = (value, status = 200) => new Response(JSON.stringify(value), { status, headers: { 'content-type': 'application/json', 'cache-control': 'no-store', 'x-content-type-options': 'nosniff' } });
const re = /^[A-Za-z0-9_-]{16,64}$/;
const device = 'fixture-device-example';
async function auth(req, env) {
 const timestamp = req.headers.get('x-bridge-timestamp') || '';
 const nonce = req.headers.get('x-bridge-nonce') || '';
 if (!/^\d{10,12}$/.test(timestamp) || !re.test(nonce) || Math.abs(Date.now()/1000-Number(timestamp)) > 90) return null;
 const route = new URL(req.url).pathname;
 const role = await verifyStagingAgentSignature(req, env, timestamp+'\n'+nonce+'\n'+req.method+' '+route+'\n'+device);
 return role ? { nonce, role } : null;
}
export class StageSocket {
 constructor(state, env) { this.state = state; this.env = env; }
 async fetch(req) {
  if (req.headers.get('x-stage-internal') !== this.env.STAGE_INTERNAL) return json({ error: 'unauthorized' }, 401);
  const path = new URL(req.url).pathname;
  if (path === '/consume-poll') {
   if (req.method !== 'POST') return json({ error: 'method' }, 405);
   const nonce = req.headers.get('x-stage-nonce'); if (!re.test(nonce || '')) return json({ error: 'nonce' }, 400);
   try {
    const db = this.state.storage.sql, now = Math.floor(Date.now()/1000);
    db.exec('CREATE TABLE IF NOT EXISTS poll_nonces(nonce TEXT PRIMARY KEY,seen_at INTEGER NOT NULL)');
    const inserted = db.exec('INSERT OR IGNORE INTO poll_nonces(nonce,seen_at) VALUES (?,?) RETURNING nonce', nonce, now).toArray();
    if (inserted.length !== 1) return json({ error: 'replay' }, 409);
    if (now % 3600 < 60) db.exec('DELETE FROM poll_nonces WHERE seen_at<?', now-240);
    return json({ ok: true });
   } catch { return json({ error: 'nonce_unavailable' }, 503); }
  }
  if (path === '/connect') {
   const nonce = req.headers.get('x-stage-nonce'); if (!re.test(nonce || '')) return json({ error: 'nonce' }, 400);
   const seen = await this.state.storage.get('seen') || [], recent = seen.filter(x => Date.now()-x.t < 180000);
   if (recent.some(x => x.n === nonce)) return json({ error: 'replay' }, 409);
   recent.push({ n: nonce, t: Date.now() }); await this.state.storage.put('seen', recent.slice(-256));
   for (const socket of this.state.getWebSockets()) socket.close(4001, 'replaced');
   const pair = new WebSocketPair(), [client, server] = Object.values(pair); this.state.acceptWebSocket(server);
   return new Response(null, { status: 101, webSocket: client });
  }
  if (path === '/notify') {
   const nonce = req.headers.get('x-stage-nonce'); if (!re.test(nonce || '')) return json({ error: 'nonce' }, 400);
   const seen = await this.state.storage.get('notify_nonces') || [], recent = seen.filter(x => Date.now()-x.t < 180000);
   if (recent.some(x => x.n === nonce)) return json({ error: 'replay' }, 409);
   recent.push({ n: nonce, t: Date.now() }); await this.state.storage.put('notify_nonces', recent.slice(-256));
   let delivered = 0; for (const socket of this.state.getWebSockets()) if (socket.readyState === 1) { socket.send(JSON.stringify({ type: 'pending', channel: 'projects' })); delivered++; }
   return json({ ok: true, delivered });
  }
  return json({ error: 'not_found' }, 404);
 }
 webSocketMessage(socket, message) { if (message === 'ping') socket.send('pong'); else socket.close(1008, 'unsupported'); }
 webSocketClose(socket, code, reason) { try { socket.close(code, reason); } catch {} }
}
export default {
 async fetch(req, env) {
  const url = new URL(req.url);
  if (req.method === 'GET' && url.pathname === '/.well-known/oauth-protected-resource') return url.origin===PILOT_STAGE_ORIGIN?json({ resource: 'https://staging-worker.example.invalid/mcp', authorization_servers: ['https://tenant.example.auth0.com/'], scopes_supported: ['bridge.read'], bearer_methods_supported: ['header'] }):json({error:'not_found'},404);
  if (url.pathname === '/mcp') return createStagingMcpWorker().fetch(req, env);
  if (url.pathname === '/mcp/identity') {
   if (env.AIMB_J1H_IDENTITY_PREFLIGHT_ENABLED !== 'true') return json({ error: 'not_found' }, 404);
   if (url.origin!==PILOT_STAGE_ORIGIN||!pilotStageMatches(env)) return json({ error: 'pilot_stage_identity_mismatch' }, 503);
   return stagingIdentityPreflight(req);
  }
  if (req.method === 'GET' && url.pathname === '/health') {
   const result = await env.STAGING_DB.prepare('SELECT 1 AS ok').first();
   return json({ stage: 'j1h-isolated', d1: result?.ok === 1, do_bound: !!env.STAGING_DO, production: false });
  }
  if (url.pathname === '/agent/batch/poll') return j1hBatch(req, env);
  if (['/agent/batch/result', '/agent/batch/result-status'].includes(url.pathname)) return handleReadResult(req, env, url.pathname);
  if (!['/agent/realtime', '/staging/notify'].includes(url.pathname)) return json({ error: 'not_found' }, 404);
  if (url.pathname === '/agent/realtime' && (req.method !== 'GET' || req.headers.get('upgrade')?.toLowerCase() !== 'websocket')) return json({ error: 'upgrade_required' }, 426);
  if (url.pathname === '/staging/notify' && req.method !== 'POST') return json({ error: 'method' }, 405);
  const authResult = await auth(req, env); if (!authResult) return json({ error: 'unauthorized' }, 401);
  if (authResult.role === 'pilot' && !pilotStageMatches(env)) return json({ error: 'pilot_stage_identity_mismatch' }, 503);
  if (url.pathname === '/staging/notify' && authResult.role === 'pilot') return json({ error: 'pilot_scope_rejected' }, 403);
  const stub = env.STAGING_DO.get(env.STAGING_DO.idFromName(device));
  if (url.pathname === '/agent/realtime') return stub.fetch('https://internal/connect', { headers: { upgrade: 'websocket', 'x-stage-internal': env.STAGE_INTERNAL, 'x-stage-nonce': authResult.nonce } });
  return stub.fetch('https://internal/notify', { method: 'POST', headers: { 'x-stage-internal': env.STAGE_INTERNAL, 'x-stage-nonce': authResult.nonce } });
 }
};
