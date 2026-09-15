# TrueGround OCD — Canonical Documentation

Status: DRAFT FOR REVIEW
Date: 2026-09-15
Owner: Product owner

## Purpose

This directory is the canonical compass for the OCD product built on the IAmina machine.

The product is a separate client/vertical. IAmina is the reusable platform/core; OCD-specific product, safety, domain logic, prompts, policies, evaluations and data rules belong to the OCD capsule and must not leak into the generic IAmina Core.

## Canonical documents

1. `01_PRODUCT_NORTH_STAR.md` — fixed product target and visual/functional destination.
2. `02_OCD_PRODUCT_SPEC.md` — product behavior and V1 functional scope.
3. `03_OCD_CLINICAL_SAFETY.md` — safety boundaries, anti-reassurance rules and validation requirements.
4. `04_IAMINA_CAPSULE_ARCHITECTURE.md` — strict Core vs OCD capsule separation.
5. `05_DATA_PRIVACY_SECURITY.md` — sensitive-data, privacy and security requirements.
6. `06_ROADMAP_TO_TARGET.md` — execution path from foundation to V1 target.
7. `07_ACCEPTANCE_GATES.md` — objective evidence required before any phase can be considered verified.

## Source-of-truth precedence

When documents overlap, use this precedence by subject:

- Product vision / target UX → `01_PRODUCT_NORTH_STAR.md`
- Functional behavior → `02_OCD_PRODUCT_SPEC.md`
- Safety / clinical behavior → `03_OCD_CLINICAL_SAFETY.md`
- Architecture → `04_IAMINA_CAPSULE_ARCHITECTURE.md`
- Data / privacy / security → `05_DATA_PRIVACY_SECURITY.md`
- Execution order → `06_ROADMAP_TO_TARGET.md`
- Definition of verified → `07_ACCEPTANCE_GATES.md`

A decision must have one canonical home. Do not duplicate competing truths across files.

## Working method

Every significant task follows:

`READ → PLAN → EXECUTE → VERIFY`

And must define:

- GOAL — what must be achieved.
- SUCCESS — measurable acceptance condition.
- PROOF — concrete evidence that success was achieved.

## Project guardrails

- No merge without explicit product-owner approval.
- No production deployment without explicit product-owner approval.
- No real database, user-data, secret or production-schema mutation without explicit approval.
- No medical claim, diagnosis, therapeutic promise or unvalidated clinical behavior.
- No OCD-specific logic inside generic IAmina Core.
- Every AI feature must be evaluated for reassurance seeking, checking, rumination, repetitive questioning and inadvertent reinforcement of compulsions.
- Preserve existing validated behavior and provide non-regression evidence for every significant change.
- Keep changes small, isolated and auditable.

## Status vocabulary

Use only:

- `NOT STARTED`
- `IN PROGRESS`
- `BLOCKED`
- `READY FOR REVIEW`
- `VERIFIED`

`VERIFIED` requires the acceptance gate and evidence. Green CI alone is not sufficient.

## Current state

This documentation set defines the target and guardrails only. It does not constitute clinical validation, production readiness, regulatory clearance, or authorization to merge/deploy.
