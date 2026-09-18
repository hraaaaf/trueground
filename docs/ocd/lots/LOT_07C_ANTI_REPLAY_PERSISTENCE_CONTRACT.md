# LOT 07C — Anti-Replay Persistence Contract

Status: ARCHITECTURE APPROVED / DURATION POLICY HUMAN GATE
Date: 2026-09-18
Parent: LOT 07 — Practice experience

## GOAL

Allow the anti-replay guard to survive an application restart without creating an OCD practice history, clinical journal, streak, score, analytics stream, or provider-backed record.

## APPROVED ARCHITECTURE

The product owner approved local persistence using `shared_preferences`.

Implementation uses the modern `SharedPreferencesAsync` API.

Only two technical markers are allowed:

- `trueground.practice.pause.completed_at.v1`
- `trueground.practice.uncertainty.completed_at.v1`

Each value is a UTC ISO-8601 completion timestamp.

## PROHIBITED DATA

The persistence layer MUST NOT store:

- obsession or fear text;
- reassurance requests;
- user-entered content;
- anxiety/distress scores;
- whether a compulsion was "successfully" resisted;
- counts or streaks;
- exposure hierarchy;
- practice notes;
- clinician data;
- account identifiers;
- analytics events;
- longitudinal symptom history.

## SEMANTIC BOUNDARY

A stored timestamp means only:

> this bounded UI flow reached its terminal state at this time.

It does NOT mean:

- treatment completed;
- ERP completed;
- compulsion prevented;
- clinical progress;
- symptom change;
- adherence success.

## STORAGE BOUNDARY

- local device only;
- no cloud sync introduced by TrueGround;
- no provider;
- no database;
- no IAmina Core modification;
- no real-user migration because the feature is not deployed.

## FAILURE BOUNDARY

Storage failure MUST fail safely without blocking navigation or crashing the app.

The product MUST NOT tell the user that a clinical safety guarantee exists because a timestamp was stored.

## UNRESOLVED POLICY — HUMAN GATE

Architecture is approved, but the duration for which a persisted completion marker disables direct replay is NOT scientifically or product-validated in the current repository.

LOT07C MUST NOT invent a duration such as:

- 5 minutes;
- 1 hour;
- 24 hours;
- until midnight;
- one practice per day.

The duration must be an explicit product/safety decision.

Until that decision is made, the persistence adapter may be implemented and tested, but persisted timestamps MUST NOT yet change runtime replay availability.

## NEXT DECISION

Choose the expiry/re-enable semantics for each technical marker before wiring persistence into the Practice runtime.
