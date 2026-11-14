# Gate B — second-pass security review

Date: 2026-11-14. Scope: offline `patch-envelope-v1` verifier, its negative tests, and the dedicated PR CI workflow. This is a second review pass after implementation by the same author; it is not represented as an independent third-party audit.

## Findings and disposition

| Finding | Severity for live use | Disposition |
|---|---:|---|
| A caller could forge a `{ verified: true }` principal object if it bypasses the trusted identity adapter. | Critical | The module takes only an already-verified-principal contract; README explicitly requires upstream JWT signature/issuer/audience/expiry validation. No live integration is allowed by this candidate. Remains a mandatory integration gate. |
| Process-local nonce memory does not survive restart or coordinate multiple processes. | Critical | Ledger bounded at 10,000, synchronous, atomic within one Node process, and fails closed when full. README states a durable atomic ledger is required before live use. Remains a mandatory integration gate. |
| This package does not enforce Windows path identity, handles, ACLs, reparse/junction checks, transaction recovery, or execute patches. | Critical | Intentionally out of scope; only symbolic fixture targets are accepted and there are no filesystem/process/network imports. Remains a mandatory Win32/native gate. |
| A reused service/owner key could undermine separate approval authority. | High | Verifier rejects identical public-key fingerprints across the two signing roles. Negative test included. |
| Private signing key material could accidentally be supplied as a verifier trust key. | High | Verifier accepts public `KeyObject`/public PEM/JWK only and rejects private key objects, PEM, and JWK `d`. Negative test included. |
| Large/noncanonical documents could create parser ambiguity or excess allocation. | Medium | Raw document capped at 64 KiB before parse; malformed UTF-8, noncanonical serialization, duplicate keys, unknown fields, and non-integer numbers fail closed. Negative tests included. |
| Action/scope confusion could elevate a preparation envelope. | High | Required scopes are derived from an internal action map; all mutating actions require both their action scope and `bridge.patch.approve`, plus a separately signed owner approval bound to the envelope digest. Negative tests included. |

## Review checks

- Signature algorithms are fixed to Ed25519 with domain separation; no algorithm negotiation.
- Envelope and approval use distinct trusted keyrings and distinct signature domains.
- Approval binds operation ID, envelope-payload SHA-256, owner subject, scope, issue/expiry, and a separate nonce.
- Replay entries are claimed together only after all validation passes; live entries are not evicted to make room.
- TTL is capped at 120 seconds with 30 seconds future clock skew; exact expiry is rejected.
- Targets/actions are fixed symbolic fixture identifiers; no path, command, shell, Worker, MCP, D1, or Windows service API is present.
- PR CI uses read-only permissions, ephemeral test keys, no secrets, no staging calls, and SHA-pinned checkout/setup-node actions.

## Verdict

**GO for offline review/CI only. NO-GO for any identity adapter, MCP/Worker connection, Windows installation, patch application, task restart, merge, or deployment.** The candidate does not resolve the native Windows filesystem blockers from Gate A.
