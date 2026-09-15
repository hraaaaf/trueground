# 06 — ROADMAP TO TARGET

Status: DRAFT FOR REVIEW
Date: 2026-09-15

## GOAL

Define the ordered execution path from project foundation to the approved OCD V1 target without allowing product, architecture, safety, privacy or UX work to drift from the canonical documents.

This roadmap is sequence-driven, not date-driven. A phase advances only when its acceptance gate in `07_ACCEPTANCE_GATES.md` is satisfied.

## Global execution rule

Every phase follows:

`READ → PLAN → EXECUTE → VERIFY`

Each significant phase must state:

- GOAL
- SUCCESS
- PROOF

No phase is complete merely because code compiles or CI is green.

## PHASE 0 — Canonical foundation

### Goal
Freeze product, safety, architecture, privacy and acceptance criteria before implementation.

### Required outputs
- `00_README.md`
- `01_PRODUCT_NORTH_STAR.md`
- `02_OCD_PRODUCT_SPEC.md`
- `03_OCD_CLINICAL_SAFETY.md`
- `04_IAMINA_CAPSULE_ARCHITECTURE.md`
- `05_DATA_PRIVACY_SECURITY.md`
- `06_ROADMAP_TO_TARGET.md`
- `07_ACCEPTANCE_GATES.md`
- approved Dashboard V3 reference

### Success
No material contradiction remains between product hierarchy, navigation, safety rules and Core/capsule separation.

### Proof
Document review + branch diff + explicit product-owner approval.

## PHASE 1 — Existing-system inspection and architecture contract

### Goal
Inspect the real IAmina implementation and the TrueGround repository before choosing stack details or writing integration code.

### Required work
- inspect IAmina Core repository structure;
- inspect current auth, model runtime, memory, tool and observability primitives;
- inspect existing mobile/web stack if present;
- identify what is genuinely reusable versus client-specific;
- map the minimal OCD capsule contract;
- identify environment, secret, data and deployment boundaries;
- document unresolved architecture decisions.

### Success
A small, explicit integration plan exists with no invented files, APIs or interfaces.

### Proof
Architecture inventory + dependency map + proposed capsule boundary + reviewed decision record.

### Blocker
Do not build a generic framework from assumptions. Extraction into Core must be justified by inspected existing code.

## PHASE 2 — Application shell and design foundation

### Goal
Create the smallest stable app shell capable of reproducing Dashboard V3 without clinical behavior yet.

### Required work
- app bootstrap using the approved stack;
- navigation shell;
- typography, spacing, icon and component tokens;
- theme/background/surface primitives;
- loading, error and empty-state conventions;
- accessibility baseline;
- responsive/mobile viewport baseline.

### Success
The shell runs locally in an isolated environment and supports the canonical V3 navigation structure.

### Proof
Screenshots + smoke tests + commit SHA + no production deployment.

## PHASE 3 — Dashboard V3 static target

### Goal
Match the approved product hierarchy before adding intelligence.

### Required home elements
- brand/header;
- `Choose your next move.`;
- `Make room for uncertainty. Choose what matters.`;
- `I'm stuck in a loop`;
- `Pause the ritual`;
- `Practice uncertainty`;
- `Continue planned practice`;
- `Return to what matters`;
- `Need a person, not an answer?`;
- `Review patterns when useful`;
- `Home / Loop / Practice / Support / Profile`.

### Success
Home matches the approved V3 logic and visual density without score-heavy or compulsive-monitoring UI.

### Proof
Reference screenshots at required sizes + screenshot review against target + accessibility checks.

## PHASE 4 — Data and privacy foundation

### Goal
Introduce only the minimum storage/auth/data primitives needed for approved V1 behavior.

### Required work
- user/client/tenant scoping;
- environment isolation;
- auth/authorization checks;
- privacy-minimized data model;
- sensitive-content logging rules;
- deletion/retention design;
- provider-data-flow documentation before sending real content to any AI provider.

### Success
No cross-client path, raw sensitive-content logging shortcut or production-data dependency is required for development/testing.

### Proof
Schema/design review + access tests + log inspection + secret scan where supported.

## PHASE 5 — Bounded Loop flow

### Goal
Make `I'm stuck in a loop` operational without creating an unrestricted reassurance chatbot.

### Required behavior
- bounded entry;
- brief context capture;
- approved safety routing;
- cautious loop-pattern recognition;
- small approved action set;
- explicit end/transition state;
- safe provider failure state.

### Success
A user can enter the flow, receive a bounded next action and exit without the app encouraging endless conversation.

### Proof
Functional tests + UX screenshots + safety evals + provider-failure tests.

## PHASE 6 — Compulsion Firewall capability

### Goal
Detect likely reassurance/checking/rumination repetition and change system behavior accordingly.

### Required work
- session-level repetition detection;
- cautious reason codes;
- paraphrase/reformulation cases;
- refusal/redirection behavior;
- false-positive handling;
- audit/evaluation hooks that respect privacy.

Longitudinal repetition detection is added only after memory/privacy rules are verified.

### Success
The system does not simply provide fresh reassurance when the same certainty request is repeated or reformulated.

### Proof
Versioned evaluation suite covering normal, repeated, ambiguous and adversarial cases.

## PHASE 7 — Practice experience

### Goal
Deliver bounded, calm practice tools without turning them into performance mechanics.

### Initial surfaces
- `Pause the ritual`;
- `Practice uncertainty`;
- `Continue planned practice`.

### Constraints
- no streak pressure;
- no competitive counts;
- no uncontrolled LLM-generated exposure plans;
- clear start/end;
- safe degraded state.

### ERP boundary
Any treatment-like ERP engine requires separate scientific/clinical validation per `03_OCD_CLINICAL_SAFETY.md` before production claims or autonomous exposure generation.

### Success
Practice flows are bounded, understandable and do not require unsupported clinical claims.

### Proof
UX tests + safety review + content/version evidence + failure-state tests.

## PHASE 8 — Values and human support

### Goal
Help users redirect attention toward meaningful activity and preserve a clear route to real people.

### Required work
- `Return to what matters` flow;
- user-led values/categories;
- `Need a person, not an answer?` flow;
- therapist/trusted-person configuration only if explicitly approved;
- region-validated support resources where required.

### Success
The app can move a user away from the loop without pretending the AI is the only source of support.

### Proof
Functional tests + copy review + routing tests.

## PHASE 9 — Pattern review and longitudinal memory

### Goal
Provide useful history without creating a compulsive score-checking surface.

### Required work
- explicit memory scope;
- minimal retained facts/events;
- user-initiated pattern review;
- no default severity score;
- no prominent home trend graph;
- edit/delete/retention behavior where required;
- false-inference safeguards.

### Success
History adds continuity while remaining bounded and privacy-minimized.

### Proof
Memory retrieval tests + deletion tests + pattern-review UX tests + checking-risk evaluation.

## PHASE 10 — Full safety and adversarial evaluation

### Goal
Test the assembled product as a system, not only individual prompts/components.

### Required coverage
Use the canonical risk families from `03_OCD_CLINICAL_SAFETY.md`, plus provider/tool/memory failure, ambiguous cases and multilingual cases for every supported language.

### Success
Approved thresholds are met and no known release-blocking safety defect remains unresolved.

### Proof
Versioned evaluation report + failures + fixes + rerun evidence.

## PHASE 11 — Beta readiness

### Goal
Prove the V1 can be safely reviewed as a coherent product candidate.

### Required work
- end-to-end smoke tests;
- supported viewport/device validation;
- accessibility baseline;
- privacy/security baseline;
- account/session edge cases;
- offline/degraded behavior where relevant;
- non-regression suite;
- release notes and known risks;
- explicit list of unimplemented/out-of-scope features.

### Success
All mandatory V1 gates are VERIFIED or explicitly blocked with documented risk ownership.

### Proof
Beta readiness report referencing `07_ACCEPTANCE_GATES.md`.

## PHASE 12 — Release decision

### Goal
Separate technical readiness from authorization to release.

Even if every test passes, release requires explicit product-owner approval.

No merge, public deployment, TestFlight, Play Store, Vercel production, real-user migration or production-data change is authorized by this roadmap.

## Scope discipline

Future ideas such as clinician dashboards, communities, medication features, wearables, family plans, additional conditions, autonomous advanced ERP, social features or broad mental-health coaching are separate roadmap decisions.

They must not be inserted into V1 merely because the architecture could support them.
