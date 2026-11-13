# G2 sanitized import report

## Scope and provenance

- Repository target: public `hraaaaf/trueground`, isolated branch `chore/aimb-g1-g3-windows-ci-20261112`, under `engineering/aimb-j1-dev/`.
- Source worktree HEAD: `57b26d0cb3e1d84d801c1fea85b0c2414dbc285e`. Selected source files also contained local uncommitted candidate updates; only the explicit file snapshot and its hashes are transferred. No Git history is included.
- The exported candidate includes the developer bridge contract and quota model, foreground read-only Windows agent and native handle gate, signed-result and staging MCP read adapter/worker modules, V7 content-integrity check, tests, and the nested router integration candidate.
- Exact published file list and SHA-256 values are in `SHA256SUMS.txt`. Local validation logs, local PowerShell result JSON, key-generation utility, private/public key files, local proof bundles, and the source `.git` directory are excluded.

## Public-repository sanitization and review

- The source candidate contained real staging and Auth0 identifiers. In this export only, those values were replaced with reserved example hostnames, a sample Auth0 issuer, a synthetic device label, and reserved UUIDs. Any live staging values must be supplied only in a separately authorized private configuration; this snapshot must fail closed against real endpoints as exported.
- Gitleaks scan of the candidate source: PASS, zero findings after replacing one test-only nonce string that matched the generic-api-key rule. The test now generates a fresh random nonce at runtime. Scanner report was saved outside the source snapshot.
- Two-pass content review checked the explicit file inventory, source/tests, workflow, filenames, file sizes, private-key markers, secret-scan output, public endpoint/identity literals, and local path references. No private key, token, `.env`, local database, personal data, or local filesystem path is included in the published allowlist.
- The only workflow added is offline Windows CI, guarded to this branch and this directory, with read-only `contents` permission, immutable action SHAs, no secrets/environment, no staging requests, and no deploy step.
- Offline workflow SHA-256: `2fd6e7495600b91cd50cd055b997a1d5b7930af30d8e122bf4d537c651328f01`.

## CI correction record

- First candidate workflow run `43334495405` failed at the manifest step because the export publisher omitted `SHA256SUMS.txt` itself from the Git tree. The source manifest was valid; no Node or PowerShell candidate test ran in that attempt.
- Corrected the publication set to include the manifest file (which lists every other allowlisted source/document file), and refreshed its SHA-256 entries. A follow-up Windows CI run is required before calling G2 successful.
- The second run `43334713725` found a byte-level SHA mismatch after Windows checkout. The repository root attributes did not specify normalization for this new directory. Added a scoped `.gitattributes` rule (`* -text`) so the SHA manifest validates the exact committed bytes instead of line-ending-transformed working copies. A local regression probe with `core.autocrlf=true` passed. The workflow now includes the relative filename and expected/actual hashes in a future mismatch error; those diagnostics contain no secrets. The follow-up CI run must verify this fix.
- Third run `43335124720` passed credential checks, SHA manifest, and syntax, then failed in Node tests because the hosted Windows process is elevated and the native gate correctly returned `ELEVATED_PROCESS_DENIED`. The security gate remains unchanged. Added `run-restricted-windows-tests.ps1`, a fixed-suite launcher that uses a Windows restricted LUA token for Node, PowerShell 7, and Windows PowerShell 5.1 when the parent is elevated; it has no arbitrary command interface. The same launcher passed the three suites locally under the existing non-elevated Lenovo session. A fourth GitHub run must validate its restricted-token path.
- Fourth run `43335814239` launched the restricted Node suite, but `DISABLE_MAX_PRIVILEGE | LUA_TOKEN` prevented child PowerShell initialization (`0xC0000142`).
- Fifth run `43336070404` still returned `0xC0000142` for PowerShell children under the LUA-filtered process. The isolated-token approach is not reliable for the nested PowerShell test harness.
- Replaced that approach with a disposable local standard user created only on the ephemeral GitHub runner, granted read/execute on the candidate tree and modify access to its temporary logs, then deleted in `finally`. Its password is generated in memory and never emitted or stored. The candidate code's elevated-process rejection remains unchanged. This account-creation path has not yet been exercised by GitHub Actions; the next run is required to validate it. The Lenovo local non-elevated test results remain the direct evidence for the native path.
- Sixth run `43336977155` stopped before tests because the generated local account name exceeded Windows' 20-character limit. Shortened the random account name; no account or test process was created by that failed setup. The next run must validate the complete CI path.

## Local validation on Windows

- Node.js test suite: 89 passed, 0 failed, exit 0.
- JavaScript syntax checks: passed for all exported `.js` and `.mjs` files, exit 0.
- PowerShell 7 native Win32 adversarial suite: 17 passed, 0 failed, 0 skipped, exit 0.
- Windows PowerShell 5.1 native suite: 16 passed, 0 failed, 1 skipped, exit 0. `leaf-symlink-setup` was skipped because this Lenovo session is not elevated; the PowerShell 7 suite completed all 17 tests. No elevation was attempted. GitHub-hosted Windows CI must report this test's actual result separately.
- Git checkout line-ending regression probe: PASS with `core.autocrlf=true`; the scoped `.gitattributes` rule preserved the exact SHA-256 of a LF fixture through add/commit/checkout.
- Tests operate on synthetic temporary fixtures. No D1, Cloudflare Worker, Auth0, scheduled task, production agent, or H3 endurance process was accessed or changed.

## Limits and gate

This is an audited source import and offline CI candidate, not a live integration. The placeholder staging pins intentionally do not identify the deployed staging Worker, D1 database, or Auth0 tenant. No GitHub secret or variable was changed, no trusted/live workflow was run, no D1 write or deployment occurred, and PR #39 must remain draft and unmerged. A successful CI run validates this imported snapshot only; it does not authorize staging or production use.

## Seventh CI attempt and correction

- Run `43337188765` (`cd76f1366c93fa4ddae2e17a4612e9251bca67d0`) passed credential screening, the exported SHA-256 manifest, and syntax checks for 25 JavaScript files, but failed the Node suite. The failure was confined to test setup: the test process inherited the hosted administrator's `USERPROFILE` and `TEMP`, so the newly created standard account could not create its temporary fixtures there (`EPERM`).
- Updated the fixed-suite launcher to bootstrap the disposable user's Windows profile, resolve its registered path by the exact temporary SID, verify that path remains under `C:\Users\<temporary-user>`, and point child `USERPROFILE`, `TEMP`, and `TMP` to the disposable profile / ACL-scoped test directory. The native security gate and its non-elevated requirement are unchanged. The fixture E2E still uses only the exact allowlisted `%USERPROFILE%\AI_Machine_Bridge_DEV_FIXTURE` parent and removes the per-run fixture.
- Updated local run results after this correction: Node 89/89 PASS, PowerShell 7 17/17 PASS, and Windows PowerShell 5.1 16 PASS / 0 FAIL / 1 admin-only symlink-creation SKIP. The helper parser and changed JavaScript syntax checks pass. The complete elevated GitHub account/profile path still requires a new CI run.

- Eighth run `43338031993` failed at SHA verification before tests because its manifest contained the new report hash but the atomic Git tree update omitted the changed report file itself; CI correctly detected the inconsistency (`G2_IMPORT_REPORT.md`). This was a publication-set mistake, not a test/runtime failure. The next commit includes the report and manifest together, and the required candidate CI run must verify that exact tree.
