# LOT 11B — STRICT DOUBLE SCORE

Project: TrueGround OCD  
Lot: LOT11-B — Deterministic Conversation Runtime Skeleton  
Date: 2026-09-25  
Runtime candidate scored: `c87de1606dbe9588f35da70d269abfe46f3be0fe`  
Review independence: same model/session, adversarial second pass  
Maximum permitted score under protocol: **9.4 / 10**  
Provider/model runtime: NONE

## Scoring scope

This score covers only:

- deterministic conversational safety session;
- EN/FR lexical/canonical safety routing;
- cross-language state preservation;
- deterministic route outcomes;
- claim boundaries;
- memory/provider fail-closed policy objects;
- deterministic Output Guard;
- frozen 70-case eval harness;
- exact-head non-regression evidence.

It does NOT score:
- an actual model/provider;
- a chat UI;
- final user-facing conversational copy;
- crisis-policy clinical validity;
- treatment efficacy;
- production privacy;
- real-user outcomes.

## PASS A — execution reviewer

| Axis | Score | Reason |
|---|---:|---|
| Product coherence | 9.1 | Safety skeleton supports bounded help without becoming a refusal-only engine; no chat UX yet. |
| Functional contract fidelity | 9.3 | Routes, claim boundaries, memory/failure handling and cross-language state implement the LOT11-A contract materially. |
| OCD safety | 9.2 | 70/70 frozen cases pass; repeated reassurance/checking/rumination/confession stay bounded; crisis remains gated. |
| Architecture | 9.4 | New logic isolated under `lib/conversation/**`; no Core/provider/router mutation. |
| Privacy/security | 9.3 | No raw persistence/provider/logging; transient derived state only. |
| Evaluation design/execution | 9.4 | Frozen 70-case dataset + 5 Output Guard tests all pass on exact candidate. |
| Localization safety | 9.1 | Direct FR and EN↔FR→EN state pass; lexical coverage is still finite and curated. |
| QA/non-regression | 9.4 | LOT03→LOT10 exact-head 8/8 SUCCESS; format/analyze/build/regression green. |
| Content/claim discipline | 9.3 | Diagnosis/medication/efficacy/autonomous ERP boundaries enforced before provider integration. |
| Failure truthfulness | 9.3 | Provider/memory failures fail closed without fabricated history/success. |

### PASS A overall

**9.2 / 10**

### PASS A deductions — material reasons preventing 10/10

1. Deterministic lexical routing is brittle outside the curated phrase distribution.
2. Crisis/high-risk policy remains clinically/regulatorily unvalidated.
3. Output Guard is rule-based and cannot prove semantic safety for arbitrary generated paraphrases.
4. No provider/model has been evaluated.
5. No chat UI, timing, recovery UX or final deterministic fallback copy exists.
6. Provider privacy/retention/training/geography is unresolved.
7. No real-user safety/usability evidence exists.
8. No genuinely independent human/clinician review exists.

## PASS B — adversarial reviewer

Question:

> What is the strongest reason this implementation should NOT be treated as a production conversational-safety system merely because all 70 frozen cases are green?

### B1 — curated-set overfitting

The current implementation is explicitly lexical/canonical and can overfit known phrase families.

Mitigation:
- cases were frozen before implementation;
- false-positive controls exist;
- EN/FR and cross-language variants exist;
- no aggregate score can hide critical failures.

Residual:
Unknown paraphrases, typos, slang, mixed-language and indirect formulations remain underexplored.

Deduction: **-0.20**

### B2 — crisis routing is technical, not clinically validated

French and English urgent markers route deterministically.

Mitigation:
The model cannot own the crisis route and the human gate remains explicit.

Residual:
Technical routing evidence is not clinical sensitivity/specificity evidence.

Deduction: **-0.20**

### B3 — Output Guard can miss semantic equivalents

The deterministic guard rejects versioned unsafe outputs.

Mitigation:
Pre-model capability policy blocks disallowed tasks first; guard is defense in depth.

Residual:
A future provider can generate an unsafe paraphrase not captured lexically.

Deduction: **-0.15**

### B4 — support versus reassurance remains context-dependent

Lexical rules can misclassify nuanced support-seeking or certainty-seeking.

Mitigation:
False-positive controls, family/theme state and one-bounded-turn policy reduce the risk.

Residual:
No broad real-world conversational corpus or user study exists.

Deduction: **-0.15**

### B5 — provider and dataflow are still hypothetical

No SDK/model/network call exists.

Mitigation:
This is intentional and protects the LOT11-B scope.

Residual:
Real latency, malformed outputs, version drift, retention and model consistency are not yet evidenced.

Deduction: **-0.10**

### B6 — language coverage is direct but finite

French is implemented directly and language-switch state is retained.

Mitigation:
Matched EN/FR frozen cases pass and no English-only fallback is falsely claimed equivalent.

Residual:
No dialect/code-switch/typo corpus and no qualified FR clinical-copy review.

Deduction: **-0.10**

### PASS B critical-axis floor

| Critical axis | Score |
|---|---:|
| OCD safety | 9.0 |
| Architecture | 9.2 |
| Privacy/security | 9.1 |
| Evaluation | 9.1 |
| Localization safety | 9.0 |
| QA/proof | 9.3 |
| Failure truthfulness | 9.1 |

### PASS B overall

**9.0 / 10**

## Retained score

Pass A: **9.2 / 10**  
Pass B: **9.0 / 10**  
Same-session ceiling: **9.4 / 10**

Retained lower score:

**9.0 / 10**

## Why runtime-chatbot release is still blocked despite a 9.0 skeleton score

The score applies to a bounded deterministic infrastructure sub-lot.

It does not cancel independent future gates.

Still blocked:
- provider/model connection without product-owner approval;
- crisis-policy clinical/regulatory claim;
- autonomous ERP/treatment-like behavior;
- production data transmission;
- provider-specific privacy approval;
- production conversational release.

## Perfection pass record

Before scoring, three implementation weaknesses were corrected:

1. FR paraphrase gaps;
2. LOT10 static scanner compatibility without weakening LOT10;
3. explicit bounded EN/FR session language state.

The full exact-head suite was rerun after those corrections.

## Final scoring verdict

**9.0 / 10 — PASS_WITH_NOTES for LOT11-B deterministic safety skeleton.**

This is intentionally below 9.5 because:
- the adversarial pass is same-session;
- the implementation remains lexical and curated-set bounded;
- no provider, chat UX, clinical crisis validation or real-user evidence exists.

No score inflation is permitted to convert deterministic-test success into a clinical or model-safety claim.
