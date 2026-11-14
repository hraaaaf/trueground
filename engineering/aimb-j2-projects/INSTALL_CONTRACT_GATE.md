# ODM #51 — J2 Projects narrow Windows integration contract

Status: **OFFLINE CONTRACT / NO-GO LIVE**. Stacked on PR #50 (which depends on #49 and #48). No Lenovo mutation, no merge and no cloud deployment.

## What has actually been built

- `install-evidence-contract.ps1`: a deterministic, read-only contract verifier. It accepts **synthetic fixture evidence only** and always returns `live_install_allowed=false`. SHA-256 mismatches, altered task identities, dangerous filesystem evidence, missing backups and unexpected privileged run levels fail closed.
- `install-evidence-contract.test.ps1`: negative fixtures for hash, backup, ACL, reparse, task drift and recovery escalation.
- `projects-local-preflight.readonly.ps1`: a local-only read inspector for source file hashes, simple reparse indicators, ACL owner/rule count and four task states. This is **diagnostic, not a secure Win32 attestation**. It neither performs writes nor is invoked by ChatGPT.
- One Windows PowerShell 5.1 CI job; no secrets, no remote machine access.

## Important: THIS IS NOT A LIVE INSTALLER

There is no privileged MCP tool, remote shell, file replacement primitive, stop/start Task Scheduler action or cryptographic owner approval channel here. These modules cannot install a patch or claim to prevent race conditions. A `true` fixture value is not proof of a native Windows state; the verifier deliberately rejects live use.

## Required independent proofs before authorizing any live installation

1. Obtain the complete active `workspace-agent.ps1` file **as bytes** via an authorized local attestation; record the exact SHA-256, encoding, path, target file ID and securely captured backup. The restricted plugin text reader cannot attest byte hashes.
2. Verify file handles and every ancestor directory against junctions/reparse points using a local audited Windows implementation, check DACL/owner against a trustworthy policy and protect against TOCTOU.
3. Capture and compare the exact four scheduled-task definitions, principals, states and run levels (not merely names). Ensure only Workspace will be affected; no general-purpose elevated command execution.
4. Verify a pinned, authorized signed manifest binding old and new hashes, target file identity, device and owner, approval nonce/expiration and explicit one-shot scope. Enforce signature-to-owner binding and durable anti-replay as appropriate; never trust a bare `verified=true` flag.
5. Implement the *separate* installer with exclusive handles, byte-exact backup, atomic staged switch, rollback after crash, retained journal, hash postchecks and safe recovery. It is **not** implemented by this PR.
6. Require distinct owner approval for exact bytes and restart effect. No install/merge/Cloudflare/D1/Auth0/plugin modification before that GO.
7. Upon successful local installation, verify Workspace identity/heartbeat, then perform three near-concurrent actual ChatGPT Projects reads: **3/3 DONE with nonempty content**, no expiration; measure queue latency, signed ACK and D1/DO costs. If any fails, stop and recover under the approved local protocol.

## Verified limits and priority

Real Lenovo presence is online, but the plugin reports `remote_commands=false`, and its admin scope reports `admin_execution_enabled=false`. The original Workspace Projects loop polls at most one job per 60-second iteration. The latest real burst was 1 DONE / 2 EXPIRED.

The objective of ODM #51 is reliable **development autonomy** through GitHub/CI; J4 autonomous self-repair is a separate, deferred project. Do not credit J2 completion on synthetic CI alone.

Roadmap canonical at the time of authoring: V2 **13/24 (54.2%)**, J2 **2/4 (50%)**, J4 **0/5 (0%)**.
