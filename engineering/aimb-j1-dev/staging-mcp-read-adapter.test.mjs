import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createStagingMcpReadAdapter, PILOT_STAGING_D1_UUID, PILOT_STAGING_WORKER_VERSION, STAGING_MCP_READ_TOOL_NAMES } from './staging-mcp-read-adapter.mjs';

const subject = 'auth0|j1-dev-fixture-principal';
const verifiedClaims = { verified: true, iss: 'https://tenant.example.auth0.com/', aud: 'https://staging-worker.example.invalid/mcp' };
const tokenClaims = new Map([
  ['valid-token-0001', { ...verifiedClaims, sub: subject, scopes: ['bridge.read'] }],
  ['other-subject-0001', { ...verifiedClaims, sub: 'auth0|other', scopes: ['bridge.read'] }],
  ['missing-scope-0001', { ...verifiedClaims, sub: subject, scopes: ['openid'] }],
  ['unverified-token-01', { verified: false, sub: subject, scopes: ['bridge.read'] }],
  ['wrong-issuer-00001', { ...verifiedClaims, iss: 'https://wrong.example/', sub: subject, scopes: ['bridge.read'] }],
  ['wrong-audience-0001', { ...verifiedClaims, aud: 'https://production.example/mcp', sub: subject, scopes: ['bridge.read'] }]
]);
const request = body => new Request('https://staging.example/mcp', {
  method: 'POST', headers: { authorization: 'Bearer valid-token-0001', 'content-type': 'application/json' }, body: JSON.stringify(body)
});
const rpc = (id, method, params) => ({ jsonrpc: '2.0', id, method, ...(params ? { params } : {}) });
async function responseJson(adapter, req) { const res = await adapter.handle(req); return { status: res.status, body: await res.json() }; }

function fixtureAdapter(queueImpl = async job => ({ ok: true, action: job.action, args: job.args, files: ['sample-a.txt'], content: 'fixture only' }), maxWaitMs = 60_000) {
  const calls = [];
  const adapter = createStagingMcpReadAdapter({
    expectedSubject: subject,
    maxWaitMs,
    verifyBearer: async token => tokenClaims.get(token) ?? { verified: false },
    queue: { getIdentity: async () => ({ workerVersion: PILOT_STAGING_WORKER_VERSION, d1Uuid: PILOT_STAGING_D1_UUID }), executeRead: async job => { calls.push(job); return queueImpl(job); } }
  });
  return { adapter, calls };
}

test('MCP tools/list exposes only the two project read tools', async () => {
  const { adapter } = fixtureAdapter();
  const { status, body } = await responseJson(adapter, request(rpc(1, 'tools/list')));
  assert.equal(status, 200);
  assert.deepEqual(body.result.tools.map(t => t.name).sort(), [...STAGING_MCP_READ_TOOL_NAMES].sort());
  assert.deepEqual([...STAGING_MCP_READ_TOOL_NAMES].sort(), ['list_dev_project_files', 'read_dev_project_file']);
  assert.ok(body.result.tools.every(t => !/patch|commit|test|exec|shell/i.test(t.name)));
});

test('two-tool MCP E2E simulation binds exact principal and read actions', async () => {
  const { adapter, calls } = fixtureAdapter();
  const listed = await responseJson(adapter, request(rpc(2, 'tools/call', { name: 'list_dev_project_files', arguments: { project_id: 'bridge-agent', offset: 0, limit: 20 } })));
  const read = await responseJson(adapter, request(rpc(3, 'tools/call', { name: 'read_dev_project_file', arguments: { project_id: 'bridge-agent', path: 'sample-a.txt' } })));
  assert.equal(listed.status, 200); assert.equal(listed.body.result.isError, false);
  assert.deepEqual(listed.body.result.structuredContent.files, ['sample-a.txt']);
  assert.equal(read.status, 200); assert.equal(read.body.result.structuredContent.content, 'fixture only');
  assert.deepEqual(calls.map(x => [x.subject, x.projectId, x.action]), [
    [subject, 'bridge-agent', 'list_project_files'], [subject, 'bridge-agent', 'read_project_text']
  ]);
  assert.deepEqual(calls.map(x => x.args), [{ offset: 0, limit: 20 }, { path: 'sample-a.txt' }]);
  assert.ok(calls.every(x => x.deadlineMs === 60_000 && x.signal instanceof AbortSignal));
});

test('unverified token, wrong issuer/audience, subject or scope fail before queue', async () => {
  const { adapter, calls } = fixtureAdapter();
  for (const [token, code] of [['unverified-token-01', 'BEARER_NOT_VERIFIED'], ['wrong-issuer-00001', 'ISSUER_NOT_ALLOWLISTED'], ['wrong-audience-0001', 'AUDIENCE_NOT_ALLOWLISTED'], ['other-subject-0001', 'PRINCIPAL_NOT_ALLOWLISTED'], ['missing-scope-0001', 'SCOPE_REQUIRED']]) {
    const req = new Request('https://staging.example/mcp', { method: 'POST', headers: { authorization: `Bearer ${token}`, 'content-type': 'application/json' }, body: JSON.stringify(rpc(4, 'tools/list')) });
    const { status, body } = await responseJson(adapter, req);
    assert.equal(status, 401); assert.match(body.error.message, new RegExp(code));
  }
  assert.equal(calls.length, 0);
});

test('tool calls reject modification surface, path traversal and other projects', async () => {
  const { adapter, calls } = fixtureAdapter();
  const bad = [
    { name: 'prepare_project_patch', arguments: { project_id: 'bridge-agent' } },
    { name: 'read_dev_project_file', arguments: { project_id: 'bridge-agent', path: '../outside.txt' } },
    { name: 'read_dev_project_file', arguments: { project_id: 'bridge-agent', path: 'sub/../outside.txt' } },
    { name: 'read_dev_project_file', arguments: { project_id: 'other-project', path: 'safe.txt' } },
    { name: 'list_dev_project_files', arguments: { project_id: 'bridge-agent', limit: 101 } }
  ];
  for (const input of bad) {
    const { body } = await responseJson(adapter, request(rpc(5, 'tools/call', input)));
    assert.ok(body.error);
  }
  assert.equal(calls.length, 0);
});

test('unpinned Worker or D1 identity is rejected before queue execution', async () => {
  let queued = 0;
  const adapter = createStagingMcpReadAdapter({ expectedSubject: subject, verifyBearer: async token => tokenClaims.get(token), queue: {
    getIdentity: async () => ({ workerVersion: 'production-v15', d1Uuid: 'production-d1' }),
    executeRead: async () => { queued++; return { ok: true }; }
  } });
  const { body } = await responseJson(adapter, request(rpc(8, 'tools/call', { name: 'list_dev_project_files', arguments: { project_id: 'bridge-agent' } })));
  assert.match(body.error.message, /STAGING_IDENTITY_MISMATCH/); assert.equal(queued, 0);
});

test('one active read per adapter instance; concurrent duplicate is refused', async () => {
  let release, queued = 0;
  const adapter = createStagingMcpReadAdapter({ expectedSubject: subject, verifyBearer: async token => tokenClaims.get(token), queue: {
    getIdentity: async () => ({ workerVersion: PILOT_STAGING_WORKER_VERSION, d1Uuid: PILOT_STAGING_D1_UUID }),
    executeRead: async () => { queued++; return new Promise(resolve => { release = resolve; }); }
  } });
  const args = { name: 'list_dev_project_files', arguments: { project_id: 'bridge-agent' } };
  const first = responseJson(adapter, request(rpc(9, 'tools/call', args)));
  while (!release) await new Promise(resolve => setTimeout(resolve, 1));
  const second = await responseJson(adapter, request(rpc(10, 'tools/call', args)));
  assert.match(second.body.error.message, /READ_ALREADY_ACTIVE/); assert.equal(queued, 1);
  release({ ok: true, files: [] }); assert.equal((await first).body.result.isError, false);
});

test('adapter fails closed on unavailable or overlong result and bounds the wait', async () => {
  let timedOutSignal;
  const { adapter } = fixtureAdapter(async job => { timedOutSignal = job.signal; return new Promise(() => {}); }, 1000);
  const short = createStagingMcpReadAdapter({ expectedSubject: subject, maxWaitMs: 1000, verifyBearer: async token => tokenClaims.get(token), queue: { getIdentity: async () => ({ workerVersion: PILOT_STAGING_WORKER_VERSION, d1Uuid: PILOT_STAGING_D1_UUID }), executeRead: async () => new Promise(() => {}) } });
  assert.throws(() => createStagingMcpReadAdapter({ expectedSubject: subject, maxWaitMs: 60001, verifyBearer: async () => ({}), queue: { getIdentity() {}, executeRead() {} } }), /WAIT_LIMIT_INVALID/);
  const failed = await responseJson(adapter, request(rpc(6, 'tools/call', { name: 'read_dev_project_file', arguments: { project_id: 'bridge-agent', path: 'safe.txt' } })));
  assert.ok(failed.body.error);
  const pendingReq = request(rpc(7, 'tools/call', { name: 'list_dev_project_files', arguments: { project_id: 'bridge-agent' } }));
  const start = Date.now(); const pending = await short.handle(pendingReq); const payload = await pending.json();
  assert.ok(Date.now() - start < 1500); assert.match(payload.error.message, /STAGING_READ_TIMEOUT/);
  assert.equal(timedOutSignal.aborted, true);
});

test('initialized notification receives bounded no-content acknowledgement', async () => {
  const { adapter } = fixtureAdapter();
  const req = request({ jsonrpc: '2.0', method: 'notifications/initialized' });
  const response = await adapter.handle(req);
  assert.equal(response.status, 202); assert.equal(await response.text(), '');
});
