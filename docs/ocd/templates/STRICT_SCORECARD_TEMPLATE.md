# STRICT SCORECARD TEMPLATE

Use for every material stage and for the final lot audit.

Scoring source of truth: `docs/ocd/10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md`.

## Identity

- Lot: `LOT XX — <title>`
- Stage: `<stage>`
- Commit / PR: `<reference>`
- Planned weight: `<%>`
- Reviewer: `<role / agent / human>`
- Review type: `EXECUTION | ADVERSARIAL | FINAL LOT AUDIT`

## GOAL

<goal>

## SUCCESS

<measurable success criteria>

## PROOF

<direct evidence>

## Dimension scoring

| Dimension | Weight | Score /10 | Evidence | Deductions |
|---|---:|---:|---|---|
| Requirements / target fidelity | 20% | `<x.x>` | `<reference>` | `<deductions>` |
| Correctness / behavior / consistency | 20% | `<x.x>` | `<reference>` | `<deductions>` |
| Evidence / proof strength | 15% | `<x.x>` | `<reference>` | `<deductions>` |
| Non-regression / compatibility | 15% | `<x.x>` | `<reference>` | `<deductions>` |
| Critical risk quality | 15% | `<x.x>` | `<reference>` | `<deductions>` |
| Craft / usability / maintainability | 10% | `<x.x>` | `<reference>` | `<deductions>` |
| Scope discipline | 5% | `<x.x>` | `<reference>` | `<deductions>` |

If a dimension is `N/A`, state the exact reason and normalize remaining weights per the protocol.

## Hard-cap check

- [ ] No required test/check failing
- [ ] No required evidence missing
- [ ] Required UI render inspected where applicable
- [ ] Direct target/render comparison exists where visual fidelity is claimed
- [ ] No mandatory specialist missing
- [ ] No unresolved `CHANGES_REQUIRED`
- [ ] No observed regression
- [ ] No material safety/privacy/security/data-integrity blocker
- [ ] No unsupported medical/clinical claim or unapproved treatment-like behavior

Applicable cap: `<none | x.x>`
Reason: `<reason>`

## Score

- Weighted raw score: `<x.xx/10>`
- Score after hard cap: `<x.x/10>`
- Score rounded downward to one decimal: `<x.x/10>`

For a material stage closeout:

- EXECUTION_SCORE: `<x.x/10>`
- ADVERSARIAL_SCORE: `<x.x/10>`
- FINAL_STAGE_SCORE: `<min(x.x, x.x)>`
- Score delta: `<x.x>`
- Delta >0.5 investigated: `YES | NO | N/A`

## Strongest reasons this is not 10/10

1. `<reason>`
2. `<reason>`
3. `<reason>`

## Perfection pass

- Highest-impact in-scope deduction: `<item>`
- Fix performed: `<fix>`
- Tests/evidence rerun: `<reference>`
- Re-score: `<x.x/10>`
- Remaining in-scope improvement: `<item or none>`
- Deferred/out-of-scope deduction: `<item or none>`

## Verdict

`PASS | PASS_WITH_NOTES | CHANGES_REQUIRED | BLOCKED | NOT_APPLICABLE`

## Final status

`NOT STARTED | IN PROGRESS | BLOCKED | READY FOR REVIEW | VERIFIED`
