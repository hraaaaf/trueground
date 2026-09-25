# HANDOVER — TrueGround OCD / LOT 10 → LOT 11

Project: TrueGround OCD
Repository: `hraaaaf/trueground`
Date: 2026-09-25
Lot: LOT 10 — System Safety
Branch at source evidence: `feat/fr-localization`
Exact source HEAD: `09c9f95c4a3f14f7a32719cee513015fe7b0e505`
PR #22: OPEN / DRAFT / NOT MERGED
Merge authorization: NOT GRANTED
Deployment authorization: NOT GRANTED

## GOAL

Verify the deterministic TrueGround OCD capsule as one system against the canonical safety families, add supported-language evidence, and preserve the IAmina Core / OCD capsule boundary without introducing an LLM/provider.

## SUCCESS

Partially achieved.

Verified on exact source HEAD:
- LOT03→LOT10 GitHub Actions: 8/8 SUCCESS;
- format and static analysis green;
- focused LOT10 system-safety tests green;
- full Flutter/widget/accessibility regression green;
- release web build green;
- English + French deterministic localization exists;
- no runtime LLM/AI/provider dependency introduced;
- no production data, database, secret or external deployment mutation;
- architecture remains deterministic and OCD-specific logic remains outside generic IAmina Core.

Not achieved:
- GATE 10 may NOT be called VERIFIED;
- dedicated clinically reviewed regional acute-risk/crisis policy remains unresolved;
- French real-web visual proof is not yet valid: Chrome web capture renders cleanly but remains EN despite CI preference seeding;
- no genuinely independent final adversarial certification has established a >=9.5 score;
- no qualified human clinical validation exists for the crisis policy or treatment-like claims.

## PROOF

Exact-head CI on `09c9f95c4a3f14f7a32719cee513015fe7b0e505`:

- LOT03 Flutter shell — run 36082305511 — SUCCESS
- LOT04 Dashboard V3 — run 36082305497 — SUCCESS
- LOT05 Bounded Loop — run 36082305548 — SUCCESS
- LOT06 Compulsion Firewall — run 36082305416 — SUCCESS
- LOT07 Practice Experience — run 36082305732 — SUCCESS
- LOT08 Values and Human Support — run 36082305559 — SUCCESS
- LOT09 Memory Pattern Review — run 36082305427 — SUCCESS
- LOT10 System Safety — run 36082305568 — SUCCESS

LOT10 artifact:
- artifact id: `10842960660`
- digest: `sha256:4a08f28724f7b6ef85b82f1b337f451cad562b85aa1c556a02a05c5e4fe3e2c5`

## What was done

- system-safety contract/eval infrastructure and deterministic boundaries;
- high-risk routing logic bounded without inferring intent from intrusive thoughts;
- English/French localization architecture;
- FR/EN selector implementation;
- representative safety tests;
- unsupported-claim detection fixtures;
- memory degradation truthfulness tests;
- web build proof;
- visual-evidence pipelines.

## What was NOT done

- no merge;
- no deployment;
- no production/runtime AI provider;
- no autonomous ERP engine;
- no diagnosis/severity/treatment-efficacy behavior;
- no medication guidance;
- no final approved regional crisis policy;
- no clinician sign-off;
- no validated French web screenshot despite a clean Chrome render.

## Files materially involved

Existing LOT10 / FR scope includes, among others:
- `lib/localization/trueground_locale.dart`
- `lib/localization/language_toggle.dart`
- `lib/localization/language_screen.dart`
- `lib/app/trueground_app.dart`
- `lib/dashboard/dashboard_v3_screen.dart`
- safety/loop/practice/values/support/pattern screens
- `test/system_safety_test.dart`
- `test/localization_test.dart`
- `test/fr_localization_visual_evidence.dart`
- `.github/workflows/lot10_system_safety.yml`
- `docs/ocd/lots/LOT_10_SYSTEM_SAFETY_CONTRACT.md`
- LOT10 eval/review documentation.

## Non-regression

Exact-head LOT03→LOT10 CI is green on the source candidate.
Existing deterministic OCD flows remain covered by the full regression suite.
No AI/provider dependency was introduced.

## Specialist review status

Because GATE 10 still has material external/clinical proof gaps, the lot remains VERIFICATION INCOMPLETE.

- AI_EVAL_AGENT: implementation/eval evidence green, final certification not closed.
- OCD_SAFETY_AGENT: blocking human-reviewed acute-risk/crisis policy remains.
- QA_NON_REGRESSION_AGENT: exact-head automated regression green.
- LOCALIZATION_AGENT: code/test coverage exists; real-web FR screenshot proof remains incomplete.
- REGULATORY_CLINICAL_REVIEW: required for crisis-policy validation; not completed.

## Current blockers / risks

### KF-01 — acute-risk/crisis policy
The canonical safety framework requires a dedicated reviewed policy before production release. Existing behavior must not be described as clinically validated.

### VIS-FR-01 — real-web French visual proof
Headless Chrome capture renders the dashboard cleanly, but currently loads EN despite CI seeding. Widget-test screenshots show rendering artifacts and must not be used as product visual proof.

### AI boundary for LOT11
LOT11 introduces the first proposed conversational AI runtime. It must not reuse green LOT10 CI as authorization to add a provider without its own architecture/privacy/safety gates.

## Repository truth

Source candidate: `feat/fr-localization@09c9f95c4a3f14f7a32719cee513015fe7b0e505`
PR #22: OPEN, DRAFT, NOT MERGED
Base of PR #22: `ui/polish-sub9-screens`
CI: LOT03→LOT10 8/8 SUCCESS on the exact source HEAD.
No merge or deployment is authorized.

## Next lot

Approved direction:
**LOT 11 — Bounded Conversational Companion**

LOT11-A is documentation/evidence-first:
- scientific baseline;
- conversational safety contract;
- architecture boundary;
- pre-implementation adversarial eval set;
- provider-selection decision framework;
- privacy/data-flow contract.

LOT11-A MUST NOT add a runtime LLM/provider yet.

See:
`docs/ocd/handovers/LOT_11_START_PROMPT.md`

## État

VERIFICATION INCOMPLETE / BLOCKED FOR FULL GATE 10 CERTIFICATION

LOT11-A documentation/eval preparation may proceed in parallel because it does not bypass KF-01, does not ship clinical behavior, and must preserve KF-01 as a release blocker.
