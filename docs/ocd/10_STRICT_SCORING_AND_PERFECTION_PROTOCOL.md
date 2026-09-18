# 10 — STRICT SCORING AND PERFECTION PROTOCOL

Status: CANONICAL PROJECT GOVERNANCE
Date: 2026-09-18

## GOAL

Prevent a lot from being declared `VERIFIED` or execution-`CLOSED` on implementation evidence alone.

This protocol is mandatory for every material TrueGround lot. It applies even when a lot-specific prompt, older handover or base branch does not mention it.

## Non-negotiable closeout rule

A material lot may not be declared `VERIFIED` or execution-`CLOSED` until all of the following exist:

1. a first severe multi-axis score;
2. a second independent/adversarial score performed as a separate review pass whose explicit job is to find reasons the first score is too generous;
3. the final reported score is the LOWER of the two overall scores;
4. at least five concrete reasons preventing 10/10 are documented;
5. every material weakness discovered by either scoring pass is fixed and retested, or recorded as an explicit blocker/risk with a justified verdict;
6. the exact evidence, both scores and the retained lower score are recorded in the lot handover;
7. exact-head CI and non-regression evidence remain green after any scoring-driven change.

If any item above is missing, the maximum allowed state is:

`VERIFICATION INCOMPLETE`

Never `VERIFIED`.

## Scoring independence

The second score must not merely copy, average, endorse or paraphrase the first.

It must:

- inspect the same exact candidate independently;
- actively search for hidden regressions, weak evidence, unsafe assumptions and reasons to deduct points;
- state its own axis scores before comparing with the first score;
- identify disagreements with the first review;
- keep the lower score even when the first reviewer believes the second is too harsh.

If a genuinely separate reviewer/agent capability is unavailable, perform a clearly separated adversarial second pass with a fresh rubric and label that limitation. Do not falsely claim reviewer independence.

## Required axes

Score each applicable axis from 0.0 to 10.0:

- PRODUCT / SCOPE FIDELITY
- FUNCTIONAL CORRECTNESS
- UI / UX FIDELITY
- ACCESSIBILITY
- SAFETY / OCD ANTI-COMPULSION
- CONTENT / CLAIM DISCIPLINE
- ARCHITECTURE / CORE-CAPSULE SEPARATION
- DATA / PRIVACY / SECURITY
- QA / NON-REGRESSION
- EVIDENCE / REPRODUCIBILITY

Mark an axis `NOT_APPLICABLE` only with an explicit reason.

A mean may be displayed for diagnostic context, but it can NEVER be the retained certification score.

The retained score is:

`RETAINED_SCORE = min(EXECUTION_SCORE, ADVERSARIAL_SCORE, all applicable caps, every critical-dimension score)`

For a lot containing multiple material steps:

`LOT_SCORE = min(all retained material-step scores)`

Never average material steps. Never let strong dimensions compensate for a weak critical dimension.

Critical dimensions include, whenever applicable:
- safety / clinical / scientific claims;
- security / privacy / tenant isolation;
- data integrity / migrations / restore;
- architecture boundary violations;
- release / rollback / reproducibility;
- required UI geometry / accessibility / interaction behavior;
- any dimension explicitly designated critical by the project.

Do not inflate the score because a limitation is out of scope. Score the authorized deliverable as delivered, while separately recording production-readiness limitations.

## Severity anchors and hard caps

- `10.0/10` is exceptional and requires complete evidence, every applicable binary gate green, no known realistically improvable in-scope weakness, AND a genuinely independent reviewer that did not author the implementation.
- Any retained score `>= 9.5/10` requires a genuinely independent adversarial review of the final diff/runtime/evidence. A second pass by the same agent/session is not independent.
- If the same person/model/session performs execution and adversarial review, automatic cap: `9.4/10`.
- Required test red, required gate not green, or required proof absent/stale: cap `7.9/10`.
- Demonstrated regression: cap `6.9/10` until remediation and fresh non-regression proof.
- Blocking safety, privacy, security, data-integrity, or clinical/scientific-claim issue: cap `5.9/10` AND status `BLOCKED`.
- Significant UI/UX work without real Target ↔ Render comparison at required identical viewports/states: visual-fidelity dimension cap `7.5/10`.
- Any unresolved score divergence `> 0.5` between the two primary passes blocks closeout until investigated and rescored.
- Any material in-scope weakness found during the final Perfection Pass must be corrected before `VERIFIED`.

Caps stack; the lowest applicable cap wins.

A score is evidence-backed criticism, not a reward for effort.

## Mandatory Perfection Pass

Before any lot can be `VERIFIED`, perform a final Perfection Pass after all ordinary implementation/review work:

1. list every remaining weakness, uncertainty and rough edge;
2. separate genuinely out-of-scope/external limits from realistically improvable in-scope issues;
3. fix every materially improvable in-scope issue;
4. rerun every affected test/evidence item on the new exact HEAD;
5. rerun BOTH scoring passes;
6. retain the new lower result under all caps and critical-dimension floors.

A Perfection Pass that identifies an improvable material weakness and leaves it unfixed prohibits `VERIFIED`.

## Mandatory five reasons preventing 10/10

Each scoring pass must state at least five candidate-specific deductions or residual uncertainties.

They must be concrete. Examples include:

- missing real-device accessibility validation;
- incomplete visual state coverage;
- placeholder destination behind an otherwise valid CTA;
- unresolved privacy gate;
- missing production crisis policy;
- weak failure-state evidence;
- copy not clinically reviewed.

Do not invent defects merely to fill five entries. If fewer than five genuine deductions exist, list remaining evidence uncertainties that prevent proving perfection.

## Material finding rule

If either scoring pass discovers a material issue:

1. mark the affected axis;
2. determine whether it is in current lot scope;
3. if in scope, fix narrowly;
4. rerun focused tests immediately;
5. rerun required non-regression and exact-head CI;
6. refresh screenshots/evidence if UI changed;
7. rerun BOTH scores on the new candidate.

A pre-fix score cannot certify a post-fix candidate.

## Handover record

Every `LOT_XX_HANDOVER.md` must include:

- scorer/pass A identifier;
- score A and axis table;
- scorer/pass B identifier;
- score B and axis table;
- explicit independence/adversarial method;
- retained score = `min(score A, score B)`;
- at least five reasons preventing 10/10 from each pass;
- material findings and their disposition;
- exact candidate SHA scored;
- evidence references;
- whether scoring caused code/copy/UI changes and therefore required reruns.

## Gate interaction

This protocol is additive to:

- `07_ACCEPTANCE_GATES.md`;
- `08_SPECIALIST_REVIEW_MATRIX.md`;
- `09_LOT_WINDOW_HANDOVER_PROTOCOL.md`.

Green CI, specialist PASS, screenshots or a completed handover do not bypass double scoring.

If those documents conflict with this protocol on whether double scoring is required for material lot closeout, this protocol governs until the product owner explicitly changes the rule.

## Merge and deployment

Double scoring does not authorize merge.

Double scoring does not authorize deployment.

Only explicit product-owner approval authorizes those irreversible/external actions after current repository truth is rechecked.

## Principle

**One implementation. Two critical scoring passes. Keep the lower score. Prove why it deserves even that.**
