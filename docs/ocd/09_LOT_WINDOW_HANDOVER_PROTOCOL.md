# 09 — LOT / WINDOW HANDOVER PROTOCOL

Status: DRAFT FOR REVIEW
Date: 2026-09-16

## GOAL

Keep execution surgical by working **one coherent lot per conversation/window** and forcing an explicit handover before the next lot begins.

The rule is simple:

> **ONE WINDOW = ONE LOT.**

When a lot is closed, the current window does not silently continue into the next lot. It produces a handover and a copy-ready starter prompt for a fresh window.

This prevents context drift, hidden assumptions, stale SHAs, accidental scope expansion and the classic human/agent ritual of continuing until nobody remembers what was originally being built.

All lot transitions are also subject to `10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md`.

## Core workflow

Every implementation lot follows:

`READ → PLAN → EXECUTE → SCORE → SPECIALIST REVIEW → ADVERSARIAL RE-SCORE → PERFECT WITHIN SCOPE → VERIFY → HANDOVER → NEXT WINDOW PROMPT`

A lot is not considered fully closed until the handover package and strict scorecard exist.

## What is a lot?

A lot is one bounded, auditable objective with its own:

- GOAL;
- SUCCESS;
- PROOF;
- material-stage plan and weights;
- branch/PR scope where applicable;
- required specialist reviews;
- acceptance gate;
- non-regression checks;
- strict scoring and adversarial re-scoring plan.

Examples:

- LOT 01 — inspect IAmina Core and map reusable primitives;
- LOT 02 — define the OCD capsule contract;
- LOT 03 — create the app shell;
- LOT 04 — reproduce Dashboard V3 statically;
- LOT 05 — implement the bounded Loop flow.

A roadmap phase may contain more than one lot if the phase is too large for one clean window.

## One-window rule

A window must not silently expand from one completed lot into another material lot.

Once the current lot reaches `VERIFIED` or an explicitly accepted `BLOCKED/READY FOR REVIEW` stopping point:

1. stop implementation work;
2. run the final adversarial severity review;
3. perform any required in-scope perfection pass;
4. compute and record the final lot score;
5. generate the lot handover;
6. generate the next-window starter prompt if the next lot is already approved;
7. record the exact current repository state;
8. begin the next lot only in a fresh window using that prompt.

Minor finishing work inside the same lot is allowed. A new objective, new acceptance gate or new architectural/product question means a new lot/window.

Score-chasing must not be used as a pretext for scope expansion. Perfection work is limited to evidence-backed weaknesses inside the approved lot.

## Required handover artifacts

For every closed lot create:

`docs/ocd/handovers/LOT_XX_HANDOVER.md`

and, when a next lot is already defined:

`docs/ocd/handovers/LOT_YY_START_PROMPT.md`

where `YY` is the next lot number.

If the next lot is not yet approved, the handover must state that no next-window execution prompt is authorized yet.

## Mandatory contents of LOT_XX_HANDOVER.md

Every handover must contain the following sections.

### 1. Identity

- project/repository;
- lot number and title;
- date;
- branch;
- base branch;
- exact HEAD SHA at handover time;
- PR number/state if one exists;
- current merge/deploy authorization state.

### 2. GOAL / SUCCESS / PROOF

Restate what the lot was intended to achieve and whether each success criterion was actually met.

### 3. Strict scorecard

Use `10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md` and `templates/STRICT_SCORECARD_TEMPLATE.md`.

The handover must include:

- every material stage;
- planned weight;
- execution score `/10`;
- adversarial score `/10`;
- final stage score `/10` using the lower justified score;
- score delta and discrepancy investigation when delta is `>0.5`;
- evidence and deductions;
- remediation/perfection work performed;
- `LOT_AGGREGATE_SCORE`;
- `LOT_AUDIT_SCORE`;
- `FINAL_LOT_SCORE`;
- lowest material-stage score;
- lowest critical-dimension score;
- top five reasons the lot is not `10/10`;
- remaining improvement delta to `10.0`;
- explicit statement whether the `>=9.0` verification threshold is met.

A high aggregate may not hide a low critical stage or blocker.

### 4. What was done

List only completed work.

### 5. What was NOT done

Explicitly list deferred, blocked or out-of-scope work so the next window does not infer completion.

### 6. Files changed

List exact repository paths touched by the lot.

### 7. Tests and non-regression

Include:

- exact tests/checks run;
- results;
- screenshots or artifacts where applicable;
- what existing behavior was checked;
- anything not tested.

Missing required proof must be reflected in the score using the hard caps from the scoring protocol.

### 8. Specialist review ledger

For every specialist required by `08_SPECIALIST_REVIEW_MATRIX.md`, record:

- reviewer role;
- verdict (`PASS`, `PASS_WITH_NOTES`, `CHANGES_REQUIRED`, `BLOCKED`, `NOT_APPLICABLE`);
- severe score `/10` when applicable;
- evidence/reference;
- strongest deductions;
- unresolved notes.

No handover may disguise an unresolved `CHANGES_REQUIRED`, `BLOCKED`, low critical score or missing mandatory review as success.

### 9. Final adversarial severity review

Before closeout, answer:

1. What are the five strongest reasons this lot is not `10/10`?
2. Which deduction is most likely to matter to a real user?
3. Which deduction is most likely to cause regression later?
4. Which claim has the weakest proof?
5. What would an expert reviewer attack first?
6. Is there hidden scope creep?
7. Is any risk being disguised as a non-blocking note?
8. What can still be improved inside the current lot without architectural or product expansion?

Then re-score the lot and use the lower justified score.

### 10. Current risks / blockers

State remaining uncertainty, known defects, missing validation, clinical/regulatory boundaries and any stale external dependency.

Risk acceptance does not erase score deductions.

### 11. Repository truth at handover

Record and verify at handover time:

- base branch SHA;
- HEAD SHA;
- ahead/behind divergence;
- PR status;
- CI/check status;
- unresolved review threads where applicable.

Do not assume these values remain current in the next window.

### 12. Next lot

State the recommended next lot only if it is already within the approved roadmap/scope.

A handover may recommend but must not silently authorize a scope expansion.

## Mandatory contents of LOT_YY_START_PROMPT.md

The starter prompt must be self-contained and copy-ready for a fresh conversation/window.

It must instruct the next window to:

1. read the previous lot handover first;
2. read the canonical documents relevant to the next lot, including `10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md`;
3. verify repository state again instead of trusting stale SHAs;
4. inspect branch, HEAD, base, PR, divergence and CI/checks;
5. restate GOAL → SUCCESS → PROOF before modifying anything;
6. identify material stages and planned weights before execution;
7. identify mandatory specialist reviewers from `08_SPECIALIST_REVIEW_MATRIX.md`;
8. score every material stage, then adversarially re-score it;
9. use the lower justified score and investigate deltas `>0.5`;
10. remain inside the next lot scope;
11. preserve Core IAmina / OCD capsule separation;
12. preserve existing behavior and run non-regression checks;
13. never merge or deploy without explicit product-owner approval;
14. stop and report if repository reality differs materially from the handover.

## Starter prompt canonical skeleton

```text
HANDOVER — TrueGround OCD / LOT XX → LOT YY

Repository: hraaaaf/trueground
Previous lot handover: docs/ocd/handovers/LOT_XX_HANDOVER.md
Target lot: LOT YY — <title>

Start by reading the handover and the canonical files it references, including:
- docs/ocd/08_SPECIALIST_REVIEW_MATRIX.md
- docs/ocd/10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md

Do NOT assume any SHA, branch state, PR state or CI result is still current.
Verify first:
- base branch and SHA;
- working branch and HEAD SHA;
- open PR and exact state;
- ahead/behind divergence;
- CI/checks;
- unresolved review comments/threads if applicable.

Before any modification, state:
GOAL
SUCCESS
PROOF

Then define:
- material stages;
- planned weight of each material stage;
- mandatory specialist reviewers;
- critical dimensions;
- minimum score thresholds.

Then inspect the existing implementation and execute only the approved LOT YY scope.

Mandatory rules:
- READ → PLAN → EXECUTE → SCORE → SPECIALIST REVIEW → ADVERSARIAL RE-SCORE → PERFECT WITHIN SCOPE → VERIFY;
- use docs/ocd/08_SPECIALIST_REVIEW_MATRIX.md to identify required reviewers;
- use docs/ocd/10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md for every material score;
- every stage gets EXECUTION_SCORE and ADVERSARIAL_SCORE;
- FINAL_STAGE_SCORE uses the lower justified score;
- investigate score delta >0.5;
- perform the required perfection pass;
- no invented files/routes/tables/interfaces;
- no unrequested refactor or feature expansion;
- no OCD-specific logic in generic IAmina Core;
- preserve existing behavior and prove non-regression;
- no merge without explicit product-owner approval;
- no deployment or real-data/production mutation without explicit approval.

At lot end, do not start LOT ZZ in this window.
Before handover:
- run the final adversarial severity review;
- list the five strongest reasons the lot is not 10/10;
- perform allowed perfection fixes;
- rerun evidence;
- re-score;
- require FINAL_LOT_SCORE >=9.0 plus all binary gates before VERIFIED.

Create:
- docs/ocd/handovers/LOT_YY_HANDOVER.md with the strict scorecard
- docs/ocd/handovers/LOT_ZZ_START_PROMPT.md (only if LOT ZZ is already approved)

Finish with:
Résultat — include FINAL_LOT_SCORE /10
Modifications
Tests
Non-régression
Preuves
Risques
État — include threshold status
Prochaine étape
```

The generated prompt may add lot-specific requirements but must not remove the guardrails above.

## Handover freshness rule

A handover is a snapshot, not an oracle.

The next window must always re-check live repository state before acting.

If the handover says HEAD `abc123` but GitHub now reports another HEAD, the new window must investigate before proceeding.

Scores are also snapshots. A score from a stale HEAD is not proof for a newer HEAD unless the diff is inspected and the relevant evidence remains valid.

## Blocked lots

A blocked lot still receives a handover if the window is ending.

The handover must clearly state:

- `État: BLOCKED`;
- exact blocker;
- evidence;
- strict score and applicable hard cap;
- what must become true before work resumes;
- whether a next lot is allowed in parallel or not.

Do not manufacture a next-lot prompt that bypasses a blocking dependency on the critical path.

## PR and merge rule

A handover does not authorize merge.

A next-window starter prompt does not authorize merge.

A `VERIFIED` lot does not authorize merge.

A high score does not authorize merge.

Only explicit product-owner approval authorizes merge, and the exact current PR/HEAD must be re-checked immediately before that action.

## Deployment rule

No handover, roadmap state, specialist PASS, acceptance gate or score authorizes deployment.

Production, Vercel, TestFlight, Play Store or any external environment requires separate explicit product-owner approval.

## Lot closeout gate

A lot may be called `CLOSED` for execution purposes only when:

- its acceptance criteria have reached the appropriate state;
- mandatory specialist reviews and scores are recorded;
- tests/non-regression evidence are recorded;
- final adversarial audit is recorded;
- required perfection pass is completed or remaining deductions are explicitly deferred with reason;
- `FINAL_LOT_SCORE` is recorded;
- if status is `VERIFIED`, `FINAL_LOT_SCORE >= 9.0` and all binary gates pass;
- `LOT_XX_HANDOVER.md` exists;
- the next-window starter prompt exists if a next approved lot is known;
- exact repository state is captured;
- no merge/deploy is implied.

## Principle

**Context should be transferred deliberately, and quality should be challenged deliberately.**

When uncertain between two plausible scores, keep the lower score until stronger evidence justifies the higher one.
