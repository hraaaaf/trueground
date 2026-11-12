# AI Machine Bridge — Windows CI on trueground

This is the **public** repository `hraaaaf/trueground`. The workflow added on this branch is restricted to **offline validation of code already present in** `engineering/aimb-j1h`.

## Guarantees and exclusions

- `.github/workflows/aimb-p0-windows-ci.yml` only has `workflow_dispatch`; it does **not** deploy Cloudflare, Vercel, or D1 and has no Auth0 action.
- It pins checkout/setup-node, runs as `windows-latest`, uses a read-only GitHub token and disables credential persistence.
- Syntax-checks JS, executes Node integrity/unit/mock tests, and only **parses**, never executes, `windows-gate.ps1`.
- Uploads seven-day test evidence with SHA-256 hashes.
- Basic key-file and PEM scanning is **not an exhaustive secrets audit**.
- It does **not** exercise remote Lenovo files, native Win32 fixture tests, or the latest unpushed J1-DEV local candidate.
- A GitHub-hosted runner is ephemeral, **not** a permanent ChatGPT MCP/Windows agent.

## Manual testing and approval gate

1. Review the branch diff. Do not turn on the existing trusted signed-staging workflow or upload the local RSA key.
2. The new workflow is branch-gated. GitHub may require the workflow to be present on the repository's default branch to dispatch it through the standard UI/API; it is **not yet a CI PASS**.
3. To run it, first explicitly authorize the workflow placement and dispatch. Inspect the evidence artifact after the run.
4. Before importing source from Lenovo, require a file-by-file secret audit (not just the scanner) and ensure the source can be made public.
5. Separate GO required for any staging write/deployment, GitHub protected branch merge, or production operation.

## Milestones

- G1: `trueground` selected by the user (PUBLIC); isolated branch prepared. Private repository creation intentionally canceled.
- G2: latest Lenovo candidate not imported.
- G3: Windows CI workflow prepared and committed; GitHub Actions run pending.
