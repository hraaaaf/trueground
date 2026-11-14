# G2 — Import contract: Lenovo J1-DEV candidate into public trueground

**Destination**: `hraaaaf/trueground`, isolated branch `chore/aimb-g1-g3-windows-ci-20261112`, subdirectory `engineering/aimb-j1-dev/`. This repo is **PUBLIC**. No local private key, OAuth token, authorization headers, data fixtures from real patients/users, private configs, or environment files may be committed. Do not merge or deploy.

**Local source / provenance** (as reported by Codex, not yet independently re-fetched):
- Source worktree: `C:\Users\lenovo\Documents\Codex\2026-11-11\ordre-de-mission-codex-ai-machine\j1-dev-unblock-candidate\j1-dev-native-windows-candidate`
- Last documented local commit: `57b26d0cb3e1d84d801c1fea85b0c2414dbc285e`, with subsequent local P0 Auth0/RSA changes reported but no new commit established in this contract.
- Reference Notion: https://app.notion.com/p/41377c6633628166bebef6ca16a23102

## Required local preflight before any push

1. Create a **fresh, isolated export directory**; never `git add .` from the source worktree.
2. Produce an explicit **allowlist of source, tests, and documentation** needed to build J1-DEV. Copy only listed files. Exclude local/private key files, `.env*`, credentials, machine config, live audit logs and fixtures, PEM/P12/PFX/KEY, SQLite/D1 db dumps, cached OAuth tokens, `.git`, `node_modules`, `*.log`, recordings, screenshots, and personal filesystem metadata.
3. Audit every staged file by **filename, binary type, size and full content**, including leaked secrets inside `.md`, `.json`, `.js`, `.ps1`, and generated source. Replace real device identifiers, hosts, emails and user paths with documented sample placeholders when not needed for tests.
4. Scan with an established secret scanner (for example Gitleaks or equivalent), inspect its report, and do a second manual review of the complete staged diff. No result from a naive regex by itself justifies publication.
5. Compute SHA-256 for each exported file and a manifest; record source commit, intended new GitHub commit and diff. Confirm all files are appropriate for **public disclosure**.
6. Run offline tests, syntax checks and the Win32-only mocks on Lenovo. Do not read/transfer the pilot private RSA key.
7. Prepare a branch commit containing *only sanitized export files*, with **no live staging workflow changes**. Check the diff and secret audit once more **before push**.
8. Push ONLY the isolated branch on `hraaaaf/trueground`; leave PR #39 draft and do not merge. A user-authorized G2 transfer is not permission to deploy Cloudflare, access D1, change Auth0, start Windows tasks, or touch H3.
9. Return: commit URL, list of exported files, evidence SHA-256, scanner PASS, independent reviewer result, and test summary. ChatGPT will then inspect via GitHub connector and add a *new isolated offline CI job* for the candidate.

## Zero-leak / fail-closed rules

- If any source contains a real token, private JWK, OAuth secret, device signing key, private hostname/credential, personal data or ambiguous fixture, **STOP**. Document filenames only; never paste secret values into chat, GitHub Issues, PRs or Notion.
- If automatic git history would expose earlier sensitive material, **export a fresh sanitized snapshot**, never push the source branch history.
- Existing `engineering/aimb-j1h` tests and the CI run #27 validate the *old J1-H source only*, not the J1-DEV code.
- The new branch's offline workflow is `workflow_dispatch` only, and may be unavailable from GitHub's UI until its workflow file is in the default branch. Do not merge merely to enable it.
