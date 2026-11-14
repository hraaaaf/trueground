# J1 P0 — Authenticated fixture MCP: tested, not deployed

**Code:** `engineering/aimb-j1-dev/minimal-mcp.mjs` and `v7-candidate/worker.js`, plus public bundled fixture `fixture.mjs`. The V7 candidate preserves `/health`, `/agent/batch/poll`, result routes, and StageSocket; it adds exactly `/mcp` and OAuth protected-resource metadata.

**Evidence:** [GitHub Actions run #46](https://github.com/hraaaaf/trueground/actions/runs/43338922986) completed **7/7 SUCCESS** (Windows Node 24 integrated tests and original six J1-H jobs). Tests used ephemeral RSA keys and a synthetic user identity. No live Auth0 tokens or production systems.

**Important distinction:** this first-slice fixture MCP reads only a **static test asset bundled with the Worker**. It does NOT read a real Windows Lenovo file, and no staging D1 jobs or writes are involved. It is an independent test slice, not the more advanced imported `staging-mcp-worker.mjs` / Windows J1-DEV runner.

## STOP gates before Cloudflare staging activation

1. Reconcile the imported G2 sanitized J1-DEV code and the new minimal fixture MCP. Use a reviewed staging-only deployment plan; never copy the public placeholder identifiers into live settings.
2. Confirm exact Auth0 issuer, API audience, `bridge.read` scope and the **verified real user's `sub`** using a legitimate OAuth Authorization Code + PKCE browser flow. No fabricated principal. The test candidate requires `AUTH0_ISSUER`, `AUTH0_AUDIENCE` and `AUTH0_ALLOWED_SUB`; absence denies every request.
3. Confirm ChatGPT plugin OAuth redirect URI, authorization server metadata and origin before release.
4. Preserve V7 rollback version `605a258b-580e-4f32-b9b0-4e0bd8d0efcd`, current staging D1 bindings and signed-agent routes. Deploy/roll back staging only after specific GO and with no production, Lenovo service, H3, GitHub protected-branch merge or Vercel change.
5. After live auth preflight, call `initialize`, `tools/list`, then `read_staging_fixture` from the ChatGPT connector and compare exact fixture content. A Node mock PASS is not a real plugin E2E.
6. DO NOT replace either RSA/JWK key used by V7 agents for this read-only public fixture proof.

**Current verdict:** OFFLINE PASS; LIVE STAGING / CHATGPT E2E NOT VALIDATED. Source stays on draft PR #39 until an authorized integration step.
