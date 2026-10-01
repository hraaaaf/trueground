# LOT11-D — Independent Review A V2 — Safety & Architecture

Date: 2026-09-27
Repository: `hraaaaf/trueground`
PR: #28
Reviewed HEAD: `3d67930a204cfe1dc9bfee75e318866a1d0a1e2f`
Base: `50d6acd4e406ed6dabe04c0713eb1643df011494`

## GOAL

Re-review LOT11-D after the first adversarial review found A1/A2/A3 blockers.

Target path:

`ConversationSafetySession → provider adapter → strict response contract → DeterministicConversationOutputGuard → bounded runtime result`

## EVIDENCE

- exact PR diff at reviewed HEAD;
- `conversation_runtime.dart`;
- `conversation_output_guard.dart`;
- `lot11d_conversation_runtime_test.dart`;
- LOT11-C response schema;
- dependency graph in `pubspec.yaml`;
- exact-head GitHub Actions LOT03→LOT10;
- full Flutter suite: 244 tests PASS;
- source search under `lib/` for provider secrets, network URLs and logging.

## PREVIOUS BLOCKERS

### A1 — Post-model OCD safety families

CLOSED.

The production output guard now has deterministic violations for:
- reassurance reinforcement;
- checking reinforcement;
- rumination reinforcement;
- reconfession solicitation;
- intrusive-thought intent inference.

Exact-path adversarial tests that previously failed now pass.

EN and FR coverage exists, together with bounded safe controls to reduce obvious false-positive regressions.

### A2 — Runtime provider timeout

CLOSED.

`BoundedConversationRuntime` owns a provider timeout at the runtime boundary.

Default:
`15 seconds`.

The timeout is injectable for deterministic testing and returns the existing `providerFailure / failClosed` behavior.

The prior stalled-provider adversarial test now passes without an external timeout wrapper.

### A3 — Rejected provider text exposed downstream

CLOSED.

A rejected provider response is no longer populated into `ConversationRuntimeResult.response`.

Only the fail-closed decision and output-guard violation metadata remain available.

Tests prove rejected certainty and fabricated-memory text are not exposed.

## ARCHITECTURE / PRIVACY

PASS.

- IAmina Core is untouched.
- No provider SDK, HTTP dependency or networking dependency was added.
- No Groq/API key/Authorization token is present under `lib/`.
- No runtime `print` or `debugPrint` logging was introduced.
- No provider URL is embedded in the Flutter client.
- Deterministic pre-model safety remains authoritative.
- Provider payload cannot select an application route.
- No UI change was introduced.

## REMAINING NOTE

The output guard is intentionally deterministic and lexical. It is not exhaustive against arbitrary paraphrase space.

Broader adversarial paraphrase expansion belongs to LOT11-F and must not be silently claimed as complete in LOT11-D.

This is not treated as an LOT11-D blocker because representative exact-path families, EN/FR cases and bounded false-positive controls are now proven.

## SCORE

- Architecture separation: 9.8/10
- Pre-model deterministic authority: 9.7/10
- Post-model bounded safety: 9.5/10
- Fail-closed behavior: 9.7/10
- Privacy / secret handling: 9.8/10
- Runtime encapsulation: 9.6/10

Strict retained score: **9.5/10**

## VERDICT

**PASS**

The previous A1/A2/A3 blockers are closed on the reviewed HEAD.
