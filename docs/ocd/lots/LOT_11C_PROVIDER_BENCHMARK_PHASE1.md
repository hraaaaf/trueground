# LOT11-C — Provider Benchmark — Phase 1

Date: 2026-09-26

## GOAL

Prepare a provider-neutral, offline-first benchmark harness without making any external model call.

## SUCCESS

Phase 1 is acceptable only if:
- deterministic OCD routing remains authoritative;
- non-model-eligible turns never reach a provider adapter;
- network adapters fail closed unless **both** the explicit synthetic-eval authorization and the network kill switch are enabled;
- non-synthetic fixtures fail closed;
- response envelopes are strict and reject additional properties;
- generated text still passes through `DeterministicConversationOutputGuard`;
- metrics contain no raw prompt or completion;
- no provider SDK, secret, DB, Core IAmina change, UI change, merge, or deployment is introduced.

## IMPLEMENTATION

Prepared files:
- `tool/lot11c/provider_benchmark.dart`
- `tool/lot11c/lot11c_response.schema.json`
- `test/lot11c_provider_benchmark_test.dart`

The harness deliberately contains **no Groq HTTP client** and no environment-key lookup.

Flow:

```text
synthetic fixture
→ ConversationSafetySession
→ deterministic-only return when !modelEligible
→ provider adapter abstraction
→ strict response-envelope validation
→ language consistency check
→ DeterministicConversationOutputGuard
→ sanitized metrics
```

## FAIL-CLOSED RULES

The runner fails closed when:
- fixture is not synthetic;
- a network adapter is used while the network kill switch is disabled;
- a network adapter is used while authorization is `offlineOnly`;
- provider throws;
- response envelope is malformed;
- response language does not match fixture language;
- deterministic output guard rejects generated text.

## STRICT RESPONSE SCHEMA

The model-facing response contract contains only:
- `schema_version`
- `message`
- `language`
- `mode`

It intentionally contains **no safety verdict**, diagnosis, route selection, crisis decision, reassurance classification, memory authority, or treatment decision. Those remain deterministic/capsule-owned.

## PRIVACY / LOGGING

`BenchmarkMetricRecord.toSanitizedJson()` records only identifiers and aggregate execution metrics:
- fixture id;
- provider/model;
- latency;
- token counts;
- retries;
- malformed flag;
- output-guard rejection flag;
- estimated cost.

Raw user text and generated message are not exported by this metric record.

## PHASE 2 GATE

No real provider call is authorized by this Phase 1 work.

Exact gate remains:

`GROQ GPT-OSS-120B SYNTHETIC EVAL GO`

Only after that human gate may a network adapter be added/executed against synthetic fixtures.
