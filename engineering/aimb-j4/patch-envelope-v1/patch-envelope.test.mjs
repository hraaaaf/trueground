import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  createHash, generateKeyPairSync, randomBytes, sign,
} from 'node:crypto';
import {
  canonicalJson, NonceLedger, verifyPatchEnvelope,
} from './patch-envelope.mjs';

const NOW = 1_800_000_000;
const ISSUER = 'https://identity.example.test/';
const AUDIENCE = 'aimb-j4-offline-test';
const DEVICE = 'fixture-device-01';
const SUBJECT = 'auth0|offline-owner-fixture';
const hash = (label) => createHash('sha256').update(label).digest('hex');
const nonce = () => randomBytes(18).toString('base64url');
const keys = () => generateKeyPairSync('ed25519');
const service = keys();
const owner = keys();
const serviceKeyring = new Map([['service-test', service.publicKey]]);
const ownerKeyring = new Map([['owner-test', owner.publicKey]]);
const principal = (overrides = {}) => ({
  verified: true, issuer: ISSUER, audience: [AUDIENCE], subject: SUBJECT,
  scopes: ['bridge.patch.prepare', 'bridge.patch.apply', 'bridge.task.restart', 'bridge.patch.rollback', 'bridge.patch.approve'],
  ...overrides,
});
const basePayload = (overrides = {}) => ({
  action: 'prepare', after_sha256: hash('after'), artifact_sha256: hash('artifact'),
  before_sha256: hash('before'), device_id: DEVICE, expires_at: NOW + 60,
  issued_at: NOW, nonce: nonce(), operation_id: '8f09e604-9c08-4c6d-af67-4991884f71de',
  owner_subject: SUBJECT, plan_sha256: hash('plan'), target: 'fixture:commands-agent',
  version: 'patch-envelope-v1', ...overrides,
});
function signedDocument(payload, pair, keyId, domain) {
  const message = Buffer.concat([Buffer.from(domain), Buffer.from(canonicalJson(payload))]);
  return { key_id: keyId, payload, signature: sign(null, message, pair.privateKey).toString('base64url') };
}
function envelope(payload = basePayload(), pair = service, keyId = 'service-test') {
  return canonicalJson(signedDocument(payload, pair, keyId, 'AIMB_PATCH_ENVELOPE_V1\0'));
}
function approvalFor(payload, overrides = {}, pair = owner, keyId = 'owner-test') {
  const digest = createHash('sha256').update(canonicalJson(payload)).digest('hex');
  const claims = {
    envelope_sha256: digest, expires_at: Math.min(payload.expires_at, NOW + 50),
    issued_at: NOW, nonce: nonce(), operation_id: payload.operation_id,
    owner_subject: payload.owner_subject, scope: 'bridge.patch.approve',
    version: 'owner-approval-v1', ...overrides,
  };
  return canonicalJson(signedDocument(claims, pair, keyId, 'AIMB_OWNER_APPROVAL_V1\0'));
}
function run({ payload = basePayload(), approval, principalValue = principal(), ledger = new NonceLedger(), now = NOW, envelopeText, serviceRing = serviceKeyring, ownerRing = ownerKeyring } = {}) {
  return verifyPatchEnvelope({
    envelope: envelopeText ?? envelope(payload), approval, serviceKeyring: serviceRing,
    ownerKeyring: ownerRing, verifiedPrincipal: principalValue, expectedIssuer: ISSUER,
    expectedAudience: AUDIENCE, expectedDeviceId: DEVICE, now, ledger,
  });
}
function expectCode(code, fn) { assert.throws(fn, new RegExp(`PATCH_ENVELOPE:${code}`)); }

test('valid prepare envelope verifies and returns the derived scope', () => {
  const result = run();
  assert.deepEqual(result.requiredScopes, ['bridge.patch.prepare']);
  assert.equal(result.ownerApprovalVerified, false);
  assert.match(result.envelopeSha256, /^[a-f0-9]{64}$/);
});

test('valid apply envelope requires and verifies a separate owner approval', () => {
  const payload = basePayload({ action: 'apply' });
  const result = run({ payload, approval: approvalFor(payload) });
  assert.deepEqual(result.requiredScopes, ['bridge.patch.apply', 'bridge.patch.approve']);
  assert.equal(result.ownerApprovalVerified, true);
});

test('valid restart and rollback require owner approval', () => {
  for (const action of ['restart', 'rollback']) {
    const payload = basePayload({ action });
    assert.equal(run({ payload, approval: approvalFor(payload) }).action, action);
  }
});

test('scope is derived from action, not supplied by the envelope', () => {
  const payload = basePayload({ action: 'apply', scope: 'bridge.patch.prepare' });
  expectCode('ENVELOPE_SCHEMA', () => run({ payload }));
});

test('missing required action scope is rejected', () => {
  const payload = basePayload({ action: 'apply' });
  expectCode('SCOPE_DENIED', () => run({ payload, approval: approvalFor(payload), principalValue: principal({ scopes: ['bridge.patch.prepare'] }) }));
});
test('mutating action also requires the independent owner-approval scope', () => {
  const payload = basePayload({ action: 'apply' });
  expectCode('SCOPE_DENIED', () => run({ payload, approval: approvalFor(payload), principalValue: principal({ scopes: ['bridge.patch.apply'] }) }));
});

test('unverified identity is rejected', () => expectCode('PRINCIPAL_NOT_VERIFIED', () => run({ principalValue: principal({ verified: false }) })));
test('identity issuer mismatch is rejected', () => expectCode('PRINCIPAL_ISSUER', () => run({ principalValue: principal({ issuer: 'https://wrong.test/' }) })));
test('identity audience mismatch is rejected', () => expectCode('PRINCIPAL_AUDIENCE', () => run({ principalValue: principal({ audience: ['other'] }) })));
test('identity subject must match the signed owner subject', () => expectCode('PRINCIPAL_SUBJECT', () => run({ principalValue: principal({ subject: 'auth0|other' }) })));
test('device identity is bound to expected device', () => expectCode('DEVICE_MISMATCH', () => run({ payload: basePayload({ device_id: 'other-device' }) })));
test('target outside symbolic fixture allowlist is rejected', () => expectCode('TARGET_NOT_ALLOWED', () => run({ payload: basePayload({ target: '../../outside.ps1' }) })));
test('arbitrary action is rejected', () => expectCode('ACTION_NOT_ALLOWED', () => run({ payload: basePayload({ action: 'exec' }) })));
test('invalid operation id is rejected', () => expectCode('OPERATION_ID', () => run({ payload: basePayload({ operation_id: 'not-a-uuid' }) })));
test('uppercase UUID text is rejected to avoid noncanonical operation identifiers', () => expectCode('OPERATION_ID', () => run({ payload: basePayload({ operation_id: '8F09E604-9C08-4C6D-AF67-4991884F71DE' }) })));
test('non-ASCII owner subject is rejected by the wire profile', () => expectCode('OWNER_SUBJECT', () => run({ payload: basePayload({ owner_subject: 'auth0|owner-é' }), principalValue: principal({ subject: 'auth0|owner-é' }) })));
test('uppercase or malformed artifact digest is rejected', () => expectCode('SHA_ARTIFACT_SHA256', () => run({ payload: basePayload({ artifact_sha256: 'A'.repeat(64) }) })));
test('malformed short nonce is rejected', () => expectCode('NONCE', () => run({ payload: basePayload({ nonce: 'short' }) })));

test('expired envelope is rejected at exact expiry boundary', () => expectCode('ENVELOPE_EXPIRED', () => run({ payload: basePayload({ expires_at: NOW }), now: NOW })));
test('envelope may expire one second after now', () => assert.equal(run({ payload: basePayload({ expires_at: NOW + 1 }) }).action, 'prepare'));
test('envelope issued too far in future is rejected', () => expectCode('ENVELOPE_NOT_YET_VALID', () => run({ payload: basePayload({ issued_at: NOW + 31, expires_at: NOW + 90 }) })));
test('envelope TTL above 120 seconds is rejected', () => expectCode('ENVELOPE_TTL', () => run({ payload: basePayload({ expires_at: NOW + 121 }) })));
test('envelope TTL exactly 120 seconds is accepted', () => assert.equal(run({ payload: basePayload({ expires_at: NOW + 120 }) }).action, 'prepare'));
test('expired approval is rejected', () => {
  const payload = basePayload({ action: 'apply' });
  expectCode('APPROVAL_EXPIRED', () => run({ payload, approval: approvalFor(payload, { expires_at: NOW }) }));
});
test('approval cannot outlive its envelope', () => {
  const payload = basePayload({ action: 'apply', expires_at: NOW + 40 });
  expectCode('APPROVAL_OUTLIVES_ENVELOPE', () => run({ payload, approval: approvalFor(payload, { expires_at: NOW + 50 }) }));
});

test('signature tampering is rejected', () => {
  const payload = basePayload();
  const doc = JSON.parse(envelope(payload));
  doc.payload.target = 'fixture:files-agent';
  expectCode('ENVELOPE_SIGNATURE_INVALID', () => run({ payload, envelopeText: canonicalJson(doc) }));
});
test('unknown service signing key is rejected', () => {
  const payload = basePayload();
  const text = envelope(payload, service, 'unknown');
  expectCode('ENVELOPE_UNKNOWN_KEY', () => run({ payload, envelopeText: text }));
});
test('private service key material is refused by the verifier', () => {
  const payload = basePayload();
  expectCode('ENVELOPE_PRIVATE_KEY_FORBIDDEN', () => run({ payload, serviceRing: new Map([['service-test', service.privateKey]]) }));
});
test('public PEM key is accepted while appended private material is rejected', () => {
  const payload = basePayload();
  const publicPem = service.publicKey.export({ type: 'spki', format: 'pem' });
  assert.equal(run({ payload, serviceRing: new Map([['service-test', publicPem]]) }).action, 'prepare');
  const mixed = `${publicPem}${service.privateKey.export({ type: 'pkcs8', format: 'pem' })}`;
  expectCode('ENVELOPE_PUBLIC_KEY_REQUIRED', () => run({ payload, serviceRing: new Map([['service-test', mixed]]) }));
});
test('public Ed25519 JWK is accepted', () => {
  const payload = basePayload();
  const publicJwk = service.publicKey.export({ format: 'jwk' });
  assert.equal(run({ payload, serviceRing: new Map([['service-test', publicJwk]]) }).action, 'prepare');
});
test('private JWK is rejected even when its public coordinates are valid', () => {
  const payload = basePayload();
  const privateJwk = service.privateKey.export({ format: 'jwk' });
  expectCode('ENVELOPE_PRIVATE_KEY_FORBIDDEN', () => run({ payload, serviceRing: new Map([['service-test', privateJwk]]) }));
});
test('wrong algorithm key type is rejected', () => {
  const rsa = generateKeyPairSync('rsa', { modulusLength: 2048 });
  const payload = basePayload();
  expectCode('ENVELOPE_KEY_TYPE', () => run({ payload, serviceRing: new Map([['service-test', rsa.publicKey]]) }));
});
test('noncanonical whitespace is rejected', () => {
  const text = envelope();
  expectCode('DOCUMENT_NOT_CANONICAL', () => run({ envelopeText: ` ${text}` }));
});
test('oversized signed document is rejected before JSON parsing', () => {
  expectCode('DOCUMENT_TOO_LARGE', () => run({ envelopeText: ' '.repeat(64 * 1024 + 1) }));
});
test('invalid UTF-8 byte sequence is rejected', () => {
  expectCode('DOCUMENT_UTF8', () => run({ envelopeText: Buffer.from([0xc3, 0x28]) }));
});
test('duplicate JSON keys are rejected by canonical-byte comparison', () => {
  expectCode('DOCUMENT_NOT_CANONICAL', () => run({ envelopeText: '{"key_id":"a","key_id":"b","payload":{},"signature":"x"}' }));
});
test('unknown envelope wrapper fields are rejected', () => {
  const doc = JSON.parse(envelope()); doc.extra = true;
  expectCode('ENVELOPE_SCHEMA', () => run({ envelopeText: canonicalJson(doc) }));
});

test('mutating envelope requires owner approval', () => {
  const payload = basePayload({ action: 'apply' });
  expectCode('APPROVAL_REQUIRED', () => run({ payload }));
});
test('owner approval signature is checked against a separate keyring', () => {
  const payload = basePayload({ action: 'apply' });
  const wrongOwner = keys();
  expectCode('APPROVAL_SIGNATURE_INVALID', () => run({ payload, approval: approvalFor(payload, {}, wrongOwner) }));
});
test('owner approval key must be cryptographically distinct from service signing key', () => {
  const payload = basePayload({ action: 'apply' });
  const reusedOwnerRing = new Map([['owner-test', service.publicKey]]);
  const approval = approvalFor(payload, {}, service);
  expectCode('APPROVAL_KEY_REUSED', () => run({ payload, approval, ownerRing: reusedOwnerRing }));
});
test('owner approval is bound to exact envelope bytes and operation', () => {
  const payload = basePayload({ action: 'apply' });
  const approval = approvalFor({ ...payload, plan_sha256: hash('different-plan') });
  expectCode('APPROVAL_ENVELOPE', () => run({ payload, approval }));
});
test('owner approval subject and scope are checked', () => {
  const payload = basePayload({ action: 'apply' });
  expectCode('APPROVAL_OWNER', () => run({ payload, approval: approvalFor(payload, { owner_subject: 'other' }) }));
  expectCode('APPROVAL_SCOPE', () => run({ payload, approval: approvalFor(payload, { scope: 'bridge.patch.apply' }) }));
});

test('exact envelope replay is rejected', () => {
  const payload = basePayload(); const text = envelope(payload); const ledger = new NonceLedger();
  run({ payload, envelopeText: text, ledger });
  expectCode('REPLAY', () => run({ payload, envelopeText: text, ledger }));
});
test('approval nonce must differ from envelope nonce', () => {
  const payload = basePayload({ action: 'apply' });
  expectCode('APPROVAL_NONCE', () => run({ payload, approval: approvalFor(payload, { nonce: payload.nonce }) }));
});
test('envelope and approval nonces are claimed together after validation', () => {
  const payload = basePayload({ action: 'apply' }); const ledger = new NonceLedger({ capacity: 1 });
  expectCode('LEDGER_FULL', () => run({ payload, approval: approvalFor(payload), ledger }));
  assert.equal(ledger.size, 0, 'failed multi-claim must not partially consume the nonce');
});
test('nonce ledger fails closed at capacity without evicting a live nonce', () => {
  const ledger = new NonceLedger({ capacity: 1 }); ledger.claimMany([{ id: 'a', expiresAt: NOW + 10 }], NOW);
  expectCode('LEDGER_FULL', () => ledger.claimMany([{ id: 'b', expiresAt: NOW + 10 }], NOW));
  assert.equal(ledger.size, 1);
});
test('nonce ledger evicts expired entries and accepts new nonce', () => {
  const ledger = new NonceLedger({ capacity: 1 }); ledger.claimMany([{ id: 'old', expiresAt: NOW }], NOW - 1);
  ledger.claimMany([{ id: 'new', expiresAt: NOW + 5 }], NOW); assert.equal(ledger.size, 1);
});
test('duplicate claims in one atomic request are rejected', () => {
  const ledger = new NonceLedger();
  expectCode('NONCE_REUSE', () => ledger.claimMany([{ id: 'same', expiresAt: NOW + 5 }, { id: 'same', expiresAt: NOW + 6 }], NOW));
});
