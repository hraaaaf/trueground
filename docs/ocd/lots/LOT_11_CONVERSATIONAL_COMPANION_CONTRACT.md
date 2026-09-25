# LOT 11 — BOUNDED CONVERSATIONAL COMPANION CONTRACT

Status: LOT11-A PRE-IMPLEMENTATION CONTRACT
Date: 2026-09-25
Provider/model runtime: NONE
Base handover: `docs/ocd/handovers/LOT_11_START_PROMPT.md`

## GOAL

Define the safety, capability, architecture, privacy and failure contract for a future natural-language companion without turning TrueGround into an unrestricted reassurance, checking, rumination or treatment chatbot.

## SUCCESS

This contract is successful for LOT11-A when:

- every required conversation family has an allowed/prohibited policy;
- deterministic safety decisions remain outside the future model;
- IAmina Core / OCD capsule separation is preserved;
- no provider, SDK, key or runtime prompt is introduced;
- EN + FR semantic safety is required explicitly;
- raw conversation persistence is not introduced;
- crisis/high-risk remains a human-reviewed release dependency;
- eval outcomes and thresholds are defined before any model experiment.

## PROOF — inspected repository truth

Inspected on `feat/fr-localization@09c9f95c4a3f14f7a32719cee513015fe7b0e505` and the LOT10→LOT11 handover branch.

Current runtime truth:

- Flutter runtime is deterministic.
- Runtime dependencies are Flutter, `go_router` and `shared_preferences`.
- No model/provider SDK exists.
- No generic provider adapter exists in this repository.
- No chat screen/composer exists.
- Existing bounded routes include Loop, Practice, Values, Support, Pattern Review and Urgent Support.
- `CompulsionFirewallSession` is deterministic and session-scoped.
- `HighRiskBoundary` is deterministic.
- LOT09 longitudinal memory stores only structured event types and timestamps; no raw chat exists.
- Current `CompulsionFirewallSession` and `HighRiskBoundary` use English lexical markers. They are **not proven multilingual safety routers** for a future EN/FR chat.
- The urgent-support surface exists technically, but the acute-risk/crisis policy remains not clinically/regional-policy validated.
- The existing Practice scientific contract defines the current V1 intended population as adults; LOT11-A does not expand that population.

## Population boundary

LOT11-A inherits the existing adults-only V1 boundary from the approved Practice scientific contract.

It does not authorize conversational behavior targeted to children or adolescents. Any future pediatric/minor scope requires a separate product, clinical, safeguarding, privacy and content decision before runtime support is claimed.

## Governance decision — numbering

**Decision: preserve the canonical roadmap unchanged.**

LOT11 is an implementation-lot label inserted before beta readiness. It does not rename or renumber canonical `GATE 11 — BETA_READINESS_VERIFIED`.

This lot therefore makes **no change** to `docs/ocd/07_ACCEPTANCE_GATES.md`.

Any future roadmap renumbering requires explicit product-owner approval.

## Architecture decision

### Rejected interpretation

Do not implement:

`Chat screen → vendor SDK → model decides what to do`

That would give the model authority over OCD safety, provider failure and routing.

### Approved LOT11 target

```text
Future Chat UI
    ↓
Session Safety Envelope
(language + bounded in-memory turn state; no raw persistence)
    ↓
Deterministic Safety Router — OCD capsule
    ├─ acute-risk / human-gate branch first
    ├─ repeated reassurance / checking / rumination / confession
    ├─ explicit support / practice / values intents
    └─ capability allow/deny decision
    ↓
OCD Conversation Policy — OCD capsule
    ↓
Provider-Agnostic Model Adapter — FUTURE, NOT IMPLEMENTED
    ↓
Model/Provider — FUTURE, NOT SELECTED
    ↓
Deterministic Output Guard — OCD capsule
    ↓
Bounded action/router
    ├─ render bounded text
    ├─ /loop
    ├─ /practice
    ├─ /values
    ├─ /support
    └─ approved urgent path
```

### Why the order matters

Acute-risk routing must be considered before ordinary anti-reassurance logic so that explicit immediate danger is not swallowed as "another OCD loop."

The provider must never decide whether a user should enter or leave the acute-risk path.

The output guard must treat generated text as untrusted even if the input router allowed generation.

## IAmina Core / OCD capsule boundary

### OCD capsule owns

- reassurance/checking/rumination/confession policy;
- OCD-specific repetition state and reason codes;
- intrusive-thought versus intent safeguards;
- OCD crisis integration rules;
- allowed/prohibited conversational behavior;
- OCD output guard rules;
- OCD eval datasets and thresholds;
- EN/FR safety equivalence cases;
- routing into Loop/Practice/Values/Support.

### Generic Core may own later, only after real inspection

A future generic Core could provide domain-neutral primitives such as:

- provider request/response transport;
- timeout/cancellation;
- generic retry plumbing;
- token/usage metadata;
- generic structured response envelope;
- generic observability hooks that never receive sensitive text by default.

No such interface is treated as existing today.

LOT11-A does not change IAmina Core.

## Existing-component reuse boundary

The existing `CompulsionFirewallSession` and `HighRiskBoundary` are useful evidence of deterministic design, but they are not automatically promoted to the LOT11 router.

Reasons:

1. both are primarily English lexical classifiers;
2. LOT11 requires EN + FR and cross-language repetition handling;
3. current firewall was designed for an existing bounded flow, not unrestricted natural-language coverage;
4. high-risk behavior still carries the KF-01 human clinical/regulatory gate.

LOT11-B must either generalize these safely with direct multilingual tests or introduce a new capsule-side composition that reuses only proven primitives. It must not silently assume FR coverage.

## Capability modes

Future policy outcomes are restricted to these conceptual modes:

- `ALLOW_GENERATION` — model may answer a benign request under output guard.
- `BOUNDED_SUPPORT_GENERATION` — at most one supportive, non-certainty response before a deterministic pivot if the same loop continues.
- `DETERMINISTIC_PIVOT` — no fresh model answer; route or bounded deterministic response.
- `HUMAN_GATE` — behavior depends on an approved human-reviewed policy; provider generation must not substitute.
- `FAIL_CLOSED` — provider/policy/memory failure produces truthful degraded behavior, not unrestricted chat.

These are contract labels only. They are not runtime code in LOT11-A.

## Conversational behavior matrix

| Input family | Allowed behavior | Prohibited behavior | Deterministic action | Future model allowed? | Max persistence before pivot | Fallback / rationale |
|---|---|---|---|---|---|---|
| Ordinary informational/helpful request | Answer usefully when no safety family is detected | Fabricated facts, medical personalization outside policy | Allow path | Yes | Normal session bounds | Output guard; benign-control evals |
| Distress/uncertainty without certainty seeking | Acknowledge emotion; offer practical/emotional support; values/human-support option | Settling feared proposition merely to soothe | Support-capable path | Yes, bounded | 2 semantically related support turns before explicit next-step offer | Support ≠ reassurance; Causier & Salkovskis |
| Explicit reassurance request | Brief acknowledgment; decline certainty; offer support/next step | "Yes, definitely safe", guarantees, probability-as-certainty | Mark reassurance family | One bounded support response only | 1 generated response; next related turn pivots | ERS/checking evidence |
| Paraphrased repeated reassurance | Recognize likely returning loop cautiously | New certainty phrased differently | Deterministic pivot to bounded action | No | Pivot on second high-confidence related certainty turn | Prevent reassurance escape |
| Checking request | Clarify only when needed to distinguish ordinary factual help from proxy checking; avoid doing obsessional verification | Rechecking/proving feared proposition repeatedly | Checking policy | At most one bounded support response when high-confidence OCD checking | 1; repeated related request pivots | Checking-proxy risk |
| Repeated checking | Offer bounded next action | Perform "one last check" | Deterministic pivot | No | Second related checking turn | Existing LOT06 principle |
| Rumination/endless analysis | Name possible analysis loop cautiously; redirect to action/uncertainty | Continue causal/moral/probability analysis indefinitely | Rumination policy | One bounded response maximum | Second related analytic continuation pivots | Avoid rumination extension |
| Confession/repetition | Acknowledge without soliciting details; redirect | Moral absolution; ask for "one more detail" | Confession policy | One bounded response maximum | Related reconfession pivots | Avoid confession ritual |
| Retrospective certainty seeking | Support uncertainty and present-focused next step | Decide what a past event "proves" about identity/safety | Certainty policy | One bounded response maximum | Related repeat pivots | Same mechanism as certainty seeking |
| Forced yes/no certainty | Refuse false certainty; offer bounded alternative | Obey "just say yes/no", guarantee, promise | Deterministic certainty policy | No when high-confidence certainty forcing | Immediate pivot | Adversarial anti-bypass |
| Intrusive harm thought without intent | Nonjudgmental support; do not infer intent/diagnosis; ordinary OCD route if no acute marker | "You are dangerous" or "you are definitely safe because it is OCD" | Intrusive-thought boundary | Yes, bounded if otherwise allowed | Normal bounds; repetition rules still apply | Intrusive thought ≠ intent |
| Explicit immediate danger/intention/inability to stay safe | Exit ordinary OCD conversation into approved real-world urgent path | Model risk score, model-only triage, generic reassurance | Acute-risk branch | No | Immediate | KF-01 / human-reviewed policy required |
| Ambiguous safety uncertainty | Treat as separate high-risk policy problem; do not reason it away as OCD | Model decides "probably safe" | HUMAN_GATE until approved policy | No | Immediate | Conservative separation from reassurance |
| Desire for Practice | Route to existing bounded deterministic Practice | Generate personalized autonomous exposure | `/practice` | No required generation | Immediate route | LOT07 contract |
| Values / return-to-life request | Route/support user-chosen ordinary next step | Pick moral values or "perfect" action | `/values` | No required generation | Immediate route | LOT08 values boundary |
| Human support request | Facilitate existing real-world support route | Pretend a call/message was sent | `/support` | No required generation | Immediate route | Existing truthful support contract |
| Personalized diagnosis request | State boundary; suggest appropriate professional assessment route where relevant | Diagnose OCD / differential diagnosis / probability as medical fact | Deterministic claim boundary | No | Immediate | Clinical-safety contract |
| Personalized medication request | General boundary + clinician/pharmacist route as appropriate | Start/stop/change dose, individualized safety assurance | Deterministic claim boundary | No | Immediate | Medication boundary |
| Treatment-efficacy / autonomous ERP request | Keep to approved bounded Practice; no efficacy claim | Prescribe generated ERP/hierarchy or promise symptom change | Deterministic scope boundary | No | Immediate | LOT07 + scientific transfer limit |
| Provider timeout/empty/malformed output | Truthful degraded state; bounded routes stay available | Fabricate a response or silently bypass policy | FAIL_CLOSED | No after failure | No semantic retry loop | Provider failure must be explicit |
| Memory unavailable/stale/malformed | Say memory/history cannot be relied on; continue only on current-turn data where safe | Pretend prior history was checked | Memory-degraded path | Only for current-turn benign content if policy permits | No retries for certainty | LOT09 truthfulness |
| EN↔FR language switching | Preserve safety state and semantic family across language change | Reset loop state because wording/language changed | Language-aware session policy | Per underlying family | Same limits across languages | Anti-bypass requirement |

## Support versus reassurance decision rule

The product must not infer compulsion merely because a user wants comfort.

A request is more compatible with support when the requested outcome is presence, practical help, emotional acknowledgment or help moving toward an ordinary action **without requiring the system to settle the feared proposition**.

A request is more compatible with certainty seeking when the requested outcome is to prove, guarantee, re-check, morally absolve or repeatedly settle the feared proposition.

Ambiguous cases must be tested for false positives. The classifier must not shame the user or state that a compulsion is clinically proven.

## Repetition policy

The turn limits above are **product safety bounds**, not clinically validated doses.

Rules:

- the first high-confidence reassurance/checking/rumination/confession request must not receive certainty;
- one bounded supportive generated turn may be permitted for some first occurrences;
- a second semantically related certainty/checking/rumination continuation must not cause a fresh model attempt to settle the issue;
- once pivoted, 5-turn and 10-turn paraphrases must remain bounded;
- cross-language EN→FR→EN rephrasing must not reset the safety state;
- legitimate correction, accessibility need, ordinary factual follow-up and explicit human-support seeking must remain false-positive controls.

## Acute-risk contract

LOT11-A does NOT validate the current crisis/high-risk policy.

Hard rule:

> Model generation is not an acceptable fallback for unresolved acute-risk policy.

Before any runtime conversational release:

- the supported launch region(s) must be explicit;
- the acute-risk policy and exact escalation copy must receive qualified human clinical/regulatory review;
- EN and FR must each be tested;
- intrusive-thought false positives and explicit-danger false negatives must be adversarially evaluated;
- the system must remain truthful about whether any person/service was contacted.

Until that gate is closed, acute-risk routing is a release blocker for conversational runtime.

## Provider-agnostic interface requirements — future only

LOT11-A defines requirements, not code.

A future model adapter may receive only:

- minimized current user message needed for the approved response;
- minimal bounded prior-turn context required for conversational coherence;
- language code;
- approved policy mode and non-sensitive reason code;
- approved system/policy version identifiers.

It must not receive by default:

- account identifiers unnecessary to generation;
- raw LOT09 longitudinal history;
- analytics profile;
- unrelated prior conversations;
- hidden clinical labels;
- production secrets in prompts;
- data from another IAmina client.

Provider response must be treated as untrusted text until Output Guard approval.

Full raw conversation history is **off by default**. When prior context is truly necessary, prefer the smallest policy-safe summary/state over replaying the transcript; any raw prior turn sent to a provider remains sensitive provider data and must be covered by the selected provider's approved data-flow contract.

The provider must not be able to invoke arbitrary tools or change routes directly in the initial implementation.

## Deterministic Output Guard requirements

Before any generated text is shown, future LOT11 implementation must reject or replace outputs containing material violations such as:

- certainty/guarantee about the feared proposition;
- repeated checking assistance;
- diagnostic assertion;
- personalized medication instruction;
- treatment-efficacy claim;
- autonomous unvalidated exposure/hierarchy;
- inferred harmful intent from intrusive thought alone;
- false claim that a human/emergency service was contacted;
- fabricated memory retrieval;
- crisis/risk assessment that the app cannot perform;
- instruction that professional care is unnecessary.

A guard failure must fail closed to a deterministic bounded fallback. It must never expose the rejected unsafe text and then append a disclaimer.

The Output Guard is **defense in depth, not a semantic safety proof**. A lexical/rule guard cannot be assumed to catch every unsafe paraphrase. The pre-model capability policy must prevent disallowed tasks from reaching the model in the first place, and whole-system adversarial evals remain mandatory even when every deterministic guard passes.

## Privacy / data-flow contract

**NO RAW CHAT PERSISTENCE BY DEFAULT.**

Conversation text is treated as high-sensitivity data.

### LOT11-A

- no provider exists;
- no raw conversation is transmitted;
- no raw conversation is persisted;
- no new analytics event is added;
- no secret is added.

### Future runtime default

- raw chat remains session-transient unless a separate persistence decision is approved;
- no raw sensitive free text in logs, analytics, crash breadcrumbs or CI artifacts;
- logging prefers request ID, policy version, safe reason code, latency/outcome and provider/model version;
- provider context is minimized to the smallest necessary window;
- retry/failure logs must not capture the prompt by convenience;
- provider retention/training/geography/security terms must be reviewed before selection;
- deletion semantics must be truthful; transient data and any provider retention must be documented explicitly.

### LOT09 memory separation

Existing Pattern Memory contains structured event type + timestamp only.

LOT11 must not silently convert it into raw conversation memory.

By default:
- raw chat is not appended to Pattern Memory;
- Pattern Memory is not serialized wholesale into a provider prompt;
- memory-unavailable states do not block benign current-turn assistance, but the system must not claim history-aware reasoning;
- any future derived conversational memory requires a separate data/privacy decision, schema and deletion contract.

## Analytics contract

Disallowed by default:

- message body;
- obsession theme text;
- generated response body;
- confession content;
- crisis text;
- prompt dumps.

Potentially allowed after privacy review:

- feature opened;
- policy outcome code;
- bounded-route destination;
- provider timeout flag;
- language code;
- model/policy version;
- coarse latency bucket.

No analytics metric may reward repeated reassurance turns as engagement success.

## Localization contract

Supported product languages are EN + FR.

Safety equivalence requirements:

- all critical eval families require direct EN and FR evidence;
- cross-language repeats must retain the same session safety state;
- translation alone does not prove classifier equivalence;
- current English lexical firewall/high-risk markers are insufficient evidence for French;
- final safety copy requires FR content review independent of the English pass;
- English fallback may exist for missing interface strings, but a missing FR safety rule may not silently fall back to an untested English-only classifier and be called equivalent.

## No-provider rule

LOT11-A explicitly forbids:

- OpenAI/Anthropic/Gemini/local-model SDKs;
- provider API keys or secrets;
- runtime system prompts;
- model calls in app/tests/CI;
- production user data;
- provider comparison driven by live sensitive prompts.

Provider comparison begins only after this contract, eval dataset and thresholds are frozen and reviewed.

## Out of scope for LOT11-A

- chat UI implementation;
- provider selection;
- prompt engineering against a live model;
- tool use;
- autonomous ERP;
- diagnostic scoring;
- medication guidance;
- crisis protocol validation;
- raw conversation persistence;
- Core extraction/refactor;
- production analytics;
- deployment.

## LOT11-B entry conditions

A future implementation/experiment sub-lot may start only when:

1. LOT11-A scientific baseline is accepted;
2. this contract is accepted;
3. versioned eval cases exist;
4. acceptance thresholds are fixed;
5. architecture/privacy review is complete;
6. specialist review and double score are recorded;
7. the crisis dependency remains explicit and cannot be bypassed by the model;
8. product owner authorizes the next sub-lot.

Passing LOT11-A does not authorize merge, deployment or production AI.
