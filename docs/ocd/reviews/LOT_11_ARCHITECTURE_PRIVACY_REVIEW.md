# LOT 11 — ARCHITECTURE & PRIVACY REVIEW

Status: LOT11-A REVIEW — RUNTIME AI NOT AUTHORIZED
Date: 2026-09-25
Scope: documentation / pre-implementation only
Branch: `lot/11a-conversational-safety-contract`

## GOAL

Challenge the proposed Bounded Conversational Companion architecture against the inspected TrueGround runtime, IAmina Core/capsule doctrine and sensitive-data requirements before any provider SDK or model call is introduced.

## SUCCESS

This review passes LOT11-A architecture/privacy only if:

- proposed interfaces are not represented as existing code;
- OCD policy remains capsule-owned;
- current English-only deterministic classifiers are not misrepresented as EN/FR-ready;
- raw chat persistence/logging is disallowed by default;
- provider selection remains blocked until data-flow terms can be reviewed;
- provider/model cannot own safety routing;
- failure modes fail closed;
- LOT09 structured memory remains separate;
- crisis/high-risk remains a human-reviewed dependency.

## Evidence inspected

Repository truth inspected on `feat/fr-localization@09c9f95c4a3f14f7a32719cee513015fe7b0e505` and LOT10→LOT11 handover:

- `pubspec.yaml`
- `lib/app/router.dart`
- `lib/compulsion_firewall/compulsion_firewall.dart`
- `lib/safety/high_risk_boundary.dart`
- `lib/safety/urgent_support_screen.dart`
- `lib/loop/loop_flow_policy.dart`
- `lib/loop/loop_flow_screen.dart`
- `lib/practice/practice_screen.dart`
- `lib/values/values_screen.dart`
- `lib/support/support_screen.dart`
- `lib/patterns/pattern_memory_store.dart`
- `lib/patterns/pattern_review_screen.dart`
- `lib/localization/trueground_locale.dart`
- `docs/ocd/04_IAMINA_CAPSULE_ARCHITECTURE.md`
- `docs/ocd/05_DATA_PRIVACY_SECURITY.md`
- LOT10 contract/evals/tests.

## Finding A — no provider abstraction exists here

Direct inspection shows no runtime AI/model/provider dependency in `pubspec.yaml` and no provider adapter in this repo.

Verdict:
**PASS — contract corrected to requirements-only.**

The LOT11 architecture may describe a provider-agnostic adapter as a future boundary, but must not claim an IAmina Core implementation already exists.

Consequence for LOT11-B:
- inspect the actual IAmina Core repository/runtime before reuse;
- if no generic adapter exists, do not create Core coupling merely to satisfy the diagram;
- a capsule-local narrow adapter may be the safer first implementation until a genuinely generic abstraction is proven.

## Finding B — current deterministic safety code is not EN/FR-ready

`CompulsionFirewallSession` uses:
- ASCII/English normalization;
- hard-coded English phrases for certainty, checking, rumination, confession, hard escapes;
- English semantic token aliases.

`HighRiskBoundary` similarly uses hard-coded English urgent/intrusive phrases.

The UI localization layer translating screen copy does not make these classifiers multilingual.

Verdict:
**MATERIAL FINDING — explicitly captured as a LOT11-B implementation requirement.**

This does not block LOT11-A documentation closeout because LOT11-A introduces no runtime chat and now explicitly forbids treating these components as proven EN/FR routers.

It DOES block any claim that the future conversational safety router is already implemented.

## Finding C — high-risk policy remains externally gated

A technical `/urgent-support` route and deterministic markers exist, but the canonical safety contract still requires separately reviewed acute-risk policy/copy.

Verdict:
**RUNTIME RELEASE BLOCKER PRESERVED.**

LOT11 must not use model intelligence to compensate for the missing human-reviewed policy.

Required before runtime release:
- supported region(s) defined;
- qualified clinical/regulatory review;
- exact EN/FR escalation behavior reviewed;
- false-negative and intrusive-thought false-positive cases tested;
- truthfulness about contact/dispatch preserved.

## Finding D — model cannot be the safety authority

The target architecture places deterministic routing before the future provider and deterministic output checks after it.

Verdict:
**PASS.**

Required invariant:
- provider can propose text only within an already approved capability mode;
- provider cannot set acute-risk disposition;
- provider cannot bypass repetition policy;
- provider cannot invoke arbitrary tools/routes in the initial implementation;
- provider output is never displayed before guard evaluation.

## Finding E — Core/capsule separation is preserved

OCD-specific concepts remain in the capsule:
- reassurance;
- checking;
- rumination;
- confession;
- intrusive-thought boundary;
- crisis integration;
- OCD evals/thresholds;
- output-claim rules;
- language-specific OCD safety cases.

Only generic transport/runtime mechanics are candidates for eventual Core reuse after actual Core inspection.

Verdict:
**PASS.**

No IAmina Core change is authorized by LOT11-A.

## Finding F — raw conversation storage must remain opt-in, not default

Current LOT09 memory is a narrow local store of structured event types and timestamps. It is not raw dialogue memory.

Verdict:
**PASS_WITH_NOTES.**

LOT11 contract correctly defaults to:
- no raw chat persistence;
- no raw sensitive text in routine logs/analytics;
- minimized provider context;
- no silent expansion of Pattern Memory.

Future work requiring longitudinal chat memory must be a separate approved data design with:
- schema;
- purpose;
- retention;
- user scope;
- edit/delete behavior;
- derived-cache deletion;
- provider implications.

## Finding G — provider data-flow cannot be approved before provider selection

No provider is selected in LOT11-A.

Therefore retention, training usage, data residency, subprocessors, security controls and deletion behavior cannot yet be validated.

Verdict:
**EXPECTED OPEN ITEM, NOT A LOT11-A FAILURE.**

Correct LOT11-A behavior is to define the review requirements and prohibit production connection until a candidate is chosen and reviewed.

## Proposed future data flow

```text
User message
  ↓
OCD capsule session envelope (transient)
  ↓
deterministic safety router
  ├── deterministic route: no provider data
  └── allowed generation
          ↓
     minimization/redaction
          ↓
     provider adapter
          ↓
     provider/model
          ↓
     untrusted text
          ↓
     deterministic OCD output guard
          ↓
     display OR deterministic fallback
```

Default excluded from provider context:
- account email/name;
- cross-client data;
- raw LOT09 history;
- unrelated prior chat;
- analytics profile;
- secrets;
- hidden diagnosis labels;
- production debug context.

## Session-state design requirement

A future session state may retain minimal in-memory safety metadata such as:
- language;
- turn index;
- prior normalized/safe semantic fingerprints;
- policy family/reason codes;
- pivoted/not-pivoted flag.

It must not require raw-turn persistence to preserve the anti-repeat policy.

Whether semantic fingerprints themselves are persisted is out of scope and defaults to **no persistence**.

## Cross-language state requirement

Language switching must not create a new safety session.

EN→FR→EN must preserve:
- already-triggered repetition pivot;
- prior safe reason state;
- acute-risk override;
- provider-failure state.

This is a key reason the current English-only lexical firewall cannot simply be inserted unchanged in front of chat.

## Output-guard failure model

The output guard must fail closed if:
- parsing fails;
- policy version is missing;
- prohibited claim is detected;
- safety decision is inconsistent;
- model response is empty/malformed;
- the guard itself cannot complete its required checks.

Fail closed means:
- do not display the untrusted generated answer;
- present a deterministic truthful fallback;
- keep approved bounded routes available where appropriate.

It does not mean silently retrying the model until a desired answer appears.

## Logging review

Allowed-by-default observability fields:
- request/session correlation ID that is not a raw user identifier;
- component;
- timestamp;
- model/provider/version;
- policy version;
- safe reason code;
- success/failure;
- latency bucket.

Forbidden-by-default:
- full user message;
- full provider prompt;
- full generated response;
- obsession/confession text;
- crisis text;
- raw Pattern Memory;
- secret values.

Any exception requires explicit privacy/security review.

## Analytics review

A future analytics event can measure route/outcome without storing mental-health free text.

Examples potentially acceptable after review:
- companion_opened;
- bounded_route_selected;
- provider_failed;
- policy_pivoted;
- language_code.

Do not optimize on:
- number of reassurance turns;
- time spent reopening certainty loops;
- "engagement" that rewards repeated compulsive questioning.

## Supply-chain requirement

Before adding a provider SDK or helper dependency:
- prove it is necessary;
- review maintenance/licensing/security;
- prefer a narrow HTTP/adapter surface if consistent with repository conventions;
- pin versions;
- ensure the SDK cannot silently collect or log sensitive content;
- keep credentials out of repository/tests/artifacts.

## ADR record

### ADR-11A-001 — Canonical Gate 11 remains Beta Readiness
Decision: LOT11 is an inserted implementation-lot label; no gate renumbering.

### ADR-11A-002 — Safety authority stays deterministic and capsule-owned
Decision: model is downstream of pre-model policy and upstream of deterministic output guard.

### ADR-11A-003 — No raw conversation persistence by default
Decision: session-transient raw chat; separate explicit approval required for persistence.

### ADR-11A-004 — No provider choice or SDK in LOT11-A
Decision: provider requirements are defined first; candidates come later.

### ADR-11A-005 — Current English classifiers are not claimed as EN/FR safety implementation
Decision: multilingual router work is a LOT11-B requirement with direct eval proof.

### ADR-11A-006 — LOT09 memory is not chat memory
Decision: structured event/timestamp store remains separate and is not automatically sent to a provider.

## Review verdict

**PASS_WITH_NOTES for LOT11-A architecture/privacy documentation.**

The proposed architecture is compatible with the inspected repository and project governance because it does not invent an existing adapter, preserves capsule ownership and defaults to data minimization.

Notes/blockers that carry forward:
1. current safety classifiers are English-centric and require explicit multilingual implementation/evidence;
2. provider terms cannot be reviewed until a candidate exists;
3. crisis/high-risk remains a human-reviewed release blocker;
4. exact user-facing generative copy does not exist yet and has not been reviewed;
5. no runtime behavior has been tested because runtime AI is intentionally absent.

This verdict does NOT authorize model integration, merge, deployment or production data.
