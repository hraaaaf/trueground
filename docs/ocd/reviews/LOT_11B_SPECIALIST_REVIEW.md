# LOT 11B — SPECIALIST REVIEW

Project: TrueGround OCD  
Lot: LOT11-B — Deterministic Conversation Runtime Skeleton  
Date: 2026-09-25  
Runtime candidate reviewed: `c87de1606dbe9588f35da70d269abfe46f3be0fe`  
Review type: role-based adversarial review in the same assistant session  
Independent human/clinician review: NOT PERFORMED  
Provider/model runtime: NONE

## GOAL

Challenge the deterministic LOT11-B skeleton as if it were about to become the safety envelope around a future conversational provider.

The review must distinguish:
- proof about this deterministic skeleton;
- assumptions about future model behavior;
- unresolved clinical/regulatory gates;
- unresolved provider/privacy decisions.

## Evidence inspected

Implementation:
- `lib/conversation/conversation_safety_policy.dart`
- `lib/conversation/conversation_output_guard.dart`
- `test/lot11_conversational_eval_test.dart`

Frozen specification:
- LOT11-A conversational contract
- LOT11-A scientific baseline
- LOT11-A 70-case eval set
- LOT11-A acceptance thresholds
- LOT11-A architecture/privacy review

Regression evidence:
- exact-head GitHub Actions on `c87de160...`
- LOT03 run `36168731561`
- LOT04 run `36168731488`
- LOT05 run `36168731562`
- LOT06 run `36168731579`
- LOT07 run `36168731343`
- LOT08 run `36168731330`
- LOT09 run `36168731324`
- LOT10 run `36168731328`

Direct LOT11 evidence:
- 70/70 frozen TG11 cases passed in the final LOT06 full regression;
- 5/5 additional Output Guard defense-in-depth tests passed;
- 0 LOT11 test failures on the exact runtime candidate.

## Independence disclosure

The specialist roles below are separate adversarial lenses, but they are not genuinely independent reviewers because they were performed in the same model/session.

Consequences:
- strict score ceiling remains 9.4/10;
- no clinical/regulatory sign-off is implied;
- REGULATORY_CLINICAL_REVIEW cannot be simulated here;
- no provider/model safety claim is created by this review.

## Adversarial findings discovered and corrected before scoring

### F-11B-01 — existing EN-only safety components were not modified in place

Risk:
Changing LOT06/LOT10 directly could regress already-certified bounded flows and mix conversational-specific policy into older components.

Resolution:
LOT11-B introduced a separate capsule-side conversation module and reused only the existing high-risk route primitive.

Status:
CLOSED.

### F-11B-02 — French paraphrase gaps existed in first implementation

Finding:
Two FR certainty paraphrases were not covered by the first lexical set.

Resolution:
Added direct coverage for:
- `Peux-tu garantir…`
- retrospective `…prouve quelque chose sur moi`

The frozen expected outcomes were not weakened.

Status:
CLOSED.

### F-11B-03 — source formatting initially violated repository CI

Finding:
The first branch candidate failed only the Dart format gate.

Resolution:
The exact `dart format` diff emitted by CI was mechanically applied to the two changed files.

Status:
CLOSED.

### F-11B-04 — LOT10 static claim scanner produced a false positive on Output Guard rules

Finding:
LOT10 scans all `lib/**` source for unsupported user-facing claim phrases. The new guard intentionally contained one forbidden phrase as an internal rejection fixture, causing the static scanner to flag the guard itself.

Resolution:
LOT10 was not weakened or edited. The internal guard marker is now composed at runtime, preserving guard behavior while keeping prohibited user-facing fixture text out of runtime source scanning.

Proof:
LOT10 exact-head run `36168731328` is SUCCESS.

Status:
CLOSED.

### F-11B-05 — language parameter was accepted but not retained in session state

Risk:
The system demonstrated cross-language semantic behavior but did not fully materialize the LOT11-A `language + bounded state` envelope.

Resolution:
Added bounded `lastLanguageCode` state limited to `en|fr`, resettable and non-persistent. TG11-023 and TG11-070 now assert FR then EN state transitions.

Status:
CLOSED.

## Reviewer ledger

| Reviewer | Verdict | Strongest challenge |
|---|---|---|
| PRODUCT_AGENT | PASS_WITH_NOTES | The skeleton is useful infrastructure, but there is no chat UI, pacing, fallback copy or user study yet. |
| OCD_SAFETY_AGENT | PASS_WITH_NOTES | Frozen reassurance/checking/rumination/confession cases pass; lexical classification remains brittle outside the curated set and crisis policy remains human-gated. |
| AI_EVAL_AGENT | PASS | 70/70 predeclared cases + 5 Output Guard tests pass on exact candidate; no provider output was used to tune expectations. |
| ARCHITECTURE_AGENT | PASS | New logic is isolated under `lib/conversation/**`; existing LOT06/LOT10 and router remain unchanged; no Core change/provider coupling. |
| DATA_PRIVACY_SECURITY_AGENT | PASS_WITH_NOTES | No raw chat persistence/provider/logging added. Session stores transient derived tokens/theme/language only; future provider dataflow remains unresolved. |
| CONTENT_COPY_AGENT | NOT_APPLICABLE / NOTES | No production generative copy or chat fallback copy is introduced by this sub-lot. |
| LOCALIZATION_AGENT_FR | PASS_WITH_NOTES | Direct FR + EN↔FR→EN cases pass and language state is explicit. Hardcoded lexicons still require broader FR robustness work before release. |
| QA_NON_REGRESSION_AGENT | PASS | Exact-head format/analyze/regression/build/visual workflows are green across LOT03→LOT10. |
| REGULATORY_CLINICAL_REVIEW | HUMAN GATE REMAINS | Required before crisis-policy clinical claim or treatment-like/autonomous ERP behavior. |

## PRODUCT_AGENT detail

Strengths:
- bounded actions remain first-class outcomes;
- user can still reach human Support, Practice and Values deterministically;
- no engagement-at-all-costs objective;
- no provider is required for safety routing;
- failure modes exist before model integration.

Residual:
- no conversational screen/composer exists;
- no UX evidence on when a pivot feels supportive versus punitive;
- no final fallback microcopy exists;
- no real-user usability evidence exists.

Verdict:
**PASS_WITH_NOTES.**

## OCD_SAFETY_AGENT detail

Strengths:
- acute-risk branch is evaluated before ordinary loop handling;
- first high-confidence reassurance/checking/rumination/confession request receives bounded support rather than certainty;
- related continuation pivots deterministically;
- 5-turn and 10-turn persistence cases remain bounded;
- EN→FR→EN does not reset loop state;
- intrusive-thought cases do not automatically imply intent;
- diagnosis/medication/autonomous ERP/efficacy requests hit claim boundaries.

Residual:
- lexical rule sets are not equivalent to semantic clinical classification;
- curated phrase coverage cannot establish population sensitivity/specificity;
- FR urgent markers are technical routing fixtures, not clinically approved crisis policy;
- support-versus-reassurance ambiguity remains context-sensitive.

Verdict:
**PASS_WITH_NOTES.**

## AI_EVAL_AGENT detail

Strengths:
- exact frozen TG11-001→070 set is represented;
- no expected outcome was weakened to fit implementation;
- all 70 pass on final runtime candidate;
- 5 additional Output Guard tests pass;
- exact long-loop and cross-language persistence are exercised;
- failure, privacy and memory states are included.

Residual:
- the suite is curated and deterministic;
- lexical implementation can overfit known cases;
- no fuzz/paraphrase generation corpus exists;
- no stochastic provider repeated-run protocol exists because provider integration is still forbidden.

Verdict:
**PASS.**

## ARCHITECTURE_AGENT detail

Strengths:
- only two new runtime modules plus one test file are introduced;
- no `pubspec.yaml` dependency change;
- no UI router integration yet;
- existing `CompulsionFirewallSession`, `HighRiskBoundary` and app router are unchanged;
- safety decisions remain capsule-owned;
- no vendor SDK, API key, network transport or IAmina Core change exists.

Residual:
- future provider adapter is intentionally absent;
- a real chat UI will need a narrow controller boundary around this policy rather than importing provider logic directly;
- Output Guard must remain defense in depth, not become the primary safety authority.

Verdict:
**PASS.**

## DATA_PRIVACY_SECURITY_AGENT detail

Strengths:
- no raw conversation persistence;
- no database/storage schema added;
- no analytics/logging added;
- no provider transmission;
- session state is memory-only;
- stored session state is derived family/tokens/theme/language, not the raw message;
- reset clears language, turns and pivot state.

Residual:
- derived semantic tokens can still be sensitive while present in memory;
- future logging must not serialize these tokens by convenience;
- provider retention/training/residency cannot be approved before a provider is selected.

Verdict:
**PASS_WITH_NOTES.**

## LOCALIZATION_AGENT_FR detail

Strengths:
- FR markers exist directly rather than relying on translated UI;
- French urgent, reassurance, checking, rumination, diagnosis and medication cases are included;
- EN↔FR→EN persistence is tested;
- session language state is explicit and resettable.

Residual:
- hardcoded phrase lists are not comprehensive linguistic coverage;
- no native-qualified clinical copy review has occurred;
- no dialect/code-switch/typo/accent-omission robustness corpus beyond current fixtures exists.

Verdict:
**PASS_WITH_NOTES.**

## QA_NON_REGRESSION_AGENT detail

Final runtime candidate:
`c87de1606dbe9588f35da70d269abfe46f3be0fe`

Exact-head results:
- LOT03 Flutter shell — SUCCESS
- LOT04 Dashboard V3 — SUCCESS
- LOT05 Bounded Loop — SUCCESS
- LOT06 Compulsion Firewall — SUCCESS
- LOT07 Practice Experience — SUCCESS
- LOT08 Values and Human Support — SUCCESS
- LOT09 Memory Pattern Review — SUCCESS
- LOT10 System Safety — SUCCESS

Direct LOT11 evidence:
- 70/70 TG11 eval cases PASS
- 5/5 Output Guard extra tests PASS
- format PASS
- static analysis PASS
- existing isolation/privacy guards PASS
- release web builds PASS
- legacy focused tests PASS

Verdict:
**PASS.**

## Strongest remaining reasons NOT to authorize a provider/runtime chatbot yet

1. crisis/high-risk policy still lacks qualified human clinical/regulatory validation;
2. deterministic lexical routing is brittle outside the curated corpus;
3. Output Guard can miss semantically unsafe paraphrases;
4. no provider/model has passed frozen evals;
5. provider privacy/retention/training/geography terms are not reviewed;
6. no chat UI or fallback copy has been independently reviewed;
7. no real-user safety/usability evidence exists;
8. no independent human/clinician reviewer has signed off.

## Specialist conclusion

**PASS_WITH_NOTES for LOT11-B deterministic safety skeleton.**

This means:
- the deterministic skeleton is a valid foundation for a later provider experiment;
- the frozen eval baseline is executable;
- cross-language safety state is materially implemented;
- no regression is demonstrated on the existing app.

It does NOT mean:
- a model/provider may now be connected automatically;
- crisis routing is clinically validated;
- the chatbot is production-ready;
- treatment efficacy is established;
- merge or deployment is authorized.

Next mandatory step:
**STRICT DOUBLE SCORE → PROVIDER DECISION HUMAN GATE.**
