# 02 — OCD PRODUCT SPEC

Status: DRAFT FOR REVIEW
Date: 2026-09-15

## GOAL

Define the V1 product behavior precisely enough that design, mobile, backend and AI work converge on the same product instead of building four neighboring interpretations.

This document defines product behavior only. Clinical/safety constraints are canonical in `03_OCD_CLINICAL_SAFETY.md`.

## Primary product loop

The intended product loop is:

`Trigger → user notices distress/urge → app helps classify the loop → bounded support/action → user records outcome if useful → longitudinal progress`

The app must avoid turning this into:

`Trigger → ask for certainty → AI reassures → temporary relief → repeat`.

## V1 navigation

Primary bottom navigation:

- `Home`
- `SOS`
- `Journal`
- `Progress`
- `Coach`

Names may change only through an explicit product decision.

## Home

The dashboard is a summary and launch surface, not a dense analytics page.

Required blocks:

### Greeting
- Calm contextual greeting.
- No false claim about mood/state unless derived from user-provided data.

### I'm spiraling
- Highest-priority CTA.
- Opens the bounded SOS flow.
- Must not immediately drop the user into unrestricted free chat.

### OCD Loop Status
- Gives a compact user-facing summary of recent self-reported/app-observed activity.
- Wording must avoid presenting an unvalidated medical score or diagnosis.

### Today's Plan
- Small number of relevant actions.
- Avoid excessive task count or completion pressure.

### ERP Practice
- Entry point for structured practice.
- Actual clinical protocol must be validated before implementation beyond a safe prototype.

### Compulsion Firewall
- Entry point for handling likely reassurance/checking/rumination loops.

### Progress This Week
- Small set of meaningful indicators.
- Metrics must not reward compulsive logging or perfectionism.

### Recent Journal
- Quick access to recent user-authored entry/context.

## SOS / "I'm spiraling"

Purpose: provide short, bounded support during a difficult moment without becoming a reassurance loop.

Candidate flow:

1. User enters what is happening, optionally in free text.
2. System identifies the likely interaction pattern, with uncertainty language.
3. System checks for safety-critical content where required.
4. System avoids certainty/reassurance if the request appears compulsive.
5. System offers a bounded next action appropriate to the validated policy.
6. Session ends or transitions to a safe tool instead of encouraging indefinite looping.

The exact wording and decision policy belong to the safety specification and evaluated prompt/policy layer.

## Compulsion Firewall

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

## Coach

The Coach is not an unrestricted therapist simulation.

V1 responsibilities:

- explain app concepts;
- guide approved exercises;
- help structure a journal entry;
- identify likely loop patterns using cautious language;
- redirect reassurance-seeking behavior according to safety policy;
- surface professional-help guidance when policy requires it.

V1 must not:

- diagnose OCD or another condition;
- prescribe or change medication;
- make emergency-care decisions beyond approved escalation guidance;
- claim to replace professional care;
- invent personalized exposure tasks outside validated boundaries.

## Journal

The journal should capture useful context without demanding exhaustive logging.

Candidate fields:

- timestamp;
- user text;
- optional trigger category;
- optional urge/compulsion category;
- optional distress/intensity self-rating if validated for UX;
- action taken;
- optional reflection.

Avoid mandatory fields that may encourage compulsive completeness.

## Progress

Progress should emphasize behavior and flexibility rather than symptom perfection.

Candidate indicators for validation:

- urges delayed;
- compulsive responses resisted;
- practices completed;
- time/instances where user chose a planned alternative;
- qualitative reflection.

No score should be labeled clinically meaningful without validation.

## ERP Practice

ERP-related functionality is a controlled domain feature and must not be improvised from a generic LLM.

Before production implementation, define and approve:

- intended scope;
- inclusion/exclusion rules;
- who authors/validates exercises;
- hierarchy behavior;
- stop/escalation conditions;
- contraindication/safety handling;
- data captured;
- evaluation set.

Until then, ERP UI may be mocked but must not be represented as clinically validated treatment delivery.

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
