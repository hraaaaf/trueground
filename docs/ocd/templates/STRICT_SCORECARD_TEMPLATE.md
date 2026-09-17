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

## Mandatory domain breakdown

Every applicable domain MUST receive its own severe score. Do not hide a weak domain inside a strong aggregate. Use `N/A` only with a concrete reason.

| Domain | Score /10 | Evidence | Main deduction |
|---|---:|---|---|
| Product / requirements fidelity | `<x.x | N/A>` | `<reference>` | `<deduction>` |
| Functional correctness | `<x.x | N/A>` | `<reference>` | `<deduction>` |
| UX / usability | `<x.x | N/A>` | `<reference>` | `<deduction>` |
| UI craft / visual quality | `<x.x | N/A>` | `<reference>` | `<deduction>` |
| Visual target fidelity | `<x.x | N/A>` | `<target/render comparison>` | `<deduction>` |
| Accessibility | `<x.x | N/A>` | `<reference>` | `<deduction>` |
| Code quality / maintainability | `<x.x | N/A>` | `<reference>` | `<deduction>` |
| Tests / non-regression | `<x.x | N/A>` | `<reference>` | `<deduction>` |
| Security / privacy / data integrity | `<x.x | N/A>` | `<reference>` | `<deduction>` |
| OCD safety / claim discipline | `<x.x | N/A>` | `<reference>` | `<deduction>` |
| Architecture / boundary discipline | `<x.x | N/A>` | `<reference>` | `<deduction>` |
| Scope discipline | `<x.x>` | `<reference>` | `<deduction>` |
| Evidence quality | `<x.x>` | `<reference>` | `<deduction>` |

Lowest applicable domain score: `<x.x/10>`  
Lowest critical-domain score: `<x.x/10>`

## UI / target fidelity sub-scorecard

Required whenever the lot materially changes UI or claims fidelity to a visual target. Otherwise state `N/A` with the reason.

| UI axis | Score /10 | Proof | Main deduction |
|---|---:|---|---|
| Composition / layout | `<x.x>` | `<render>` | `<deduction>` |
| Typography / hierarchy | `<x.x>` | `<render>` | `<deduction>` |
| Palette / contrast | `<x.x>` | `<render>` | `<deduction>` |
| Spacing / density / rhythm | `<x.x>` | `<render>` | `<deduction>` |
| Components / cards / controls | `<x.x>` | `<render>` | `<deduction>` |
| Branding / iconography | `<x.x>` | `<render>` | `<deduction>` |
| Responsive fidelity on required viewports | `<x.x>` | `<renders>` | `<deduction>` |
| Text scaling / accessibility behavior | `<x.x>` | `<test/render>` | `<deduction>` |
| Overall target resemblance | `<x.x>` | `<direct target ↔ render comparison>` | `<deduction>` |

UI fidelity score retained: `<lowest justified composite /10>`

Rules:
- do not score visual fidelity from source code alone;
- inspect the actual rendered output on every required viewport;
- use direct target ↔ render comparison whenever a target exists;
- a material target-defining structural mismatch is a major deduction and cannot be averaged away by polish elsewhere;
- do not call an implementation pixel-perfect without direct proof.

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
4. `<reason>`
5. `<reason>`

## Perfection pass

- Highest-impact in-scope deduction: `<item>`
- Fix performed: `<fix>`
- Tests/evidence rerun: `<reference>`
- Re-score: `<x.x/10>`
- Remaining in-scope improvement: `<item or none>`
- Deferred/out-of-scope deduction: `<item or none>`

## Final lot closeout

Required once per lot after all material-stage scorecards exist.

- LOT_AGGREGATE_SCORE: `<x.x/10>`
- LOT_AUDIT_SCORE: `<x.x/10>`
- FINAL_LOT_SCORE: `<min(x.x, x.x)>`
- Lowest material-stage score: `<x.x/10>`
- Lowest critical-domain score: `<x.x/10>`
- Specialist scores: `<role=x.x, ...>`
- Top five deductions: `<references>`
- Perfection fixes completed: `<references>`
- Remaining delta to 10.0: `<x.x>`
- Independence limitation / cap: `<none | description>`
- `FINAL_LOT_SCORE >= 9.0`: `YES | NO`
- All binary gates green: `YES | NO`
- Required evidence inspected: `YES | NO`
- Eligible for `VERIFIED`: `YES | NO`

## Verdict

`PASS | PASS_WITH_NOTES | CHANGES_REQUIRED | BLOCKED | NOT_APPLICABLE`

## Final status

`NOT STARTED | IN PROGRESS | BLOCKED | READY FOR REVIEW | VERIFIED`
