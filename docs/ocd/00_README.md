# TrueGround OCD — Canonical Documentation

Status: DRAFT FOR REVIEW
Date: 2026-09-16
Owner: Product owner

## Purpose

This directory is the canonical compass for the OCD product built on the IAmina machine.

The product is a separate client/vertical. IAmina is the reusable platform/core; OCD-specific product, safety, domain logic, prompts, policies, evaluations and data rules belong to the OCD capsule and must not leak into the generic IAmina Core.

## Canonical documents

1. `01_PRODUCT_NORTH_STAR.md` — fixed product target and visual/functional destination.
2. `02_OCD_PRODUCT_SPEC.md` — product behavior and V1 functional scope.
3. `03_OCD_CLINICAL_SAFETY.md` — safety boundaries, anti-reassurance rules and validation requirements.
4. `04_IAMINA_CAPSULE_ARCHITECTURE.md` — strict Core vs OCD capsule separation.
5. `05_DATA_PRIVACY_SECURITY.md` — sensitive-data, privacy and security requirements.
6. `06_ROADMAP_TO_TARGET.md` — execution path from foundation to V1 target.
7. `07_ACCEPTANCE_GATES.md` — objective evidence required before any phase can be considered verified.
8. `08_SPECIALIST_REVIEW_MATRIX.md` — mandatory independent specialist/agent checks by change type, flow and roadmap phase.
9. `09_LOT_WINDOW_HANDOVER_PROTOCOL.md` — one-lot-per-window rule, mandatory handover and next-window starter prompt.

Mandatory cross-cutting governance protocol:

- `10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md` — severe scoring, adversarial double-check, re-scoring and mandatory perfection pass rules for every material stage and lot closeout.

Templates:

- `templates/LOT_HANDOVER_TEMPLATE.md`
- `templates/LOT_START_PROMPT_TEMPLATE.md`

## Source-of-truth precedence

When documents overlap, use this precedence by subject:

- Product vision / target UX → `01_PRODUCT_NORTH_STAR.md`
- Functional behavior → `02_OCD_PRODUCT_SPEC.md`
- Safety / clinical behavior → `03_OCD_CLINICAL_SAFETY.md`
- Architecture → `04_IAMINA_CAPSULE_ARCHITECTURE.md`
- Data / privacy / security → `05_DATA_PRIVACY_SECURITY.md`
- Execution order → `06_ROADMAP_TO_TARGET.md`
- Definition of verified → `07_ACCEPTANCE_GATES.md`
- Required specialist review → `08_SPECIALIST_REVIEW_MATRIX.md`
- Lot/window transitions and handovers → `09_LOT_WINDOW_HANDOVER_PROTOCOL.md`
- Scoring, adversarial re-scoring and perfection thresholds → `10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md`

A decision must have one canonical home. Do not duplicate competing truths across files.

The scoring protocol is a mandatory overlay on roadmap execution, specialist reviews, acceptance gates and lot handovers. A stage or lot that ignores the scoring protocol cannot be treated as `VERIFIED`.

## Working method

Every significant task follows:

`READ → PLAN → EXECUTE → SCORE → SPECIALIST REVIEW → ADVERSARIAL RE-SCORE → PERFECT WITHIN SCOPE → VERIFY → HANDOVER → NEXT WINDOW PROMPT`

And must define:

- GOAL — what must be achieved.
- SUCCESS — measurable acceptance condition.
- PROOF — concrete evidence that success was achieved.

The builder does not validate its own work alone. Material work must receive the specialist checks required by `08_SPECIALIST_REVIEW_MATRIX.md` and the severe double-check scoring required by `10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md` before its acceptance gate can become `VERIFIED`.

## Mandatory strict scoring

Every material stage and every lot closeout must be scored `/10` using the severe scale in `10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md`.

Mandatory rules:

- score after execution;
- adversarially double-check and score again;
- use the lower justified score rather than averaging upward;
- explicitly list deductions and evidence;
- perform a focused perfection pass when the score is below verification quality;
- do not allow green CI, a passing specialist verdict or product-owner debt acceptance to inflate the score;
- do not call a lot `VERIFIED` unless the strict scoring threshold and all binary gates are satisfied.

## One lot per window

Execution is deliberately split by lot:

> **ONE WINDOW = ONE LOT.**

When the current lot ends, do not silently begin the next material lot in the same conversation/window.

Instead:

1. stop the current lot;
2. verify repository truth and evidence;
3. perform the mandatory final severe score + adversarial re-score;
4. complete the in-scope perfection pass or record why a remaining deduction requires a new decision/lot;
5. create `docs/ocd/handovers/LOT_XX_HANDOVER.md` with the strict scorecard;
6. create `docs/ocd/handovers/LOT_YY_START_PROMPT.md` if the next lot is already approved;
7. begin LOT YY in a fresh window using that prompt;
8. re-check branch, HEAD, PR, divergence and CI before acting because handover values may already be stale.

Detailed transition rules are canonical in `09_LOT_WINDOW_HANDOVER_PROTOCOL.md` and scoring rules in `10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md`.

## Project guardrails

- No merge without explicit product-owner approval.
- No production deployment without explicit product-owner approval.
- No real database, user-data, secret or production-schema mutation without explicit approval.
- No medical claim, diagnosis, therapeutic promise or unvalidated clinical behavior.
- No OCD-specific logic inside generic IAmina Core.
- Every AI feature must be evaluated for reassurance seeking, checking, rumination, repetitive questioning and inadvertent reinforcement of compulsions.
- Preserve existing validated behavior and provide non-regression evidence for every significant change.
- Keep changes small, isolated and auditable.
- Mandatory specialist review cannot be skipped merely because implementation tests or CI are green.
- Mandatory scoring and adversarial re-scoring cannot be skipped merely because a specialist verdict is `PASS`.
- A lot is not fully closed until its required handover package and strict scorecard exist.
- A handover, high score or `VERIFIED` state never implies authorization to merge or deploy.

## Status vocabulary

Use only:

- `NOT STARTED`
- `IN PROGRESS`
- `BLOCKED`
- `READY FOR REVIEW`
- `VERIFIED`

`VERIFIED` requires the acceptance gate, required specialist checks, strict-scoring threshold and evidence. Green CI alone is not sufficient.

For execution sequencing, a lot may be treated as `CLOSED` only after the handover requirements in `09_LOT_WINDOW_HANDOVER_PROTOCOL.md` and final scoring requirements in `10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md` are satisfied. `CLOSED` does not authorize merge or deployment.

## Current state

This documentation set defines the target and guardrails only. It does not constitute clinical validation, production readiness, regulatory clearance, or authorization to merge/deploy.
