# HANDOVER — TrueGround OCD / LOT 06 → LOT 07

Repository: `hraaaaf/trueground`

Previous lot handover:
`docs/ocd/handovers/LOT_06_HANDOVER.md`

Target lot:
`LOT 07 — Practice experience`

Target gate:
`GATE 7 — PRACTICE_EXPERIENCE_VERIFIED`

LOT 06 / PR #14 has been merged.

Known merge snapshot:

- merged LOT06 candidate: `64872299233576fdefd9134199874a7365e16e0c`;
- merge commit: `8015e0dbe46f9b51b67ce0b43affec4687166823`;
- target branch: `lot/04-dashboard-v3-static`;
- LOT06 retained strict score: `9.00 / 10`;
- LOT06 gate: `GATE 6 — COMPULSION_FIREWALL_VERIFIED`;
- deployment: NOT PERFORMED.

These values are a snapshot, not an oracle.

Do not trust any SHA, branch state, PR state or CI state until rechecked live.

## START CONDITION

Before any LOT07 modification:

1. read `docs/ocd/handovers/LOT_06_HANDOVER.md`;
2. verify PR #14 remains merged and identify the exact live merge/base SHA;
3. inspect all post-merge LOT03/04/05/06 workflow results on the merge commit;
4. inspect current branches and confirm whether a LOT07 branch already exists;
5. inspect the current Practice route/screen and all navigation/tests;
6. inspect whether any existing approved practice content, policy, exercise definitions or safety constraints already exist;
7. do not invent ERP behavior, exercise content, provider behavior, persistence, or a clinical protocol merely because the roadmap names Practice.

If repository truth materially differs from this handover, reconcile before modifying runtime code.

## READ FIRST — OBLIGATORY

Read at minimum, in order:

1. `docs/ocd/handovers/LOT_06_HANDOVER.md`
2. `docs/ocd/01_PRODUCT_NORTH_STAR.md`
3. `docs/ocd/02_OCD_PRODUCT_SPEC.md`
4. `docs/ocd/03_OCD_CLINICAL_SAFETY.md`
5. `docs/ocd/04_IAMINA_CAPSULE_ARCHITECTURE.md`
6. `docs/ocd/05_DATA_PRIVACY_SECURITY.md`
7. `docs/ocd/06_ROADMAP_TO_TARGET.md`
8. `docs/ocd/07_ACCEPTANCE_GATES.md`
9. `docs/ocd/08_SPECIALIST_REVIEW_MATRIX.md`
10. `docs/ocd/09_LOT_WINDOW_HANDOVER_PROTOCOL.md`
11. `docs/ocd/10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md`
12. current Practice route/screen/component implementation;
13. LOT05 bounded Loop handoff behavior;
14. LOT06 Compulsion Firewall implementation/tests;
15. current CI workflows;
16. central governance adoption.

## READ → PLAN → EXECUTE → VERIFY

Before modifying anything, publish:

### GOAL

The exact Practice behavior LOT07 will implement on the inspected repository.

### SUCCESS

Observable criteria tied to Gate 7.

### PROOF

Tests, safety review, screenshots, failure-state evidence, non-regression and exact-head CI required.

Then continue automatically until a real human gate is reached.

## CANONICAL LOT07 SCOPE

Roadmap Phase 7 defines the initial Practice surfaces:

- `Pause the ritual`;
- `Practice uncertainty`;
- `Continue planned practice`.

Canonical constraints:

- bounded start/end state;
- no streak pressure;
- no competitive scoring/counts;
- no uncontrolled LLM-generated exposure plan;
- no promise of immediate calm, certainty, symptom elimination or clinical efficacy;
- safe provider/tool failure state where applicable;
- ERP-like behavior only inside an explicitly approved validation boundary.

The product spec further requires:

### Pause the ritual

- short bounded tool;
- creates time/space between urge and action;
- must not become a countdown users are encouraged to repeat compulsively;
- exact behavioral guidance must come from approved safety/content policy.

### Practice uncertainty

- entry point for approved uncertainty-tolerance / OCD-specific practice;
- must not make anxiety reduction the immediate promised goal;
- must not generate uncontrolled exposure tasks from a generic model.

### Continue planned practice

- returns to a previously approved/saved practice only if such persistence is actually implemented and allowed;
- avoid streaks, completion pressure and competitive scoring.

If no approved saved-practice persistence exists, do not invent one. Provide the safest scope-consistent degraded/placeholder behavior supported by the canonical docs and existing architecture, or stop at a human gate if a product decision is required.

## ERP / CLINICAL BOUNDARY — ABSOLUTE

LOT07 must NOT silently become an autonomous ERP engine.

No production ERP-like behavior may be introduced merely because a model can generate exposures.

Before any treatment-like ERP capability, the canonical safety doc requires explicit decisions on:

- intended population;
- clinician/scientific review;
- exposure-generation rules;
- hierarchy construction;
- exclusions and contraindication handling;
- physical-safety boundaries;
- crisis/escalation behavior;
- stopping rules;
- comorbid/ambiguous presentations;
- evaluation methodology;
- product claims.

If the smallest viable LOT07 implementation requires any unresolved treatment-like behavior:

STOP → HUMAN GATE

Present:

OPTION A
OPTION B
RECOMMENDATION
IMPACT

Do not improvise clinical content.

## SCIENTIFIC CLAIM DISCIPLINE

Forbidden without explicit validation:

- “this treats OCD”;
- “clinically proven”;
- “this exposure is prescribed for you”;
- “your anxiety should go down”;
- “discomfort means the exercise is working”;
- diagnosis;
- medication advice;
- personalized treatment recommendation;
- efficacy percentage or therapeutic promise.

Prefer cautious product language that describes the action without claiming a medical outcome.

## COMPULSION-RISK SAFETY

LOT07 must explicitly test whether Practice itself can become compulsive.

At minimum test:

- repeated restarting of the same practice;
- repeated countdown use;
- “one more time” requests;
- checking whether the exercise was done “correctly”;
- perfectionistic completion behavior;
- reassurance about whether the user practiced enough;
- repeated distress/self-rating;
- compulsive comparison with prior attempts;
- repeated switching between Loop and Practice;
- use of Practice as avoidance instead of return-to-life support;
- pressure from streaks, badges, scores or counts — these must not be introduced.

LOT06 Compulsion Firewall behavior must remain intact and must not be bypassed by Practice.

## FALSE POSITIVES / LEGITIMATE USE

Do not treat normal repetition as pathology automatically.

Test:

- user reopens Practice after navigation;
- accessibility retry;
- app/UI failure retry;
- user corrects a selection;
- genuinely different practice choice;
- resumed approved practice if supported;
- user exits early;
- user seeks human support;
- offline/degraded path.

Do not label these behaviors as compulsions.

## DATA / PRIVACY

Gate 4 is not globally considered complete merely because LOT06 is verified.

If LOT07 can be implemented locally/deterministically without persistence/provider dependence, prefer that path.

No longitudinal practice history, saved plan, analytics, raw OCD content, account state or provider transmission may be introduced unless the actual Gate4/privacy requirements are verified and the scope explicitly permits it.

No real user data.

If `Continue planned practice` requires persistence that does not currently exist, do not invent or simulate stored history deceptively.

## ARCHITECTURE

Core IAmina and the OCD capsule remain separated.

All OCD-specific practice semantics belong in the OCD capsule.

No OCD-specific concepts such as:

- ERP;
- exposure hierarchy;
- reassurance;
- ritual prevention;
- uncertainty practice;
- compulsion scoring;

may leak into generic IAmina Core.

If a Core modification appears necessary:

STOP → HUMAN GATE

Present:

OPTION A
OPTION B
RECOMMENDATION
IMPACT

Do not modify Core automatically.

## UI / UX

Preserve LOT03 + LOT04 + LOT05 + LOT06.

No global redesign.

For any material Practice UI change provide:

- BEFORE;
- AFTER;
- identical viewports/states;
- 360 px;
- 390 px;
- overflow/cutoff validation;
- 200% text scaling where relevant;
- accessibility semantics/touch targets;
- loading/empty/error/degraded states where applicable.

Do not treat Flutter test-font screenshots as production typography fidelity proof.

The Practice experience must remain calm and bounded, not gamified or score-heavy.

## SAFE DEGRADED STATE

If LOT07 uses no provider/tool, document that provider failure is NOT_APPLICABLE and prove local deterministic behavior.

If any provider/tool is introduced, failure must not silently fall back to:

- unrestricted chat;
- fabricated exercise content;
- generic advice;
- reassurance;
- unsafe exposure generation.

Failure state must be explicit, bounded and non-deceptive.

## MANDATORY SPECIALIST REVIEWS

Per the current specialist matrix, Phase 7 requires at minimum:

- `OCD_SAFETY_AGENT`
- `UI_UX_AGENT`
- `CONTENT_COPY_AGENT`
- `AI_EVAL_AGENT` when AI is used

Also require when applicable:

- `ACCESSIBILITY_AGENT` for material Practice UI;
- `QA_NON_REGRESSION_AGENT` for the implementation and full regression;
- `ARCHITECTURE_AGENT` if interfaces/dependencies/Core boundary are touched;
- `DATA_PRIVACY_SECURITY_AGENT` if persistence, analytics, provider, logging, account/history or sensitive data flow is touched;
- `REGULATORY_CLINICAL_REVIEW` if treatment-like ERP behavior, diagnostic/therapeutic claims or crisis policy is introduced.

Every reviewer returns exactly one:

`PASS | PASS_WITH_NOTES | CHANGES_REQUIRED | BLOCKED | NOT_APPLICABLE`

No unresolved `CHANGES_REQUIRED` or `BLOCKED` may be hidden.

## TESTING — MINIMUM MATRIX

LOT07 must test behavior, not only static strings.

At minimum:

1. Pause the ritual has a bounded start/end;
2. Practice uncertainty has a bounded start/end;
3. Continue planned practice behaves honestly given the real persistence state;
4. no unrestricted free-text therapist simulation;
5. no uncontrolled exposure generation;
6. no immediate-calm/certainty promise;
7. no streaks/badges/competitive counts;
8. repeated restart does not create an endless ritual loop;
9. “one more time” behavior remains bounded;
10. completion does not ask the user to prove success;
11. exit/back works;
12. Support escape remains available where required;
13. LOT05 handoff into Practice remains valid;
14. LOT06 Compulsion Firewall remains intact;
15. 360 px;
16. 390 px;
17. 200% text scaling;
18. accessibility semantics/touch targets;
19. error/degraded state;
20. no infinite loop;
21. no unsupported medical/clinical claims;
22. no persistence/provider/analytics introduced implicitly.

If actual inspected scope contains additional Practice states, extend the matrix rather than replacing these baseline cases.

## NON-REGRESSION

Before closeout:

- LOT03 must remain green;
- LOT04 must remain green;
- LOT05 must remain green;
- LOT06 must remain green;
- LOT07 must be green;
- Home/Loop/Practice/Support/Profile navigation remains intact;
- Compulsion Firewall tests remain green;
- no Core/capsule boundary regression;
- no new dependency without justification;
- no provider/persistence/data flow hidden in Practice;
- no unrelated redesign.

## DOUBLE SCORING

Apply `docs/ocd/10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md`.

Two passes are mandatory:

PASS A — severe execution review

PASS B — adversarial review whose explicit job is to find why PASS A is too generous.

Retain the lower result.

Critical LOT07 dimensions include at minimum:

- OCD/practice safety;
- uncontrolled ERP/exposure risk;
- reassurance/checking reinforcement;
- compulsive repetition/restart risk;
- content/claim discipline;
- UI/UX;
- accessibility;
- Core/capsule separation;
- privacy/data;
- non-regression;
- evidence/reproducibility.

Same model/session cap: 9.4.

Any divergence >0.5 must be investigated.

Threshold for VERIFIED:

- retained score ≥ 9.0;
- all applicable gates green;
- no unresolved material in-scope weakness.

Green CI alone ≠ VERIFIED.

## PERFECTION PASS

Before VERIFIED:

1. enumerate all remaining weaknesses;
2. classify each as:
   - in-scope improvable;
   - external/deferred;
   - out of scope;
3. fix every material in-scope weakness;
4. rerun affected tests;
5. rerun screenshots/evidence;
6. rerun exact-head non-regression;
7. rerun both scoring passes;
8. retain the lower score.

A known material in-scope weakness left unfixed prohibits VERIFIED.

## CONTINUOUS EXECUTION

Once LOT07 is started in its fresh window, continue automatically through:

READ
→ PLAN
→ EXECUTE
→ TEST
→ FIX
→ SPECIALIST REVIEW
→ VERIFY
→ PERFECTION PASS
→ DOUBLE SCORE

Do not repeatedly ask “Go?”.

Stop only for a real human gate:

- unresolved product/clinical choice;
- Core IAmina modification;
- treatment-like ERP boundary;
- production/data/secrets;
- merge;
- deployment;
- irreversible external action.

## MERGE / DEPLOY

This starter prompt does NOT authorize:

- merge;
- Vercel deployment;
- production release;
- TestFlight / Play Store;
- production DB/schema mutation;
- real-user-data mutation;
- secret/config mutation.

Each requires separate explicit product-owner authorization.

## LOT END

At LOT07 closeout, do not silently start LOT08 in the same window.

Create:

- `docs/ocd/handovers/LOT_07_HANDOVER.md`
- `docs/ocd/handovers/LOT_08_START_PROMPT.md` only if LOT08 is explicitly authorized

Always finish with:

### Résultat

### Modifications

### Tests

### Non-régression

### Preuves

### Risques

### État

### Prochaine étape
