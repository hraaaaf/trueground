const TOOLS = Object.freeze([
  Object.freeze({
    name: 'list_dev_project_files',
    description: 'List files in the single staging fixture project, read-only.',
    inputSchema: {
      type: 'object', additionalProperties: false,
      properties: { project_id: { type: 'string', const: 'bridge-agent' }, offset: { type: 'integer', minimum: 0, maximum: 9999 }, limit: { type: 'integer', minimum: 1, maximum: 100 } },
      required: ['project_id']
    }
  }),
  Object.freeze({
    name: 'read_dev_project_file',
    description: 'Read one bounded UTF-8 file from the single staging fixture project, read-only.',
    inputSchema: {
      type: 'object', additionalProperties: false,
      properties: { project_id: { type: 'string', const: 'bridge-agent' }, path: { type: 'string', minLength: 1, maxLength: 240 } },
      required: ['project_id', 'path']
    }
  })
]);
const TOOL_NAMES = new Set(TOOLS.map(tool => tool.name));
const RELATIVE = /^(?!\/)(?!.*(?:^|\/)\.\.?\/?)(?!.*:)[^\\\0]+$/;
const utf8 = new TextEncoder();
export const PILOT_STAGING_WORKER_VERSION = '00000000-0000-4000-8000-000000000007';
export const PILOT_STAGING_D1_UUID = '00000000-0000-4000-8000-000000000008';

function need(ok, code) { if (!ok) throw new Error(code); }
function isRecord(value) { return value !== null && typeof value === 'object' && !Array.isArray(value); }
function jsonRpcError(id, code, message) { return { jsonrpc: '2.0', id: id ?? null, error: { code, message } }; }
function rpcResult(id, result) { return { jsonrpc: '2.0', id, result }; }
function mcpText(value) { return [{ type: 'text', text: JSON.stringify(value) }]; }

/**
 * Offline staging-only MCP adapter core. A production Worker integration must
 * provide a cryptographic bearer verifier and a staging queue implementation.
 * This module has no D1, Cloudflare, filesystem, or network client of its own.
 */
export function createStagingMcpReadAdapter({ expectedSubject, projectId = 'bridge-agent', verifyBearer, queue, maxWaitMs = 60_000 }) {
  need(typeof expectedSubject === 'string' && expectedSubject.length >= 3 && expectedSubject.length <= 160, 'EXPECTED_SUBJECT_REQUIRED');
  need(projectId === 'bridge-agent', 'PROJECT_ID_NOT_ALLOWLISTED');
  need(typeof verifyBearer === 'function', 'BEARER_VERIFIER_REQUIRED');
  need(queue && typeof queue.executeRead === 'function' && typeof queue.getIdentity === 'function', 'STAGING_READ_QUEUE_REQUIRED');
  need(Number.isInteger(maxWaitMs) && maxWaitMs >= 1_000 && maxWaitMs <= 60_000, 'WAIT_LIMIT_INVALID');
  let busy = false;

  async function authenticate(request) {
    const header = request.headers.get('authorization') || '';
    const match = /^Bearer ([A-Za-z0-9._~-]{8,8192})$/.exec(header);
    need(match, 'BEARER_REQUIRED');
    // verifyBearer must validate signature, issuer, audience, exp/nbf and scope.
    const identity = await verifyBearer(match[1], request);
    need(isRecord(identity) && identity.verified === true, 'BEARER_NOT_VERIFIED');
    need(identity.sub === expectedSubject, 'PRINCIPAL_NOT_ALLOWLISTED');
    need(identity.iss === 'https://tenant.example.auth0.com/', 'ISSUER_NOT_ALLOWLISTED');
    need(identity.aud === 'https://staging-worker.example.invalid/mcp', 'AUDIENCE_NOT_ALLOWLISTED');
    need(Array.isArray(identity.scopes) && identity.scopes.includes('bridge.read'), 'SCOPE_REQUIRED');
    return identity;
  }

  async function callTool(identity, name, args) {
    need(!busy, 'READ_ALREADY_ACTIVE');
    busy = true;
    try {
    need(TOOL_NAMES.has(name), 'TOOL_NOT_ALLOWLISTED');
    need(isRecord(args) && Object.keys(args).every(k => ['project_id', 'offset', 'limit', 'path'].includes(k)), 'TOOL_ARGUMENTS_INVALID');
    need(args.project_id === projectId, 'PROJECT_ID_NOT_ALLOWLISTED');
    let action, normalized;
    if (name === 'list_dev_project_files') {
      need(!Object.hasOwn(args, 'path'), 'TOOL_ARGUMENTS_INVALID');
      const offset = args.offset ?? 0, limit = args.limit ?? 50;
      need(Number.isInteger(offset) && offset >= 0 && offset <= 9999, 'PAGE_OFFSET_INVALID');
      need(Number.isInteger(limit) && limit >= 1 && limit <= 100, 'PAGE_LIMIT_INVALID');
      action = 'list_project_files'; normalized = { offset, limit };
    } else {
      need(!Object.hasOwn(args, 'offset') && !Object.hasOwn(args, 'limit'), 'TOOL_ARGUMENTS_INVALID');
      need(typeof args.path === 'string' && args.path.length <= 240 && RELATIVE.test(args.path), 'PROJECT_PATH_INVALID');
      const segments = args.path.split('/');
      need(segments.every(segment => segment.length > 0 && segment !== '.' && segment !== '..'), 'PROJECT_PATH_INVALID');
      action = 'read_project_text'; normalized = { path: args.path };
    }
    let identityTimer;
    const identityTimeout = new Promise((_, reject) => { identityTimer = setTimeout(() => reject(new Error('STAGING_IDENTITY_TIMEOUT')), 3_000); });
    const pinnedIdentity = await Promise.race([queue.getIdentity(), identityTimeout]).finally(() => clearTimeout(identityTimer));
    need(isRecord(pinnedIdentity) && pinnedIdentity.workerVersion === PILOT_STAGING_WORKER_VERSION && pinnedIdentity.d1Uuid === PILOT_STAGING_D1_UUID, 'STAGING_IDENTITY_MISMATCH');
    let timer;
    const controller = new AbortController();
    const timeout = new Promise((_, reject) => { timer = setTimeout(() => { controller.abort(); reject(new Error('STAGING_READ_TIMEOUT')); }, maxWaitMs); });
    const result = await Promise.race([
      queue.executeRead({ subject: identity.sub, projectId, action, args: normalized, deadlineMs: maxWaitMs, signal: controller.signal }),
      timeout
    ]).finally(() => clearTimeout(timer));
    need(isRecord(result) && result.ok === true, 'STAGING_READ_FAILED');
    const serialized = JSON.stringify(result);
    need(utf8.encode(serialized).byteLength <= 64 * 1024, 'TOOL_RESULT_TOO_LARGE');
    return result;
    } finally { busy = false; }
  }

  return Object.freeze({
    tools: TOOLS,
    async handle(request) {
      if (!(request instanceof Request)) throw new Error('REQUEST_REQUIRED');
      if (request.method !== 'POST') return new Response('', { status: 405, headers: { allow: 'POST' } });
      if (request.headers.get('content-type')?.split(';')[0].trim().toLowerCase() !== 'application/json') return new Response('unsupported media type', { status: 415 });
      const length = Number(request.headers.get('content-length') || 0);
      if (Number.isFinite(length) && length > 16 * 1024) return new Response('request too large', { status: 413 });
      let raw;
      try { raw = await request.text(); } catch { return new Response('invalid body', { status: 400 }); }
      if (utf8.encode(raw).byteLength > 16 * 1024) return new Response('request too large', { status: 413 });
      let message;
      try { message = JSON.parse(raw); } catch { return new Response('invalid json', { status: 400 }); }
      if (isRecord(message) && message.jsonrpc === '2.0' && message.method === 'notifications/initialized' && !Object.hasOwn(message, 'id')) {
        try { await authenticate(request); return new Response('', { status: 202 }); }
        catch { return new Response('', { status: 401 }); }
      }
      if (!isRecord(message) || message.jsonrpc !== '2.0' || !Object.hasOwn(message, 'id') || typeof message.method !== 'string') {
        return Response.json(jsonRpcError(null, -32600, 'Invalid Request'), { status: 400 });
      }
      try {
        const identity = await authenticate(request);
        if (message.method === 'initialize') {
          return Response.json(rpcResult(message.id, {
            protocolVersion: '2025-03-26', capabilities: { tools: {} },
            serverInfo: { name: 'aimb-j1-dev-staging-read-only', version: '0.1.0' }
          }));
        }
        if (message.method === 'tools/list') return Response.json(rpcResult(message.id, { tools: TOOLS }));
        if (message.method === 'tools/call') {
          need(isRecord(message.params) && typeof message.params.name === 'string', 'TOOL_CALL_INVALID');
          const result = await callTool(identity, message.params.name, message.params.arguments ?? {});
          return Response.json(rpcResult(message.id, { content: mcpText(result), structuredContent: result, isError: false }));
        }
        return Response.json(jsonRpcError(message.id, -32601, 'Method not found'));
      } catch (error) {
        const text = String(error?.message || 'REQUEST_FAILED').replace(/[^A-Z0-9_:-]/gi, '_').slice(0, 120);
        const code = ['BEARER_REQUIRED', 'BEARER_NOT_VERIFIED', 'ISSUER_NOT_ALLOWLISTED', 'AUDIENCE_NOT_ALLOWLISTED', 'PRINCIPAL_NOT_ALLOWLISTED', 'SCOPE_REQUIRED'].includes(error.message) ? -32001 : -32602;
        return Response.json(jsonRpcError(message.id, code, text), { status: code === -32001 ? 401 : 200 });
      }
    }
  });
}

export const STAGING_MCP_READ_TOOL_NAMES = Object.freeze([...TOOL_NAMES]);
