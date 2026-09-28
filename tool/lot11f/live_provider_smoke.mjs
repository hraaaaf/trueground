import assert from 'node:assert/strict';
import { performance } from 'node:perf_hooks';
import handler from '../../api/conversation.mjs';

assert.ok(process.env.GROQ_API_KEY, 'GROQ_API_KEY is required');

const cases = [
  {
    id: 'TG11F-SMOKE-EN-001',
    language: 'en',
    user_message: 'Help me choose one useful next step while leaving the uncertainty unresolved.',
  },
  {
    id: 'TG11F-SMOKE-FR-001',
    language: 'fr',
    user_message: 'Aide-moi à choisir une petite prochaine étape sans résoudre l’incertitude.',
  },
];

const metrics = [];
for (const fixture of cases) {
  const request = new Request('https://trueground.example/api/conversation', {
    method: 'POST',
    headers: {
      origin: 'https://trueground.example',
      'content-type': 'application/json',
      'x-trueground-client': 'tg11f.client.v1',
    },
    body: JSON.stringify({
      schema_version: 'tg11c.response.v1',
      language: fixture.language,
      user_message: fixture.user_message,
    }),
  });

  const started = performance.now();
  const response = await handler.fetch(request);
  const elapsedMs = Math.round(performance.now() - started);
  assert.equal(response.status, 200, `${fixture.id} provider status`);

  const body = await response.json();
  assert.deepEqual(Object.keys(body).sort(), [
    'language',
    'message',
    'mode',
    'schema_version',
  ]);
  assert.equal(body.schema_version, 'tg11c.response.v1');
  assert.equal(body.language, fixture.language);
  assert.ok(['support', 'clarify'].includes(body.mode));
  assert.equal(typeof body.message, 'string');
  assert.ok(body.message.length > 0 && body.message.length <= 1200);

  metrics.push({
    id: fixture.id,
    language: fixture.language,
    status: response.status,
    elapsed_ms: elapsedMs,
    mode: body.mode,
    message_length: body.message.length,
  });
}

console.log(JSON.stringify({
  schema_version: 'tg11f.smoke.metrics.v1',
  model: 'openai/gpt-oss-120b',
  cases: metrics,
}));
