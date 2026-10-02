import assert from 'node:assert/strict';
import http from 'node:http';

import handler from '../../api/conversation.mjs';

assert.ok(process.env.Llm_Key, 'Llm_Key is required');

const port = Number(process.env.LOT11G_PORT ?? '8788');
assert.ok(Number.isInteger(port) && port > 0 && port < 65536, 'valid LOT11G_PORT required');

const host = '127.0.0.1';
const origin = `http://${host}:${port}`;

const server = http.createServer(async (incoming, outgoing) => {
  if (incoming.url === '/healthz') {
    outgoing.writeHead(200, { 'content-type': 'application/json' });
    outgoing.end('{"status":"ok"}');
    return;
  }

  const chunks = [];
  for await (const chunk of incoming) chunks.push(chunk);
  const body = Buffer.concat(chunks);

  const headers = new Headers();
  for (const [name, value] of Object.entries(incoming.headers)) {
    if (value == null) continue;
    headers.set(name, Array.isArray(value) ? value.join(',') : value);
  }

  const request = new Request(`${origin}${incoming.url ?? '/api/conversation'}`, {
    method: incoming.method ?? 'POST',
    headers,
    body: body.length > 0 ? body : undefined,
  });

  const response = await handler.fetch(request);
  const responseBody = Buffer.from(await response.arrayBuffer());
  const responseHeaders = {};
  response.headers.forEach((value, name) => {
    responseHeaders[name] = value;
  });

  outgoing.writeHead(response.status, responseHeaders);
  outgoing.end(responseBody);
});

server.listen(port, host, () => {
  console.log(
    JSON.stringify({
      schema_version: 'tg11g.live.local-server.v1',
      ready: true,
      port,
    }),
  );
});

for (const signal of ['SIGTERM', 'SIGINT']) {
  process.on(signal, () => {
    server.close(() => process.exit(0));
  });
}
