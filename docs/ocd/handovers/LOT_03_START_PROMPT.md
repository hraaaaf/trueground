# HANDOVER — TrueGround OCD / LOT 02 → LOT 03

Repository: `hraaaaf/trueground`

Previous lot handover:
`docs/ocd/handovers/LOT_02_HANDOVER.md`

Previous lot contract:
`docs/ocd/lots/LOT_02_CLIENT_ISOLATION_CAPSULE_CONTRACT.md`

Target lot:
`LOT 03 — Application shell + design foundation`

Roadmap mapping:
`PHASE 2 — Application shell and design foundation`

Acceptance gate:
`GATE 2 — APP_SHELL_VERIFIED`

## STARTING REPOSITORY SNAPSHOT

This is a snapshot only. Re-check everything live before acting.

At prompt preparation time:

- PR #3 (`docs: LOT 02 define TrueGround client isolation and OCD capsule contract`) is merged into `lot/01-iamina-core-inspection`.
- LOT 02 merge commit on that branch: `5b5c588864b3bc413fcf281fb528ce3ca18bdfc9`.
- TrueGround `main` remained at `e1cdd5485e80c3c8bb4f7f5e3bdf695709111d61` after that merge.
- No production deployment was performed.
- No IAmina Core/runtime code was modified by LOT 02.
- No TrueGround runtime existed at LOT 02 closeout.

Do NOT trust these SHAs as current when LOT 03 starts.

## FIRST ACTIONS — READ BEFORE MODIFYING

Read, in this order:

1. `docs/ocd/handovers/LOT_02_HANDOVER.md`
2. `docs/ocd/lots/LOT_02_CLIENT_ISOLATION_CAPSULE_CONTRACT.md`
3. `docs/ocd/00_README.md`
4. `docs/ocd/01_PRODUCT_NORTH_STAR.md`
5. `docs/ocd/02_OCD_PRODUCT_SPEC.md`
6. `docs/ocd/04_IAMINA_CAPSULE_ARCHITECTURE.md`
7. `docs/ocd/05_DATA_PRIVACY_SECURITY.md`
8. `docs/ocd/06_ROADMAP_TO_TARGET.md`
9. `docs/ocd/07_ACCEPTANCE_GATES.md`
10. `docs/ocd/08_SPECIALIST_REVIEW_MATRIX.md`
11. `docs/ocd/09_LOT_WINDOW_HANDOVER_PROTOCOL.md`
12. `docs/ocd/assets/DASHBOARD_TARGET_V3.md`

Also inspect the actual repository tree before creating or modifying runtime files.

Do not infer that a stack, framework, folder structure, route, dependency, app identifier or build system exists merely because the roadmap expects an app shell.

## LIVE STATE VERIFICATION — MANDATORY

Before any modification, verify on GitHub:

- current default branch and SHA;
- current `lot/01-iamina-core-inspection` SHA;
- current LOT 02 merge state;
- whether a LOT 03 branch already exists;
- all open PRs and their exact base/head/state;
- ahead/behind divergence for the branch you intend to use;
- CI/check status;
- unresolved review comments/threads;
- current repository tree and dependency manifests, if any;
- current `hraaaaf/IAMINA-MVP main` HEAD if any shared Core reuse is contemplated.

If repository reality differs materially from this prompt or the LOT 02 handover, stop implementation and report the divergence before changing files.

## IMPORTANT STACK DECISION GATE

The roadmap requires an app bootstrap using the approved stack.

At prompt preparation time, the inspected canonical artifacts did not provide sufficient evidence of a formally approved concrete application stack for TrueGround.

Therefore LOT 03 must first determine whether an explicit stack decision already exists in the repository or a newer approved product decision.

If a concrete stack is already explicitly approved:
- cite the exact evidence;
- inspect the existing project/runtime before modifying it;
- continue inside that approved stack.

If no concrete stack is explicitly approved:
- DO NOT improvise;
- DO NOT bootstrap a framework;
- present the important decision as:
  - OPTION A
  - OPTION B
  - RECOMMENDATION
  - IMPACT
- wait for explicit product-owner validation before creating runtime/dependency files.

Choosing a new stack or adding foundational dependencies is an architecture decision, not a minor implementation detail.

## BEFORE MODIFICATION — STATE THIS EXPLICITLY

### GOAL

Create the smallest isolated TrueGround application shell capable of supporting the canonical Dashboard V3 navigation and visual system without implementing clinical/OCD behavior yet.

### SUCCESS

LOT 03 succeeds only if all applicable items below are proven:

- the approved stack is identified from explicit evidence before bootstrap;
- the app boots locally without production infrastructure;
- TrueGround is a separate client/runtime from Diabetes;
- no Diabetes app/module/runtime/data/auth dependency is pulled into the TrueGround shell;
- canonical navigation shell exists for `Home / Loop / Practice / Support / Profile`;
- typography, spacing, icon, component, surface/background and theme primitives exist at the minimum useful level;
- loading, empty and error-state conventions exist;
- responsive/mobile baseline exists;
- accessibility baseline exists;
- no clinical/OCD behavior, reassurance logic, Compulsion Firewall, ERP behavior, AI prompt policy, memory schema or data model is introduced;
- the shell can support the Dashboard V3 target in LOT 04 without prematurely implementing LOT 04 itself;
- local smoke tests pass;
- rendered screenshots are inspected, not only source code;
- non-regression and dependency-boundary checks are recorded;
- no deployment occurs.

### PROOF

Minimum expected proof:

- exact branch and commit SHA;
- changed-file list;
- local boot/run evidence;
- smoke-test commands and results;
- rendered screenshots at minimum 360 px and 390 px widths, plus any other explicitly supported target width;
- screenshot review for navigation, overflow, loading/empty/error conventions and accessibility-sensitive layout;
- specialist review ledger;
- CI/check state if CI exists;
- explicit statement of what was not tested;
- no production deployment.

## LOT 03 SCOPE — ALLOWED

Only the minimum application/design foundation required by roadmap Phase 2:

- app bootstrap in the explicitly approved stack;
- base application structure;
- canonical navigation shell;
- minimum design tokens for typography, spacing, icons, surfaces/backgrounds and theme;
- reusable generic shell/components only where justified by actual use;
- loading convention;
- empty-state convention;
- error-state convention;
- accessibility baseline;
- responsive/mobile viewport baseline;
- local/dev-only configuration needed to run the shell safely;
- smoke tests and focused UI/accessibility tests needed to prove the shell.

Keep changes small, isolated and auditable.

## LOT 03 SCOPE — FORBIDDEN / DEFERRED

Do NOT implement in LOT 03:

- the full Dashboard V3 static screen hierarchy beyond what is strictly required to prove the shell;
- Loop behavior;
- unrestricted chat;
- reassurance/checking/rumination handling;
- Compulsion Firewall behavior;
- ERP/practice behavior;
- AI provider integration;
- OCD prompts/policies/evals;
- longitudinal memory;
- real auth/data persistence unless separately required and approved for the shell;
- database tables, migrations or production schema;
- production secrets;
- production analytics;
- real-user data;
- crisis/support protocol;
- clinical claims;
- autonomous treatment behavior;
- unrelated refactors;
- framework abstractions that are not required by the shell;
- deployment to Vercel, TestFlight, Play Store or any external environment.

LOT 04 is the static Dashboard V3 target. Do not silently absorb LOT 04 into LOT 03.

## ARCHITECTURE BOUNDARY — NON-NEGOTIABLE

Preserve LOT 02 Option A:

`TrueGround composition -> TrueGround/OCD capsule -> approved generic IAmina Core primitives`

Forbidden:

- `IAmina Core -> OCD implementation`;
- `TrueGround -> Diabetes implementation`;
- `TrueGround runtime -> Diabetes runtime/API`;
- `TrueGround runtime -> Diabetes DB/cache/storage`;
- shared Diabetes auth/session as a shortcut;
- importing the existing Diabetes-coupled IAmina app composition unchanged;
- using `PatientModule` or a feature flag as the client-isolation mechanism.

If LOT 03 requires any IAmina Core source change, stop and treat it as a separate reviewed architecture change. Do not modify IAmina Core casually from the TrueGround lot.

## SPECIALIST REVIEWS — MANDATORY

Per `docs/ocd/08_SPECIALIST_REVIEW_MATRIX.md`, Phase 2 requires before verification:

- `UI_UX_AGENT`
- `ACCESSIBILITY_AGENT`
- `QA_NON_REGRESSION_AGENT`

The UI_UX review must inspect rendered screenshots, not only code.

If LOT 03 adds a new dependency or makes/changes a foundational architecture choice, also require as applicable:

- `ARCHITECTURE_AGENT`
- `DATA_PRIVACY_SECURITY_AGENT`

If any screen contains OCD-facing symptom/reassurance/practice/progress content beyond neutral shell placeholders, that is likely scope drift; stop and reassess rather than silently expanding the lot.

If no independent specialist-agent execution interface is available, explicitly record that limitation and perform separate adversarial review passes. Do not falsely claim independent human/model review.

Each reviewer must return exactly one:

- `PASS`
- `PASS_WITH_NOTES`
- `CHANGES_REQUIRED`
- `BLOCKED`
- `NOT_APPLICABLE` with explicit reason

Review principle:

`Find the strongest reason this should NOT be approved.`

## UI / UX VALIDATION

This is a significant UI foundation change, so provide visual evidence.

At minimum validate:

- 360 px width;
- 390 px width;
- any additional explicitly supported width;
- navigation ergonomics;
- no cutoff/overflow;
- text scaling does not destroy critical navigation;
- touch targets are reasonable;
- semantic labels/focus behavior where applicable;
- loading state;
- empty state;
- error state.

Because no prior TrueGround runtime shell existed at LOT 02 closeout, use target/reference vs implementation validation rather than inventing a fake “before” application screenshot.

Use `docs/ocd/assets/DASHBOARD_TARGET_V3.md` as the product/visual North Star, but do not claim pixel-perfect matching from the compressed 512×341 reference. LOT 03 is shell/design foundation; LOT 04 owns static Dashboard V3 reproduction.

## NON-REGRESSION

Verify at minimum:

- documentation and canonical contracts remain intact;
- no existing TrueGround docs are removed or silently contradicted;
- no Diabetes code/runtime behavior is modified unless separately authorized;
- no OCD-specific logic leaks into generic IAmina Core;
- local development does not require production data/secrets;
- dependency additions are minimal and justified;
- existing CI/checks continue to pass if they exist;
- actual local app behavior matches the claims made in the closeout.

A compiling build or green CI alone is not sufficient proof.

## MUTATION / RELEASE RULES

No merge without explicit product-owner approval.

No deployment without explicit product-owner approval.

No production database, production schema, real-user data, secrets or production configuration mutation without explicit product-owner approval.

Do not use production as a test environment.

## LOT END

At the end of LOT 03:

1. Stop. Do not start LOT 04 in the same window.
2. Create:
   - `docs/ocd/handovers/LOT_03_HANDOVER.md`
   - `docs/ocd/reviews/LOT_03_SPECIALIST_REVIEW.md`
3. Create `docs/ocd/handovers/LOT_04_START_PROMPT.md` only if LOT 04 is explicitly approved by the product owner.
4. Record exact repository truth at handover time:
   - branch;
   - base;
   - HEAD SHA;
   - ahead/behind;
   - PR state;
   - CI/checks;
   - unresolved threads;
   - screenshots/evidence paths.
5. Do not merge or deploy merely because Gate 2 reaches `VERIFIED`.

## REQUIRED FINAL FORMAT

Finish LOT 03 with exactly these chantier sections:

### Résultat
What was actually achieved.

### Modifications
Exact files/components changed.

### Tests
Exact commands/checks executed and results.

### Non-régression
What existing behavior and boundaries were checked.

### Preuves
SHA, PR, screenshots, logs, CI/checks and review artifacts.

### Risques
Remaining uncertainty and unresolved notes.

### État
One of:
- `NOT STARTED`
- `IN PROGRESS`
- `BLOCKED`
- `READY FOR REVIEW`
- `VERIFIED`

### Prochaine étape
One recommended next action only.

## EXECUTION PRINCIPLE

`READ → PLAN → EXECUTE → SPECIALIST REVIEW → VERIFY → HANDOVER`

Accuracy over speed. Proof over assumption. Stability over refactor. Approved scope over improvisation.
