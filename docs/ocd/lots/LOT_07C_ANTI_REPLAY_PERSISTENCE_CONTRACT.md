# LOT 07C — Anti-Replay Persistence Contract

Status: ARCHITECTURE + 2-HOUR UX ANTI-REPLAY POLICY APPROVED
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

## APPROVED ANTI-REPLAY WINDOW

Product-owner decision: a persisted completion marker disables direct replay for exactly 2 hours after terminal completion.

This is an internal UX anti-replay guard. It is NOT:

- an ERP schedule;
- a recommended practice frequency;
- a clinical dose;
- a statement that two hours is therapeutically optimal;
- a promise that replay after two hours is clinically indicated.

The UI MUST NOT expose a countdown, remaining time, exact re-enable time, "come back in two hours" instruction, streak, or frequency target.

At exactly `completed_at + 2h`, the technical marker no longer disables that surface.

A future timestamp caused by device-clock manipulation is not treated as a clinical/security boundary. This mechanism is intentionally a local UX guard, not tamper-resistant enforcement.

## FAILURE SEMANTICS

If completion-state reads fail, the affected practice surfaces remain unavailable for that app session rather than opening a blind replay path. Navigation outside those surfaces remains available.

If a completion write fails, the current in-memory session guard remains active and the app does not crash. Cross-restart persistence cannot be guaranteed when the local platform store itself is unavailable.
