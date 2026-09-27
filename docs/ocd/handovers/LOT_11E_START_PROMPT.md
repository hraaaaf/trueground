# START PROMPT — TrueGround OCD / LOT11-E

Repository: `hraaaaf/trueground`

Previous closeout:
`docs/ocd/handovers/LOT_11D_HANDOVER.md`

Target:
**LOT11-E — Conversation UX**

IMPORTANT:
This prompt authorizes implementation and verification of LOT11-E only.

It does NOT authorize:
- merge;
- deployment;
- production/provider traffic;
- real-user conversation data;
- a concrete Groq transport in Flutter;
- provider secrets in client code;
- changing deterministic OCD safety authority;
- IAmina Core contamination;
- autonomous ERP;
- diagnosis;
- medication guidance;
- crisis-routing delegation;
- LOT11-F adversarial expansion;
- LOT11-G human/clinical certification.

## READ FIRST

1. `docs/ocd/handovers/LOT_11D_HANDOVER.md`
2. `docs/ocd/reviews/LOT_11D_REVIEW_A_V2_SAFETY_ARCHITECTURE.md`
3. `docs/ocd/reviews/LOT_11D_REVIEW_B_V2_EVIDENCE_INTEGRITY.md`
4. `docs/ocd/handovers/LOT_11D_START_PROMPT.md`
5. current `ConversationSafetySession`
6. current `BoundedConversationRuntime`
7. current `DeterministicConversationOutputGuard`
8. current Loop, Practice, Values, Support, Urgent and Memory routes
9. current EN/FR localization resources
10. current app shell, navigation and accessibility patterns

Do not assume repository state from this prompt.

Re-inspect:
- exact branch and HEAD;
- PR #28 state;
- exact-head CI;
- current app routes/screens/components;
- current conversation-related UI, if any;
- localization keys;
- existing design tokens;
- responsive behavior;
- accessibility semantics;
- current provider/runtime wiring.

## GOAL

Expose the already-bounded LOT11-D conversational runtime through the smallest safe and understandable user experience.

Target interaction principle:

`Conversation UI → deterministic safety/runtime boundary → bounded response OR deterministic route/fallback`

The UI must never become a bypass around LOT11-D.

## SUCCESS

LOT11-E succeeds only if all of the following are proven:

1. the user can enter a conversational request through a clear bounded companion surface;
2. model-eligible output can be displayed only when LOT11-D returns `generated`;
3. `deterministicOnly` outcomes route/display only deterministic approved behavior;
4. `failClosed` never displays rejected provider text;
5. urgent/human-gate behavior remains deterministic and visually distinct;
6. reassurance/checking/rumination/confession pivots cannot be bypassed through UI retry mechanics;
7. repeated submit/retry does not silently create a compulsion loop;
8. EN + FR copy is explicit, bounded and semantically aligned;
9. loading, disabled, timeout/failure and retry states are truthful;
10. no raw provider/debug payload is visible;
11. no raw conversation text is added to analytics/logs;
12. accessibility semantics, focus, keyboard behavior and readable states are verified;
13. responsive behavior is verified on the project target sizes;
14. existing LOT03→LOT10 behavior remains green;
15. LOT11-D runtime tests remain green;
16. no live provider transport, secret or production data is required for UI verification;
17. significant UI changes include before/after validation captures.

## UX SAFETY RULES

The UI must not:

- display a rejected provider response, even transiently;
- automatically retry provider generation after fail-closed;
- offer repeated “check again”, “are you sure”, “regenerate until satisfied” mechanics;
- present a model response as diagnosis, clinical judgment or safety assessment;
- imply that a human, therapist or emergency service was contacted when none was;
- allow raw system/provider payload inspection through normal product UI;
- persist raw chat history unless explicitly approved in a later data decision;
- use engagement patterns that reward repeated reassurance seeking.

Prefer:

- one bounded response;
- deterministic route transition when policy requires it;
- truthful failure copy;
- one clear next action;
- existing Loop / Practice / Values / Support destinations;
- explicit uncertainty-tolerant language;
- minimal conversation persistence.

## REQUIRED STATES TO INSPECT / IMPLEMENT

At minimum verify the need for and behavior of:

- idle / empty state;
- text entry;
- submit;
- provider-eligible loading state;
- generated bounded response;
- deterministic pivot to Loop;
- deterministic Practice route;
- deterministic Values route;
- deterministic Support route;
- urgent/human-gate state;
- claim boundary;
- privacy boundary;
- memory-truthful state;
- timeout/provider-failure state;
- malformed/wrong-language fail-closed state;
- EN/FR locale switch behavior.

Do not invent new routes if existing approved routes already satisfy the outcome.

## RETRY / REPETITION RULE

Any retry interaction is safety-sensitive.

Before implementing retry/regenerate:
- inspect current session state behavior;
- prove the retry does not reset `ConversationSafetySession`;
- prove repeated reassurance/checking/rumination/confession still pivots;
- prove a provider failure retry cannot expose rejected output;
- avoid an unlimited regenerate loop.

If safe retry semantics are ambiguous, present options and wait for Product Owner approval.

## DATA / PRIVACY

Default for LOT11-E:
- no raw chat persistence;
- no analytics payload containing user free text;
- no provider secret in client;
- no production conversation traffic;
- synthetic/fake adapter only for deterministic UI verification unless separately authorized.

Do not change LOT09 Pattern Memory semantics in this sub-lot.

## VISUAL / ACCESSIBILITY PROOF

For any significant conversational UI introduced or modified:

- capture BEFORE baseline where applicable;
- capture AFTER states;
- verify target widths at minimum: 360, 390, 768, 1280;
- verify loading, success, deterministic pivot and fail-closed states;
- verify EN and FR;
- verify keyboard/focus and semantics;
- preserve existing visual language unless a design change is explicitly approved.

## REQUIRED TESTS

At minimum include automated evidence that:

- submit dispatches through the bounded runtime;
- generated result displays only approved response text;
- deterministic result does not display provider text;
- fail-closed result displays no rejected provider text;
- timeout displays truthful fallback;
- urgent result uses deterministic support/human-gate UI;
- repeated reassurance/checking path preserves session state;
- locale EN/FR remains semantically aligned;
- no raw free text is sent to logging/analytics;
- existing navigation and accessibility tests remain green.

## CARRIED RESIDUALS

Do not silently resolve or erase these:

1. no real server-side Groq transport chain exists in this repository;
2. no ephemeral independent human review of raw synthetic completions exists;
3. broader post-model paraphrase/adversarial expansion remains LOT11-F;
4. human/clinical safety certification remains LOT11-G.

## NON-GOALS

- no server-side provider bridge;
- no live Groq traffic;
- no production secrets;
- no broad safety-classifier refactor;
- no LOT11-F adversarial corpus expansion;
- no LOT11-G human/clinical review;
- no LOT11-H closed alpha;
- no LOT12 personalization;
- no new memory architecture;
- no autonomous ERP;
- no diagnosis/medication behavior.

## EXECUTION

READ → PLAN → EXECUTE → VERIFY.

Before significant UI modification:
GOAL → SUCCESS → PROOF.

Keep the patch small and auditable.

Do not merge without explicit Product Owner approval.
Do not deploy without explicit Product Owner approval.

## EXIT

When LOT11-E evidence is complete, produce:

- exact changed files;
- exact UI states implemented;
- before/after captures;
- EN/FR evidence;
- accessibility evidence;
- exact tests/results;
- exact-head non-regression;
- safety regression proof;
- remaining risks;
- independent strict review;
- handover to LOT11-F only after a new Human Gate.
