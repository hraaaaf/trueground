# HANDOVER START PROMPT — TrueGround OCD / LOT 02

Copy the text below into a **fresh conversation/window** to begin LOT 02.

---

HANDOVER — TrueGround OCD / LOT 01 → LOT 02

Repository: `hraaaaf/trueground`

Previous lot handover:
`docs/ocd/handovers/LOT_01_HANDOVER.md`

Previous lot inspection:
`docs/ocd/lots/LOT_01_IAMINA_CORE_INSPECTION.md`

Previous specialist review:
`docs/ocd/reviews/LOT_01_SPECIALIST_REVIEW.md`

Product-owner architecture decision recorded after LOT 01 closeout:

> **OPTION A APPROVED** — TrueGround must use a **separate deployment/data plane** from the diabetes client while reusing shared/versioned IAmina Core code where justified by inspected evidence.

This decision is a starting constraint for LOT 02. It does **not** authorize any merge, deployment, production mutation or IAmina Core change.

Target lot:
**LOT 02 — TrueGround client isolation + OCD capsule contract**

Start by reading, in order:

1. `docs/ocd/handovers/LOT_01_HANDOVER.md`
2. `docs/ocd/lots/LOT_01_IAMINA_CORE_INSPECTION.md`
3. `docs/ocd/reviews/LOT_01_SPECIALIST_REVIEW.md`
4. `docs/ocd/00_README.md`
5. `docs/ocd/04_IAMINA_CAPSULE_ARCHITECTURE.md`
6. `docs/ocd/05_DATA_PRIVACY_SECURITY.md`
7. `docs/ocd/06_ROADMAP_TO_TARGET.md`
8. `docs/ocd/07_ACCEPTANCE_GATES.md`
9. `docs/ocd/08_SPECIALIST_REVIEW_MATRIX.md`
10. `docs/ocd/09_LOT_WINDOW_HANDOVER_PROTOCOL.md`

Also inspect the live source of `hraaaaf/IAMINA-MVP` again. Do not rely on the previous lot's IAmina SHA if `main` moved.

Do NOT assume any SHA, branch state, PR state or CI result in the handover is still current.

Verify first:

- `hraaaaf/trueground` default branch + SHA;
- canonical-foundation branch + HEAD;
- LOT 01 branch + HEAD;
- open PRs and exact state;
- ahead/behind divergence;
- CI/check status;
- unresolved review comments/threads if applicable;
- current `hraaaaf/IAMINA-MVP main` HEAD.

Before any modification, state:

GOAL
SUCCESS
PROOF

## GOAL

Define the smallest auditable architecture contract that allows TrueGround/OCD to reuse proven IAmina Core primitives while remaining a **separate client/product** from the diabetes client, under the approved Option A boundary.

## Approved architecture direction

### OPTION A — APPROVED

Separate TrueGround deployment/data plane using shared/versioned IAmina Core code.

LOT 02 must turn that decision into an explicit contract covering:

- which IAmina Core primitives are actually reused;
- how shared Core code is versioned/consumed without creating runtime or data coupling;
- which infrastructure is duplicated per client for isolation;
- what must remain physically/logically separate between TrueGround and Diabetes;
- how future Core changes avoid breaking either client.

### OPTION B — NOT SELECTED

Do not introduce a shared multi-tenant IAmina runtime as part of LOT 02.

If evidence discovered during inspection shows that Option A is materially unsafe or infeasible, stop and report the contradiction instead of silently switching to Option B.

## Required architecture contract

Document the OCD capsule contract precisely enough to define:

- what remains generic IAmina Core;
- what belongs exclusively to TrueGround/OCD;
- deployment boundary;
- auth/account boundary;
- data/storage boundary;
- memory/conversation boundary;
- AI egress/provider boundary;
- prompt/policy/eval boundary;
- routing/module registration boundary;
- frontend packaging/branding boundary;
- account deletion/export/retention responsibility;
- forbidden dependency direction;
- versioning/update strategy for shared Core code;
- tests/static checks required to prevent OCD logic leaking into Core;
- tests/static checks required to prevent cross-client data or configuration coupling.

Do not design the Loop UI, Compulsion Firewall behavior, ERP behavior or detailed database schema beyond what is strictly needed to establish the architecture boundary.

## Mandatory specialist review

From `08_SPECIALIST_REVIEW_MATRIX.md`, run at minimum:

- `ARCHITECTURE_AGENT`
- `DATA_PRIVACY_SECURITY_AGENT`
- `OCD_SAFETY_AGENT` for any boundary that could change OCD safety ownership
- `QA_NON_REGRESSION_AGENT` if existing IAmina code is modified

If the available environment cannot actually invoke an independent sub-agent, do not invent one. Record the limitation and perform an explicit separate adversarial review pass, then leave final verification to the appropriate review gate.

## Mandatory rules

- `READ → PLAN → EXECUTE → SPECIALIST REVIEW → VERIFY`
- one window = LOT 02 only;
- Option A is the approved architecture direction;
- no invented files/routes/tables/interfaces;
- inspect current IAmina source before describing existing capabilities;
- no unrequested refactor or feature expansion;
- no OCD-specific logic in generic IAmina Core;
- no shared production DB, runtime memory, secrets or user data between Diabetes and TrueGround unless separately and explicitly approved in the future;
- preserve diabetes behavior and prove non-regression if IAmina code is touched;
- no merge without explicit product-owner approval;
- no deployment, Vercel action, TestFlight, Play Store, production migration or real-data mutation without explicit approval.

At lot end, do **not** start LOT 03 in the same window.

Create:

- `docs/ocd/handovers/LOT_02_HANDOVER.md`
- `docs/ocd/handovers/LOT_03_START_PROMPT.md` only if LOT 03 scope is already approved

Finish with:

Résultat
Modifications
Tests
Non-régression
Preuves
Risques
État
Prochaine étape

---
