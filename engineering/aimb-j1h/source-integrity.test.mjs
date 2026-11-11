import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { test } from 'node:test';
import assert from 'node:assert/strict';

const expected = {
  "e2e-windows-runner.mjs": "c2d9662d388be15b31d8360999e07c4d2a44d5885d1a9599975938e56b7ca0c7",
  "e2e-windows-runner.test.mjs": "0977a96d9e1b97f1066046d2fd9568b91e61ca58725af7019f673828f5ad6e40",
  "observability-v073.test.mjs": "f78b9041edcb9824a9a8c87ec188b8ce7d4c06fd6d97acd2b1ccf4862e2d328a",
  "poll-scheduler.mjs": "82faede46c9ade9c51ca84e248f0763259b0b55a1dd063bb5d179b67f9c50e6f",
  "poll-scheduler.test.mjs": "136b81853a691ffedf6d3155ab91b80203802bf90d4e6be780800527a7d545a1",
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
