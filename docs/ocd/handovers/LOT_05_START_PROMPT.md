# HANDOVER — TrueGround OCD / LOT 04 → LOT 05

Repository: `hraaaaf/trueground`

Previous lot handover expected:
`docs/ocd/handovers/LOT_04_HANDOVER.md`

Target lot:
`LOT 05 — Bounded Loop flow`

Status of this file:
Realigned after LOT 04D / PR #10 was merged into `lot/04-dashboard-v3-static`. The product owner explicitly authorized LOT 05 execution in the current fresh LOT 05 window after live re-verification and handover reconciliation. This file does **not** authorize merge, deployment, production data mutation, secrets/config mutation, or any LOT 06 work.

## START CONDITION

Before executing LOT 05, confirm that:

1. `docs/ocd/handovers/LOT_04_HANDOVER.md` exists and reflects the actual final LOT 04 state;
2. the repository/base branch to build on is explicitly identified from live GitHub state;
3. LOT 04 acceptance evidence is not being inferred from stale screenshots or stale CI;
4. the LOT 05 working branch is created from the intended approved base, not from an assumed SHA;
5. any dependency on data/auth/persistence/provider behavior is checked against Gate 4 (`DATA_PRIVACY_BASELINE_VERIFIED`) before implementation.

If the LOT 04 handover is still missing, or repository reality materially differs from it, stop execution and report the mismatch before modifying runtime code.

## READ FIRST — IN THIS ORDER

1. `docs/ocd/handovers/LOT_04_HANDOVER.md`
2. `docs/ocd/01_PRODUCT_NORTH_STAR.md`
3. `docs/ocd/02_OCD_PRODUCT_SPEC.md`
4. `docs/ocd/03_OCD_CLINICAL_SAFETY.md`
5. `docs/ocd/04_IAMINA_CAPSULE_ARCHITECTURE.md`
6. `docs/ocd/05_DATA_PRIVACY_SECURITY.md`
7. `docs/ocd/06_ROADMAP_TO_TARGET.md`
8. `docs/ocd/07_ACCEPTANCE_GATES.md`
9. `docs/ocd/08_SPECIALIST_REVIEW_MATRIX.md`
10. `docs/ocd/09_LOT_WINDOW_HANDOVER_PROTOCOL.md`
11. `docs/ocd/10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md` if present on the final LOT 04 base
12. the actual Flutter/app-shell implementation and tests on the final LOT 04 base

Do not trust any branch name, SHA, PR state, CI state, screenshot, route, component, dependency, interface, table or service until inspected live.

## REPOSITORY TRUTH — RECHECK LIVE

Final LOT 04 runtime base verified live for this realignment:

- final LOT 04 branch: `lot/04-dashboard-v3-static`;
- LOT 04D PR: `#10` — CLOSED / MERGED / not deployed;
- merged LOT 04D candidate: `0aa63b923be7198ace25bc23b1712177bb7bbf66`;
- LOT 04 merge commit / runtime anchor: `2b5f29dba596f99be05b124d093aa751d3a4222d`;
- final pre-merge evidence: LOT 03 run `35283449797` SUCCESS; LOT 04 run `35283449809` SUCCESS;
- visual artifact `10523732921`;
- visual artifact digest `sha256:260a326f90efcbf9179f4b5cc01f946b9d974ca6424a66bb79baaf362259d96d`;
- unresolved PR #10 review threads at reconciliation: none.

These values describe the verified LOT 04 closeout/runtime anchor. They remain a snapshot, not an oracle. Before any LOT 05 runtime change, verify the live branch/HEAD again and use the reconciled `LOT_04_HANDOVER.md` present on the LOT 05 working branch.

Gate 4 note at reconciliation:
the inspected Flutter repository contains no auth, persistence, analytics, model/provider SDK or production data dependency. Therefore `DATA_PRIVACY_BASELINE_VERIFIED` is **not claimed as fully VERIFIED**. LOT 05 must remain local-only and deterministic unless that gate is separately implemented and proven. No raw OCD free text, provider transmission, longitudinal memory, analytics or persistence is authorized in LOT 05.

## GOAL

Make `I'm stuck in a loop` operational as a short, bounded support flow that helps the user move from a loop/urge toward one approved next action and then exit or transition, without creating an unrestricted reassurance chatbot or introducing LOT 06 Compulsion Firewall behavior prematurely.

The intended product sequence remains:

`Notice → choose → practice → return to life`

and must not drift into:

`Trigger → ask for certainty → AI reassures → temporary relief → repeat`.

## SUCCESS

LOT 05 succeeds only if all applicable criteria below are proven on the exact candidate HEAD.

### Product behavior

- `I'm stuck in a loop` opens a dedicated bounded flow;
- the user is not dropped into unrestricted free chat;
- brief context capture is intentionally small and does not encourage exhaustive rumination;
- the flow uses cautious, non-diagnostic language;
- the system does not promise certainty, immediate calm, symptom elimination or clinical efficacy;
- the user receives a small approved action set rather than an open-ended conversational loop;
- the flow has an explicit end or transition state;
- a visible path to human support remains available where required;
- returning to Home/Practice/Support preserves existing navigation behavior.

### OCD safety behavior

At minimum, the flow must be exercised against:

- ordinary informational/context input;
- reassurance seeking;
- checking-style requests;
- rumination/endless-analysis prompts;
- confession/repetition-style prompts;
- retrospective certainty seeking;
- repeated `what if`/yes-no certainty pressure;
- ambiguous cases;
- intrusive-thought language versus genuine acute-risk language;
- unsupported medical/diagnostic requests;
- degraded/provider-failure behavior if a provider is used.

The LOT 05 flow must not pretend to implement the full Compulsion Firewall. Session-level repetition detection, paraphrase matching and longitudinal repetition policy belong to LOT 06 unless explicitly re-scoped by the product owner.

### UI/UX

- visual language remains coherent with the final Dashboard V3 shell;
- the flow is usable at 360 px and 390 px;
- no overflow/cutoff;
- important actions remain reachable with 200% text scaling;
- touch targets/semantics remain accessible;
- loading/error/empty/degraded states are defined where applicable;
- the UI does not introduce score pressure, streaks, compulsive counters or repeated self-rating.

### Architecture

- OCD-specific policy remains outside generic IAmina Core;
- no OCD-specific import or behavior is added to generic Core;
- dependency direction remains `App shell → OCD capsule → approved Core interfaces → infrastructure/provider`;
- no screen talks directly to a vendor SDK if an approved abstraction exists;
- no new generic framework/refactor is introduced merely for LOT 05;
- no Diabetes/client-specific runtime/data coupling is introduced.

### Data/privacy precondition

Roadmap Phase 4 / Gate 4 precedes provider/persistence-dependent behavior.

Before introducing any auth, persistence, user-history, analytics, memory, sensitive logging or provider transmission:

- inspect whether `DATA_PRIVACY_BASELINE_VERIFIED` is actually satisfied on the chosen base;
- inspect the real implementation rather than assuming the architecture exists;
- do not use production DBs, production secrets or real user data;
- do not log raw OCD free text by default;
- do not add longitudinal memory in LOT 05;
- do not send sensitive content to a model provider without the required documented data flow.

If Gate 4 is not verified, LOT 05 may only implement behavior that can be proven safely without the missing persistence/auth/provider dependency. Any part that requires the missing baseline must be reported as `BLOCKED`, not silently improvised.

## PROOF

Minimum evidence for LOT 05 closeout:

- exact branch and HEAD SHA;
- changed-file list and diff inspection;
- focused functional/widget tests for the bounded Loop flow;
- explicit tests proving the user is not placed into unrestricted chat;
- safety evaluation cases covering reassurance/checking/rumination/ambiguity relevant to the implemented behavior;
- provider/degraded-state test where applicable;
- 360 px screenshot(s);
- 390 px screenshot(s);
- 200% text-scaling/accessibility proof;
- navigation/non-regression checks for Home / Loop / Practice / Support / Profile;
- client-isolation/Core-boundary checks;
- specialist review ledger;
- strict scorecard/perfection pass if the protocol exists on the final base;
- exact CI result on the final candidate HEAD.

Green CI alone is not completion.

## IN SCOPE

Only the smallest bounded Loop flow necessary to satisfy Gate 5 behavior:

- entry from `I'm stuck in a loop` / Loop surface as supported by the inspected shell;
- brief bounded context input or approved selection UI;
- approved safety-routing boundary;
- cautious pattern-oriented response framing;
- a small approved set of next actions already supported by product scope;
- explicit exit/transition state;
- safe degraded state;
- focused tests/evals/evidence;
- only the minimal wiring required by the inspected existing architecture.

## OUT OF SCOPE

Do **not** add unless a separate explicit decision authorizes it:

- full Compulsion Firewall / LOT 06;
- longitudinal repetition detection;
- semantic paraphrase matching across sessions;
- longitudinal memory;
- pattern-review history;
- ERP engine or autonomous exposure generation;
- diagnosis/screening claims;
- medication guidance;
- clinically validated treatment claims;
- new crisis protocol invented ad hoc;
- unrestricted therapist simulation or generic free chat;
- streaks, severity badges, reassurance counters or progress gamification;
- production analytics;
- production auth/data migrations;
- real-user-data mutation;
- IAmina Core refactor not strictly required by inspected evidence;
- new dependencies unless necessary and separately justified/reviewed;
- LOT 07+ features;
- deployment.

## CRISIS / HIGH-RISK BOUNDARY

Do not improvise a new clinical or crisis protocol inside LOT 05.

If the existing canonical policy is insufficient for a high-risk path required by implementation:

- preserve a conservative, non-deceptive safe boundary using only approved existing wording/behavior;
- do not claim emergency services or a person were contacted unless a real action occurred;
- document the missing policy as a blocker for production readiness;
- require the applicable OCD safety / qualified human review before making treatment/crisis claims.

Intrusive thoughts must not automatically be equated with intent, and genuine acute-risk disclosures must not be dismissed merely because the product is OCD-focused.

## MANDATORY SPECIALIST REVIEWS

Per the current specialist matrix, LOT 05 requires at minimum:

- `OCD_SAFETY_AGENT`
- `AI_EVAL_AGENT`
- `UI_UX_AGENT`
- `QA_NON_REGRESSION_AGENT`

Add these when applicable to actual changes:

- `ACCESSIBILITY_AGENT` for material UI/accessibility behavior;
- `CONTENT_COPY_AGENT` for material microcopy/policy-facing copy;
- `ARCHITECTURE_AGENT` if Core/capsule interfaces or provider abstraction are touched;
- `DATA_PRIVACY_SECURITY_AGENT` if auth, persistence, provider data flow, logging, analytics, memory or sensitive-data handling is touched;
- `REGULATORY_CLINICAL_REVIEW` if the implementation crosses into treatment/diagnostic/crisis claims or treatment-like behavior.

Every required reviewer returns exactly one explicit verdict:

`PASS | PASS_WITH_NOTES | CHANGES_REQUIRED | BLOCKED | NOT_APPLICABLE`

Any unresolved `CHANGES_REQUIRED` or `BLOCKED` prevents verification.

## STRICT SCORING

If `docs/ocd/10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md` exists on the final chosen base, apply it exactly.

Do not award a high score because CI is green.

The final lot score must expose weak domains instead of averaging them away, and the final perfection pass must actively search for reasons the lot is not 10/10.

For an OCD-facing flow, safety weakness cannot be hidden inside a strong visual or engineering aggregate.

## EXECUTION ORDER

Follow exactly:

`READ → PLAN → EXECUTE → SPECIALIST REVIEW → VERIFY`

Before modifying anything, publish:

### GOAL
What LOT 05 will achieve on the inspected codebase.

### SUCCESS
Observable pass criteria tied to Gate 5 and all prerequisites.

### PROOF
Exact tests, screenshots, safety evals, CI and specialist evidence required.

Then:

1. inspect the real current shell/routes/components/tests;
2. inspect whether Gate 4 prerequisites materially affect the intended implementation;
3. identify the smallest LOT 05 design consistent with existing architecture;
4. state files expected to change only after inspection;
5. implement only that bounded scope;
6. run focused tests early;
7. run safety evals/adversarial cases;
8. produce real 360/390 rendered evidence;
9. run full relevant non-regression/CI;
10. obtain specialist reviews;
11. perform final strict/perfection review;
12. capture exact repository truth;
13. create the LOT 05 handover;
14. do not start LOT 06 in the same window.

## NON-REGRESSION

At minimum preserve and prove:

- Dashboard V3 Home visual hierarchy;
- Home / Loop / Practice / Support / Profile navigation shell;
- 360/390 responsive behavior;
- accessibility/text scaling baseline;
- client isolation;
- IAmina Core / OCD capsule separation;
- no Diabetes dependency leakage;
- no new production dependency;
- no behavior change outside the explicit LOT 05 flow.

## STOP CONDITIONS

Stop and report before continuing if any of these is true:

- LOT 04 handover is missing when execution is about to begin;
- chosen LOT 05 base differs materially from the handover and cannot be reconciled safely;
- Gate 4 is required by the intended design but not verified;
- implementing the flow would require unapproved production auth/data/provider work;
- the only path forward requires an OCD-specific change inside generic IAmina Core;
- crisis/treatment behavior would require inventing an unapproved policy;
- safety evaluation reveals a material increase in reassurance, checking, rumination or compulsive repetition;
- a required specialist returns `CHANGES_REQUIRED` or `BLOCKED`;
- exact-HEAD tests/evidence cannot be produced.

Do not bypass a stop condition just to keep the lot moving.

## MERGE / DEPLOY / DATA RULES

This prompt authorizes none of the following:

- merge;
- Vercel or any external deployment;
- TestFlight / Play Store release;
- production database/schema change;
- real-user-data mutation;
- production secret/config mutation.

Each irreversible/external action requires separate explicit product-owner approval.

## LOT END

At the end of LOT 05, do not start LOT 06 in the same window.

Create:

- `docs/ocd/handovers/LOT_05_HANDOVER.md`
- `docs/ocd/handovers/LOT_06_START_PROMPT.md` only if LOT 06 is explicitly approved

Finish with exactly these sections:

### Résultat

### Modifications

### Tests

### Non-régression

### Preuves

### Risques

### État

### Prochaine étape
