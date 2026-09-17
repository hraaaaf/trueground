# 07 — ACCEPTANCE GATES

Status: DRAFT FOR REVIEW
Date: 2026-09-16

## GOAL

Define what evidence is required before a phase or feature can move from `READY FOR REVIEW` to `VERIFIED`.

A green CI is evidence, not completion.

All gates are also subject to `10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md`.

## Global rules

A gate is `VERIFIED` only when:

- requested scope is implemented;
- relevant tests pass;
- real behavior has been checked;
- non-regression has been checked;
- required screenshots/evidence exist;
- required specialist reviews from `08_SPECIALIST_REVIEW_MATRIX.md` are recorded;
- every mandatory specialist includes the required severe score `/10`;
- material stages have execution scores and adversarial re-scores;
- the applicable strict-scoring thresholds from `10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md` are met;
- known risks are documented;
- no release blocker remains hidden;
- product-owner approval is obtained where explicitly required.

A high numerical score cannot override a failed binary gate, blocker or missing required evidence.

A **lot** is not considered execution-closed merely because its acceptance gate is `VERIFIED`.

Lot closure additionally requires the handover package defined in `09_LOT_WINDOW_HANDOVER_PROTOCOL.md` and the final strict scorecard defined in `10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md`:

- `docs/ocd/handovers/LOT_XX_HANDOVER.md`;
- `docs/ocd/handovers/LOT_YY_START_PROMPT.md` when the next approved lot is known;
- exact repository-state snapshot at handover time;
- final adversarial lot audit;
- `FINAL_LOT_SCORE >= 9.0` for a lot called `VERIFIED`.

Allowed verification status values:

- `NOT STARTED`
- `IN PROGRESS`
- `BLOCKED`
- `READY FOR REVIEW`
- `VERIFIED`

## GATE 0 — CANONICAL_FOUNDATION_REVIEWED

### Required
- all nine canonical Markdown files exist;
- the mandatory cross-cutting scoring protocol `10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md` exists and is referenced by execution, review and handover rules;
- Dashboard V3 is referenced as the current target;
- Product Spec navigation matches North Star navigation;
- no score-heavy V1/V2 home requirement remains canonical;
- Core IAmina / OCD capsule boundary is explicit;
- privacy and safety release blockers are explicit;
- specialist review requirements are explicit;
- one-lot-per-window and handover requirements are explicit;
- strict scoring, adversarial re-scoring and perfection-pass requirements are explicit;
- roadmap and gates reference each other correctly.

### Proof
- branch diff;
- changed-file list;
- document review notes;
- strict scorecard;
- explicit product-owner approval before merge.

## GATE 1 — ARCHITECTURE_BOUNDARY_VERIFIED

### Required
- actual IAmina code has been inspected;
- no invented interface is treated as existing;
- reusable Core primitives are identified from code;
- OCD-specific concepts remain outside generic Core;
- client/tenant isolation path is documented;
- provider/model dependency direction is explicit;
- failure modes are documented.

### Proof
- architecture inventory;
- dependency map;
- inspected file paths and commit SHAs;
- tests or static checks covering boundary violations where practical.

### Blockers
- OCD-specific imports in generic Core without explicit approval;
- cross-client state dependency;
- direct vendor coupling that bypasses the approved abstraction without justification.

## GATE 2 — APP_SHELL_VERIFIED

### Required
- approved app stack bootstraps locally;
- canonical navigation shell exists;
- loading/error/empty conventions exist;
- no production environment is required for local development;
- accessibility baseline exists.

### Proof
- local run evidence;
- smoke tests;
- screenshots;
- commit SHA.

## GATE 3 — DASHBOARD_V3_VERIFIED

### Required
The home screen includes the canonical V3 hierarchy:

- `Choose your next move.`;
- `Make room for uncertainty. Choose what matters.`;
- `I'm stuck in a loop`;
- `Pause the ritual`;
- `Practice uncertainty`;
- `Continue planned practice`;
- `Return to what matters`;
- `Need a person, not an answer?`;
- `Review patterns when useful`;
- `Home / Loop / Practice / Support / Profile`.

The home screen must not default to:

- severity badges;
- streaks;
- competitive counts;
- daily completion pressure;
- prominent anxiety/progress trend graphs;
- reassurance counters.

### UI proof
At minimum, capture and inspect:

- 360 px mobile width;
- 390 px mobile width;
- any additional supported target width;
- tablet size only if tablet support is in scope.

For significant redesigns, provide before/after or target/implementation comparison.

### Required behavior
- no overflow/cutoff;
- tappable targets work;
- loading/empty/error states are defined where applicable;
- text scaling/accessibility does not destroy critical navigation;
- screenshots are compared to the canonical target.

### Scoring constraint
For target-driven UI, visual fidelity must be scored from the actual render, not source code. If direct target/render comparison is missing, apply the hard cap from `10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md`.

### Limitation
Pixel-perfect verification cannot be claimed until a full-resolution canonical source image is committed and used for comparison.

## GATE 4 — DATA_PRIVACY_BASELINE_VERIFIED

### Required
- auth/ownership enforcement where relevant;
- tenant/client scoping;
- no production DB dependency for local/test use;
- no committed secrets;
- raw sensitive conversation/journal content absent from routine logs by default;
- data-flow documentation for any AI provider;
- deletion/retention behavior designed before real-user persistence;
- analytics events avoid sensitive free text by default.

### Proof
- access-control tests;
- log inspection;
- secret/dependency checks where supported;
- schema/data-flow review.

### Blockers
- cross-client leakage;
- unauthorized user-data access;
- exposed secrets;
- misleading deletion behavior;
- unreviewed real-data mutation.

## GATE 5 — LOOP_FLOW_VERIFIED

### Required
- `I'm stuck in a loop` opens a bounded flow;
- user is not dropped into unrestricted chat;
- likely reassurance/checking/rumination requests follow approved policy;
- interaction offers a small set of approved next actions;
- flow has a clear end/transition state;
- provider failure produces a safe degraded state;
- human-support path remains available where required.

### Proof
- functional tests;
- screenshots/video of flow;
- provider-failure test;
- safety evaluation results.

## GATE 6 — COMPULSION_FIREWALL_VERIFIED

### Required evaluation categories
- normal informational requests;
- reassurance seeking;
- repeated reassurance with paraphrasing;
- checking requests;
- rumination-style analysis;
- repeated/confession-style questioning;
- ambiguous cases;
- adversarial attempts to obtain certainty;
- memory/session edge cases.

### Required behavior
- repeat questions do not simply receive repeated certainty;
- false-positive loop detection remains within an explicitly reviewed tolerance;
- the system does not shame or punish the user;
- internal reason codes are auditable without exposing unnecessary sensitive content.

### Proof
- versioned eval dataset;
- pass/fail report;
- known failures;
- fixes and rerun evidence.

## GATE 7 — PRACTICE_EXPERIENCE_VERIFIED

### Required
- bounded start/end state;
- no streak pressure or competitive scoring;
- no uncontrolled model-generated exposure plan;
- copy does not promise immediate calm or certainty;
- safe provider/tool failure state;
- any ERP-like behavior stays inside the explicitly approved validation boundary.

### Proof
- UX tests;
- content/safety review;
- screenshots;
- failure-state tests.

## GATE 8 — VALUES_SUPPORT_VERIFIED

### Required
- `Return to what matters` is user-led, not morally prescriptive;
- `Need a person, not an answer?` is clear and functional;
- the app never claims a person was contacted unless a real action occurred;
- any regional support resources have been reviewed for the supported launch region.

### Proof
- functional tests;
- copy review;
- routing tests.

## GATE 9 — MEMORY_PATTERN_REVIEW_VERIFIED

### Required
- memory scope is explicit;
- retrieval is user/client scoped;
- pattern review is user-initiated and bounded;
- no default severity grade is presented as clinical fact;
- deletion/edit/retention behavior works as documented;
- the system does not pretend history was checked when memory is unavailable.

### Proof
- retrieval tests;
- isolation tests;
- deletion tests;
- degraded-memory test;
- UX checking-risk review.

## GATE 10 — SYSTEM_SAFETY_VERIFIED

### Required
- all canonical OCD safety families from `03_OCD_CLINICAL_SAFETY.md` are represented in the versioned eval set;
- ambiguous high-risk messages follow the dedicated approved routing policy;
- provider/tool/memory failure cases are covered;
- every supported language has its own representative safety tests;
- unsupported medical claims are detected in evaluation.

### Proof
- versioned full-system eval report;
- thresholds approved before release;
- regression rerun after fixes.

### Blocker
Any known material increase in reassurance, checking, rumination, compulsive repetition, unsafe practice guidance or unsupported medical claims blocks release until resolved or explicitly accepted through a documented risk decision.

A documented risk acceptance does not erase the scoring deduction.

## GATE 11 — BETA_READINESS_VERIFIED

### Required
- mandatory gates 1–10 are verified or explicitly not applicable with justification;
- end-to-end smoke tests pass;
- supported viewport/device validation passes;
- accessibility baseline passes;
- privacy/security baseline passes;
- account/session edge cases are tested;
- non-regression suite passes;
- strict scorecards exist for material phases;
- final product-level adversarial audit meets the applicable scoring threshold;
- known risks and out-of-scope items are documented;
- no production deployment has been performed merely to prove readiness.

### Proof
A beta readiness report containing:

- repository/branch;
- exact HEAD SHA;
- test commands and results;
- screenshots;
- CI state;
- strict scorecards and final score;
- unresolved risks;
- release blockers;
- explicit recommendation.

## GATE 12 — RELEASE_AUTHORIZED

Technical verification and a high score are not release authorization.

Before any merge or external production release:

- exact PR and HEAD SHA must be identified;
- current CI/check state must be confirmed;
- strict scorecard must be current;
- material risks must be stated;
- product owner must give explicit approval.

Without that approval:

**DO NOT MERGE. DO NOT DEPLOY.**

## Lot closeout gate

Every lot/window closeout must satisfy `09_LOT_WINDOW_HANDOVER_PROTOCOL.md` and `10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md`.

### Required

- one coherent lot only was executed in the window;
- current lot state is explicit;
- every material stage has execution score + adversarial re-score + final stage score;
- required specialist verdicts and scores are recorded;
- tests and non-regression evidence are recorded;
- final adversarial severity review is recorded;
- focused perfection pass is completed where required;
- `FINAL_LOT_SCORE` is recorded;
- a lot called `VERIFIED` has `FINAL_LOT_SCORE >= 9.0` and all binary gates pass;
- exact repository truth is captured;
- `LOT_XX_HANDOVER.md` exists;
- `LOT_YY_START_PROMPT.md` exists if the next lot is already approved;
- next window is instructed to re-check all potentially stale repository state;
- no handover text implies automatic merge or deployment.

### Blocker

Do not begin the next material lot in the same window merely because time/context remains available.

Do not hide a low score, missing proof or unresolved specialist issue behind an aggregate score.

## Standard chantier closeout

Every significant chantier ends with:

### Résultat
What was actually achieved, including the strict score where applicable.

### Modifications
Files/components changed.

### Tests
Exact tests executed and results.

### Non-régression
What existing behavior was checked.

### Preuves
SHA, PR, screenshots, CI, logs, reports and score evidence.

### Risques
Remaining uncertainty and explicit score deductions.

### État
One allowed status only, plus whether the applicable scoring threshold is met.

### Prochaine étape
One recommended next action.

Then, if the window is closing the lot, generate the mandatory handover package and strict scorecard before starting a new window.
