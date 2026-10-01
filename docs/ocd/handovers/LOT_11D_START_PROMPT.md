# START PROMPT — TrueGround OCD / LOT11-D

Repository: `hraaaaf/trueground`

Previous closeout:
`docs/ocd/handovers/LOT_11C_HANDOVER.md`

Target:
**LOT11-D — Bounded Conversational Runtime**

IMPORTANT:
This prompt authorizes implementation and verification of LOT11-D only.
It does NOT authorize merge, deployment, production data mutation, real-user provider traffic, IAmina Core contamination, autonomous ERP, diagnosis, medication guidance, or crisis-routing delegation to the model.

## READ FIRST

1. `docs/ocd/handovers/LOT_11C_HANDOVER.md`
2. `docs/ocd/reviews/LOT_11C_EVAL_RUBRIC_V4.md`
3. `docs/ocd/reviews/LOT_11C_THRESHOLD_PROOF_MATRIX_V4.md`
4. `docs/ocd/reviews/LOT_11C_REVIEW_A_SAFETY_ARCHITECTURE.md`
5. `docs/ocd/reviews/LOT_11C_REVIEW_B_EVAL_INTEGRITY.md`
6. current `ConversationSafetySession`
7. current `DeterministicConversationOutputGuard`
8. current provider-neutral LOT11-C harness and schema
9. current routing, Loop, Practice, Values, Support, Urgent and Memory code/tests
10. current runtime dependencies and secrets handling

Do not assume repository state from this prompt.
Re-inspect exact HEAD, branch, PR state, CI, dependency graph, provider abstractions and current runtime path before modification.

## GOAL

Implement the smallest bounded conversational runtime that wires an eligible synthetic/user turn through:

`ConversationSafetySession → bounded provider adapter → strict response schema → DeterministicConversationOutputGuard → bounded conversation outcome`

while keeping deterministic OCD safety authority outside the model.

## SUCCESS

LOT11-D is successful only if all of the following are proven:

1. only model-eligible deterministic outcomes can invoke the provider;
2. reassurance/checking/rumination/confession/high-risk/diagnosis/medication/autonomous-ERP/privacy-boundary routes cannot be delegated to the provider when the deterministic policy says no;
3. the real runtime uses the same strict response contract qualified in LOT11-C;
4. returned provider text passes the actual `DeterministicConversationOutputGuard` before display/use;
5. provider/network/schema/timeout failure is fail-closed and truthful;
6. no raw prompt/completion logging is introduced;
7. no provider secret is embedded in Flutter/client code;
8. EN + FR behavior remains bounded;
9. exact-path integration tests exist for allow-generation and deterministic bypass routes;
10. adversarial tests cover reassurance seeking, repeated checking, rumination, repeated confession, intrusive-thought intent inference, medication, diagnosis, ERP, privacy/memory fabrication and provider failure;
11. existing LOT03→LOT10 behavior remains green;
12. no UI redesign or unrelated feature is added.

## REQUIRED PROOF

At minimum create automated evidence for:

- model-eligible request reaches provider adapter exactly once;
- non-model-eligible request reaches provider adapter zero times;
- provider response is rejected when the production output guard rejects it;
- provider failure produces deterministic fail-closed outcome;
- malformed schema produces deterministic fail-closed outcome;
- wrong-language provider response produces deterministic fail-closed or bounded correction according to the existing contract;
- no provider invocation occurs for urgent/human-gate paths;
- no runtime path gives the model authority over route selection.

Use synthetic fixtures only until a later human gate explicitly authorizes real-user traffic.

## LOT11-C RESIDUAL EVIDENCE TO CARRY

The Product Owner accepted two residual evidence gaps to progress:

1. LOT11-C did not prove one single live production-path chain through `ConversationSafetySession → provider → output guard`.
   LOT11-D should close this gap with exact-path integration proof.

2. An ephemeral independent human review mechanism for synthetic completions is still absent.
   Do not claim this is resolved unless it is actually implemented and reviewed. It may remain for later review hardening if outside LOT11-D runtime scope.

## NON-GOALS

- no conversational UI redesign (LOT11-E);
- no broad adversarial expansion beyond runtime proof (LOT11-F);
- no clinical/human certification (LOT11-G);
- no closed alpha (LOT11-H);
- no personalization/pattern intelligence (LOT12);
- no production deployment;
- no real patient/user data;
- no new architecture outside the minimum provider runtime boundary.

## EXECUTION RULE

READ → PLAN → EXECUTE → VERIFY.

Before an important implementation change:
GOAL → SUCCESS → PROOF.

Prefer the smallest auditable patch.
Do not merge without explicit Product Owner approval.
Do not deploy without explicit Product Owner approval.

## EXIT

When LOT11-D evidence is complete, produce:
- exact changed files;
- exact tests and results;
- exact-head non-regression;
- architecture proof;
- remaining risks;
- independent strict review;
- handover to LOT11-E only after a new human gate.
