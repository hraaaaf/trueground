# LOT11-C — Independent Review A — Safety & Architecture

Date: 2026-09-26
Repository: hraaaaf/trueground
PR: #27
Reviewed HEAD: 157f88970b54db5fed93449232c67c2b7997452f

## GOAL
Independently assess whether LOT11-C preserves the deterministic OCD safety architecture and privacy boundaries while adding Groq GPT-OSS-120B benchmark execution.

## EVIDENCE INSPECTED
- PR #27 exact head/base metadata
- compare 643d708234c3067fcd92954f8bed6087528acc1c...157f88970b54db5fed93449232c67c2b7997452f
- provider_benchmark.dart
- lot11c_provider_benchmark_test.dart
- groq_provider_benchmark.py
- groq_synthetic_smoke.py
- strict response schema
- GitHub workflow
- exact-head LOT03→LOT10 + LOT11-C workflow results
- automated 60-call artifact/run evidence

## PASS FINDINGS
- IAmina Core is untouched.
- OCD safety policy remains deterministic and separate.
- Provider-facing schema contains no diagnosis, route, crisis, memory or treatment authority.
- Offline harness enforces synthetic-only + network authorization + kill switch.
- Non-model-eligible deterministic routes do not reach the Dart provider adapter.
- Existing LOT03→LOT10 workflows all pass on the exact reviewed SHA.
- 60-call automated provider run passed current automated thresholds.
- No real user data was used.

## BLOCKERS

### A1 — Real Groq benchmark bypasses the production safety path
The Python full benchmark calls Groq directly for every fixture, including diagnosis, medication, ERP and privacy cases.
It does not invoke the actual Dart ConversationSafetySession before the provider call and does not run the actual DeterministicConversationOutputGuard on returned Groq messages.

This is acceptable as an additional provider stress test, but it cannot be the sole evidence for the architecture defined in LOT11-C.

Required:
- clearly label direct Python benchmark as provider-adversarial stress only;
- add an exact-path integration proof that real model-eligible synthetic inputs pass through the deterministic pre-model gate and the actual output guard.

### A2 — Completion-derived diagnostic text can be logged
When a synthetic safety flag fires, groq_provider_benchmark.py logs normalized_context derived from the model completion.
This conflicts with the frozen rule: no raw prompt/completion logging.

Required:
- remove completion-derived context from CI logs/artifacts;
- retain only fixture id, repetition, metric and rule id.

### A3 — Human review evidence gap
Sanitized artifacts intentionally omit completions. That protects privacy, but also means an independent human reviewer cannot reconstruct whether helpfulness judgments were valid.

Required:
- define an ephemeral synthetic-only review mechanism that allows independent review without persisting raw prompts/completions in CI logs or repository artifacts.

## SCORE
Architecture: 9.2/10
OCD safety boundary: 9.0/10
Privacy/logging: 8.4/10
Fail-closed behavior: 9.3/10
Evidence integrity: 8.4/10

Strict retained score: 8.4/10

## VERDICT
CHANGES_REQUIRED

Automated benchmark PASS is real evidence, but LOT11-C must not be human-certified on this HEAD.
