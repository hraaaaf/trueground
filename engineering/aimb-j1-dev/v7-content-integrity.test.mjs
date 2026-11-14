import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { parseContentV2Multipart, verifyPinnedV7Modules, V7_MODULE_SHA256 } from './v7-content-integrity.mjs';

const digest = value => createHash('sha256').update(value).digest('hex');
function multipart(boundary, parts, order = Object.keys(parts)) {
  const chunks = [];
  for (const name of order) {
    chunks.push(Buffer.from(`--${boundary}\r\nContent-Disposition: form-data; name="${name}"; filename="${name}"\r\nContent-Type: application/javascript\r\n\r\n`, 'ascii'));
    chunks.push(Buffer.from(parts[name]));
    chunks.push(Buffer.from('\r\n', 'ascii'));
  }
  chunks.push(Buffer.from(`--${boundary}--\r\n`, 'ascii'));
  return Buffer.concat(chunks);
}

test('multipart boundary and part order do not affect per-module SHA-256', () => {
  const parts = { 'worker.js': 'export default { fetch(){ return "ok" } }\n', 'staging-result.mjs': 'export const result = true;\n' };
  const expected = Object.fromEntries(Object.entries(parts).map(([name, source]) => [name, digest(source)]));
  const first = verifyPinnedV7Modules('multipart/form-data; boundary="aabbcc001122"', multipart('aabbcc001122', parts), expected);
  const second = verifyPinnedV7Modules('multipart/form-data; boundary=ffeedd998877', multipart('ffeedd998877', parts, ['staging-result.mjs', 'worker.js']), expected);
  assert.deepEqual(first, second);
  assert.deepEqual(first.map(x => x.name), ['staging-result.mjs', 'worker.js']);
  assert.equal(parseContentV2Multipart('multipart/form-data; boundary=aabbcc001122', multipart('aabbcc001122', parts)).size, 2);
});

test('boundary-like bytes inside module source stay in the module body', () => {
  const source = Buffer.from('const sample = "\r\n--aabbcc001122-not-a-delimiter";\n');
  const parts = { 'worker.js': source, 'staging-result.mjs': Buffer.from('ok') };
  const expected = Object.fromEntries(Object.entries(parts).map(([name, bytes]) => [name, digest(bytes)]));
  const body = multipart('aabbcc001122', parts);
  const parsed = parseContentV2Multipart('multipart/form-data; boundary=aabbcc001122', body);
  assert.deepEqual(parsed.get('worker.js'), source);
  assert.equal(verifyPinnedV7Modules('multipart/form-data; boundary=aabbcc001122', body, expected).length, 2);
});

test('hashes only module bodies and rejects changed, duplicate, missing or unexpected parts', () => {
  const parts = { 'worker.js': Buffer.from([0, 1, 2, 13, 10, 3]), 'staging-result.mjs': Buffer.from('result\n') };
  const expected = Object.fromEntries(Object.entries(parts).map(([name, bytes]) => [name, digest(bytes)]));
  const body = multipart('ca11ab1e', parts);
  assert.deepEqual(verifyPinnedV7Modules('multipart/form-data; boundary=ca11ab1e', body, expected).map(x => x.bytes), [7, 6]);
  const altered = multipart('deadcafe', { ...parts, 'worker.js': Buffer.from('changed') });
  assert.throws(() => verifyPinnedV7Modules('multipart/form-data; boundary=deadcafe', altered, expected), /MODULE_SHA256_MISMATCH:worker\.js/);
  const duplicate = Buffer.from('--aa11aa11\r\nContent-Disposition: form-data; name="worker.js"; filename="worker.js"\r\n\r\none\r\n--aa11aa11\r\nContent-Disposition: form-data; name="worker.js"; filename="worker.js"\r\n\r\ntwo\r\n--aa11aa11--\r\n');
  assert.throws(() => parseContentV2Multipart('multipart/form-data; boundary=aa11aa11', duplicate), /MULTIPART_DUPLICATE_MODULE/);
  assert.throws(() => verifyPinnedV7Modules('multipart/form-data; boundary=aa11aa11', multipart('aa11aa11', { 'worker.js': 'only one' }), expected), /MODULE_SET_MISMATCH/);
  assert.throws(() => parseContentV2Multipart('multipart/form-data; boundary=aa11aa11', multipart('aa11aa11', { '../worker.js': 'bad' })), /MULTIPART_MODULE_PATH_REJECTED/);
});

test('V7 module pins from the independently supplied extraction record are well-formed', () => {
  assert.equal(typeof verifyPinnedV7Modules, 'function');
  assert.deepEqual(Object.keys(V7_MODULE_SHA256).sort(), ['staging-result.mjs', 'worker.js']);
  assert.deepEqual(V7_MODULE_SHA256, {
    'worker.js': '7836e800de131cd84f3951eb5bd99799d2a2f9f85406aa440bf6499078f697c7',
    'staging-result.mjs': '4692867dc0cfeb6fc7d66e02c27e1951932c155e9a61cb6a9f97aa199a278845'
  });
  for (const hash of Object.values(V7_MODULE_SHA256)) assert.match(hash, /^[a-f0-9]{64}$/);
});
