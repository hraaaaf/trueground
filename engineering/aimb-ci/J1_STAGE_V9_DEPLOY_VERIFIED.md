# J1 staging V9 — activation and HTTP smoke proof (2026-11-13)

## GOAL
Activate the minimal authenticated MCP fixture on staging, preserve production and V7 rollback, verify that anonymous access is rejected.

## SUCCESS
**STAGING V9 DEPLOYED 100%. HTTP SMOKE PASS. CHATGPT AUTHENTICATED E2E NOT YET VALIDATED.**

- Worker: `ai-machine-bridge-j1h-staging`
- Staging deployment: `fab2d2cc-3cdd-487c-b47b-167514750a30`
- Active version: `7c22ae21-d1a9-4c9a-abbf-817c3262efcc` (V9, 100%).
- Source fingerprint: `21fc4bc9e7c8bc367d781c8a2af6b87514fd5e410094c27bb9443925f23cbb97` (same JS fingerprint as V8 candidate).
- Rollback version: `605a258b-580e-4f32-b9b0-4e0bd8d0efcd` (V7).
- Production J0-D remains on `b5a594db-e092-4cad-8881-33c702262fac`, 100%.
- V9 inherits original STAGE_INTERNAL, STAGING_DB, STAGING_DO and STAGING_PUB_JWK bindings. It adds AUTH0_ISSUER, AUTH0_AUDIENCE and AUTH0_ALLOWED_SUB on **staging only**. No raw private identity or credentials are recorded in this document; AUTH0_ALLOWED_SUB was obtained from a previously authenticated project request by the same connected ChatGPT plugin.
- Staging OAuth audience/resource (NOT production): `https://ai-machine-bridge-j1h-staging.benmoussa-achraf.workers.dev/mcp`.

## Real HTTP validation

[GitHub Actions run 43389965419](https://github.com/hraaaaf/trueground/actions/runs/43389965419): seven jobs **COMPLETED SUCCESS**. In Windows staging transport job, after existing unsigned-WebSocket refusal check, new `engineering/aimb-j1h/staging-mcp-smoke.mjs` step completed **SUCCESS**:

- `GET /health` => HTTP 200; isolated staging D1 and Durable Object bound, production=false.
- `GET /.well-known/oauth-protected-resource` => HTTP 200; expected staging audience, HTTPS issuer, scope `bridge.read`.
- `GET /mcp` anonymous => HTTP 401 with `WWW-Authenticate` challenge.
- `POST /mcp` anonymous with `tools/list` JSON => HTTP 401.
- No user JWT or signed agent request sent, no D1 job written by this validation, no changes to Windows tasks, H3, or Vercel.

## Remaining blocker for J2

The ChatGPT plugin installed in the existing conversation still targets the **production J0-D MCP**. It does not automatically discover the new staging V9 tool. Live authenticated `initialize`, `tools/list`, `read_staging_fixture` were **not** tested through ChatGPT.

A separate ChatGPT web custom MCP connection or authorized plugin refresh must point to the staging URL. The OAuth client must be allowed to request an access token scoped to the staging audience, with real client registration/callback, PKCE and `bridge.read`; the OAuth application/API registration remains to verify in Auth0. Reuse of a production-audience token on staging is intentionally prohibited.

The available ChatGPT tools cannot create/edit the OAuth client in Auth0 or install/repoint a custom plugin in the user's ChatGPT UI. Those steps require the authorized account owner/admin. Do not falsely mark J2 complete.

## Rollback
Cloudflare Worker deployments API: deploy version `605a258b-580e-4f32-b9b0-4e0bd8d0efcd` at 100% to staging only if a test or security gate fails. No rollback was needed after the passing anonymous HTTP smoke tests.

**GO/NO-GO:** staging activation GO and anonymous network smoke PASS; authenticated ChatGPT J2 NO-GO pending OAuth client/ChatGPT connection.
