# 01 — PRODUCT NORTH STAR

Status: APPROVED TARGET / IMPLEMENTATION NOT YET VERIFIED
Date: 2026-09-15

## GOAL

Create a calm, premium mobile OCD companion that helps users step out of obsessive-compulsive loops without turning the product into a reassurance machine, a symptom scoreboard or a compulsive self-monitoring surface.

The canonical V1 dashboard target is **Dashboard V3**, frozen in:

`docs/ocd/assets/DASHBOARD_TARGET_V3.md`

and represented by the stored preview:

`docs/ocd/assets/dashboard_target_v3.jpg.b64`

Implementation must converge toward this product logic and hierarchy before redesign or expansion is proposed.

## Product thesis

The product is not positioned as a generic mental-health chatbot.

The core product idea is:

**Help the user notice an OCD loop, create space before a compulsive response, practice uncertainty, and return attention toward what matters.**

Working positioning:

> Less checking. More living.

This wording is a product direction, not a therapeutic efficacy claim.

## Why the target changed

The first dashboard concept emphasized loop status, a daily plan, counts and weekly progress indicators.

Early feedback from a person living with OCD raised a credible product risk: prominent symptom scoring and repeated progress monitoring can increase anxiety or become another object of checking/perfectionistic behavior.

The approved V3 therefore changes the home philosophy from:

`MONITOR → SCORE → COMPLETE`

to:

`NOTICE → CHOOSE → PRACTICE → RETURN TO LIFE`

This is a product and safety direction. Detailed clinical behavior remains governed by `03_OCD_CLINICAL_SAFETY.md`.

## Target user

Initial scope:

- Adults only unless a later validated decision explicitly expands age coverage.
- Users seeking structured support around OCD-related patterns.
- Users may or may not already be in professional care.

The app must not assume a diagnosis merely because someone uses it.

## Canonical V1 dashboard hierarchy

The mobile dashboard should preserve the approved V3 hierarchy:

1. Brand/header area.
2. Calm contextual greeting.
3. Headline: `Choose your next move.`
4. Supporting principle: `Make room for uncertainty. Choose what matters.`
5. Primary bounded action: `I'm stuck in a loop`.
6. Primary practice choices:
   - `Pause the ritual`;
   - `Practice uncertainty`;
   - `Continue planned practice`.
7. Values-oriented action: `Return to what matters`.
8. Human-support escape hatch: `Need a person, not an answer?`.
9. Optional, user-initiated pattern review: `Review patterns when useful`.
10. Bottom navigation: `Home / Loop / Practice / Support / Profile`.

## Home-screen anti-targets

The dashboard must not default to:

- `mild / moderate / severe` OCD status badges;
- streaks;
- anxiety scores as the central home metric;
- daily completion pressure;
- reassurance-resisted counters;
- exposure counts as competitive progress;
- prominent trend graphs that invite repeated checking;
- gamification that rewards compulsive monitoring;
- open-ended journaling prompts that encourage repeated analysis of the obsession.

This does not prohibit clinically justified measurement. It means measurement must be purposeful, bounded, reviewed against OCD safety risks and placed where it cannot dominate the daily home experience.

## Product principles

### 1. Anti-reassurance by design

The product must not maximize engagement by repeatedly answering certainty-seeking questions.

### 2. Choice over grading

The home experience should present useful next actions rather than continuously tell the user how well or badly they are doing.

### 3. Action over endless analysis

The app should help users move from looping conversation toward a bounded next step when appropriate.

### 4. Values over rituals

The product should help the user redirect attention toward meaningful life activity rather than make OCD itself the center of the interface.

### 5. Progress without perfectionism

Metrics must avoid encouraging compulsive self-monitoring, streak obsession or punitive completion pressure.

### 6. Calm, not clinical coldness

The interface should feel trustworthy, warm and quiet without pretending to be a clinician.

### 7. Safety over conversational smoothness

When the safe behavior conflicts with giving a satisfying answer, safety wins.

### 8. Human support remains visible

The product must preserve a clear route toward a therapist, trusted person or appropriate external support when a conversation should not remain inside the AI experience.

### 9. Vertical specialization

OCD is a distinct capsule/client built on IAmina Core. Product-specific intelligence remains isolated from the reusable machine.

## V1 is NOT

- A diagnostic tool.
- A replacement for a psychiatrist, psychologist or emergency service.
- A medication prescriber.
- A promise to cure OCD.
- An unrestricted chatbot that answers every question.
- A symptom-performance game.
- A social network.
- A clinician dashboard in the first consumer V1 unless separately approved.

## Success definition

V1 is successful when a user can:

- understand the proposition quickly;
- recognize what to do when caught in a loop;
- access bounded OCD-specific practice without being pushed into repeated monitoring;
- return toward personally meaningful activity;
- continue a planned practice without pressure or gamified scoring;
- reach human support clearly when needed;
- review patterns only when useful and in a non-compulsive manner;
- receive consistent anti-reassurance behavior from the AI layer;
- use the core experience on supported mobile sizes without broken layout or dead-end states.

## Out-of-scope expansion

Do not add adjacent conditions, broad mental-health coaching, family accounts, clinician portals, wearable integrations, communities, medication modules or marketplace features without a separate product decision.

## North-star rule

**MATCH FIRST. IMPROVE LATER.**

Any significant departure from Dashboard V3 requires:

- current state;
- proposed alternative;
- reason;
- expected impact;
- explicit product-owner approval.

No implementation may claim pixel-level verification against V3 until a full-resolution canonical image is committed and screenshot comparison has been performed.
