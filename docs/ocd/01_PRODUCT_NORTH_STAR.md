# 01 — PRODUCT NORTH STAR

Status: DRAFT FOR REVIEW
Date: 2026-09-15

## GOAL

Create a calm, premium mobile OCD companion that helps users recognize and interrupt obsessive-compulsive loops without turning the product into a reassurance machine.

The V1 target is the dashboard mockup validated during product exploration. Implementation must converge toward that hierarchy and product logic before any redesign or expansion is proposed.

## Product thesis

The product is not positioned as a generic mental-health chatbot.

The core product idea is:

**Help the user notice an OCD loop, resist compulsive reassurance/checking, and practice safer structured responses.**

Working positioning:

> Break the loop, not the thought.

This wording is a product direction, not a therapeutic efficacy claim.

## Target user

Initial scope:

- Adults only unless a later validated decision explicitly expands age coverage.
- Users seeking structured support around OCD-related patterns.
- Users may or may not already be in professional care.

The app must not assume a diagnosis merely because someone uses it.

## V1 dashboard target

The mobile dashboard should preserve the validated hierarchy:

1. Brand/header area.
2. Calm contextual greeting.
3. Primary SOS action: `I'm spiraling`.
4. `OCD Loop Status` summary.
5. `Today's Plan`.
6. `ERP Practice` entry point.
7. `Compulsion Firewall` entry point.
8. `Progress This Week`.
9. `Recent Journal`.
10. Bottom navigation: `Home / SOS / Journal / Progress / Coach`.

The approved mockup is the visual target reference. Until that image is stored in-repo, no implementation should claim pixel-level verification against it.

## Product principles

### 1. Anti-reassurance by design

The product must not maximize engagement by repeatedly answering certainty-seeking questions.

### 2. Action over endless analysis

The app should help users move from looping conversation toward a bounded next step when appropriate.

### 3. Calm, not clinical coldness

The interface should feel trustworthy, warm and quiet without pretending to be a clinician.

### 4. Progress without perfectionism

Metrics must avoid encouraging compulsive self-monitoring, streak obsession or punitive completion pressure.

### 5. Safety over conversational smoothness

When the safe behavior conflicts with giving a satisfying answer, safety wins.

### 6. Vertical specialization

OCD is a distinct capsule/client built on IAmina Core. Product-specific intelligence remains isolated from the reusable machine.

## V1 is NOT

- A diagnostic tool.
- A replacement for a psychiatrist, psychologist or emergency service.
- A medication prescriber.
- A promise to cure OCD.
- An unrestricted chatbot that answers every question.
- A social network.
- A clinician dashboard in the first consumer V1 unless separately approved.

## Success definition

V1 is successful when a user can:

- understand the core proposition quickly;
- enter an SOS flow without confusion;
- record and review relevant patterns;
- access structured OCD-specific exercises/features;
- see progress in a non-compulsive manner;
- receive consistent anti-reassurance behavior from the AI layer;
- use the core experience on supported mobile sizes without broken layout or dead-end states.

## Out-of-scope expansion

Do not add adjacent conditions, broad mental-health coaching, family accounts, clinician portals, wearable integrations, communities, medication modules or marketplace features without a separate product decision.

## North-star rule

**MATCH FIRST. IMPROVE LATER.**

Any significant departure from this target requires:

- current state;
- proposed alternative;
- reason;
- expected impact;
- explicit product-owner approval.
