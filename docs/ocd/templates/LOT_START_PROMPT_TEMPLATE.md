# START PROMPT — TrueGround OCD / LOT YY

Copy this content into a fresh conversation/window.

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
- docs/ocd/handovers/LOT_ZZ_START_PROMPT.md only if LOT ZZ is already approved.

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
