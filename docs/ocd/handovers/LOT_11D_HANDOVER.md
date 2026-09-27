# LOT11-D — Closeout / Human Gate

Date: 2026-09-27
Repository: `hraaaaf/trueground`
PR: #28

Certified code evidence HEAD:
`3d67930a204cfe1dc9bfee75e318866a1d0a1e2f`

Independent re-review commit:
`59c3e2b1534003184c8066149d5003cc5059af58`

Target:
**LOT11-D — Bounded Conversational Runtime**

## GOAL

Implement the smallest provider-neutral bounded conversational runtime:

`ConversationSafetySession → provider adapter → strict response contract → DeterministicConversationOutputGuard → bounded runtime result`

while preserving deterministic OCD safety authority outside the model.

## SUCCESS EVIDENCE

Exact product-runtime behavior now proves:

- only model-eligible deterministic outcomes invoke the provider adapter;
- urgent, diagnosis, medication, autonomous ERP, privacy and memory-boundary routes remain deterministic;
- repeated reassurance, checking, rumination and confession pivot deterministically;
- provider output is schema-validated before use;
- wrong-language and malformed payloads fail closed;
- provider exception fails closed;
- stalled provider timeout fails closed at the runtime boundary;
- rejected provider content is not exposed in `ConversationRuntimeResult.response`;
- post-model guard rejects reassurance reinforcement, checking reinforcement, rumination reinforcement, reconfession solicitation and intrusive-thought intent inference;
- EN/FR post-model safety cases pass;
- bounded false-positive controls pass;
- fabricated-memory provider output is rejected and not exposed;
- the runtime response contract has an executable equivalence test against `tool/lot11c/lot11c_response.schema.json`;
- no provider SDK, HTTP dependency, provider URL, client secret, raw prompt logging or completion logging was added to Flutter;
- IAmina Core remains untouched.

Full Flutter suite on certified code evidence HEAD:
**244 tests PASS**.

Exact-head non-regression on `3d67930a204cfe1dc9bfee75e318866a1d0a1e2f`:
- LOT03: SUCCESS — run `36324918586`
- LOT04: SUCCESS — run `36324918518`
- LOT05: SUCCESS — run `36324918550`
- LOT06: SUCCESS — run `36324918566`
- LOT07: SUCCESS — run `36324918520`
- LOT08: SUCCESS — run `36324918623`
- LOT09: SUCCESS — run `36324918576`
- LOT10: SUCCESS — run `36324918509`

## ADVERSARIAL REVIEW HISTORY

Initial independent review found real blockers:
- incomplete post-model OCD safety;
- no runtime-owned provider timeout;
- rejected provider text remained exposed;
- incomplete exact-path runtime-family evidence;
- no executable response-contract drift proof.

Those findings were reproduced dynamically with failing adversarial tests before remediation.

After hardening:

Review A V2:
`docs/ocd/reviews/LOT_11D_REVIEW_A_V2_SAFETY_ARCHITECTURE.md`

Verdict: **PASS**
Strict retained score: **9.5/10**

Review B V2:
`docs/ocd/reviews/LOT_11D_REVIEW_B_V2_EVIDENCE_INTEGRITY.md`

Verdict: **PASS_WITH_NOTES**
Strict retained score: **9.3/10**

## HUMAN GATE

Product Owner decision on 2026-09-27:

**OPTION A APPROVED**

Decision:
LOT11-D closes at the provider-neutral client/runtime boundary.

The absence of a concrete live server-side provider transport is explicitly accepted as a carried residual and does not expand LOT11-D scope.

This Human Gate authorizes:
- administrative closeout of LOT11-D;
- preparation and progression to LOT11-E — Conversation UX.

It does NOT authorize:
- merge;
- deployment;
- production/provider traffic;
- real-user conversation data;
- production secrets;
- production DB/config changes.

## ACCEPTED RESIDUAL EVIDENCE GAPS

### R1 — Live server-side provider transport chain

NOT RESOLVED.

This repository proves:
`ConversationSafetySession → injectable ConversationProviderAdapter → schema → production OutputGuard → bounded result`.

It does not yet prove:
`ConversationSafetySession → real server-side Groq transport → live provider response → production OutputGuard`.

Do not add a direct Groq HTTP client to Flutter to close this gap.

The future server-side provider bridge must preserve:
- server-side secrets;
- no raw chat logging;
- deterministic routing authority;
- strict response schema;
- timeout/fail-closed behavior;
- post-model output guard;
- no IAmina Core contamination.

### R2 — Ephemeral independent human review of raw synthetic completions

NOT RESOLVED.

Sanitized CI intentionally excludes raw completions.
A dedicated human/clinical review mechanism remains appropriate for later review hardening, especially LOT11-G.

### R3 — Broader paraphrase/adversarial expansion

The deterministic post-model guard is intentionally lexical and bounded.

Broader paraphrase/adversarial expansion remains a LOT11-F target and must not be represented as complete in LOT11-D.

## ARCHITECTURAL CONSTRAINTS CARRIED FORWARD

- IAmina Core and OCD capsule remain separate.
- Deterministic safety routing remains authoritative.
- Provider never owns crisis routing, reassurance/checking/rumination/confession classification, diagnosis, medication, autonomous ERP, memory truthfulness or route selection.
- No real-user provider traffic is authorized.
- No raw chat persistence is authorized by this closeout.
- No direct vendor secret may exist in Flutter/client code.
- LOT11-E must not weaken or bypass the LOT11-D runtime boundary.

## STATE

LOT11-D: **CLOSED FOR ROADMAP PROGRESSION**
Human Gate: **OPTION A APPROVED**
Merge: **NOT AUTHORIZED**
Deployment: **NOT AUTHORIZED**
Next sub-lot: **LOT11-E — Conversation UX**
