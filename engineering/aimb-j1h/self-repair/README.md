# AI Machine Bridge J2 P0 - offline self-repair foundation

**STATUS: CANDIDATE ONLY. NO deployment, no MCP registration, no automatic execution.**
This isolated folder belongs to canonical J1-H/J2. Do NOT merge it into TrueGround main.

## What is implemented

- An offline, allowlisted Windows repair engine for THREE legacy Bridge scripts only.
- Read-only inspect/plan, SHA-256 precondition, exact target line, validated cadence transition, plan ID, backup, file verification and byte-exact rollback.
- A separate local CLI exposing inspect, plan, apply, verify and rollback. APPLY requires the exact reviewed plan ID and is **not a real remote owner-authentication mechanism**.
- A PowerShell installer which is **dry-run by default**, checks a clean Git checkout against an explicit reviewed 40-digit commit SHA, Node.js 22+, SHA-256 copies, and installs **only the inert CLI files**.
- No cloud access, PowerShell execution, Windows Task Scheduler operation, credential access, arbitrary file editing, or background autonomous activity.

The only permitted source transitions in the current P0 engine are Commands 4->15 or 15->60; Files 4->60; Workspace 8->60. Already-corrected files are not patched. This intentionally does NOT permit generic remote code editing.

## Security limitation

The planId is only a local intent binding. It can NOT be treated as an Auth0 token, hardware approval, or authorization to run code through MCP. Before introducing remote APPLY, implement a separate non-self-editable signed updater with narrow OS permissions, Auth0 scope separation, explicit owner GO for each change, nonce/replay protection, immutable audit logs, ACL/reparse-path review, circuit breaker, and independent threat-model review. No arbitrary shell.

A script update without task restart does not change the running PowerShell process. This module DOES NOT restart tasks. No auto-rollback or automatic deployment of a new version exists yet.

## Codex local handover - installation only (after PR CI PASS)

1. Read the full PR diff and CI jobs; select the exact approved HEAD commit (40 hex digits), NOT a moving branch.
2. On the authorized Lenovo, clone a fresh, CLEAN disposable checkout of the repository and checkout that reviewed SHA. Do not introduce any PEM keys or secrets.
3. From that checkout, inspect the expected installer with PowerShell parser. Check its source hashes and run DRY RUN:

    powershell -NoProfile -File .\engineering\aimb-j1h\self-repair\install-local.ps1 -ExpectedCommit REVIEWED_COMMIT_SHA

4. If and only if owner installation approval and dry-run pass, run:

    powershell -NoProfile -File .\engineering\aimb-j1h\self-repair\install-local.ps1 -Install -ExpectedCommit REVIEWED_COMMIT_SHA

5. Verify only USERPROFILE\AI_Machine_Bridge_SelfRepair_P0 was created and contains cadence-core.mjs, repair-cli.mjs, README.md; hashes match source. Verify all existing Bridge tasks/PIDs/XML unchanged.
6. Smoke test read-only inspect (no write):

    node "$env:USERPROFILE\AI_Machine_Bridge_SelfRepair_P0\repair-cli.mjs" inspect --target commands
    node "$env:USERPROFILE\AI_Machine_Bridge_SelfRepair_P0\repair-cli.mjs" inspect --target files
    node "$env:USERPROFILE\AI_Machine_Bridge_SelfRepair_P0\repair-cli.mjs" inspect --target workspace

Expected only if scripts are unchanged since LOT A/B/C: Commands 15s, Files 60s, Workspace 60s. If source or SHA differs -> NO-GO; report without changes.

## CI and limits

Native offline tests with synthetic files; Windows/Linux Node22/24:
    node --test engineering/aimb-j1h/self-repair/cadence-core.test.mjs

On Windows, CI also PowerShell-parses the installer and performs a DRY RUN in the clean GitHub runner checkout. It NEVER invokes -Install, any agent script, scheduled task, Cloudflare or live MCP.

## Not yet implemented: main plugin self-healing

1. Secure versioned MCP and Cloudflare staging contract for fingerprint, redacted logs, prepare/validate, commit, verify, restart and rollback.
2. Signed, independently-reviewed on-device updater with owner approval/UAC when required.
3. Bounded Projects queue drain with TTL/ACK/idempotence and 60s fallback, without repeating the previous D1 quota incident.
4. H2-C signed staging proof, 24h D1/DO quota evidence, authorized Lenovo E2E with ChatGPT/iPhone.
5. Explicit GO before any activation/deployment/merge.

Canonical roadmap remains V2 13/24 PE = 54.2%, J2 2/4 PE = 50% pending acceptance of new gates.
