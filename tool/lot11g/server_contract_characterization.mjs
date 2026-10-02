import assert from 'node:assert/strict';
import handler from '../../api/conversation.mjs';

const originalFetch = globalThis.fetch;
const originalKey = process.env.Llm_Key;

function request(body) {
  return new Request('https://trueground.example/api/conversation', {
    method: 'POST',
    headers: {
      origin: 'https://trueground.example',
      'content-type': 'application/json',
      'x-trueground-client': 'tg11f.client.v1',
    },
    body: JSON.stringify(body),
  });
}

function body(userMessage, context = []) {
  return {
    schema_version: 'tg11c.response.v1',
    language: 'en',
    user_message: userMessage,
    context,
  };
}

function successfulProviderResponse() {
  return new Response(
    JSON.stringify({
      choices: [
        {
          message: {
            content: JSON.stringify({
              schema_version: 'tg11c.response.v1',
              message:
                'Choose one small next step without resolving the uncertainty.',
              language: 'en',
              mode: 'support',
            }),
          },
        },
      ],
    }),
    { status: 200, headers: { 'content-type': 'application/json' } },
  );
}

async function run() {
  process.env.Llm_Key = 'test-only-key';
  globalThis.fetch = async () => successfulProviderResponse();

  const message1201 = 'x'.repeat(1201);
  const direct1201 = await handler.fetch(request(body(message1201)));
  assert.equal(
    direct1201.status,
    200,
    'characterization: a 1201-character current user message is accepted',
  );

  const replayed1201 = await handler.fetch(
    request(
      body('ordinary next turn', [
        { role: 'user', content: message1201 },
        { role: 'assistant', content: 'bounded response' },
      ]),
    ),
  );
  assert.equal(
    replayed1201.status,
    400,
    'characterization: the same 1201-character message is rejected once replayed as context',
  );
  assert.deepEqual(await replayed1201.json(), { error: 'invalid_request' });

  const direct2000 = await handler.fetch(request(body('x'.repeat(2000))));
  assert.equal(direct2000.status, 200);

  const direct2001 = await handler.fetch(request(body('x'.repeat(2001))));
  assert.equal(direct2001.status, 400);
  assert.deepEqual(await direct2001.json(), { error: 'invalid_request' });

  delete process.env.Llm_Key;
  const missingKey = await handler.fetch(request(body('ordinary message')));
  assert.equal(missingKey.status, 503);
  const missingKeyBody = await missingKey.json();
  assert.deepEqual(missingKeyBody, { error: 'provider_unavailable' });

  process.env.Llm_Key = 'test-only-key';
  globalThis.fetch = async () =>
    new Response('provider failure', { status: 500 });
  const upstream500 = await handler.fetch(request(body('ordinary message')));
  assert.equal(upstream500.status, 502);
  const upstream500Body = await upstream500.json();
  assert.deepEqual(upstream500Body, { error: 'provider_unavailable' });

  globalThis.fetch = async () =>
    new Response(
      JSON.stringify({
        choices: [{ message: { content: '{"language":"en"}' } }],
      }),
      { status: 200, headers: { 'content-type': 'application/json' } },
    );
  const malformed = await handler.fetch(request(body('ordinary message')));
  assert.equal(malformed.status, 502);
  const malformedBody = await malformed.json();
  assert.deepEqual(malformedBody, { error: 'provider_unavailable' });

  assert.deepEqual(
    missingKeyBody,
    upstream500Body,
    'characterization: configuration and upstream failures expose the same sanitized reason',
  );
  assert.deepEqual(
    upstream500Body,
    malformedBody,
    'characterization: upstream and malformed-provider failures expose the same sanitized reason',
  );

  console.log(
    JSON.stringify({
      schema_version: 'tg11g.characterization.v1',
      context_length_mismatch_reproduced: true,
      provider_reason_codes_collapsed: true,
      live_provider_calls: 0,
    }),
  );
}

try {
  await run();
} finally {
  globalThis.fetch = originalFetch;
  if (originalKey === undefined) delete process.env.Llm_Key;
  else process.env.Llm_Key = originalKey;
}
