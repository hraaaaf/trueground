# HANDOVER — TrueGround OCD / LOT XX

Date: YYYY-MM-DD
Status: `READY FOR REVIEW | VERIFIED | BLOCKED`

## Identity

- Repository: `hraaaaf/trueground`
- Lot: `LOT XX — <title>`
- Base branch: `<branch>`
- Base SHA: `<sha>`
- Working branch: `<branch>`
- HEAD SHA: `<sha>`
- PR: `#<number> | none`
- PR state: `<draft/open/etc>`
- Merge authorization: `NOT AUTHORIZED` unless explicitly approved
- Deployment authorization: `NOT AUTHORIZED` unless explicitly approved

## GOAL

<what this lot had to achieve>

## SUCCESS

- [ ] <criterion 1>
- [ ] <criterion 2>

## PROOF

- <evidence>

## Strict scorecard

Scoring MUST follow `docs/ocd/10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md`.

### Material-stage ledger

| Stage | Planned weight | Execution score | Adversarial score | Final stage score | Evidence | Main deductions |
|---|---:|---:|---:|---:|---|---|
| `<stage>` | `<%>` | `<x.x/10>` | `<x.x/10>` | `<x.x/10>` | `<reference>` | `<deductions>` |

### Lot score

- LOT_AGGREGATE_SCORE: `<x.x/10>`
- LOT_AUDIT_SCORE: `<x.x/10>`
- FINAL_LOT_SCORE: `<x.x/10>`
- Lowest material-stage score: `<x.x/10>`
- Lowest critical-dimension score: `<x.x/10>`
- Verification threshold `>=9.0`: `MET | NOT MET`

### Top five deductions

1. `<deduction>`
2. `<deduction>`
3. `<deduction>`
4. `<deduction>`
5. `<deduction>`

### Perfection pass

- Fixes completed: `<items>`
- Evidence rerun: `<references>`
- Re-score after fixes: `<x.x/10>`
- Remaining improvement delta to `10.0`: `<delta>`
- Remaining deductions requiring a new decision/lot: `<items or none>`

## What was done

- <completed item>

## What was NOT done

- <deferred / blocked / out-of-scope item>

## Files changed

- `<path>`

## Tests

| Check | Result | Evidence |
|---|---|---|
| `<test/check>` | `PASS/FAIL/NOT RUN` | `<reference>` |

## Non-regression

- <existing behavior checked>
- <anything not checked>

## Specialist review ledger

Every mandatory specialist must return both a verdict and a severe score `/10`.

| Specialist | Verdict | Score /10 | Evidence | Deductions / notes |
|---|---|---:|---|---|
| `<role>` | `PASS/PASS_WITH_NOTES/CHANGES_REQUIRED/BLOCKED/NOT_APPLICABLE` | `<x.x>` | `<reference>` | `<notes>` |

No handover may disguise an unresolved `CHANGES_REQUIRED`, `BLOCKED`, low critical score or missing review as success.

## Final adversarial severity review

Answer before closeout:

1. Five strongest reasons this lot is not `10/10`:
   - `<reason>`
2. Deduction most likely to matter to a real user: `<reason>`
3. Deduction most likely to cause future regression: `<reason>`
4. Weakest proof claim: `<claim>`
5. What an expert reviewer would attack first: `<issue>`
6. Hidden scope creep found: `<yes/no + details>`
7. Risk disguised as non-blocking note: `<yes/no + details>`
8. Best remaining in-scope improvement: `<item>`

## Repository truth at handover

- Base SHA: `<sha>`
- HEAD SHA: `<sha>`
- Ahead/behind: `<x/y>`
- PR state: `<state>`
- CI/checks: `<state>`
- Unresolved review threads: `<count/none>`

These values are a snapshot. The next window MUST verify them again.

## Risks / blockers

- <risk>

## État

`READY FOR REVIEW | VERIFIED | BLOCKED`

A lot cannot be marked `VERIFIED` unless its binary acceptance gates pass and its `FINAL_LOT_SCORE >= 9.0` under the strict protocol.

## Next lot

`LOT YY — <title>`

Or:

`No next lot authorized yet.`

## Required next-window artifact

If LOT YY is approved, create/update:

`docs/ocd/handovers/LOT_YY_START_PROMPT.md`
