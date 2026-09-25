# HANDOVER — TrueGround OCD / LOT11-B → PROVIDER DECISION GATE

Date: 2026-09-25  
Repository: `hraaaaf/trueground`  
Branch: `lot/11b-deterministic-conversation-skeleton`  
Runtime candidate: `c87de1606dbe9588f35da70d269abfe46f3be0fe`  
Merge: NOT AUTHORIZED / NOT PERFORMED  
Deployment: NOT AUTHORIZED / NOT PERFORMED  
Provider/model runtime: NONE

## RESULT

LOT11-B has implemented and verified the first deterministic conversational safety skeleton without connecting a model/provider.

Runtime scope:
- capsule-side conversation safety session;
- EN/FR deterministic markers and canonicalization;
- cross-language safety-state persistence;
- deterministic Loop/Practice/Values/Support routing outcomes;
- acute-risk HUMAN_GATE routing before ordinary OCD loop handling;
- diagnosis/medication/efficacy/autonomous-ERP claim boundaries;
- memory/provider fail-closed decisions;
- deterministic Output Guard;
- executable frozen LOT11-A eval harness.

Strict score:
- Pass A: 9.2/10
- Pass B: 9.0/10
- retained: **9.0/10**
- same-session cap respected.

## GOAL achieved

TrueGround now has a deterministic safety envelope that can be tested independently of any LLM.

A future provider cannot be treated as the source of truth for:
- crisis routing;
- reassurance/checking/rumination/confession repetition;
- claim boundaries;
- memory truthfulness;
- output acceptance.

## Runtime files

Created:
- `lib/conversation/conversation_safety_policy.dart`
- `lib/conversation/conversation_output_guard.dart`

Tests:
- `test/lot11_conversational_eval_test.dart`

Existing LOT06/LOT10 runtime and app router remain unchanged.

## Evaluation proof

Frozen LOT11-A dataset:
- TG11-001 → TG11-070
- 70/70 PASS on exact runtime candidate
- 5/5 additional Output Guard tests PASS
- 0 LOT11 failures

Covers:
- benign/helpful false-positive controls;
- support versus reassurance;
- reassurance persistence 2/5/10 turns;
- checking;
- rumination;
- confession;
- retrospective certainty;
- canonical OCD themes;
- intrusive thought versus explicit intent;
- EN + FR;
- EN→FR→EN safety-state bypass;
- diagnosis/medication/autonomous ERP/efficacy boundaries;
- provider failure;
- memory truthfulness;
- hidden-history/system-prompt privacy boundary;
- unsafe generated-output fixtures.

## Exact-head runtime non-regression

Runtime candidate:
`c87de1606dbe9588f35da70d269abfe46f3be0fe`

GitHub Actions:
- LOT03 Flutter shell — `36168731561` — SUCCESS
- LOT04 Dashboard V3 — `36168731488` — SUCCESS
- LOT05 Bounded Loop — `36168731562` — SUCCESS
- LOT06 Compulsion Firewall — `36168731579` — SUCCESS
- LOT07 Practice Experience — `36168731343` — SUCCESS
- LOT08 Values and Human Support — `36168731330` — SUCCESS
- LOT09 Memory Pattern Review — `36168731324` — SUCCESS
- LOT10 System Safety — `36168731328` — SUCCESS

Result:
**8/8 SUCCESS.**

## Perfection-pass fixes

Corrected before scoring:
1. direct FR certainty paraphrase gaps;
2. repository Dart formatting;
3. false positive between LOT10 static claim scanner and internal Output Guard rejection fixture;
4. explicit bounded `lastLanguageCode` session state.

No frozen expected outcome was weakened.

## Architecture boundary

Current implemented flow:

```text
future chat surface
→ ConversationSafetySession
   ├─ urgent HUMAN_GATE
   ├─ support/practice/values routes
   ├─ claim boundaries
   ├─ memory truthfulness
   └─ bounded loop state
→ FUTURE PROVIDER GATE
→ FUTURE MODEL
→ DeterministicConversationOutputGuard
→ bounded render/route
```

Not implemented:
- provider adapter;
- SDK;
- API key;
- network model call;
- tool use;
- chat UI;
- provider retries;
- model observability.

## Privacy state

Still true:
**NO RAW CHAT PERSISTENCE BY DEFAULT.**

LOT11-B adds:
- no storage;
- no DB;
- no analytics;
- no provider transmission;
- no prompt logging.

Session memory is transient and contains only derived turn family/token/theme data plus bounded EN/FR language state.

Do not serialize this state to analytics/logs by convenience.

## Clinical/regulatory state

Still unresolved:
- crisis/high-risk policy has not received qualified human clinical/regulatory approval;
- FR urgent markers prove only deterministic technical routing, not clinical sensitivity/specificity;
- no treatment efficacy claim;
- no autonomous ERP;
- no diagnosis/medication behavior.

REGULATORY_CLINICAL_REVIEW remains a real human gate.

## Specialist review

Artifact:
`docs/ocd/reviews/LOT_11B_SPECIALIST_REVIEW.md`

Verdict:
**PASS_WITH_NOTES.**

## Double score

Artifact:
`docs/ocd/reviews/LOT_11B_STRICT_DOUBLE_SCORE.md`

Retained:
**9.0 / 10.**

## Remaining limitations

1. lexical classifier robustness outside curated cases;
2. semantic Output Guard blind spots;
3. no broad typo/slang/code-switch corpus;
4. no provider/model evaluation;
5. no provider privacy terms review;
6. no chat UI or final fallback copy;
7. no real-user study;
8. no independent clinician/regulatory sign-off.

## NEXT HUMAN GATE — provider decision

Do NOT connect a model automatically.

Before the first model call, present:

### OPTION A — external cloud provider experiment

Evaluate one approved cloud provider behind a narrow adapter.

Must document:
- exact data sent;
- retention/training controls;
- region/residency/subprocessors;
- model/version pinning;
- structured-output capabilities;
- timeout/failure semantics;
- cost/latency;
- deletion/rollback path.

### OPTION B — local/self-hosted model experiment

Evaluate a local or self-hosted candidate to minimize external data transmission.

Must document:
- deployment footprint;
- model quality;
- hardware/runtime requirements;
- update/version-control burden;
- local privacy boundary;
- latency;
- safety/eval consistency.

### RECOMMENDATION

Do not choose A or B from intuition.

Perform a dated provider/privacy comparison first, then select the smallest candidate set that can be tested against the already-frozen 70-case suite.

The first model call requires explicit product-owner approval after that comparison.

## IMPACT of the next decision

Choosing a provider architecture determines:
- whether sensitive conversation leaves the device/environment;
- provider retention/training exposure;
- dependency footprint;
- cost/latency;
- model consistency/version drift;
- failure modes;
- observability/privacy design;
- rollback complexity.

This is therefore a human architecture/privacy gate, not an implementation detail.

## Do not forget

- Core IAmina / OCD capsule separation remains mandatory.
- Safety authority remains deterministic/capsule-owned.
- Provider output is always untrusted.
- Output Guard remains defense in depth.
- Crisis HUMAN_GATE remains open.
- No raw chat persistence by default.
- No merge without explicit product-owner approval.
- No deployment without explicit product-owner approval.
- No first model call without explicit product-owner approval.
