import { test } from 'node:test';
import assert from 'node:assert/strict';
import { generateKeyPairSync, sign } from 'node:crypto';
import { createAuth0JwtVerifier, createStagingMcpWorker, STAGING_AUDIENCE, STAGING_D1_UUID, STAGING_ISSUER, STAGING_MCP_TOOL_NAMES, STAGING_ORIGIN, STAGING_BASELINE_VERSION } from './staging-mcp-worker.mjs';

const subject = 'auth0|fixture-authorized-subject';
const now0 = 1_794_512_000_000;
const baseEnv = () => ({
  AIMB_J1H_ALLOWED_SUB: subject, AIMB_STAGING_D1_UUID: STAGING_D1_UUID,
  AIMB_STAGING_BASELINE_VERSION: STAGING_BASELINE_VERSION, AIMB_STAGE_RELEASE_ID: 'staging-j1dev-read-v1',
  AIMB_J1H_PILOT_ENABLED: 'true',
  STAGE_INTERNAL: 'internal-test-only',
  STAGING_DO: { idFromName: n => n, get: () => ({ fetch: async () => new Response('', { status: 200 }) }) }
});

function fixtureDb({ completeOnRead = 1, insertChanges = 1 } = {}) {
  const rows = new Map(); const stats = { inserts: 0, reads: 0, writes: 0, sql: [] };
  const db = { prepare(sql) { stats.sql.push(sql); let values = [];
    return { bind(...args) { values = args; return this; },
      async run() {
        stats.writes++;
        if (sql.startsWith('INSERT INTO project_jobs')) {
          stats.inserts++;
          if (sql.includes('COUNT(*)') && rows.size >= 2) return { meta: { changes: 0 } };
          if (insertChanges !== 1) return { meta: { changes: insertChanges } };
          const [id, device_id, requester_sub, action, args_json, created_at, expires_at] = values;
          rows.set(id, { id, device_id, requester_sub, action, args_json, status: 'pending', created_at, expires_at, result_json: null });
          return { meta: { changes: 1 } };
        }
        throw Error('SQL_MUTATION_NOT_ALLOWLISTED');
      },
      async first() {
        stats.reads++;
        const row = rows.get(values[0]); if (!row || row.requester_sub !== values[1] || row.device_id !== values[2]) return null;
        if (completeOnRead !== Infinity && stats.reads >= completeOnRead) { row.status = 'done'; row.result_json = JSON.stringify({ ok: true, fixture: true, action: row.action, args: JSON.parse(row.args_json) }); }
        return { status: row.status, result_json: row.result_json, expires_at: row.expires_at, action: row.action, args_json: row.args_json };
      }
    };
  } };
  return { db, rows, stats };
}

function request(body, token = 'valid-token-0001') { return new Request(`${STAGING_ORIGIN}/mcp`, { method: 'POST', headers: { authorization: `Bearer ${token}`, 'content-type': 'application/json' }, body: JSON.stringify(body) }); }
const rpc = (id, method, params) => ({ jsonrpc: '2.0', id, method, ...(params ? { params } : {}) });
const responseBody = async r => ({ status: r.status, body: await r.json() });
function workerFor({ completeOnRead = 1, insertChanges = 1, verifyBearer = async t => t === 'valid-token-0001' ? { sub: subject } : (() => { throw Error('TOKEN_SIGNATURE_INVALID'); })(), timeRef = { now: now0 } } = {}) {
  const { db, rows, stats } = fixtureDb({ completeOnRead, insertChanges });
  const env = { ...baseEnv(), STAGING_DB: db };
  const wakes = [];
  env.STAGING_DO.get = () => ({ fetch: async (url, init) => { wakes.push({ url: String(url), headers: init.headers }); return new Response('', { status: 200 }); } });
  const worker = createStagingMcpWorker({ verifyBearer, now: () => timeRef.now, sleep: async ms => { timeRef.now += ms; } });
  return { worker, env, rows, stats, wakes, timeRef };
}

test('Worker MCP exposes exactly two staging read tools', async () => {
  const f = workerFor(); const { status, body } = await responseBody(await f.worker.fetch(request(rpc(1, 'tools/list')), f.env));
  assert.equal(status, 200); assert.deepEqual(body.result.tools.map(x => x.name).sort(), [...STAGING_MCP_TOOL_NAMES].sort());
  assert.deepEqual([...STAGING_MCP_TOOL_NAMES].sort(), ['list_dev_project_files', 'read_dev_project_file']);
  assert.equal(f.stats.writes, 0);
});

test('read tool becomes one staging project job, wakes agent, and returns persisted result', async () => {
  const f = workerFor();
  const res = await responseBody(await f.worker.fetch(request(rpc('req-list', 'tools/call', { name: 'list_dev_project_files', arguments: { project_id: 'bridge-agent', offset: 0, limit: 20 } })), f.env));
  assert.equal(res.status, 200); assert.equal(res.body.result.isError, false);
  const [job] = [...f.rows.values()]; assert.ok(job); assert.equal(f.rows.size, 1);
  assert.equal(job.action, 'list_project_files'); assert.deepEqual(JSON.parse(job.args_json), { offset: 0, limit: 20 });
  assert.equal(job.device_id, 'fixture-device-example'); assert.equal(job.requester_sub, subject); assert.equal(job.status, 'done');
  assert.equal(job.expires_at - job.created_at, 115); assert.equal(f.wakes.length, 1); assert.match(f.wakes[0].url, /internal\/notify$/);
  assert.equal(f.stats.writes, 1); assert.ok(f.stats.reads >= 1); assert.ok(f.stats.sql.every(s => /project_jobs/.test(s)));
});

test('file-read path validation is strict and performs no D1 write', async () => {
  for (const path of ['../outside', 'a/../b', '/absolute', 'C:\\Windows\\win.ini', 'a//b', '.', 'CON', 'folder/name.']) {
    const f = workerFor();
    const r = await responseBody(await f.worker.fetch(request(rpc(2, 'tools/call', { name: 'read_dev_project_file', arguments: { project_id: 'bridge-agent', path } })), f.env));
    assert.ok(r.body.error, path); assert.equal(f.stats.writes, 0, path);
  }
});

test('wrong or missing Auth0 token is rejected before any staging mutation', async () => {
  const f = workerFor();
  const r = await responseBody(await f.worker.fetch(request(rpc(3, 'tools/call', { name: 'list_dev_project_files', arguments: { project_id: 'bridge-agent' } }), 'invalid-token-00001'), f.env));
  assert.equal(r.status, 401); assert.equal(f.stats.writes, 0);
  const noBearer = await responseBody(await f.worker.fetch(new Request(`${STAGING_ORIGIN}/mcp`, { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify(rpc(4, 'tools/list')) }), f.env));
  assert.equal(noBearer.status, 401);
});

test('wrong staging D1 identity, release label, or missing subject fails closed', async () => {
  for (const change of [{ AIMB_STAGING_D1_UUID: 'production' }, { AIMB_STAGE_RELEASE_ID: 'other' }, { AIMB_J1H_ALLOWED_SUB: '' }, { AIMB_J1H_PILOT_ENABLED: 'false' }]) {
    const f = workerFor(); Object.assign(f.env, change);
    const r = await responseBody(await f.worker.fetch(request(rpc(5, 'tools/call', { name: 'list_dev_project_files', arguments: { project_id: 'bridge-agent' } })), f.env));
    assert.ok(r.body.error); assert.equal(f.stats.writes, 0);
  }
});

test('only allowlisted read action, project and tool arguments can enqueue', async () => {
  const badCalls = [
    { name: 'prepare_project_patch', arguments: { project_id: 'bridge-agent' } },
    { name: 'read_dev_project_file', arguments: { project_id: 'other', path: 'ok.txt' } },
    { name: 'read_dev_project_file', arguments: { project_id: 'bridge-agent', path: 'safe.txt', shell: 'whoami' } }
  ];
  for (const params of badCalls) { const f = workerFor(); const r = await responseBody(await f.worker.fetch(request(rpc(6, 'tools/call', params)), f.env)); assert.ok(r.body.error); assert.equal(f.stats.writes, 0); }
});

test('partial insert or an already-active queue fails closed without polling', async () => {
  const f = workerFor({ insertChanges: 0 });
  const r = await responseBody(await f.worker.fetch(request(rpc(7, 'tools/call', { name: 'list_dev_project_files', arguments: { project_id: 'bridge-agent' } })), f.env));
  assert.ok(r.body.error); assert.equal(f.stats.reads, 0); assert.equal(f.wakes.length, 0);
});

test('pilot write cap stops after exactly two fixture jobs', async () => {
  const f = workerFor();
  for (const [id, path] of [['p1', undefined], ['p2', 'sample-a.txt']]) {
    const params = path ? { name: 'read_dev_project_file', arguments: { project_id: 'bridge-agent', path } } : { name: 'list_dev_project_files', arguments: { project_id: 'bridge-agent' } };
    const r = await responseBody(await f.worker.fetch(request(rpc(id, 'tools/call', params)), f.env)); assert.equal(r.body.result.isError, false);
  }
  const denied = await responseBody(await f.worker.fetch(request(rpc('p3', 'tools/call', { name: 'list_dev_project_files', arguments: { project_id: 'bridge-agent' } })), f.env));
  assert.ok(denied.body.error); assert.equal(f.rows.size, 2); assert.equal(f.stats.inserts, 3);
});

test('failed WSS notification falls back to bounded D1 result polling', async () => {
  const f = workerFor(); f.env.STAGING_DO.get = () => ({ fetch: async () => { throw Error('offline'); } });
  const r = await responseBody(await f.worker.fetch(request(rpc('fallback', 'tools/call', { name: 'list_dev_project_files', arguments: { project_id: 'bridge-agent' } })), f.env));
  assert.equal(r.body.result.isError, false); assert.equal(f.stats.inserts, 1); assert.equal(f.stats.reads, 1);
});

test('missing or expired agent result times out within 60 seconds and leaves no retry loop', async () => {
  const f = workerFor({ completeOnRead: Infinity });
  const r = await responseBody(await f.worker.fetch(request(rpc(8, 'tools/call', { name: 'read_dev_project_file', arguments: { project_id: 'bridge-agent', path: 'sample-a.txt' } })), f.env));
  assert.match(r.body.error.message, /STAGING_READ_TIMEOUT|STAGING_TTL_MARGIN_EXHAUSTED/);
  assert.ok(f.timeRef.now - now0 <= 60_000); assert.equal(f.stats.inserts, 1); assert.ok(f.stats.reads <= 41); assert.equal(f.stats.writes, 1);
});

test('Auth0 RS256 verifier validates issuer, audience, subject, scope and time claims', async () => {
  const { privateKey, publicKey } = generateKeyPairSync('rsa', { modulusLength: 2048 });
  const jwk = publicKey.export({ format: 'jwk' }); jwk.kid = 'test-kid'; jwk.use = 'sig'; jwk.alg = 'RS256';
  const clock = { now: now0 };
  const fetchImpl = async url => { assert.equal(url, `${STAGING_ISSUER}.well-known/jwks.json`); return Response.json({ keys: [jwk] }); };
  const verify = createAuth0JwtVerifier({ fetchImpl, now: () => clock.now });
  const jwt = claims => { const h = btoa(JSON.stringify({ alg: 'RS256', kid: 'test-kid', typ: 'JWT' })).replace(/=/g, ''); const p = btoa(JSON.stringify(claims)).replace(/=/g, ''); const input = `${h}.${p}`; return `${input}.${sign('RSA-SHA256', Buffer.from(input), { key: privateKey }).toString('base64url')}`; };
  const claims = { iss: STAGING_ISSUER, aud: STAGING_AUDIENCE, sub: subject, scope: 'openid bridge.read', iat: Math.floor(now0 / 1000), exp: Math.floor(now0 / 1000) + 300 };
  assert.deepEqual(await verify(jwt(claims), { expectedSubject: subject }), { sub: subject, scope: ['openid', 'bridge.read'] });
  for (const bad of [{ ...claims, sub: 'auth0|other' }, { ...claims, aud: 'https://prod' }, { ...claims, scope: 'openid' }, { ...claims, exp: Math.floor(now0 / 1000) - 1 }]) await assert.rejects(verify(jwt(bad), { expectedSubject: subject }));
});

test('non-MCP path and non-POST methods have no D1 effect', async () => {
  const f = workerFor();
  assert.equal((await f.worker.fetch(new Request(`${STAGING_ORIGIN}/health`), f.env)).status, 404);
  assert.equal((await f.worker.fetch(new Request(`${STAGING_ORIGIN}/mcp`, { method: 'GET' }), f.env)).status, 405);
  assert.equal(f.stats.writes, 0);
});

test('MCP initialized notification is accepted with no content and no D1 write', async () => {
  const f = workerFor();
  const r = await f.worker.fetch(request({ jsonrpc: '2.0', method: 'notifications/initialized' }), f.env);
  assert.equal(r.status, 202); assert.equal(await r.text(), ''); assert.equal(f.stats.writes, 0);
});
