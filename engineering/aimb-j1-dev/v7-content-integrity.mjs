import { createHash, timingSafeEqual } from 'node:crypto';

export const V7_MODULE_SHA256 = Object.freeze({
  'worker.js': '7836e800de131cd84f3951eb5bd99799d2a2f9f85406aa440bf6499078f697c7',
  'staging-result.mjs': '4692867dc0cfeb6fc7d66e02c27e1951932c155e9a61cb6a9f97aa199a278845'
});

const need = (condition, code) => { if (!condition) throw new Error(code); };
const hexDigest = bytes => createHash('sha256').update(bytes).digest('hex');

function safeEqualHex(a, b) {
  if (!/^[a-f0-9]{64}$/i.test(a) || !/^[a-f0-9]{64}$/i.test(b)) return false;
  return timingSafeEqual(Buffer.from(a, 'hex'), Buffer.from(b, 'hex'));
}

function parseDisposition(value) {
  const params = {};
  for (const match of value.matchAll(/(?:^|;)\s*([!#$%&'*+.^_`|~0-9A-Za-z-]+)\s*=\s*(?:"((?:\\.|[^"\\])*)"|([^;\s]*))/g)) {
    params[match[1].toLowerCase()] = (match[2] ?? match[3] ?? '').replace(/\\(.)/g, '$1');
  }
  return params;
}

function partName(headers) {
  const disposition = headers.get('content-disposition') || '';
  const params = parseDisposition(disposition);
  const candidate = params.filename || params.name;
  need(typeof candidate === 'string' && candidate.length > 0, 'MULTIPART_MODULE_NAME_MISSING');
  const normalized = candidate.replaceAll('\\', '/').split('/').at(-1);
  need(normalized === candidate && !candidate.includes('..'), 'MULTIPART_MODULE_PATH_REJECTED');
  return normalized;
}

function findBoundary(body, separator, start) {
  let at = body.indexOf(separator, start);
  while (at >= 0) {
    const suffix = body.subarray(at + separator.length, at + separator.length + 2);
    if (suffix.equals(Buffer.from('\r\n')) || suffix.equals(Buffer.from('--'))) return at;
    at = body.indexOf(separator, at + 1);
  }
  return -1;
}

/** Parse raw Cloudflare content/v2 multipart bytes without hashing MIME framing. */
export function parseContentV2Multipart(contentType, body) {
  need(typeof contentType === 'string' && Buffer.isBuffer(body), 'MULTIPART_INPUT_INVALID');
  need(body.length <= 5 * 1024 * 1024, 'MULTIPART_BODY_TOO_LARGE');
  const type = /^multipart\/form-data\s*;(.*)$/i.exec(contentType);
  need(type, 'MULTIPART_CONTENT_TYPE_INVALID');
  const boundaryMatch = /(?:^|;)\s*boundary\s*=\s*(?:"([^"]+)"|([^;\s]+))/i.exec(type[1]);
  const boundary = boundaryMatch?.[1] ?? boundaryMatch?.[2];
  need(typeof boundary === 'string' && /^[A-Za-z0-9'()+_,./:=?-]{1,70}$/.test(boundary), 'MULTIPART_BOUNDARY_INVALID');

  const marker = Buffer.from(`--${boundary}`, 'ascii');
  const separator = Buffer.from(`\r\n--${boundary}`, 'ascii');
  const headersEnd = Buffer.from('\r\n\r\n', 'ascii');
  const parts = new Map();
  let cursor = body.indexOf(marker);
  need(cursor >= 0, 'MULTIPART_FIRST_BOUNDARY_MISSING');
  need(body.subarray(0, cursor).every(byte => byte === 0x0d || byte === 0x0a || byte === 0x20 || byte === 0x09), 'MULTIPART_PREAMBLE_REJECTED');

  while (cursor >= 0) {
    let afterMarker = cursor + marker.length;
    if (body.subarray(afterMarker, afterMarker + 2).equals(Buffer.from('--'))) {
      afterMarker += 2;
      const trailer = body.subarray(afterMarker);
      need(trailer.length === 0 || trailer.equals(Buffer.from('\r\n')), 'MULTIPART_TRAILING_DATA');
      return parts;
    }
    need(body.subarray(afterMarker, afterMarker + 2).equals(Buffer.from('\r\n')), 'MULTIPART_BOUNDARY_SYNTAX');
    const headerStart = afterMarker + 2;
    const endHeaders = body.indexOf(headersEnd, headerStart);
    need(endHeaders >= 0, 'MULTIPART_HEADERS_UNTERMINATED');
    const headerText = body.toString('latin1', headerStart, endHeaders);
    const headers = new Map();
    for (const line of headerText.split('\r\n')) {
      const colon = line.indexOf(':');
      need(colon > 0, 'MULTIPART_HEADER_INVALID');
      const key = line.slice(0, colon).trim().toLowerCase();
      need(/^[!#$%&'*+.^_`|~0-9a-z-]+$/.test(key) && !headers.has(key), 'MULTIPART_HEADER_DUPLICATE_OR_INVALID');
      headers.set(key, line.slice(colon + 1).trim());
    }
    const transfer = (headers.get('content-transfer-encoding') || 'binary').toLowerCase();
    need(['binary', '8bit', '7bit'].includes(transfer), 'MULTIPART_TRANSFER_ENCODING_REJECTED');
    const name = partName(headers);
    const bodyStart = endHeaders + headersEnd.length;
    const nextBoundary = findBoundary(body, separator, bodyStart);
    need(nextBoundary >= 0, 'MULTIPART_NEXT_BOUNDARY_MISSING');
    need(!parts.has(name), 'MULTIPART_DUPLICATE_MODULE');
    parts.set(name, Buffer.from(body.subarray(bodyStart, nextBoundary)));
    cursor = nextBoundary + 2;
  }
  throw new Error('MULTIPART_CLOSING_BOUNDARY_MISSING');
}

export function verifyPinnedV7Modules(contentType, multipartBytes, expected = V7_MODULE_SHA256) {
  need(expected && typeof expected === 'object' && !Array.isArray(expected), 'MODULE_HASH_MAP_INVALID');
  need(Object.keys(expected).length > 0 && Object.keys(expected).length <= 64, 'MODULE_HASH_MAP_INVALID');
  const modules = parseContentV2Multipart(contentType, multipartBytes);
  const expectedNames = Object.keys(expected).sort();
  need(modules.size === expectedNames.length, 'MODULE_SET_MISMATCH');
  const checked = [];
  for (const name of expectedNames) {
    const bytes = modules.get(name);
    need(bytes, 'MODULE_MISSING');
    const actual = hexDigest(bytes);
    need(safeEqualHex(actual, expected[name]), `MODULE_SHA256_MISMATCH:${name}`);
    checked.push(Object.freeze({ name, bytes: bytes.length, sha256: actual }));
  }
  for (const name of modules.keys()) need(Object.hasOwn(expected, name), `UNEXPECTED_MODULE:${name}`);
  return Object.freeze(checked);
}
