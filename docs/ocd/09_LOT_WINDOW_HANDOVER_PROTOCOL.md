# 09 — LOT / WINDOW HANDOVER PROTOCOL

Status: DRAFT FOR REVIEW
Date: 2026-09-15

## GOAL

Keep execution surgical by working **one coherent lot per conversation/window** and forcing an explicit handover before the next lot begins.

The rule is simple:

> **ONE WINDOW = ONE LOT.**

When a lot is closed, the current window does not silently continue into the next lot. It produces a handover and a copy-ready starter prompt for a fresh window.

This prevents context drift, hidden assumptions, stale SHAs, accidental scope expansion and the classic human/agent ritual of continuing until nobody remembers what was originally being built.

## Core workflow

Every implementation lot follows:

`READ → PLAN → EXECUTE → SPECIALIST REVIEW → DOUBLE SCORE → VERIFY → HANDOVER → NEXT WINDOW PROMPT`

For every material lot, the double-score closeout defined in `10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md` is mandatory. If either pass is missing, the lot state is `VERIFICATION INCOMPLETE`, never `VERIFIED`.

A lot is not considered fully closed until the handover package exists.

## What is a lot?

A lot is one bounded, auditable objective with its own:

- GOAL;
- SUCCESS;
- PROOF;
- branch/PR scope where applicable;
- required specialist reviews;
- mandatory severe score + independent/adversarial second score, retaining the lower result;
- acceptance gate;
- non-regression checks.

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
2. generate the lot handover;
3. generate the next-window starter prompt;
4. record the exact current repository state;
5. begin the next lot in a fresh window using that prompt.

Minor finishing work inside the same lot is allowed. A new objective, new acceptance gate or new architectural/product question means a new lot/window.

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

### 3. What was done

List only completed work.

### 4. What was NOT done

Explicitly list deferred, blocked or out-of-scope work so the next window does not infer completion.

### 5. Files changed

List exact repository paths touched by the lot.

### 6. Tests and non-regression

Include:

- exact tests/checks run;
- results;
- screenshots or artifacts where applicable;
- what existing behavior was checked;
- anything not tested.

### 7. Specialist review ledger

For every specialist required by `08_SPECIALIST_REVIEW_MATRIX.md`, record:

- reviewer role;
- verdict (`PASS`, `PASS_WITH_NOTES`, `CHANGES_REQUIRED`, `BLOCKED`, `NOT_APPLICABLE`);
- evidence/reference;
- unresolved notes.

No handover may disguise an unresolved `CHANGES_REQUIRED` or `BLOCKED` as success.

### 8. Current risks / blockers

State remaining uncertainty, known defects, missing validation, clinical/regulatory boundaries and any stale external dependency.

### 9. Repository truth at handover

Record and verify at handover time:

- base branch SHA;
- HEAD SHA;
- ahead/behind divergence;
- PR status;
- CI/check status;
- unresolved review threads where applicable.

Do not assume these values remain current in the next window.

### 10. Next lot

State the recommended next lot only if it is already within the approved roadmap/scope.

A handover may recommend but must not silently authorize a scope expansion.

## Mandatory contents of LOT_YY_START_PROMPT.md

The starter prompt must be self-contained and copy-ready for a fresh conversation/window.

It must instruct the next window to:

1. read the previous lot handover first;
2. read the canonical documents relevant to the next lot;
3. verify repository state again instead of trusting stale SHAs;
4. inspect branch, HEAD, base, PR, divergence and CI/checks;
5. restate GOAL → SUCCESS → PROOF before modifying anything;
6. identify mandatory specialist reviewers from `08_SPECIALIST_REVIEW_MATRIX.md`;
7. remain inside the next lot scope;
8. preserve Core IAmina / OCD capsule separation;
9. preserve existing behavior and run non-regression checks;
9a. execute the mandatory severe score and independent/adversarial second score from `10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md`, retain the lower score, and never call the lot VERIFIED if either pass is missing;
10. never merge or deploy without explicit product-owner approval;
11. stop and report if repository reality differs materially from the handover.

## Starter prompt canonical skeleton

```text
HANDOVER — TrueGround OCD / LOT XX → LOT YY

Repository: hraaaaf/trueground
Previous lot handover: docs/ocd/handovers/LOT_XX_HANDOVER.md
Target lot: LOT YY — <title>

Start by reading the handover and the canonical files it references.

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

Then inspect the existing implementation and execute only the approved LOT YY scope.

Mandatory rules:
- READ → PLAN → EXECUTE → SPECIALIST REVIEW → VERIFY;
- use docs/ocd/08_SPECIALIST_REVIEW_MATRIX.md to identify required reviewers;
- no invented files/routes/tables/interfaces;
- no unrequested refactor or feature expansion;
- no OCD-specific logic in generic IAmina Core;
- preserve existing behavior and prove non-regression;
- no merge without explicit product-owner approval;
- no deployment or real-data/production mutation without explicit approval.

At lot end, do not start LOT ZZ in this window.
Create:
- docs/ocd/handovers/LOT_YY_HANDOVER.md
- docs/ocd/handovers/LOT_ZZ_START_PROMPT.md (only if LOT ZZ is already approved)

Finish with:
Résultat
Modifications
Tests
Non-régression
Preuves
Risques
État
Prochaine étape
```

The generated prompt may add lot-specific requirements but must not remove the guardrails above.

## Handover freshness rule

A handover is a snapshot, not an oracle.

The next window must always re-check live repository state before acting.

If the handover says HEAD `abc123` but GitHub now reports another HEAD, the new window must investigate before proceeding.

## Blocked lots

A blocked lot still receives a handover if the window is ending.

The handover must clearly state:

- `État: BLOCKED`;
- exact blocker;
- evidence;
- what must become true before work resumes;
- whether a next lot is allowed in parallel or not.

Do not manufacture a next-lot prompt that bypasses a blocking dependency on the critical path.

## PR and merge rule

A handover does not authorize merge.

A next-window starter prompt does not authorize merge.

A `VERIFIED` lot does not authorize merge.

Only explicit product-owner approval authorizes merge, and the exact current PR/HEAD must be re-checked immediately before that action.

## Deployment rule

No handover, roadmap state, specialist PASS or acceptance gate authorizes deployment.

Production, Vercel, TestFlight, Play Store or any external environment requires separate explicit product-owner approval.

## Lot closeout gate

A lot may be called `CLOSED` for execution purposes only when:

- its acceptance criteria have reached the appropriate state;
- mandatory specialist reviews are recorded;
- tests/non-regression evidence are recorded;
- `LOT_XX_HANDOVER.md` exists;
- the next-window starter prompt exists if a next approved lot is known;
- exact repository state is captured;
- no merge/deploy is implied.

## Principle

**Context should be transferred deliberately, not inherited accidentally.**
