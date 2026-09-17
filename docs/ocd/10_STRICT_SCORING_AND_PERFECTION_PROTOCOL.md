# 10 — STRICT SCORING & PERFECTION PROTOCOL

Status: DRAFT FOR REVIEW
Date: 2026-09-16
Owner: Product owner

## GOAL

Make quality measurable, deliberately severe and difficult to inflate.

Every material stage, artifact, flow, specialist review, acceptance gate and lot closeout must be scored, challenged, re-scored and improved before it can be treated as verified.

This protocol is a mandatory cross-cutting governance overlay on:

- `06_ROADMAP_TO_TARGET.md`;
- `07_ACCEPTANCE_GATES.md`;
- `08_SPECIALIST_REVIEW_MATRIX.md`;
- `09_LOT_WINDOW_HANDOVER_PROTOCOL.md`.

A green CI, a specialist `PASS`, or a visually plausible result is not enough by itself.

Core rule:

> **BUILD → SCORE → ADVERSARIAL DOUBLE-CHECK → RE-SCORE → PERFECT WITHIN SCOPE → VERIFY**

## What must be scored

Scoring is mandatory for every material:

- planning decision;
- implementation step;
- UI screen or flow;
- architecture decision;
- data/privacy/security change;
- AI/prompt/policy/evaluation change;
- copy/content change;
- test/non-regression checkpoint;
- specialist review;
- acceptance gate;
- lot closeout.

Purely mechanical actions such as reading a file, checking out a branch or creating a commit do not need an isolated quality score, but their correctness must be covered by the evidence and repository-truth checks of the material stage they support.

## Severe 0–10 scale

Scores use one decimal place and MUST NOT be rounded upward.

- `10.0` — exceptional; no known meaningful defect or in-scope improvement remains. Rare by design.
- `9.5–9.9` — near-reference quality; only negligible or cosmetic deductions remain.
- `9.0–9.4` — excellent and verification-grade if all binary gates and critical floors also pass.
- `8.5–8.9` — strong but not closure-grade; mandatory perfection pass required.
- `8.0–8.4` — material weaknesses remain; `CHANGES_REQUIRED`.
- `7.0–7.9` — major gaps, weak proof or incomplete execution; cannot be verified.
- `<7.0` — unacceptable for the intended scope; likely blocking.

The default mindset is to search for deductions, not reasons to award a high score.

A `10.0` must never be awarded merely because tests pass.

## Mandatory scoring dimensions

Each material stage is scored against these dimensions. If a dimension is genuinely not applicable, state `N/A` with a concrete reason rather than silently removing it.

| Dimension | Default weight | What it asks |
|---|---:|---|
| Requirements / target fidelity | 20% | Did we build exactly what was approved, without drift? |
| Correctness / behavior / consistency | 20% | Does it actually work or remain internally coherent under realistic conditions? |
| Evidence / proof strength | 15% | Is the claim supported by direct, reproducible evidence? |
| Non-regression / compatibility | 15% | Did we preserve validated behavior and check the relevant edge cases? |
| Critical risk quality | 15% | Safety, privacy, security, accessibility, OCD-risk, data integrity or equivalent risk for the stage. |
| Craft / usability / maintainability | 10% | Is the result polished, understandable, maintainable and fit for its intended surface? |
| Scope discipline | 5% | Did we avoid unrequested features, refactors, dependencies and architecture changes? |

For a stage where one dimension is `N/A`, the remaining weights are normalized proportionally. The reason for `N/A` must be recorded.

## Mandatory double-check

Every material score is produced twice.

### PASS A — EXECUTION SCORE

Immediately after the stage is implemented and its direct checks are run, record:

- dimension scores;
- weighted score;
- concrete deductions;
- evidence;
- unresolved uncertainty.

### PASS B — ADVERSARIAL SCORE

A relevant specialist or independent adversarial review pass must inspect the actual artifact, evidence and behavior and actively try to invalidate PASS A.

The adversarial reviewer must answer:

> **What is the strongest evidence that this stage is worse than the execution score claims?**

Then record a second score using the same scale.

### FINAL STAGE SCORE

`FINAL_STAGE_SCORE = min(EXECUTION_SCORE, ADVERSARIAL_SCORE)`

Never average the two scores upward.

If the difference between the two scores is greater than `0.5`, investigate the discrepancy before verification and keep the lower score until resolved by new evidence.

If no separate reviewer runtime is available and the same agent performs the adversarial pass, that limitation must be disclosed. The pass must still be separated in reasoning and evidence and must not be described as independent human validation.

For any material stage or lot where the same agent performs both the execution score and adversarial re-score and no independent reviewer/human validation is available, the authoritative score is capped at `9.4`. A score of `9.5+` requires genuinely independent review plus direct evidence.

## Hard score caps

The following caps are automatic and override any optimistic weighted calculation:

- required test/check failing → maximum `7.9` and not verified;
- required evidence missing → maximum `7.9`;
- required screenshot/render not inspected for a UI gate → maximum `7.9`;
- target-driven visual fidelity claimed without direct target/render comparison → visual-fidelity dimension maximum `7.5`;
- mandatory specialist review missing → maximum `7.9`;
- unresolved `CHANGES_REQUIRED` → maximum `7.9`;
- observed non-regression failure → maximum `6.9`;
- material safety/privacy/security/data-integrity blocker → maximum `5.9` and `BLOCKED`;
- unsupported medical/clinical claim or unapproved treatment-like behavior → maximum `5.9` and `BLOCKED` until the required validation exists;
- same-agent execution + adversarial review with no independent review available → maximum `9.4`;
- claim not backed by inspected evidence → deduct and do not score that claim as verified.

A product-owner risk acceptance may change execution status, but it must not falsify the score. Accepted debt remains a deduction.

## Stage advancement threshold

A material stage may advance normally only when:

- `FINAL_STAGE_SCORE >= 8.5`;
- no required binary test/gate is failing;
- no mandatory reviewer is missing;
- no critical dimension is below `8.0`;
- no `CHANGES_REQUIRED` or `BLOCKED` verdict remains unresolved.

If a stage is below `8.5`, fix it before continuing unless the product owner explicitly accepts a documented stop/defer decision.

For critical safety, privacy/security, data integrity, architecture-boundary or accessibility dimensions when they are central to the stage, the target floor is `9.0` before the related gate can become `VERIFIED`.

## Perfection pass

Every lot receives a final perfection pass, regardless of its current numerical score.

Any material stage scoring `8.5–8.9` requires remediation before lot closeout unless the remaining deduction is explicitly deferred because it needs a new product/architecture decision or a separate lot.

For stages already scoring `>=9.0`, the perfection pass must still inspect the largest deductions and implement any meaningful, low-risk, in-scope improvement whose benefit is supported by evidence. If no such improvement should be made, record why rather than silently skipping the pass.

The perfection pass must:

1. list the three largest evidence-backed deductions;
2. fix the highest-impact deduction that is inside the approved scope and proportionate to risk;
3. rerun the affected tests/evidence;
4. repeat the adversarial re-score;
5. continue only while improvements remain in scope and proportionate.

Do not create features, refactors, dependencies or architecture changes merely to chase a score.

If the remaining deductions require a new product decision or a new lot, record them as deferred rather than hiding them.

## Specialist scoring rule

Every mandatory specialist review from `08_SPECIALIST_REVIEW_MATRIX.md` must include both:

- the existing verdict (`PASS`, `PASS_WITH_NOTES`, `CHANGES_REQUIRED`, `BLOCKED`, `NOT_APPLICABLE`);
- a severe score `/10` with explicit deductions and evidence.

A specialist `PASS` with a low score is contradictory and must be reconciled.

Recommended consistency:

- `PASS` normally requires `>=9.0`;
- `PASS_WITH_NOTES` normally maps to `8.5–8.9` or to `>=9.0` with clearly non-blocking notes;
- `CHANGES_REQUIRED` is normally `<8.5`;
- `BLOCKED` follows the blocker itself, regardless of numerical average.

The binary verdict always remains authoritative for blockers; the score never overrides safety or correctness gates.

## Lot-level scoring

At PLAN time, identify the material stages that will form the lot score. Assign weights before implementation so the weighting cannot be manipulated after seeing results.

At lot closeout record for every material stage:

- stage name;
- planned weight;
- execution score;
- adversarial score;
- final stage score;
- evidence;
- main deductions;
- remediation performed.

Compute:

`LOT_AGGREGATE_SCORE = weighted average of FINAL_STAGE_SCORE values`

Then perform a separate end-of-lot adversarial audit and score the lot as a coherent whole:

`LOT_AUDIT_SCORE`

The authoritative lot score is:

`FINAL_LOT_SCORE = min(LOT_AGGREGATE_SCORE, LOT_AUDIT_SCORE)`

Round downward to one decimal place. Never round upward.

Apply all hard caps after the mathematical calculation. A cap can only lower the authoritative score.

## Lot verification threshold

A lot may be called `VERIFIED` only when all existing acceptance-gate requirements pass AND:

- `FINAL_LOT_SCORE >= 9.0`;
- every material stage has `FINAL_STAGE_SCORE >= 8.5`;
- every critical dimension applicable to the lot meets its required floor;
- no mandatory reviewer is missing;
- no unresolved `CHANGES_REQUIRED` or `BLOCKED` verdict remains;
- required non-regression evidence exists;
- required rendered/behavioral evidence has actually been inspected;
- the final perfection pass has been completed and documented.

If `FINAL_LOT_SCORE` is:

- `9.0–10.0` → eligible for `VERIFIED`, subject to all binary gates and hard caps;
- `8.5–8.9` → `READY FOR REVIEW`, mandatory perfection pass/remediation;
- `<8.5` → `CHANGES_REQUIRED` or `BLOCKED` depending on the defect.

A score never authorizes merge or deployment.

## Mandatory final-lot severity review

Before handover, perform one final review whose purpose is explicitly to lower an unjustified score.

It must answer:

1. What are the five strongest reasons this lot is not a `10/10`?
2. Which deduction is most likely to matter to a real user?
3. Which deduction is most likely to cause regression later?
4. Which claim has the weakest proof?
5. What would an expert reviewer attack first?
6. Is there any hidden scope creep?
7. Is any risk being disguised as a non-blocking note?
8. What can still be improved inside the current lot without architectural or product expansion?

After answering, perform the final perfection pass, rerun affected evidence, re-score the lot, and use the lower justified score.

## Required closeout output

Every significant lot handover must include a `STRICT SCORECARD` containing:

- `FINAL_LOT_SCORE / 10`;
- `LOT_AGGREGATE_SCORE / 10`;
- `LOT_AUDIT_SCORE / 10`;
- lowest material stage score;
- lowest critical-dimension score;
- specialist scores;
- top five deductions;
- perfection fixes completed;
- remaining improvement delta to `10.0`;
- independence limitation/cap if applicable;
- explicit statement of whether the `>=9.0` verification threshold is met.

The normal chantier closeout must also report the score under `Résultat` and `État`.

## No score inflation

Forbidden scoring behaviors:

- giving `10/10` because CI is green;
- awarding points for work that was not verified;
- averaging away a critical defect;
- converting missing evidence into a neutral score;
- raising a score without new evidence or a concrete fix;
- hiding a blocker inside `PASS_WITH_NOTES`;
- treating a product-owner acceptance of debt as proof that the debt disappeared;
- scoring visual fidelity from source code without inspecting the render;
- scoring AI/OCD behavior from a few cherry-picked prompts instead of the required eval set;
- calling a same-agent self-check independent validation;
- skipping the final perfection pass because the score already exceeds `9.0`.

## Final principle

> **The score exists to expose the gap between “working” and “excellent”, not to make the team feel successful.**

When uncertain between two scores, use the lower score until evidence justifies the higher one.
