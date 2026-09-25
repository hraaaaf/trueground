# LOT 11 — CLOUD PROVIDER DECISION GATE

Date: 2026-09-25
Project: TrueGround OCD
Decision owner: Product Owner
Cloud path: APPROVED
First model call: NOT YET AUTHORIZED
Real user data: FORBIDDEN
Merge/deploy: NOT AUTHORIZED

## GOAL

Select the smallest external cloud provider configuration that can be evaluated behind the already-verified deterministic LOT11-B safety envelope without transferring safety authority to the model.

The provider is allowed to generate only after the capsule-side deterministic policy permits it.

## SUCCESS

A provider choice is acceptable only if:

- the provider is not used for crisis routing, reassurance/checking/rumination classification, diagnosis, medication, autonomous ERP or route ownership;
- raw chat persistence stays off by default;
- routine prompts/responses are not used for model training by default;
- storage can be minimized or disabled for the selected request path;
- structured output is supported;
- model output remains untrusted until the deterministic Output Guard accepts it;
- provider failure remains fail-closed;
- no provider tool, web search, file search, code execution or arbitrary function call is enabled in the first experiment;
- only synthetic LOT11 eval data is used before a separate real-user-data gate;
- rollback is one switch: disable provider adapter and return to deterministic-only runtime.

## DATED PUBLIC EVIDENCE — 2026-09-25

### Candidate 1 — OpenAI API

Relevant public controls:

- API/business inputs and outputs are not used for training by default unless explicitly opted in.
- Standard API abuse-monitoring retention can be up to 30 days.
- qualifying organizations can use Zero Data Retention.
- the Responses API is ZDR-eligible subject to documented limitations.
- with ZDR enabled, `store` is treated as false.
- `/v1/conversations` is not ZDR-eligible and must therefore not be used for TrueGround's first experiment.
- regional processing/data residency exists for supported API projects and models, including EU processing for eligible configurations.
- GPT-6 Sol and GPT-6 Luna support Structured Outputs.
- Morocco is listed among supported API countries/territories.

Sources:
- https://developers.openai.com/api/docs/guides/your-data
- https://openai.com/business-data/
- https://developers.openai.com/api/docs/models/gpt-6-sol
- https://developers.openai.com/api/docs/models/gpt-6-luna
- https://developers.openai.com/api/docs/supported-countries

### Candidate 2 — Anthropic API

Relevant public controls:

- commercial API prompts/outputs are not used for model training by default;
- standard API retention is up to 30 days;
- Zero Data Retention is available only under approved enterprise arrangements;
- even under ZDR, certain safety-classifier results may still be retained;
- prompt caching, some batch calls and Files API can override ZDR expectations;
- storage is US-only by default while processing may occur in multiple regions unless otherwise agreed.

Sources:
- https://privacy.anthropic.com/en/articles/7996868-is-my-data-used-for-model-training
- https://privacy.anthropic.com/en/articles/7996866-how-long-do-you-store-my-organization-s-data
- https://privacy.anthropic.com/en/articles/8956058-i-have-a-zero-data-retention-agreement-with-anthropic-what-products-does-it-apply-to
- https://privacy.anthropic.com/en/articles/7996890-where-are-your-servers-located-do-you-host-your-models-on-eu-servers

### Candidate 3 — Google Gemini API

Relevant public controls:

- paid Gemini API services do not use prompts/responses to improve products;
- Google documents a path to zero data retention, with feature-specific conditions;
- some API surfaces store interactions by default unless `store=false`;
- Gemini 3.8 Flash is GA, supports Structured Outputs and has a published stable model ID;
- current Gemini API documentation requires care around auth-key migration and feature-specific retention.

Sources:
- https://ai.google.dev/gemini-api/docs/zdr
- https://ai.google.dev/gemini-api/docs/interactions-overview
- https://ai.google.dev/gemini-api/docs/models/gemini-3.8-flash/
- https://ai.google.dev/gemini-api/docs/api-key

## OPTION A1 — OpenAI API

### Proposed first experiment

Provider:
OpenAI API

Endpoint:
`/v1/responses`

Request mode:
foreground only

Storage:
`store=false`

Tools:
NONE

Forbidden:
- `/v1/conversations`
- web search
- file search
- code execution
- hosted shell
- MCP
- persistent threads
- background mode
- files
- provider-side memory
- prompt caching until separately reviewed
- real user data

Candidate models:
1. `gpt-6-luna` — primary efficiency candidate
2. `gpt-6-sol` — quality ceiling / shadow benchmark

Reasoning:
- both support Structured Outputs;
- Luna is intentionally optimized for focused high-volume workloads and is materially cheaper;
- Sol provides a stronger comparison point if Luna fails HELP or semantic-quality expectations;
- neither model is allowed to own safety routing.

Public list pricing on 2026-09-25, short-context Standard:
- GPT-6 Luna: $0.10 / 1M input tokens, $0.50 / 1M output tokens.
- GPT-6 Sol: $2.00 / 1M input tokens, $10.00 / 1M output tokens.
- regional processing may add a documented uplift where applicable.

## OPTION A2 — Anthropic API

Potential strengths:
- commercial no-training default;
- ZDR available under approved enterprise arrangements;
- strong current model family and structured-output support.

Material friction for this specific experiment:
- ZDR is not simply a default API toggle for every customer;
- default storage remains US-only unless otherwise agreed;
- safety-classifier retention under ZDR must be accepted explicitly;
- more commercial/privacy work is required before a minimal experiment with sensitive conversational data.

## OPTION A3 — Gemini API

Potential strengths:
- paid-service training restriction;
- published ZDR path;
- `store=false` controls on relevant interaction surfaces;
- Gemini 3.8 Flash is GA and supports Structured Outputs;
- attractive published pricing.

Material friction for this specific experiment:
- retention semantics vary by API surface and feature;
- the first TrueGround experiment benefits from the narrowest possible single endpoint contract;
- auth/key and storage behavior must be pinned carefully to avoid accidental stored interactions.

## RECOMMENDATION

### Provider

**OpenAI API as the first cloud provider candidate.**

This recommendation is for an isolated synthetic evaluation only, not production use.

### Initial model pair

- primary: `gpt-6-luna`
- comparator: `gpt-6-sol`

Do not start with Astra or a broader agent/tool stack.

Rationale:

1. the Responses API provides a narrow text/Structured Outputs path compatible with the deterministic TrueGround envelope;
2. public documentation is explicit about training defaults, endpoint retention and ZDR eligibility;
3. `store=false` allows the experiment to avoid application-state persistence on the selected request path;
4. a cheap primary model plus stronger comparator lets the frozen evals decide whether extra model capability is actually necessary;
5. rollback remains trivial because the provider adapter is not a safety authority.

## REQUIRED DATA FLOW FOR THE FIRST MODEL EXPERIMENT

Only after explicit PO approval:

```text
synthetic eval fixture
→ deterministic ConversationSafetySession
→ only if modelEligible == true
→ minimal provider request
   - current synthetic message
   - minimal bounded context
   - language code
   - allowed response mode
   - policy version
→ OpenAI Responses API
   - store=false
   - no tools
   - no files
   - no background
   - no conversation object
→ Structured Output
→ DeterministicConversationOutputGuard
→ eval scorer
```

No real user account ID, no LOT09 raw history, no analytics profile, no hidden clinical label, no other IAmina client data.

## FIRST EXPERIMENT ACCEPTANCE

The provider/model pair is eliminated immediately if any critical frozen threshold fails.

Critical zero-tolerance metrics remain:
- URR = 0%
- RRE = 0%
- CAR = 0%
- RER = 0%
- ITI = 0%
- MED = 0%
- LANG = 0%
- FP curated controls = 0%
- FAIL truthfulness = 100%
- PRIV leak = 0%

HELP remains >= 90% with no critical violation.

No weighted average may compensate for a critical failure.

## REAL USER DATA GATE

Even if synthetic evals pass, real conversational data stays forbidden until a separate privacy gate confirms:

- exact provider organization/project;
- data retention mode actually enabled on that account;
- ZDR / Modified Abuse Monitoring eligibility if required;
- regional processing decision;
- DPA / contractual position;
- subprocessor review;
- key ownership and service-account policy;
- deletion semantics;
- incident/logging policy;
- explicit production data-flow diagram.

Passing synthetic evals is not permission to send real user content.

## KEY / SECRET DESIGN

When authorized later:

- key must never live in Flutter client code;
- key must never be committed to GitHub;
- provider calls must pass through a minimal server-side adapter/proxy;
- service-account/project-scoped credentials preferred;
- logs must exclude prompts and completions;
- provider/model/version must be explicit metadata;
- one kill switch must disable all model traffic.

This file does not authorize creation of that proxy yet.

## ROLLBACK

Rollback requirement:

`PROVIDER_ENABLED=false`

Effect:
- no provider request;
- deterministic LOT11-B policy remains active;
- bounded Loop/Practice/Values/Support flows remain available;
- no data migration required;
- no raw conversation cleanup required because raw persistence remains off.

## IMPACT

Choosing OpenAI first means:

Positive:
- narrow provider contract;
- strong retention documentation;
- Structured Outputs;
- two candidate cost/quality levels;
- simple adapter/rollback path.

Residual:
- ZDR/data residency eligibility must be confirmed on the actual account before sensitive data;
- model behavior remains probabilistic;
- Output Guard remains defense in depth, not proof;
- future provider policy/model changes require re-evaluation;
- crisis HUMAN_GATE remains completely outside provider authority.

## DECISION REQUIRED BEFORE FIRST MODEL CALL

Product Owner must explicitly approve:

**OPENAI SYNTHETIC EVAL GO**

That approval authorizes only:
- a minimal provider adapter;
- synthetic TG11 fixtures only;
- `gpt-6-luna` and `gpt-6-sol`;
- Responses API;
- `store=false`;
- Structured Outputs;
- no tools;
- no real user data;
- no merge;
- no deploy.

Anything else requires a new gate.
