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

Define the smallest auditable architecture contract that allows TrueGround/OCD to reuse proven IAmina Core primitives while remaining a **separate client/product** from the diabetes client.

## Mandatory decision

Resolve the architecture choice exposed by LOT 01:

### OPTION A
Separate TrueGround deployment/data plane using shared/versioned IAmina Core code.

### OPTION B
Shared IAmina runtime with a new first-class tenant/client isolation layer.

For each option present:

- architecture impact;
- data/privacy impact;
- Core changes required;
- migration/non-regression risk to diabetes;
- operational complexity;
- scalability implications;
- evidence from current code.

Then present:

RECOMMENDATION
IMPACT

**Do not execute an irreversible architecture change until the product owner explicitly validates the option.**

## If an architecture option is approved within this lot

Document the OCD capsule contract precisely enough to define:

- what remains generic IAmina Core;
- what belongs exclusively to TrueGround/OCD;
- client/tenant/deployment boundary;
- auth/account boundary;
- data/storage boundary;
- memory/conversation boundary;
- AI egress/provider boundary;
- prompt/policy/eval boundary;
- routing/module registration boundary;
- frontend packaging/branding boundary;
- account deletion/export/retention responsibility;
- forbidden dependency direction;
- tests/static checks required to prevent OCD logic leaking into Core.

Do not design the Loop UI, Compulsion Firewall behavior, ERP behavior or database details beyond what is strictly needed to establish the architecture boundary.

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
- no invented files/routes/tables/interfaces;
- inspect current IAmina source before describing existing capabilities;
- no unrequested refactor or feature expansion;
- no OCD-specific logic in generic IAmina Core;
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
