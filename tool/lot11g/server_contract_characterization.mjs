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

  const message1200 = 'x'.repeat(1200);
  const direct1200 = await handler.fetch(request(body(message1200)));
  assert.equal(direct1200.status, 200);

  const replayed1200 = await handler.fetch(
    request(
      body('ordinary next turn', [
        { role: 'user', content: message1200 },
        { role: 'assistant', content: 'bounded response' },
      ]),
    ),
  );
  assert.equal(
    replayed1200.status,
    200,
    'a message accepted as the current turn must remain valid when replayed as bounded context',
  );

  const direct1201 = await handler.fetch(request(body('x'.repeat(1201))));
  assert.equal(direct1201.status, 400);
  assert.deepEqual(await direct1201.json(), { error: 'invalid_request' });

  delete process.env.Llm_Key;
  const missingKey = await handler.fetch(request(body('ordinary message')));
  assert.equal(missingKey.status, 503);
  const missingKeyBody = await missingKey.json();
  assert.deepEqual(missingKeyBody, {
    error: 'provider_unavailable',
    reason: 'not_configured',
  });

  process.env.Llm_Key = 'test-only-key';
  globalThis.fetch = async () =>
    new Response('provider failure', { status: 500 });
  const upstream500 = await handler.fetch(request(body('ordinary message')));
  assert.equal(upstream500.status, 502);
  const upstream500Body = await upstream500.json();
  assert.deepEqual(upstream500Body, {
    error: 'provider_unavailable',
    reason: 'upstream_http_error',
  });

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
  assert.deepEqual(malformedBody, {
    error: 'provider_unavailable',
    reason: 'invalid_response',
  });

  globalThis.fetch = async () => {
    const error = new Error('synthetic abort');
    error.name = 'AbortError';
    throw error;
  };
  const timeout = await handler.fetch(request(body('ordinary message')));
  assert.equal(timeout.status, 502);
  assert.deepEqual(await timeout.json(), {
    error: 'provider_unavailable',
    reason: 'timeout',
  });

  globalThis.fetch = async () => {
    throw new Error('synthetic transport failure');
  };
  const transport = await handler.fetch(request(body('ordinary message')));
  assert.equal(transport.status, 502);
  assert.deepEqual(await transport.json(), {
    error: 'provider_unavailable',
    reason: 'transport_error',
  });

  console.log(
    JSON.stringify({
      schema_version: 'tg11g.characterization.v2',
      context_length_contract_aligned: true,
      provider_reason_codes_sanitized: true,
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
