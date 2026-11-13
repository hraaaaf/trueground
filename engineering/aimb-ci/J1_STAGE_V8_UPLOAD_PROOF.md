# J1 staging Cloudflare — version V8 created, NOT deployed

**Date:** 2026-11-13  
**Target Worker:** `ai-machine-bridge-j1h-staging` (STAGING ONLY)  
**New un-deployed version:** `fccc8c0b-4680-4528-a0ed-02fd7132ecea` (V8)  
**Source Git commit pinned:** `2200f4c731ad1c5e9df92a5c75105b45668cf0be`  
**Worker script ETag from version upload:** `21fc4bc9e7c8bc367d781c8a2af6b87514fd5e410094c27bb9443925f23cbb97`  
**Existing active version preserved:** `605a258b-580e-4f32-b9b0-4e0bd8d0efcd` (V7, 100%).

## Upload evidence

Cloudflare Workers Upload Version API accepted a multipart upload containing:
- `v7-candidate/worker.js` — exact V7 worker body with two localized additions: import fixture MCP and route `/mcp`/protected-resource metadata.
- `v7-candidate/staging-result.mjs` — byte-identical to current V7 module.
- `minimal-mcp.mjs` — JWT RS256 verified, single static test fixture read tool; fails closed if Auth0 settings absent.
- `fixture.mjs` — public synthetic data, no patient or Lenovo data.

The version upload inherited, with strict validation, existing `STAGE_INTERNAL` (secret), `STAGING_DB` (D1), `STAGING_DO` (Durable Object namespace), and `STAGING_PUB_JWK` (original agent public key). Nothing secret was read or copied into GitHub.

Prior to upload we compared the GitHub V7 copy against the live V7 source. The result module matched exactly; the Worker matched exactly after applying the expected MCP-only edits. GitHub CI `43338922986` and `43339401655` passed seven jobs with offline Auth0/mocked fixture tests.

**Verified AFTER upload:** Cloudflare active deployment still points to V7 at 100%; V8 exists in the versions list, but was not deployed. No Auth0 settings were changed; no D1 fixture jobs were inserted or cleaned up. Production `ai-machine-bridge-j0d`, Windows tasks and H3 were untouched.

## Gates before activating V8

1. Identify and verify the actual ChatGPT/Auth0 OAuth client, redirect URI and `bridge.read` scope. Existing production OAuth authorization does not automatically establish staging MCP audience access.
2. Decide exact staging audience (resource) and authorize/configure it in Auth0. Do not reuse the production MCP audience silently.
3. Bind `AUTH0_ISSUER`, `AUTH0_AUDIENCE` and `AUTH0_ALLOWED_SUB` with an authenticated, approved user identity, and test access fail-closed. A known production requester subject alone does not prove the staging token can be issued.
4. Obtain explicit authorization for deployment of the tested V8 and the user-facing plugin connection; run `initialize`, `tools/list`, `tools/call` with an actual OAuth token. Compare exact fixture text.
5. If anything diverges, STOP; rollback to V7 `605a258b-580e-4f32-b9b0-4e0bd8d0efcd`. No additional permissions or persistent Windows agent.

**Status:** Version-upload PASS, *live deployment and real ChatGPT E2E NOT DONE*. Do not label this as plugin operational.
