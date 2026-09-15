# 02 — OCD PRODUCT SPEC

Status: DRAFT FOR REVIEW
Date: 2026-09-15

## GOAL

Define the V1 product behavior precisely enough that design, mobile, backend and AI work converge on the same product instead of building neighboring interpretations.

This document defines product behavior only. Clinical/safety constraints are canonical in `03_OCD_CLINICAL_SAFETY.md`.

The product must align with the approved Dashboard V3 in `01_PRODUCT_NORTH_STAR.md` and `assets/DASHBOARD_TARGET_V3.md`.

## Primary product loop

The intended product loop is:

`Notice → choose → practice → return to life`

A more detailed interaction may be:

`Trigger / urge → user opens app → bounded loop support → user chooses an approved next action → practice ends → user returns attention toward what matters`.

The app must avoid turning this into:

`Trigger → ask for certainty → AI reassures → temporary relief → repeat`.

It must also avoid turning recovery into:

`Trigger → score symptoms → check dashboard → compare trend → seek certainty about progress → repeat`.

## V1 navigation

Primary bottom navigation for Dashboard V3:

- `Home`
- `Loop`
- `Practice`
- `Support`
- `Profile`

Names may change only through an explicit product decision reflected in the canonical North Star.

## Home

The dashboard is a calm launch surface, not a symptom analytics page.

Required hierarchy:

### Greeting
- Calm contextual greeting.
- No false claim about mood/state unless derived from user-provided data.

### Choose your next move
- Primary home framing.
- Supporting principle: `Make room for uncertainty. Choose what matters.`
- Must not imply the app can guarantee calm, certainty or symptom reduction.

### I'm stuck in a loop
- Highest-priority CTA.
- Opens the bounded Loop flow.
- Must not immediately drop the user into unrestricted free chat.
- Supporting language should orient toward noticing the urge and creating space before a ritual/compulsive response.

### Pause the ritual
- Short bounded tool for creating time/space between urge and action.
- Must not become a countdown that users are encouraged to repeat compulsively.
- Exact behavioral guidance must be governed by approved safety/content policy.

### Practice uncertainty
- Entry point for approved uncertainty-tolerance / OCD-specific practice.
- Must not promise anxiety reduction as the immediate goal.
- Must not generate uncontrolled exposure tasks from a generic model.

### Continue planned practice
- Returns the user to a previously approved/saved practice.
- Avoid streaks, completion pressure and competitive scoring.

### Return to what matters
- Values-oriented redirection toward meaningful life activity.
- Candidate categories may include work, family, rest, faith, friends or user-defined values.
- Values content must remain user-led; the app must not impose moral priorities.

### Need a person, not an answer?
- Clear escape hatch toward human support.
- May include therapist/trusted-person pathways once approved and implemented.
- Must not imply the app contacted someone unless it actually did.

### Review patterns when useful
- Optional and user-initiated.
- Not a persistent scorecard.
- Should summarize recurring themes cautiously and without diagnostic certainty.
- Must be designed to reduce compulsive checking/perfectionistic monitoring risk.

## Home anti-targets

Do not make the home dashboard default to:

- OCD severity labels such as `mild / moderate / severe`;
- streaks;
- daily completion pressure;
- reassurance-resisted counters;
- exposure counts as competitive performance;
- prominent anxiety trend charts;
- repeated prompts to rate symptoms;
- gamified badges for resisting compulsions;
- open-ended journaling prompts that invite repeated analysis of the obsession.

Measurement may exist only when purposeful, bounded and reviewed against OCD safety risk.

## Loop flow / `I'm stuck in a loop`

Purpose: provide short, bounded support during a difficult moment without becoming a reassurance loop.

Candidate flow:

1. User briefly describes what is happening or selects a pattern.
2. System checks for safety-critical content where required.
3. System identifies the likely interaction pattern using uncertainty-aware language.
4. System avoids certainty/reassurance when the request appears compulsive.
5. System offers a small set of approved actions, such as pausing, practicing uncertainty, returning to a planned practice or reconnecting with a chosen value.
6. Interaction ends, transitions to a bounded tool or routes to human support instead of encouraging indefinite looping.

The exact wording and decision policy belong to the safety specification and evaluated policy layer.

## Compulsion Firewall capability

`Compulsion Firewall` is a capability, not necessarily a permanent dashboard card.

Purpose: detect and interrupt patterns such as:

- reassurance seeking;
- repeated checking requests;
- repeated reformulation of the same certainty question;
- rumination disguised as analysis;
- confession-style compulsive repetition;
- repeated retrospective certainty seeking.

Expected product behavior:

- recognize likely repetition across the session and, when approved, across relevant history;
- avoid simply answering the same reassurance request again;
- name the pattern carefully without asserting diagnosis;
- redirect toward an approved bounded response/tool;
- keep an auditable internal reason code for evaluation where privacy policy allows.

## Practice

The Practice area contains approved OCD-specific exercises/tools.

V1 principles:

- bounded sessions;
- no pressure to complete every day;
- no punitive streak loss;
- no implication that discomfort itself proves success;
- clear start/end state;
- safe degraded state if AI/provider functionality is unavailable.

ERP-related functionality remains controlled by the requirements below.

## ERP-related functionality

ERP-related functionality is a controlled domain feature and must not be improvised from a generic LLM.

Before production implementation beyond a safe prototype, define and approve:

- intended scope;
- inclusion/exclusion rules;
- who authors/validates exercises;
- hierarchy behavior;
- stop/escalation conditions;
- contraindication/safety handling;
- data captured;
- evaluation set;
- product claims.

Until then, ERP UI may be mocked but must not be represented as clinically validated treatment delivery.

## Support

The Support area must make human-help pathways visible without turning every normal OCD interaction into an alarm state.

Potential approved pathways:

- therapist contact/reference;
- trusted person;
- educational guidance about seeking professional care;
- crisis/escalation resources when the dedicated policy requires them.

Exact regional resources require explicit launch-jurisdiction validation.

## Profile

Profile may contain:

- preferences;
- language;
- notification controls;
- privacy/data controls;
- account controls;
- human-support configuration if later approved.

Do not bury critical privacy/deletion controls behind unnecessary friction.

## Journal / reflection

A traditional open-ended journal is not a primary V3 navigation destination.

If reflection is offered, it should be structured and optional so it does not encourage exhaustive rumination or compulsive completeness.

Candidate fields, only if validated:

- brief context;
- optional trigger/urge category;
- action chosen;
- whether the user returned to a valued activity;
- short optional note.

Avoid forcing distress ratings, exhaustive thought analysis or repeated rewriting.

## Pattern review / progress

Progress should emphasize flexibility and meaningful action rather than symptom perfection.

Candidate review concepts for validation:

- recurring patterns shown without grades;
- practices the user chose to return to;
- qualitative reflections;
- values/actions the user re-engaged with;
- optional clinician-approved measures if introduced later.

No score should be labeled clinically meaningful without validation.

Pattern review must be:

- user-initiated;
- bounded;
- non-gamified;
- designed against repeated checking behavior.

## Conversational Coach capability

Conversational support may exist inside Loop/Practice/Support flows, but V1 must not present an unrestricted therapist simulation.

Allowed responsibilities after safety approval:

- explain app concepts;
- guide approved exercises;
- help identify likely loop patterns using cautious language;
- redirect reassurance-seeking behavior according to safety policy;
- help the user choose among approved next actions;
- surface professional-help guidance when policy requires it.

It must not:

- diagnose OCD or another condition;
- prescribe or change medication;
- make emergency-care decisions beyond approved escalation guidance;
- claim to replace professional care;
- invent personalized exposure tasks outside validated boundaries.

## States required for every major screen

Each major screen/component must define:

- default;
- loading;
- empty;
- error;
- offline/degraded where relevant;
- accessibility behavior;
- safe AI/provider failure state where relevant.

## Product telemetry principles

If analytics are later approved:

- collect the minimum needed;
- never log raw sensitive conversation content by default merely for convenience;
- separate product analytics from clinical/sensitive content;
- document every event containing sensitive data;
- obtain appropriate consent where required.

## V1 completion rule

A feature is not complete because the UI exists. It requires its relevant acceptance gate, safety behavior, failure states and non-regression evidence.
