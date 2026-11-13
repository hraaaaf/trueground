import { test } from 'node:test';
import assert from 'node:assert/strict';
import { generateKeyPairSync, sign, constants, randomBytes } from 'node:crypto';

const subject = 'auth0|fixture-authorized-subject';
const issuer = 'https://tenant.example.auth0.com/';
const audience = 'https://staging-worker.example.invalid/mcp';
const { privateKey, publicKey } = generateKeyPairSync('rsa', { modulusLength: 2048 });
const jwk = publicKey.export({ format: 'jwk' }); Object.assign(jwk, { kid: 'router-test-kid', use: 'sig', alg: 'RS256' });
const legacyAgent = generateKeyPairSync('rsa', { modulusLength: 2048 });
const legacyJwk = legacyAgent.publicKey.export({format:'jwk'}); Object.assign(legacyJwk,{kid:'legacy-v7-test',use:'sig',alg:'RS256'});
const pilotAgent = generateKeyPairSync('rsa', { modulusLength: 2048 });
const pilotJwk = pilotAgent.publicKey.export({format:'jwk'}); Object.assign(pilotJwk,{kid:'pilot-j1dev-test',use:'sig',alg:'RS256'});
const originalFetch = globalThis.fetch;
globalThis.fetch = async url => { assert.equal(url, 'https://tenant.example.auth0.com/.well-known/jwks.json'); return Response.json({ keys: [jwk] }); };
const { default: worker } = await import('./worker.js');
globalThis.fetch = originalFetch;

function token() {
  const encode = x => Buffer.from(JSON.stringify(x)).toString('base64url');
  const h = encode({ alg: 'RS256', kid: 'router-test-kid', typ: 'JWT' });
  const p = encode({ iss: issuer, aud: audience, sub: subject, scope: 'bridge.read', iat: Math.floor(Date.now() / 1000), exp: Math.floor(Date.now() / 1000) + 300 });
  const input = `${h}.${p}`; return `${input}.${sign('RSA-SHA256', Buffer.from(input), { key: privateKey }).toString('base64url')}`;
}
function env() {
  const stats={d1Reads:0,d1Writes:0,sql:[]};
  return {
    AIMB_J1H_ALLOWED_SUB: subject, AIMB_STAGING_D1_UUID: '00000000-0000-4000-8000-000000000008',
    AIMB_STAGING_BASELINE_VERSION: '00000000-0000-4000-8000-000000000007',
    AIMB_STAGE_RELEASE_ID: 'staging-j1dev-read-v1', AIMB_J1H_PILOT_ENABLED: 'true', STAGE_INTERNAL: 'test-only',
    STAGING_PUB_JWK:JSON.stringify(legacyJwk), AIMB_J1H_PILOT_PUB_JWK:JSON.stringify(pilotJwk),
    STAGING_DB: { prepare: sql => ({ bind(){return this;}, async run(){stats.d1Writes++;return {meta:{changes:1}};}, async first(){stats.d1Reads++;stats.sql.push(sql);return sql.includes('SELECT 1 AS ok')?{ok:1}:null;} }) },
    STAGING_DO: { idFromName: x => x, get: () => ({ fetch: async () => new Response('', { status: 200 }) }) }
    ,stats
  };
}
const req = (path, body) => new Request(`https://staging-worker.example.invalid${path}`, { method: 'POST', headers: { authorization: `Bearer ${token()}`, 'content-type': 'application/json' }, body: JSON.stringify(body) });
function signedAgentReq(key,path,body,{method='POST',device='fixture-device-example'}={}){
  const raw=body===undefined?'':JSON.stringify(body),timestamp=String(Math.floor(Date.now()/1000)),nonce=randomBytes(18).toString('base64url');
  const canonical=`${timestamp}\n${nonce}\n${method} ${path}\n${method==='GET'||path==='/staging/notify'?device:raw}`;
  const signature=sign('RSA-SHA256',Buffer.from(canonical),{key,padding:constants.RSA_PKCS1_PADDING}).toString('base64url');
  return new Request(`https://staging-worker.example.invalid${path}`,{method,headers:{'content-type':'application/json','x-bridge-timestamp':timestamp,'x-bridge-nonce':nonce,'x-bridge-signature':signature,...(path==='/agent/realtime'?{upgrade:'websocket'}:{})},...(method==='POST'?{body:raw}:{})});
}

test('V7 main Worker router dispatches MCP / initialize and preserves existing health route', async () => {
  const e = env();
  const r = await worker.fetch(req('/mcp', { jsonrpc: '2.0', id: 'init', method: 'initialize', params: { protocolVersion: '2025-03-26', capabilities: {}, clientInfo: { name: 'test', version: '1' } } }), e);
  assert.equal(r.status, 200); assert.equal(r.headers.get('mcp-protocol-version'), '2025-03-26');
  const body = await r.json(); assert.equal(body.result.serverInfo.name, 'aimb-j1-dev-staging-read-only');
  const health = await worker.fetch(new Request('https://staging-worker.example.invalid/health'), e);
  assert.equal(health.status, 200); assert.equal((await health.json()).production, false);
});

test('integrated MCP router lists only the two read tools and keeps agent endpoints separate', async () => {
  const e = env();
  const r = await worker.fetch(req('/mcp', { jsonrpc: '2.0', id: 1, method: 'tools/list' }), e);
  assert.equal(r.status, 200); assert.deepEqual((await r.json()).result.tools.map(x => x.name).sort(), ['list_dev_project_files', 'read_dev_project_file']);
  assert.equal((await worker.fetch(new Request('https://staging-worker.example.invalid/mcp/anything'), e)).status, 404);
});

test('verified identity preflight returns Auth0 sub without touching D1',async()=>{
 const e=env();e.AIMB_J1H_IDENTITY_PREFLIGHT_ENABLED='true';const before={...e.stats};
 const response=await worker.fetch(new Request('https://staging-worker.example.invalid/mcp/identity',{headers:{authorization:`Bearer ${token()}`}}),e);
 assert.equal(response.status,200);const body=await response.json();assert.equal(body.verified,true);assert.equal(body.sub,subject);assert.equal(body.issuer,issuer);assert.equal(body.d1_read,undefined);assert.deepEqual(e.stats,before);
 const bad=await worker.fetch(new Request('https://staging-worker.example.invalid/mcp/identity',{headers:{authorization:'Bearer a.b.c'}}),e);assert.equal(bad.status,401);assert.deepEqual(e.stats,before);
});

test('OAuth protected-resource metadata is pinned to J1H Auth0 audience and bridge.read',async()=>{
 const e=env();const response=await worker.fetch(new Request('https://staging-worker.example.invalid/.well-known/oauth-protected-resource'),e);
 assert.equal(response.status,200);assert.equal(response.headers.get('cache-control'),'no-store');
 assert.deepEqual(await response.json(),{resource:audience,authorization_servers:[issuer],scopes_supported:['bridge.read'],bearer_methods_supported:['header']});
 assert.deepEqual(e.stats,{d1Reads:0,d1Writes:0,sql:[]});
 const wrongOrigin=await worker.fetch(new Request('https://production.example/.well-known/oauth-protected-resource'),e);assert.equal(wrongOrigin.status,404);
});

test('MCP tools declare OAuth scope and unauthorized calls return an auth challenge without D1 access',async()=>{
 const e=env();const list=await worker.fetch(new Request('https://staging-worker.example.invalid/mcp',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({jsonrpc:'2.0',id:4,method:'tools/list'})}),e);
 assert.equal(list.status,200);const listed=(await list.json()).result.tools;assert.equal(listed.length,2);assert.deepEqual(listed.map(x=>x._meta.securitySchemes),Array(2).fill([{type:'oauth2',scopes:['bridge.read']} ]));
 const called=await worker.fetch(new Request('https://staging-worker.example.invalid/mcp',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({jsonrpc:'2.0',id:5,method:'tools/call',params:{name:'read_dev_project_file',arguments:{project_id:'bridge-agent',path:'README.md'}}})}),e);
 assert.equal(called.status,200);const call=await called.json();assert.equal(call.result.isError,true);assert.ok(call.result._meta['mcp/www_authenticate'].length===1);assert.match(call.result._meta['mcp/www_authenticate'][0],/resource_metadata=.*error="invalid_token".*error_description=/);
 const authed=await worker.fetch(req('/mcp',{jsonrpc:'2.0',id:6,method:'tools/list'}),e);const tools=(await authed.json()).result.tools;
 assert.deepEqual(tools.map(x=>x._meta.securitySchemes),Array(2).fill([{type:'oauth2',scopes:['bridge.read']} ]));assert.deepEqual(e.stats,{d1Reads:0,d1Writes:0,sql:[]});
});

test('identity preflight gives a protected-resource challenge before returning any subject',async()=>{
 const e=env();e.AIMB_J1H_IDENTITY_PREFLIGHT_ENABLED='true';const response=await worker.fetch(new Request('https://staging-worker.example.invalid/mcp/identity'),e);
 assert.equal(response.status,401);assert.match(response.headers.get('www-authenticate'),/scope="bridge.read"/);assert.deepEqual(e.stats,{d1Reads:0,d1Writes:0,sql:[]});
});

test('MCP identity preflight is conditionally listed and has no D1 dependency or write',async()=>{
 const e=env();e.AIMB_J1H_IDENTITY_PREFLIGHT_ENABLED='true';const before={...e.stats};
 const list=await worker.fetch(req('/mcp',{jsonrpc:'2.0',id:11,method:'tools/list'}),e);assert.equal(list.status,200);
 assert.deepEqual((await list.json()).result.tools.map(x=>x.name),['aimb_identity_preflight','list_dev_project_files','read_dev_project_file']);
 const result=await worker.fetch(req('/mcp',{jsonrpc:'2.0',id:12,method:'tools/call',params:{name:'aimb_identity_preflight',arguments:{}}}),e);
 assert.equal(result.status,200);assert.equal((await result.json()).result.structuredContent.sub,subject);assert.deepEqual(e.stats,before);
});

test('identity-only OAuth phase does not expose project reads before pilot enablement',async()=>{
 const e=env();e.AIMB_J1H_IDENTITY_PREFLIGHT_ENABLED='true';e.AIMB_J1H_PILOT_ENABLED='false';const before={...e.stats};
 const response=await worker.fetch(req('/mcp',{jsonrpc:'2.0',id:17,method:'tools/list'}),e);
 assert.equal(response.status,200);assert.deepEqual((await response.json()).result.tools.map(x=>x.name),['aimb_identity_preflight']);assert.deepEqual(e.stats,before);
});

test('pilot RSA key is restricted to Projects while the existing V7 key remains accepted',async()=>{
 const e=env();const projectPoll={agent_version:'0.7.0',device_id:'fixture-device-example',purpose:'batch_poll',channels:['projects']};
 const pilotResponse=await worker.fetch(signedAgentReq(pilotAgent.privateKey,'/agent/batch/poll',projectPoll),e);assert.equal(pilotResponse.status,200);
 assert.deepEqual(Object.keys((await pilotResponse.json()).channels),['projects']);
 const commandsPoll={...projectPoll,channels:['commands']};
 const denied=await worker.fetch(signedAgentReq(pilotAgent.privateKey,'/agent/batch/poll',commandsPoll),e);assert.equal(denied.status,403);
 const legacy=await worker.fetch(signedAgentReq(legacyAgent.privateKey,'/agent/batch/poll',commandsPoll),e);assert.equal(legacy.status,200);
 assert.deepEqual(e.stats.sql.filter(x=>x.includes('FROM')),['SELECT id,action,args_json FROM project_jobs WHERE device_id=? AND status=\'pending\' AND expires_at>? AND action IN (?,?) ORDER BY created_at LIMIT 1','SELECT id,action FROM commands WHERE device_id=? AND status=\'pending\' AND expires_at>? AND action IN (?) ORDER BY created_at LIMIT 1']);
});

test('pilot RSA refuses any environment not pinned to staging V7 and its D1 UUID',async()=>{
 const e=env();e.AIMB_STAGING_D1_UUID='production-id';
 const poll={agent_version:'0.7.0',device_id:'fixture-device-example',purpose:'batch_poll',channels:['projects']};
 const response=await worker.fetch(signedAgentReq(pilotAgent.privateKey,'/agent/batch/poll',poll),e);assert.equal(response.status,503);
 assert.equal(e.stats.d1Writes,0);
});

test('pilot RSA cannot write file-channel results or send public staging notifications',async()=>{
 const e=env();const result={agent_version:'0.7.0',device_id:'fixture-device-example',purpose:'batch_result',channel:'files',job_id:'f20b9291-7a39-4854-a21c-cc7b9a240002',action:'read_authorized_text',result:{ok:true}};
 const denied=await worker.fetch(signedAgentReq(pilotAgent.privateKey,'/agent/batch/result',result),e);assert.equal(denied.status,403);assert.equal(e.stats.d1Writes,0);
 const notify=await worker.fetch(signedAgentReq(pilotAgent.privateKey,'/staging/notify',{}),e);assert.equal(notify.status,403);
});
