# patch-envelope-v1 (offline Gate B candidate)

This package defines and verifies an offline, signed patch authorization envelope. It is deliberately not connected to the AI Machine Bridge plugin, a Worker, D1, Windows services, Task Scheduler, filesystem paths, or a patch executor.

## Wire shape

The envelope is canonical UTF-8 JSON with exactly `{ "key_id", "payload", "signature" }`. The signature is Ed25519 over `AIMB_PATCH_ENVELOPE_V1\0 || canonicalJson(payload)`. The payload is an exact-schema object containing the version, operation/device IDs, a symbolic fixture target, one allowlisted action, before/after/plan/artifact SHA-256 values, issue/expiry seconds, a base64url nonce, and owner subject. Canonical JSON uses lexicographically sorted keys, compact separators, UTF-8, and safe integer numbers only. Signed claim strings are printable ASCII and UUID text is lowercase. The raw bytes must match the canonical serialization; this rejects whitespace variants, duplicate keys, and alternate encodings.

The required scope is derived from the action in code. The caller cannot choose a weaker scope. `prepare` needs its service signature and a trusted, verified principal with `bridge.patch.prepare`. `apply`, `restart`, and `rollback` additionally require both the action scope and `bridge.patch.approve`, plus a separately signed Ed25519 owner approval bound to the SHA-256 of the exact canonical envelope payload, operation ID, owner subject, expiry, and a distinct nonce. Owner approval keys are supplied separately from service signing keys, and key reuse is rejected. Private key objects, private PEM, and private JWK material are rejected by the verifier.

Targets are symbolic fixture identifiers only; no path or command is accepted. Documents are capped at 64 KiB before parsing. The module has no imports for filesystem, network, child-process, or OS control APIs.

## Trust boundary and limits

`verifiedPrincipal` must be created by an upstream identity adapter only after it validates an Auth0 JWT signature, issuer, audience, expiry, and required claims. This package does not parse or cryptographically validate JWTs and does not establish that an arbitrary JavaScript object marked `verified` is trustworthy. Callers must not pass raw JWT claims or a client-supplied identity object.

`NonceLedger` provides synchronous, bounded, fail-closed replay checks for one in-memory process. It is suitable for offline validation/tests only. It is not durable across restarts and cannot coordinate multiple processes or hosts. A live implementation needs an atomic, durable, bounded nonce store and Windows-native path/handle/ACL enforcement before any mutation can be authorized. Passing these tests is not an integration, installation, or production-readiness claim.

## Local validation

No package installation is needed (Node.js built-ins only):

```text
node --check engineering/aimb-j4/patch-envelope-v1/patch-envelope.mjs
node --check engineering/aimb-j4/patch-envelope-v1/patch-envelope.test.mjs
node --test engineering/aimb-j4/patch-envelope-v1/patch-envelope.test.mjs
```

CI runs the same tests on Windows and Linux with Node 22 and 24. Tests generate ephemeral Ed25519 keys in memory; no private key material is written or logged.
