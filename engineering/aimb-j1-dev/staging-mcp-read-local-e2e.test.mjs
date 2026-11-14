import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { mkdirSync, writeFileSync, rmSync, rmdirSync, existsSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { join } from 'node:path';
import { randomUUID } from 'node:crypto';
import { fileURLToPath } from 'node:url';
import { createStagingMcpReadAdapter, PILOT_STAGING_D1_UUID, PILOT_STAGING_WORKER_VERSION } from './staging-mcp-read-adapter.mjs';

const agent = fileURLToPath(new URL('./foreground-readonly-agent.ps1', import.meta.url));
const powershell = join(process.env.SystemRoot || 'C:\\Windows', 'System32', 'WindowsPowerShell', 'v1.0', 'powershell.exe');
const expectedSubject = 'auth0|g2-e2e-fixture-subject';
const sha256 = value => createHash('sha256').update(value, 'utf8').digest('hex');

function runNativeAgent(fixtureRoot, input) {
  const result = spawnSync(powershell, ['-NoProfile', '-NonInteractive', '-File', agent, '-FixtureRoot', fixtureRoot], {
    shell: false, windowsHide: true, encoding: 'utf8', input: `${JSON.stringify(input)}\n`, timeout: 10_000, maxBuffer: 128 * 1024
  });
  assert.equal(result.error, undefined, result.error?.message);
  assert.equal(result.status, 0, `PowerShell exit ${result.status}: ${result.stderr}`);
  assert.equal(result.stderr, '');
  const lines = result.stdout.trim().split(/\r?\n/);
  assert.equal(lines.length, 1);
  return JSON.parse(lines[0]);
}

test('MCP read tools reach an ephemeral Win32 fixture with no network or D1', async () => {
  assert.equal(process.platform, 'win32');
  assert.ok(process.env.USERPROFILE, 'Windows user profile is unavailable');
  const fixtureParent = join(process.env.USERPROFILE, 'AI_Machine_Bridge_DEV_FIXTURE');
  const parentExisted = existsSync(fixtureParent);
  mkdirSync(fixtureParent, { recursive: true });
  const fixtureRoot = join(fixtureParent, `fixture-${randomUUID().replaceAll('-', '')}`);
  mkdirSync(fixtureRoot);
  try {
    const sampleA = 'Synthetic fixture content A';
    const sampleB = 'Synthetic fixture content B';
    writeFileSync(join(fixtureRoot, '.aimb-fixture.json'), '{"fixture":"aimb-dev-readonly-v1","project_id":"bridge-agent"}', 'utf8');
    writeFileSync(join(fixtureRoot, 'sample-a.txt'), sampleA, 'utf8');
    writeFileSync(join(fixtureRoot, 'sample-b.txt'), sampleB, 'utf8');
    const who = spawnSync('whoami.exe', ['/user', '/fo', 'csv', '/nh'], { shell: false, windowsHide: true, encoding: 'utf8' });
    assert.equal(who.status, 0);
    const sid = /S-1-5-21-[0-9-]+/.exec(who.stdout)?.[0];
    assert.ok(sid, 'current runner SID is unavailable');
    const acl = spawnSync('icacls.exe', [fixtureRoot, '/inheritance:r', '/grant:r', '*S-1-5-18:(OI)(CI)(F)', `*${sid}:(OI)(CI)(RX)`], { shell: false, windowsHide: true, encoding: 'utf8' });
    assert.equal(acl.status, 0, 'fixture ACL setup failed');
    runNativeAgent(fixtureRoot,{type:'list',offset:0,limit:20});
    const routed = [];
    const adapter = createStagingMcpReadAdapter({
      expectedSubject,
      verifyBearer: async token => token === 'local-e2e-token-001' ? { verified: true, sub: expectedSubject, iss: 'https://tenant.example.auth0.com/', aud: 'https://staging-worker.example.invalid/mcp', scopes: ['bridge.read'] } : { verified: false },
      queue: {
        async getIdentity() { return { workerVersion: PILOT_STAGING_WORKER_VERSION, d1Uuid: PILOT_STAGING_D1_UUID }; },
        async executeRead(job) {
          routed.push({ subject: job.subject, projectId: job.projectId, action: job.action });
          if (job.action === 'list_project_files') return runNativeAgent(fixtureRoot, { type: 'list', ...job.args });
          if (job.action === 'read_project_text') return runNativeAgent(fixtureRoot, { type: 'read', path: job.args.path });
          throw new Error('ACTION_NOT_ALLOWLISTED');
        }
      }
    });
    const call = async (id, name, args) => {
      const response = await adapter.handle(new Request('https://staging.example.invalid/mcp', {
        method: 'POST', headers: { authorization: 'Bearer local-e2e-token-001', 'content-type': 'application/json' },
        body: JSON.stringify({ jsonrpc: '2.0', id, method: 'tools/call', params: { name, arguments: args } })
      }));
      assert.equal(response.status, 200);
      const payload=await response.json();
      assert.ok(payload.result?.structuredContent,JSON.stringify(payload));
      return payload.result.structuredContent;
    };
    const listing = await call(1, 'list_dev_project_files', { project_id: 'bridge-agent', offset: 0, limit: 20 });
    const reading = await call(2, 'read_dev_project_file', { project_id: 'bridge-agent', path: 'sample-a.txt' });
    assert.deepEqual(listing.files, ['sample-a.txt', 'sample-b.txt']);
    assert.equal(reading.content, sampleA);
    assert.equal(reading.sha256, sha256(sampleA));
    assert.deepEqual(routed, [
      { subject: expectedSubject, projectId: 'bridge-agent', action: 'list_project_files' },
      { subject: expectedSubject, projectId: 'bridge-agent', action: 'read_project_text' }
    ]);
  } finally {
    spawnSync('icacls.exe', [fixtureRoot, '/reset', '/T', '/C'], { shell: false, windowsHide: true, encoding: 'utf8' });
    rmSync(fixtureRoot, { recursive: true, force: true });
    if (!parentExisted) { try { rmdirSync(fixtureParent); } catch {} }
  }
});
