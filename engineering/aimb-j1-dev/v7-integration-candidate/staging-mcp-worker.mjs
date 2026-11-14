/* Staging-only MCP bridge candidate. Not deployed. */
export const STAGING_BASELINE_VERSION = '00000000-0000-4000-8000-000000000007';
export const STAGING_D1_UUID = '00000000-0000-4000-8000-000000000008';
export const STAGING_ISSUER = 'https://tenant.example.auth0.com/';
export const STAGING_AUDIENCE = 'https://staging-worker.example.invalid/mcp';
export const STAGING_ORIGIN = 'https://staging-worker.example.invalid';
const DEVICE_ID = 'fixture-device-example';
const PROJECT_ID = 'bridge-agent';
const POLL_TIMEOUT_MS = 60_000;
const RESULT_MAX_BYTES = 64 * 1024;
const te = new TextEncoder();
const OAUTH_SCHEMES=Object.freeze([Object.freeze({type:'oauth2',scopes:Object.freeze(['bridge.read'])})]);
const TOOL_DEFS = Object.freeze([
  Object.freeze({ name: 'list_dev_project_files', description: 'List allowlisted fixture project files (read-only).', inputSchema: { type: 'object', additionalProperties: false, properties: { project_id: { type: 'string', const: PROJECT_ID }, offset: { type: 'integer', minimum: 0, maximum: 9999 }, limit: { type: 'integer', minimum: 1, maximum: 100 } }, required: ['project_id'] }, _meta:{securitySchemes:OAUTH_SCHEMES} }),
  Object.freeze({ name: 'read_dev_project_file', description: 'Read one bounded UTF-8 fixture project file (read-only).', inputSchema: { type: 'object', additionalProperties: false, properties: { project_id: { type: 'string', const: PROJECT_ID }, path: { type: 'string', minLength: 1, maxLength: 240 } }, required: ['project_id', 'path'] }, _meta:{securitySchemes:OAUTH_SCHEMES} })
]);
const ALLOWED = new Set(TOOL_DEFS.map(x => x.name));
const IDENTITY_TOOL=Object.freeze({name:'aimb_identity_preflight',description:'Return the signed-in Auth0 subject only after RS256, issuer, audience, scope and time validation. No D1 access or writes.',inputSchema:{type:'object',additionalProperties:false,properties:{}},_meta:{securitySchemes:OAUTH_SCHEMES}});
const b64u = s => Uint8Array.from(atob(s.replace(/-/g, '+').replace(/_/g, '/') + '='.repeat((4 - s.length % 4) % 4)), c => c.charCodeAt(0));
const decodeJson = s => JSON.parse(new TextDecoder().decode(b64u(s)));
const b64 = b => btoa(String.fromCharCode(...new Uint8Array(b))).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/g, '');
const fail = code => { throw new Error(code); };
const isObj = x => x !== null && typeof x === 'object' && !Array.isArray(x);

export function createAuth0JwtVerifier({ fetchImpl = fetch, now = () => Date.now(), cacheMs = 600_000 } = {}) {
  let keys = null, fetchedAt = 0, pending;
  async function getKeys() {
    if (keys && now() - fetchedAt < cacheMs) return keys;
    if (!pending) pending = (async () => {
      const jwksUrl = new URL('.well-known/jwks.json', STAGING_ISSUER).href;
      const response = await fetchImpl(jwksUrl, { headers: { accept: 'application/json' }, redirect: 'error' });
      if (!response.ok) fail('JWKS_UNAVAILABLE');
      const doc = await response.json();
      if (!Array.isArray(doc.keys) || doc.keys.length > 20) fail('JWKS_INVALID');
      const imported = new Map();
      for (const jwk of doc.keys) if (jwk.kty === 'RSA' && jwk.use !== 'enc' && (!jwk.alg || jwk.alg === 'RS256') && typeof jwk.kid === 'string') {
        imported.set(jwk.kid, await crypto.subtle.importKey('jwk', jwk, { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' }, false, ['verify']));
      }
      keys = imported; fetchedAt = now(); return keys;
    })().finally(() => { pending = null; });
    return pending;
  }
  return async function verifyJwt(token, { expectedSubject, nowSec = Math.floor(now() / 1000) } = {}) {
    if (typeof token !== 'string' || token.length > 8192) fail('TOKEN_INVALID');
    const parts = token.split('.'); if (parts.length !== 3) fail('TOKEN_INVALID');
    const [h, p, s] = parts; let header, claims;
    try { header = decodeJson(h); claims = decodeJson(p); } catch { fail('TOKEN_INVALID'); }
    if (!isObj(header) || header.alg !== 'RS256' || typeof header.kid !== 'string' || !isObj(claims)) fail('TOKEN_POLICY_REJECTED');
    const key = (await getKeys()).get(header.kid); if (!key) fail('TOKEN_KEY_UNKNOWN');
    const good = await crypto.subtle.verify('RSASSA-PKCS1-v1_5', key, b64u(s), te.encode(`${h}.${p}`));
    if (!good) fail('TOKEN_SIGNATURE_INVALID');
    const audOk = claims.aud === STAGING_AUDIENCE || Array.isArray(claims.aud) && claims.aud.includes(STAGING_AUDIENCE);
    const scopes = typeof claims.scope === 'string' ? claims.scope.split(/\s+/) : [];
    if (claims.iss !== STAGING_ISSUER || !audOk || typeof claims.sub !== 'string' || claims.sub.length < 3 || claims.sub.length > 160 || expectedSubject !== undefined && claims.sub !== expectedSubject || !scopes.includes('bridge.read')) fail('TOKEN_CLAIMS_REJECTED');
    if (!Number.isSafeInteger(claims.exp) || claims.exp <= nowSec || claims.nbf !== undefined && (!Number.isSafeInteger(claims.nbf) || claims.nbf > nowSec + 30) || claims.iat !== undefined && (!Number.isSafeInteger(claims.iat) || claims.iat > nowSec + 30 || nowSec - claims.iat > 86_400)) fail('TOKEN_TIME_REJECTED');
    return Object.freeze({ verified: true, sub: claims.sub, iss: claims.iss, aud: claims.aud, scope: scopes, exp: claims.exp });
  };
}
const defaultAuth0Verifier = createAuth0JwtVerifier();

export async function verifyStagingBearer(request,{verifyBearer=defaultAuth0Verifier,expectedSubject}={}){
  const match=/^Bearer ([A-Za-z0-9._~-]{8,8192})$/.exec(request.headers.get('authorization')||'');
  if(!match)fail('BEARER_REQUIRED');
  const identity=await verifyBearer(match[1],expectedSubject===undefined?{}:{expectedSubject});
  if(!identity?.verified||typeof identity.sub!=='string')fail('BEARER_NOT_VERIFIED');
  return identity;
}

const RESOURCE_METADATA_URL=`${STAGING_ORIGIN}/.well-known/oauth-protected-resource`;
const OAUTH_CHALLENGE=`Bearer resource_metadata="${RESOURCE_METADATA_URL}", scope="bridge.read"`;
function responseJson(body, status = 200, extraHeaders = {}) { return Response.json(body, { status, headers: { 'cache-control': 'no-store', 'x-content-type-options': 'nosniff', 'mcp-protocol-version': '2025-03-26', ...extraHeaders } }); }
export async function stagingIdentityPreflight(request,{verifyBearer}={}){
  if(request.method!=='GET'||request.body!==null)return responseJson({error:'method_not_allowed'},405);
  try{const identity=await verifyStagingBearer(request,{verifyBearer});return responseJson({verified:true,sub:identity.sub,issuer:identity.iss,audience:identity.aud,scopes:identity.scope,expires_at:identity.exp});}
  catch{return responseJson({error:'identity_unverified'},401,{'www-authenticate':OAUTH_CHALLENGE});}
}
async function readBoundedBody(request, maxBytes) {
  if (!request.body) return '';
  const reader = request.body.getReader(), chunks = []; let total = 0;
  try {
    for (;;) {
      const { value, done } = await reader.read(); if (done) break;
      total += value.byteLength;
      if (total > maxBytes) { await reader.cancel('body limit exceeded').catch(() => {}); fail('REQUEST_TOO_LARGE'); }
      chunks.push(value);
    }
  } finally { reader.releaseLock(); }
  const bytes = new Uint8Array(total); let offset = 0;
  for (const chunk of chunks) { bytes.set(chunk, offset); offset += chunk.byteLength; }
  try { return new TextDecoder('utf-8', { fatal: true }).decode(bytes); } catch { fail('REQUEST_UTF8_INVALID'); }
}
function rpc(id, result) { return { jsonrpc: '2.0', id, result }; }
function rpcError(id, code, message) { return { jsonrpc: '2.0', id: id ?? null, error: { code, message } }; }
function validateTool(name, args) {
  if (!ALLOWED.has(name) || !isObj(args) || args.project_id !== PROJECT_ID) fail('TOOL_NOT_ALLOWLISTED');
  if (name === 'list_dev_project_files') {
    if (Object.keys(args).some(k => !['project_id', 'offset', 'limit'].includes(k))) fail('ARGUMENTS_INVALID');
    const offset = args.offset ?? 0, limit = args.limit ?? 50;
    if (!Number.isInteger(offset) || offset < 0 || offset > 9999 || !Number.isInteger(limit) || limit < 1 || limit > 100) fail('ARGUMENTS_INVALID');
    return { action: 'list_project_files', args: { offset, limit } };
  }
  if (Object.keys(args).some(k => !['project_id', 'path'].includes(k)) || typeof args.path !== 'string' || args.path.length > 240 || args.path.startsWith('/') || args.path.includes(':')) fail('PROJECT_PATH_INVALID');
  const path = args.path.replaceAll('\\', '/');
  const segments = path.split('/');
  if (path !== args.path || segments.some(x => !x || x === '.' || x === '..' || /[. ]$/.test(x) || /^(con|prn|aux|nul|com[1-9]|lpt[1-9])(?:\..*)?$/i.test(x)) || path.includes('\0')) fail('PROJECT_PATH_INVALID');
  return { action: 'read_project_text', args: { path } };
}

export function createProjectReadQueue({ env, verifyBearer, now = () => Date.now(), sleep = ms => new Promise(r => setTimeout(r, ms)), pollEveryMs = 2000 }) {
  const db = env?.STAGING_DB;
  if (!db || typeof db.prepare !== 'function') fail('STAGING_D1_BINDING_REQUIRED');
  const pinnedSubject = env.AIMB_J1H_ALLOWED_SUB;
  if (typeof pinnedSubject !== 'string' || pinnedSubject.length < 3 || pinnedSubject.length > 160) fail('STAGING_SUBJECT_NOT_CONFIGURED');
  if (env.AIMB_STAGING_D1_UUID !== STAGING_D1_UUID || env.AIMB_STAGING_BASELINE_VERSION !== STAGING_BASELINE_VERSION || env.AIMB_STAGE_RELEASE_ID !== 'staging-j1dev-read-v1') fail('STAGING_IDENTITY_MISMATCH');
  if (env.AIMB_J1H_PILOT_ENABLED !== 'true') fail('STAGING_PILOT_DISABLED');
  if (typeof env.STAGE_INTERNAL !== 'string' || !env.STAGE_INTERNAL || !env.STAGING_DO) fail('STAGING_WAKE_BINDING_REQUIRED');
  const verify = verifyBearer || defaultAuth0Verifier;
  async function executeRead({ subject, action, args, deadlineMs = POLL_TIMEOUT_MS }) {
    if (subject !== pinnedSubject || !['list_project_files', 'read_project_text'].includes(action)) fail('SUBJECT_OR_ACTION_REJECTED');
    const id = crypto.randomUUID(); const nowSec = Math.floor(now() / 1000); const expires = nowSec + 115;
    const insert = await db.prepare("INSERT INTO project_jobs (id,device_id,requester_sub,action,args_json,status,created_at,expires_at) SELECT ?,?,?,?,?, 'pending',?,? WHERE NOT EXISTS (SELECT 1 FROM project_jobs WHERE device_id=? AND requester_sub=? AND status IN ('pending','leased') AND expires_at>?) AND (SELECT COUNT(*) FROM project_jobs WHERE device_id=? AND requester_sub=?)<2")
      .bind(id, DEVICE_ID, subject, action, JSON.stringify(args), nowSec, expires, DEVICE_ID, subject, nowSec, DEVICE_ID, subject).run();
    if (insert?.meta?.changes !== 1) fail('STAGING_READ_ALREADY_ACTIVE_OR_INSERT_FAILED');
    const nonce = b64(crypto.getRandomValues(new Uint8Array(18)));
    try {
      const stub = env.STAGING_DO.get(env.STAGING_DO.idFromName(DEVICE_ID));
      const wake = await stub.fetch('https://internal/notify', { method: 'POST', headers: { 'x-stage-internal': env.STAGE_INTERNAL, 'x-stage-nonce': nonce } });
      void wake; // WSS wake is best-effort; the existing agent's 60 s grouped poll is the bounded fallback.
    } catch { /* bounded polling is fallback */ }
    const deadline = Math.min(now() + Math.min(deadlineMs, POLL_TIMEOUT_MS), expires * 1000 - 48_000);
    while (now() < deadline) {
      const row = await db.prepare('SELECT status,result_json,expires_at,action,args_json FROM project_jobs WHERE id=? AND requester_sub=? AND device_id=? LIMIT 1').bind(id, subject, DEVICE_ID).first();
      if (!row) fail('STAGING_JOB_DISAPPEARED');
      if (row.action !== action || row.args_json !== JSON.stringify(args)) fail('STAGING_JOB_BINDING_MISMATCH');
      if (row.status === 'done') {
        let result; try { result = JSON.parse(row.result_json); } catch { fail('STAGING_RESULT_INVALID'); }
        if (!isObj(result) || result.ok !== true || te.encode(JSON.stringify(result)).byteLength > RESULT_MAX_BYTES) fail('STAGING_RESULT_REJECTED');
        return result;
      }
      if (row.status !== 'pending' && row.status !== 'leased') fail('STAGING_JOB_TERMINAL');
      if (Number(row.expires_at) <= Math.floor(now() / 1000) + 48) fail('STAGING_TTL_MARGIN_EXHAUSTED');
      await sleep(Math.min(pollEveryMs, Math.max(1, deadline - now())));
    }
    fail('STAGING_READ_TIMEOUT');
  }
  return Object.freeze({
    async authenticate(request) {
      const match = /^Bearer ([A-Za-z0-9._~-]{8,8192})$/.exec(request.headers.get('authorization') || '');
      if (!match) fail('BEARER_REQUIRED');
      return verify(match[1], { expectedSubject: pinnedSubject });
    },
    async executeRead(params) { return executeRead(params); }
  });
}

export function createStagingMcpWorker({ verifyBearer, now = () => Date.now(), sleep } = {}) {
  return Object.freeze({ async fetch(request, env) {
    const url = new URL(request.url);
    if (url.origin !== STAGING_ORIGIN || url.pathname !== '/mcp') return new Response('not found', { status: 404 });
    if (request.method !== 'POST') return new Response('', { status: 405, headers: { allow: 'POST', 'cache-control': 'no-store' } });
    if (request.headers.get('content-type')?.split(';')[0].trim().toLowerCase() !== 'application/json') return new Response('unsupported media type', { status: 415 });
    const contentLength = Number(request.headers.get('content-length') || 0);
    if (Number.isFinite(contentLength) && contentLength > 16 * 1024) return new Response('request too large', { status: 413 });
    let raw; try { raw = await readBoundedBody(request, 16 * 1024); } catch (e) { return new Response(e?.message === 'REQUEST_TOO_LARGE' ? 'request too large' : 'invalid body', { status: e?.message === 'REQUEST_TOO_LARGE' ? 413 : 400 }); }
    let message; try { message = JSON.parse(raw); } catch { return new Response('invalid json', { status: 400 }); }
    if (isObj(message) && message.jsonrpc === '2.0' && message.method === 'notifications/initialized' && !Object.hasOwn(message, 'id')) {
      return new Response(null, { status: 202, headers: { 'cache-control': 'no-store', 'mcp-protocol-version': '2025-03-26' } });
    }
    if (!isObj(message) || message.jsonrpc !== '2.0' || !Object.hasOwn(message, 'id') || typeof message.method !== 'string') return responseJson(rpcError(null, -32600, 'Invalid Request'), 400);
    let rpcId = message.id;
    try {
      if (message.method === 'initialize' || message.method === 'ping' || message.method === 'tools/list') {
        if (message.method === 'initialize') return responseJson(rpc(message.id, { protocolVersion: '2025-03-26', capabilities: { tools: {} }, serverInfo: { name: 'aimb-j1-dev-staging-read-only', version: '0.2.0' } }));
        if (message.method === 'ping') return responseJson(rpc(message.id, {}));
        const identityEnabled=env.AIMB_J1H_IDENTITY_PREFLIGHT_ENABLED==='true';
        const pilotEnabled=env.AIMB_J1H_PILOT_ENABLED==='true';
        const tools=identityEnabled?(pilotEnabled?[IDENTITY_TOOL,...TOOL_DEFS]:[IDENTITY_TOOL]):TOOL_DEFS;
        return responseJson(rpc(message.id, { tools }));
      }
      if (message.method !== 'tools/call' || !isObj(message.params) || typeof message.params.name !== 'string') return responseJson(rpcError(message.id, -32601, 'Method not found'));
      if(message.params.name==='aimb_identity_preflight'){
        if(env.AIMB_J1H_IDENTITY_PREFLIGHT_ENABLED!=='true')return responseJson(rpcError(message.id,-32602,'IDENTITY_PREFLIGHT_DISABLED'));
        if(!isObj(message.params.arguments??{})||Object.keys(message.params.arguments??{}).length!==0)return responseJson(rpcError(message.id,-32602,'IDENTITY_PREFLIGHT_ARGS_INVALID'));
        const identity=await verifyStagingBearer(request,{verifyBearer});
        const result={verified:true,sub:identity.sub,issuer:identity.iss,audience:identity.aud,scopes:identity.scope,expires_at:identity.exp,d1_read:false,d1_write:false};
        return responseJson(rpc(message.id,{content:[{type:'text',text:JSON.stringify(result)}],structuredContent:result,isError:false}));
      }
      const queue = createProjectReadQueue({ env, verifyBearer, now, ...(sleep ? { sleep } : {}) });
      await queue.authenticate(request);
      const checked = validateTool(message.params.name, message.params.arguments ?? {});
      const identity = await queue.authenticate(request);
      const result = await queue.executeRead({ subject: identity.sub, ...checked, deadlineMs: POLL_TIMEOUT_MS });
      return responseJson(rpc(message.id, { content: [{ type: 'text', text: JSON.stringify(result) }], structuredContent: result, isError: false }));
    } catch (e) {
      const errorText = String(e?.message || 'REQUEST_FAILED').replace(/[^A-Z0-9_:-]/gi, '_').slice(0, 120);
      const auth = /^(BEARER_|TOKEN_|JWKS_|STAGING_SUBJECT_NOT_CONFIGURED)/.test(e?.message || '');
      if(auth&&message.method==='tools/call'){
        const challenge=`Bearer resource_metadata="${RESOURCE_METADATA_URL}", error="invalid_token", error_description="${errorText}"`;
        return responseJson(rpc(rpcId,{content:[{type:'text',text:'Authentication required for this tool.'}],isError:true,_meta:{'mcp/www_authenticate':[challenge]}}));
      }
      if(auth)return responseJson(rpcError(rpcId??null,-32001,'Authentication required'),401,{'www-authenticate':OAUTH_CHALLENGE});
      return responseJson(rpcError(rpcId ?? null, auth ? -32001 : -32000, errorText), auth ? 401 : 200);
    }
  } });
}

export const STAGING_MCP_TOOL_NAMES = Object.freeze([...ALLOWED]);
