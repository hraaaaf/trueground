HANDOVER — TrueGround OCD / LOT 08 → LOT 09

Repository: hraaaaf/trueground
Previous lot handover: docs/ocd/handovers/LOT_08_HANDOVER.md
Target lot: LOT 09 — Memory / Pattern Review
Target gate: GATE 9 — MEMORY_PATTERN_REVIEW_VERIFIED

Start by reading, in order:

1. docs/ocd/handovers/LOT_08_HANDOVER.md
2. docs/ocd/07_ACCEPTANCE_GATES.md
3. docs/ocd/08_SPECIALIST_REVIEW_MATRIX.md
4. docs/ocd/10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md
5. canonical privacy/data/safety documents referenced by the repo
6. the existing dashboard/router and any current memory/persistence-related code discovered by inspection

Do NOT assume any SHA, branch state, PR state or CI result from LOT08 is still current.

First verify live repository truth:
- base branch and exact SHA;
- current working branch and exact HEAD;
- PR #17 current state;
- ahead/behind divergence;
- current CI/checks;
- unresolved reviews/comments/threads;
- whether LOT08 was merged after this handover;
- whether any new memory/pattern implementation appeared since the handover.

If repository reality differs materially from the handover, STOP implementation and report the discrepancy first.

Before any modification, state:

GOAL
SUCCESS
PROOF

## LOT09 scope

Build only the approved Memory / Pattern Review scope required by GATE 9.

Mandatory acceptance requirements:
- memory scope is explicit;
- retrieval is user/client scoped;
- pattern review is user-initiated and bounded;
- no default severity grade is presented as clinical fact;
- deletion/edit/retention behavior works exactly as documented;
- the system does not pretend history was checked when memory is unavailable;
- review surfaces must not encourage compulsive checking, rumination, repeated reassurance, self-monitoring pressure or pseudo-diagnostic interpretation;
- no unsupported clinical or predictive claim;
- IAmina Core / OCD capsule separation remains intact.

## Critical inspection rule

Do NOT invent an existing memory system.

Before proposing implementation:
- inspect current persistence dependencies;
- inspect any shared_preferences use from Practice;
- inspect models, repositories, stores, schemas and services;
- inspect router/dashboard entry points;
- inspect tests and CI;
- inspect privacy/data-flow docs;
- inspect whether client/user identity exists at all in this prototype;
- inspect deletion/retention mechanisms actually available;
- identify what can safely be implemented locally without creating an unapproved longitudinal clinical record.

If a major product/data/privacy decision is genuinely ambiguous, present:
OPTION A
OPTION B
RECOMMENDATION
IMPACT
and wait for product-owner validation.

Do not block on minor implementation details that are already determined by existing architecture.

## Safety constraints

LOT09 must be specifically tested against:
- repeated pattern checking;
- reassurance seeking from historical data;
- rumination over past events;
- pseudo-severity scoring;
- compulsive trend inspection;
- “prove I am getting better/worse” loops;
- repeated deletion/recreation/checking;
- false claims that history was retrieved when storage is unavailable;
- cross-user/client leakage if identity/scoping exists.

No medical diagnosis.
No symptom severity claim unless explicitly validated and approved.
No efficacy claim.
No crisis-routing behavior added in this lot unless separately approved.

## Required specialist reviewers

From docs/ocd/08_SPECIALIST_REVIEW_MATRIX.md, LOT09 requires at minimum:
- DATA_PRIVACY_SECURITY_AGENT
- OCD_SAFETY_AGENT
- AI_EVAL_AGENT where AI/memory inference is used
- UI_UX_AGENT
- QA_NON_REGRESSION_AGENT
- ACCESSIBILITY_AGENT if UI changes are material
- CONTENT_COPY_AGENT for user-facing pattern/memory wording

If no AI is used, mark AI_EVAL_AGENT NOT_APPLICABLE with explicit evidence.

## Proof expectations

At minimum:
- focused retrieval/scoping tests;
- deletion/edit/retention tests;
- unavailable/degraded-memory test;
- user-initiated bounded pattern-review tests;
- anti-checking / anti-rumination eval cases;
- full non-regression suite;
- exact-head CI;
- 360 px / 390 px rendered evidence for material UI;
- accessibility/text-scaling proof;
- before/after or approved Target↔Render comparison if significant UI is changed;
- strict Pass A + separated adversarial Pass B;
- retain the lower score under all protocol caps.

Do not call LOT09 VERIFIED if:
- either scoring pass is missing;
- exact-head required CI is stale/red;
- a required specialist verdict is missing;
- any material in-scope weakness from the Perfection Pass remains unfixed;
- retained governed score is below 9.0.

## Mandatory execution rules

READ → PLAN → EXECUTE → SPECIALIST REVIEW → DOUBLE SCORE → VERIFY.

- no invented files/routes/tables/interfaces;
- preserve existing behavior;
- no unrequested refactor;
- no new dependency unless existing architecture cannot satisfy the approved scope and impact is justified first;
- no OCD-specific logic in generic IAmina Core;
- no real production/user data;
- no DB/schema/secret/production mutation without explicit approval;
- no merge without explicit product-owner approval;
- no deployment without explicit product-owner approval.

At lot end, do NOT start LOT10 in this window.

Create:
- docs/ocd/handovers/LOT_09_HANDOVER.md
- docs/ocd/handovers/LOT_10_START_PROMPT.md only if LOT10 is already approved

Finish with:
Résultat
Modifications
Tests
Non-régression
Preuves
Risques
État
Prochaine étape
