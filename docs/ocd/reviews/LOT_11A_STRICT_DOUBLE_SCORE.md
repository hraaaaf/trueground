# LOT 11A — STRICT DOUBLE SCORE

Project: TrueGround OCD
Lot: LOT11-A
Date: 2026-09-25
Substantive candidate reviewed after scientific rebalance + specialist refresh: `9445ce8c10b6b0ba7dd68f97bc27f58144a470a9`
Review independence: same model/session, adversarial second pass
Maximum permitted score under protocol: **9.4 / 10**
Runtime AI/provider: NONE

## Scoring scope

This score covers only the authorized LOT11-A deliverable:

- scientific baseline;
- conversational safety/capability contract;
- architecture/privacy contract;
- pre-implementation eval dataset;
- predeclared acceptance thresholds;
- specialist review.

It does not score a conversational runtime, model, provider, chat UI, crisis protocol or clinical efficacy.

## PASS A — execution reviewer

### Axis scores

| Axis | Score | Reason |
|---|---:|---|
| Product coherence | 9.4 | Useful conversation remains allowed; support/values/human routes are first-class; no engagement-at-all-costs objective. |
| Contract consistency / functional spec | 9.3 | Required families have dispositions, repetition bounds, failure behavior and routing. |
| OCD safety | 9.2 | Strong anti-reassurance/checking/rumination/confession policy; intrusive-thought distinction explicit; crisis remains correctly gated. |
| Evidence quality / transfer discipline | 9.3 | Primary studies + meta-analyses + limitations; positive GenAI evidence and safety/validation gaps are both represented; non-OCD findings are not generalized to OCD. |
| Architecture | 9.3 | Pre-model policy + provider abstraction + post-model guard; Core/capsule separation preserved. |
| Privacy / security | 9.3 | No raw chat persistence by default; no raw logs/analytics; provider context minimized. |
| Evaluation design | 9.4 | 70 cases frozen before outputs; 2/5/10-turn persistence; false positives; EN/FR; failures; claims; memory. |
| Localization safety | 9.2 | Direct EN/FR equivalence and cross-language state are required; current EN-only classifier gap is explicit. |
| QA / non-regression evidence | 9.1 | Docs-only substantive diff and structural checks proven; final exact-head workflow proof is still a VERIFY item. |
| Content / claim discipline | 9.3 | No diagnosis/medication/efficacy/autonomous ERP claim; exact generated copy deferred for separate review. |

### PASS A overall

**9.2 / 10**

### PASS A deductions — at least five material reasons

1. Crisis/high-risk policy is not clinically/regional-policy validated.
2. Current deterministic safety classifiers are English-centric and cannot yet satisfy the EN/FR contract.
3. No provider/model has been evaluated; all generative behavior remains theoretical.
4. Provider privacy/security/retention/training terms are necessarily unknown.
5. Actual IAmina Core implementation was not inspected for provider-adapter reuse in this window.
6. Exact conversational microcopy has not been clinically reviewed.
7. No chat UX/user-study evidence exists.
8. Final exact-head CI/workflow verification is not yet attached to the scored candidate.

## PASS B — adversarial reviewer

Question used:

> What is the strongest reason this LOT11-A specification should NOT be accepted as a safe foundation, even though it looks comprehensive?

### Adversarial findings

#### B1 — curated eval overfitting risk

A future implementation can accidentally overfit 70 known cases while remaining brittle outside them.

Mitigation already present:
- policy outcomes, not target wording;
- false-positive controls;
- no aggregate score can hide a critical failure;
- future broader robustness suite must be predeclared.

Residual:
Still no real-world distribution evidence.

Deduction: **-0.20**

#### B2 — Output Guard semantic blind spots

A deterministic guard can miss unsafe paraphrases.

Mitigation:
Contract explicitly downgraded Output Guard to defense in depth; disallowed capability is blocked pre-model; whole-system eval remains mandatory.

Residual:
No implemented guard exists to inspect.

Deduction: **-0.15**

#### B3 — support versus reassurance is context-dependent

The same sentence can function as support in one context and certainty seeking in another.

Mitigation:
The contract uses requested function/outcome rather than keyword-only logic and contains support false-positive controls.

Residual:
A future classifier can still misread nuanced context.

Deduction: **-0.15**

#### B4 — multilingual policy is specified, not implemented

The current app can display FR, but its relevant lexical safety classifiers are English-centric.

Mitigation:
This is now a first-class LOT11-B requirement and cannot be claimed as already solved.

Residual:
No runtime evidence yet.

Deduction: **-0.15**

#### B5 — no stochastic evaluation protocol yet

Model temperature, repeated sampling, version drift and provider updates can change behavior.

Mitigation:
Model evaluation is out of LOT11-A scope and must be predeclared before first experiment.

Residual:
A single-pass future benchmark would be insufficient.

Deduction: **-0.10**

#### B6 — crisis policy is unresolved

A conversational surface increases the chance that acute-risk language reaches the product.

Mitigation:
No model is permitted to own this route and current HUMAN_GATE is preserved.

Residual:
Runtime release remains blocked until qualified human review.

Deduction: **-0.15**

#### B7 — provider data exposure is unresolved by definition

The contract minimizes context, but the real vendor terms/data path are unknown.

Mitigation:
No provider is selected or connected.

Residual:
Provider approval remains a separate privacy/security gate.

Deduction: **-0.10**

#### B8 — scientific confirmation-bias challenge

The initial scientific narrative was more explicit about GenAI safety gaps than about recent positive controlled evidence.

Mitigation:
Before this rescore, the baseline was amended to include PMID 41401240 and PMID 41540194 and to state explicitly that the evidence is promising in mental health generally while remaining non-OCD-specific and insufficient to validate unrestricted reassurance-sensitive chat.

Residual:
The broader GenAI literature is evolving quickly and future provider decisions will require a dated evidence refresh.

Disposition:
**Corrected before rescore; no additional retained deduction beyond the existing evidence-transfer uncertainty.**

### PASS B axis floor

| Critical axis | Adversarial score |
|---|---:|
| OCD safety | 9.0 |
| Architecture | 9.1 |
| Privacy/security | 9.1 |
| Evidence/transfer | 9.1 |
| Evaluation design | 9.2 |
| Localization safety | 9.0 |
| QA/proof | 9.0 |

### PASS B overall

**9.0 / 10**

## Retained score

Execution pass A: **9.2 / 10**

Adversarial pass B: **9.0 / 10**

Same-session ceiling: **9.4 / 10**

Retained lower score:
**9.0 / 10**

## Why the external blockers do not cap LOT11-A documentation to 5.9

The strict protocol caps a candidate when the **candidate itself** contains an unresolved blocking safety/privacy/clinical-claim defect.

LOT11-A is explicitly a pre-implementation safety specification whose required success condition is to preserve unresolved runtime dependencies as blockers rather than pretend to solve them.

Therefore:
- crisis human review remains a blocker for **runtime conversational release**, not evidence that the LOT11-A documentation violated its own scope;
- provider privacy remains a gate for **provider connection**, while LOT11-A correctly connects no provider;
- English-only current classifiers remain a **LOT11-B implementation blocker**, while LOT11-A explicitly documents that they are insufficient.

If LOT11-A had claimed these were solved, the score would be capped. It does not.

## Verification cap

The documentation quality score is **9.0 / 10**.

However, certification state remains **VERIFICATION INCOMPLETE** until final exact-head proof is collected after all LOT11-A files are present.

No "VERIFIED", merge authorization or runtime authorization is granted by this score alone.

## Conditions to preserve the 9.0 score

Any subsequent LOT11-A change must trigger re-review if it changes:
- safety dispositions;
- persistence/repetition limits;
- privacy defaults;
- architecture ownership;
- eval cases/thresholds;
- evidence interpretation;
- crisis policy;
- supported languages;
- intended population.

A documentation-only handover that does not change these decisions does not alter the substantive score, but final exact-head non-regression proof is still required.

## Post-amendment rescore

The scientific rebalance was treated as a material evidence-interpretation change and therefore triggered a fresh adversarial review before final verification.

Result after correction:
- Pass A remains **9.2 / 10**;
- Pass B remains **9.0 / 10**;
- retained score remains **9.0 / 10**;
- same-session ceiling remains **9.4 / 10**.

Reason the score does not increase:
the correction improves scientific balance but does not remove the dominant runtime uncertainties: no provider eval, no implemented multilingual router, no reviewed crisis policy, no chat UX evidence and no genuinely independent external reviewer.

## Final scoring verdict

**9.0 / 10 — PASS_WITH_NOTES for LOT11-A specification quality, pending final VERIFY.**

This is intentionally below 9.5 because:
- the second pass is not genuinely independent;
- material future-runtime uncertainty remains;
- no provider, multilingual router, chat UX or clinical crisis review exists yet.

No score inflation is permitted to hide those facts.
