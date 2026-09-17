# START PROMPT — TrueGround OCD / LOT YY

Copy this content into a fresh conversation/window.

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
- material stages for this lot;
- planned weight of each material stage;
- mandatory specialist reviewers;
- critical dimensions;
- minimum score thresholds.

Then inspect the existing implementation and execute only the approved LOT YY scope.

Mandatory rules:
- READ → PLAN → EXECUTE → SCORE → SPECIALIST REVIEW → ADVERSARIAL RE-SCORE → PERFECT WITHIN SCOPE → VERIFY;
- score every material stage using docs/ocd/10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md;
- every material stage gets an EXECUTION_SCORE and an ADVERSARIAL_SCORE;
- FINAL_STAGE_SCORE is the lower justified score, never an upward average;
- investigate any score delta >0.5;
- list concrete deductions and evidence;
- perform a perfection pass for stages scoring 8.5–8.9;
- do not mark the lot VERIFIED unless FINAL_LOT_SCORE >=9.0 and all binary gates pass;
- use docs/ocd/08_SPECIALIST_REVIEW_MATRIX.md to identify required reviewers;
- every mandatory specialist returns both a verdict and a severe score /10;
- no invented files/routes/tables/interfaces;
- no unrequested refactor or feature expansion;
- no OCD-specific logic in generic IAmina Core;
- preserve existing behavior and prove non-regression;
- no merge without explicit product-owner approval;
- no deployment or real-data/production mutation without explicit approval.

At lot end, do not start LOT ZZ in this window.
Before handover:
- run the final adversarial severity review;
- state the five strongest reasons the lot is not 10/10;
- identify the weakest proof claim;
- identify the highest-impact remaining in-scope improvement;
- perform the allowed perfection pass;
- re-score after fixes.

Create:
- docs/ocd/handovers/LOT_YY_HANDOVER.md with the mandatory STRICT SCORECARD;
- docs/ocd/handovers/LOT_ZZ_START_PROMPT.md only if LOT ZZ is already approved.

Finish with:
Résultat — include FINAL_LOT_SCORE /10
Modifications
Tests
Non-régression
Preuves
Risques
État — include whether the >=9.0 threshold is met
Prochaine étape
```
