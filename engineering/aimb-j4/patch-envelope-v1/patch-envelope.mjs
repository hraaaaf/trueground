import { createHash, createPublicKey, verify as cryptoVerify } from 'node:crypto';

export const VERSION = 'patch-envelope-v1';
export const MAX_TTL_SECONDS = 120;
export const CLOCK_SKEW_SECONDS = 30;
export const MAX_NONCE_ENTRIES = 10_000;
export const MAX_DOCUMENT_BYTES = 64 * 1024;

const ENVELOPE_DOMAIN = Buffer.from('AIMB_PATCH_ENVELOPE_V1\0', 'utf8');
const APPROVAL_DOMAIN = Buffer.from('AIMB_OWNER_APPROVAL_V1\0', 'utf8');
const ACTION_SCOPE = Object.freeze({
  prepare: 'bridge.patch.prepare',
  apply: 'bridge.patch.apply',
  restart: 'bridge.task.restart',
  rollback: 'bridge.patch.rollback',
});
const TARGETS = new Set([
  'fixture:commands-agent',
  'fixture:files-agent',
  'fixture:workspace-agent',
  'fixture:projects-agent',
]);
const ENVELOPE_FIELDS = [
  'action', 'after_sha256', 'artifact_sha256', 'before_sha256', 'device_id',
  'expires_at', 'issued_at', 'nonce', 'operation_id', 'owner_subject',
  'plan_sha256', 'target', 'version',
];
const APPROVAL_FIELDS = [
  'envelope_sha256', 'expires_at', 'issued_at', 'nonce', 'operation_id',
  'owner_subject', 'scope', 'version',
];

function fail(code) { throw new Error(`PATCH_ENVELOPE:${code}`); }

function isRecord(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

function stable(value) {
  if (value === null || typeof value === 'string' || typeof value === 'boolean') return JSON.stringify(value);
  if (typeof value === 'number') {
    if (!Number.isSafeInteger(value)) fail('NON_INTEGER_NUMBER');
    return String(value);
  }
  if (Array.isArray(value)) return `[${value.map(stable).join(',')}]`;
  if (!isRecord(value)) fail('INVALID_JSON_VALUE');
  const keys = Object.keys(value).sort();
  return `{${keys.map((key) => `${JSON.stringify(key)}:${stable(value[key])}`).join(',')}}`;
}

export function canonicalJson(value) { return stable(value); }

function parseCanonicalDocument(input) {
  if (!(typeof input === 'string' || Buffer.isBuffer(input) || input instanceof Uint8Array)) fail('DOCUMENT_TYPE');
  const bytes = Buffer.isBuffer(input) || input instanceof Uint8Array ? Buffer.from(input) : Buffer.from(input, 'utf8');
  if (bytes.byteLength > MAX_DOCUMENT_BYTES) fail('DOCUMENT_TOO_LARGE');
  const raw = bytes.toString('utf8');
  if (Buffer.from(raw, 'utf8').compare(bytes) !== 0) fail('DOCUMENT_UTF8');
  let parsed;
  try { parsed = JSON.parse(raw); } catch { fail('DOCUMENT_JSON'); }
  if (!isRecord(parsed) || canonicalJson(parsed) !== raw) fail('DOCUMENT_NOT_CANONICAL');
  return parsed;
}

function exactKeys(value, fields, code) {
  if (!isRecord(value)) fail(code);
  const actual = Object.keys(value).sort();
  const expected = [...fields].sort();
  if (actual.length !== expected.length || actual.some((key, i) => key !== expected[i])) fail(code);
}

function nonEmptyString(value, max, code) {
  if (typeof value !== 'string' || value.length === 0 || value.length > max || !/^[\x21-\x7e]+$/.test(value)) fail(code);
}

function validUuid(value) {
  return typeof value === 'string' && /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/.test(value);
}

function validNonce(value) {
  if (typeof value !== 'string' || !/^[A-Za-z0-9_-]{22,64}$/.test(value)) return false;
  try {
    const bytes = Buffer.from(value, 'base64url');
    return bytes.length >= 16 && bytes.length <= 48 && bytes.toString('base64url') === value;
  } catch { return false; }
}

function validSha(value) { return typeof value === 'string' && /^[a-f0-9]{64}$/.test(value); }

function validateTimeWindow(claims, now, maxTtl, codePrefix) {
  if (!Number.isSafeInteger(claims.issued_at) || !Number.isSafeInteger(claims.expires_at)) fail(`${codePrefix}_TIME`);
  if (claims.issued_at > now + CLOCK_SKEW_SECONDS) fail(`${codePrefix}_NOT_YET_VALID`);
  if (claims.expires_at <= now) fail(`${codePrefix}_EXPIRED`);
  if (claims.expires_at <= claims.issued_at || claims.expires_at - claims.issued_at > maxTtl) fail(`${codePrefix}_TTL`);
}

function getEd25519PublicKey(keyring, keyId, codePrefix) {
  const keyValue = keyring instanceof Map ? keyring.get(keyId) : keyring?.[keyId];
  if (!keyValue) fail(`${codePrefix}_UNKNOWN_KEY`);
  try {
    if (keyValue?.type && keyValue.type !== 'public') fail(`${codePrefix}_PRIVATE_KEY_FORBIDDEN`);
    if (typeof keyValue === 'string' || Buffer.isBuffer(keyValue)) {
      const pem = Buffer.isBuffer(keyValue) ? keyValue.toString('utf8') : keyValue;
      const lines = pem.replace(/\r\n/g, '\n').split('\n');
      const endIndex = lines.indexOf('-----END PUBLIC KEY-----');
      const onlyOptionalFinalNewline = endIndex === lines.length - 1 || (endIndex === lines.length - 2 && lines.at(-1) === '');
      if (lines[0] !== '-----BEGIN PUBLIC KEY-----' || !onlyOptionalFinalNewline || endIndex < 2 || lines.slice(1, endIndex).some((line) => !/^[A-Za-z0-9+/=]+$/.test(line))) fail(`${codePrefix}_PUBLIC_KEY_REQUIRED`);
    }
    if (isRecord(keyValue) && !keyValue.type && Object.hasOwn(keyValue, 'd')) fail(`${codePrefix}_PRIVATE_KEY_FORBIDDEN`);
    if (isRecord(keyValue) && !keyValue.type && (keyValue.kty !== 'OKP' || keyValue.crv !== 'Ed25519' || typeof keyValue.x !== 'string' || !/^[A-Za-z0-9_-]{43}$/.test(keyValue.x))) fail(`${codePrefix}_PUBLIC_KEY_REQUIRED`);
    const key = keyValue?.type === 'public'
      ? keyValue
      : (isRecord(keyValue) ? createPublicKey({ key: keyValue, format: 'jwk' }) : createPublicKey(keyValue));
    if (key.asymmetricKeyType !== 'ed25519') fail(`${codePrefix}_KEY_TYPE`);
    return key;
  } catch (error) {
    if (error?.message?.startsWith('PATCH_ENVELOPE:')) throw error;
    fail(`${codePrefix}_KEY_INVALID`);
  }
}

function verifySignedDocument(document, domain, keyring, codePrefix) {
  exactKeys(document, ['key_id', 'payload', 'signature'], `${codePrefix}_SCHEMA`);
  nonEmptyString(document.key_id, 80, `${codePrefix}_KEY_ID`);
  if (!isRecord(document.payload)) fail(`${codePrefix}_PAYLOAD`);
  if (typeof document.signature !== 'string' || !/^[A-Za-z0-9_-]{86}$/.test(document.signature)) fail(`${codePrefix}_SIGNATURE_ENCODING`);
  const signature = Buffer.from(document.signature, 'base64url');
  if (signature.length !== 64 || signature.toString('base64url') !== document.signature) fail(`${codePrefix}_SIGNATURE_ENCODING`);
  const key = getEd25519PublicKey(keyring, document.key_id, codePrefix);
  const message = Buffer.concat([domain, Buffer.from(canonicalJson(document.payload), 'utf8')]);
  if (!cryptoVerify(null, message, key, signature)) fail(`${codePrefix}_SIGNATURE_INVALID`);
  return { payload: document.payload, key };
}

export class NonceLedger {
  #entries = new Map();
  #capacity;

  constructor({ capacity = MAX_NONCE_ENTRIES } = {}) {
    if (!Number.isSafeInteger(capacity) || capacity < 1 || capacity > MAX_NONCE_ENTRIES) fail('LEDGER_CAPACITY');
    this.#capacity = capacity;
  }

  claimMany(claims, now) {
    if (!Number.isSafeInteger(now) || !Array.isArray(claims) || claims.length < 1) fail('LEDGER_INPUT');
    const ids = claims.map((claim) => claim?.id);
    if (ids.some((id) => typeof id !== 'string' || !id) || new Set(ids).size !== ids.length) fail('NONCE_REUSE');
    for (const [id, expiresAt] of this.#entries) if (expiresAt <= now) this.#entries.delete(id);
    if (ids.some((id) => this.#entries.has(id))) fail('REPLAY');
    if (this.#entries.size + claims.length > this.#capacity) fail('LEDGER_FULL');
    for (const claim of claims) {
      if (!Number.isSafeInteger(claim.expiresAt) || claim.expiresAt <= now) fail('LEDGER_EXPIRY');
    }
    for (const claim of claims) this.#entries.set(claim.id, claim.expiresAt);
  }

  get size() { return this.#entries.size; }
}

function validateEnvelopePayload(payload, { now, expectedDeviceId, expectedIssuer, expectedAudience, verifiedPrincipal, targetAllowlist }) {
  exactKeys(payload, ENVELOPE_FIELDS, 'ENVELOPE_SCHEMA');
  if (payload.version !== VERSION) fail('VERSION');
  if (!validUuid(payload.operation_id)) fail('OPERATION_ID');
  nonEmptyString(payload.device_id, 80, 'DEVICE_ID');
  if (payload.device_id !== expectedDeviceId) fail('DEVICE_MISMATCH');
  if (!targetAllowlist.has(payload.target)) fail('TARGET_NOT_ALLOWED');
  if (!Object.hasOwn(ACTION_SCOPE, payload.action)) fail('ACTION_NOT_ALLOWED');
  for (const field of ['before_sha256', 'after_sha256', 'plan_sha256', 'artifact_sha256']) {
    if (!validSha(payload[field])) fail(`SHA_${field.toUpperCase()}`);
  }
  if (!validNonce(payload.nonce)) fail('NONCE');
  nonEmptyString(payload.owner_subject, 200, 'OWNER_SUBJECT');
  validateTimeWindow(payload, now, MAX_TTL_SECONDS, 'ENVELOPE');

  const p = verifiedPrincipal;
  if (!isRecord(p) || p.verified !== true) fail('PRINCIPAL_NOT_VERIFIED');
  if (p.issuer !== expectedIssuer) fail('PRINCIPAL_ISSUER');
  const audiences = Array.isArray(p.audience) ? p.audience : [p.audience];
  if (!audiences.includes(expectedAudience)) fail('PRINCIPAL_AUDIENCE');
  if (p.subject !== payload.owner_subject) fail('PRINCIPAL_SUBJECT');
  const requiredScopes = [ACTION_SCOPE[payload.action]];
  if (payload.action !== 'prepare') requiredScopes.push('bridge.patch.approve');
  if (!Array.isArray(p.scopes) || requiredScopes.some((scope) => !p.scopes.includes(scope))) fail('SCOPE_DENIED');
  return requiredScopes;
}

function verifyOwnerApproval(approval, envelopePayload, envelopeDigest, { now, ownerKeyring, serviceKey }) {
  if (approval === undefined || approval === null) fail('APPROVAL_REQUIRED');
  const { payload, key } = verifySignedDocument(approval, APPROVAL_DOMAIN, ownerKeyring, 'APPROVAL');
  const serviceFingerprint = createHash('sha256').update(serviceKey.export({ type: 'spki', format: 'der' })).digest('hex');
  const ownerFingerprint = createHash('sha256').update(key.export({ type: 'spki', format: 'der' })).digest('hex');
  if (serviceFingerprint === ownerFingerprint) fail('APPROVAL_KEY_REUSED');
  exactKeys(payload, APPROVAL_FIELDS, 'APPROVAL_CLAIMS_SCHEMA');
  if (payload.version !== 'owner-approval-v1') fail('APPROVAL_VERSION');
  if (payload.scope !== 'bridge.patch.approve') fail('APPROVAL_SCOPE');
  if (!validUuid(payload.operation_id) || payload.operation_id !== envelopePayload.operation_id) fail('APPROVAL_OPERATION');
  if (payload.envelope_sha256 !== envelopeDigest) fail('APPROVAL_ENVELOPE');
  if (payload.owner_subject !== envelopePayload.owner_subject) fail('APPROVAL_OWNER');
  if (!validNonce(payload.nonce) || payload.nonce === envelopePayload.nonce) fail('APPROVAL_NONCE');
  validateTimeWindow(payload, now, MAX_TTL_SECONDS, 'APPROVAL');
  if (payload.expires_at > envelopePayload.expires_at) fail('APPROVAL_OUTLIVES_ENVELOPE');
  return { payload, key };
}

/**
 * Offline verifier. `verifiedPrincipal` MUST come from a separately configured,
 * cryptographically verified identity adapter. This module deliberately does
 * not parse JWTs, touch the network, resolve paths, execute commands, or write.
 */
export function verifyPatchEnvelope({
  envelope: envelopeInput,
  approval: approvalInput,
  serviceKeyring,
  ownerKeyring,
  verifiedPrincipal,
  expectedIssuer,
  expectedAudience,
  expectedDeviceId,
  now = Math.floor(Date.now() / 1000),
  ledger,
}) {
  if (!Number.isSafeInteger(now)) fail('CLOCK');
  if (!(ledger instanceof NonceLedger)) fail('LEDGER_REQUIRED');
  if (typeof expectedIssuer !== 'string' || !expectedIssuer || typeof expectedAudience !== 'string' || !expectedAudience || typeof expectedDeviceId !== 'string' || !expectedDeviceId) fail('TRUST_CONFIG');
  const envelope = parseCanonicalDocument(envelopeInput);
  const { payload, key: serviceKey } = verifySignedDocument(envelope, ENVELOPE_DOMAIN, serviceKeyring, 'ENVELOPE');
  const requiredScope = validateEnvelopePayload(payload, {
    now, expectedDeviceId, expectedIssuer, expectedAudience, verifiedPrincipal, targetAllowlist: TARGETS,
  });
  const envelopeDigest = createHash('sha256').update(canonicalJson(payload), 'utf8').digest('hex');
  const needsApproval = payload.action === 'apply' || payload.action === 'restart' || payload.action === 'rollback';
  if (needsApproval && (approvalInput === undefined || approvalInput === null)) fail('APPROVAL_REQUIRED');
  const approval = needsApproval
    ? verifyOwnerApproval(parseCanonicalDocument(approvalInput), payload, envelopeDigest, { now, ownerKeyring, serviceKey })
    : null;

  const nonceClaims = [{ id: `envelope:${payload.device_id}:${payload.nonce}`, expiresAt: payload.expires_at }];
  if (approval) nonceClaims.push({ id: `approval:${payload.device_id}:${approval.payload.nonce}`, expiresAt: approval.payload.expires_at });
  ledger.claimMany(nonceClaims, now);
  return Object.freeze({
    version: VERSION,
    operationId: payload.operation_id,
    deviceId: payload.device_id,
    target: payload.target,
    action: payload.action,
    requiredScopes: Object.freeze([...requiredScope]),
    envelopeSha256: envelopeDigest,
    expiresAt: payload.expires_at,
    ownerApprovalVerified: approval !== null,
  });
}
