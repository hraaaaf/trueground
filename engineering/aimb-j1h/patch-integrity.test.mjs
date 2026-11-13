import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { test } from 'node:test';
import assert from 'node:assert/strict';

const patch = readFileSync(new URL('./patch-v074.diff', import.meta.url));
const utf8 = patch.toString('utf8');
const digest = createHash('sha256').update(patch).digest('hex');
const EXPECTED_PATCH_SHA = 'c5a3080d35793afe8f5b7e6d5b09d9e65e9103f6d857b07fadd1f681744b0a82';

test('reference patch is byte-exact', () => {
  assert.equal(digest, EXPECTED_PATCH_SHA);
  assert.equal(patch.byteLength, 3249);
});
test('only the two authorized JS modules appear in the patch headers', () => {
  assert.deepEqual([...utf8.matchAll(/^--- a\/(.+)$/gm)].map(x => x[1]), [
    'supervisor-v07.mjs', 'e2e-windows-runner.mjs'
  ]);
  assert.deepEqual([...utf8.matchAll(/^\+\+\+ b\/(.+)$/gm)].map(x => x[1]), [
    'supervisor-v07.mjs', 'e2e-windows-runner.mjs'
  ]);
});
test('diagnostic startup and 12-second deadline are explicitly present', () => {
  assert.ok(utf8.includes("+ console.log('STAGE_BOOT'"));
  assert.ok(utf8.includes("+  this.emitEvidence('supervisor_started'"));
  assert.ok(utf8.includes("WEBSOCKET_HARD_DEADLINE_12S"));
  assert.ok(utf8.includes("SUPERVISOR_CONNECTIVITY_NOT_PROVEN"));
});
test('no deployment or secret-bearing workflow commands in patch', () => {
  assert.doesNotMatch(utf8, /(wrangler deploy|vercel deploy|secrets\.|BEGIN PRIVATE KEY)/i);
});
