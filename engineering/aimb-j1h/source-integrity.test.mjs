import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { test } from 'node:test';
import assert from 'node:assert/strict';

const expected = {
  "e2e-windows-runner.mjs": "c2d9662d388be15b31d8360999e07c4d2a44d5885d1a9599975938e56b7ca0c7",
  "e2e-windows-runner.test.mjs": "0977a96d9e1b97f1066046d2fd9568b91e61ca58725af7019f673828f5ad6e40",
  "observability-v073.test.mjs": "4bb2d8daeb15d4cbae8c5f43455862b95d70be3a50ba24b8ffee8f779c35194c",
  "poll-scheduler.mjs": "c4d9270cd1dcd29685d0c1d2a838d4d1683b5d47f4f1b812a4e06496af300e24",
  "poll-scheduler.test.mjs": "5d2452c9e24096a4a8dc8baaea6ae6b4d8961daaaf383332af753ca34a4897b0",
  "startup-v074.test.mjs": "963cc46618250357f33f3906967e986a348c950d352f7621ff65b9d6407ad382",
  "supervisor-v07.mjs": "fbc0674f592880f8b3f91bbfe80cad7dd19f8a276fb9329bdd67a027aea9d136",
  "supervisor-v07.test.mjs": "1195f9e1432270336a569dfbf9c17ef354a8bbb88c48f6a0393714fb7676adbf"
};

for (const [name, sha256] of Object.entries(expected)) {
  test(`source SHA-256 ${name}`, () => {
    const bytes = readFileSync(new URL(`./src/${name}`, import.meta.url));
    const actual = createHash('sha256').update(bytes).digest('hex');
    assert.equal(actual, sha256, `byte-exact source drift: ${name}`);
  });
}
test('all eight vetted modules pinned', () => {
  assert.equal(Object.keys(expected).length, 8);
  assert.match(expected['supervisor-v07.mjs'], /^fbc0674f/);
});
