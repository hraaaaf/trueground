# LOT 10 — SYSTEM SAFETY CONTRACT

Status: IN PROGRESS — HIGH-RISK ROUTING HUMAN GATE OPEN
Date: 2026-09-22
Base: LOT09 exact HEAD `820a50f0a26bd9434981cc9315950cdfb75928ee`
Target gate: GATE 10 — SYSTEM_SAFETY_VERIFIED

## GOAL

Verify TrueGround's existing deterministic OCD capsule as one system against the canonical safety families without introducing a second safety engine, an LLM/provider, a new supported language, or unapproved clinical behavior.

## Inspected runtime truth

- Runtime is deterministic Flutter.
- No LLM/AI/provider dependency exists in `pubspec.yaml`.
- No external tool execution path exists.
- Longitudinal memory is limited to LOT09 device-local `shared_preferences` pattern events.
- UI/content is English-only; no localization package/resources are present.
- Compulsion Firewall is session-only and sends high-confidence repeated loops to `/loop`.
- `emergency` / `immediate danger` are hard escapes from the Compulsion Firewall, but no dedicated downstream crisis/acute-risk route or approved policy exists.
- Support is ordinary human support, not crisis routing.

## Architecture boundary

LOT10 is verification-first.

It must not:
- move OCD rules into generic IAmina Core;
- add an LLM/provider;
- expand LOT09 stored content or retention;
- introduce diagnosis, severity, treatment efficacy, autonomous ERP, medication advice, or crisis instructions;
- refactor proven LOT05–LOT09 flows unless a proven blocker requires it.

## Supported language

Current supported product language for this lot: **English only**.

Evidence:
- English-only runtime copy;
- no `flutter_localizations` dependency;
- no ARB/l10n resource set discovered;
- LOT09 handover records an English-only baseline.

LOT10 therefore requires representative English safety cases. Additional languages are NOT_APPLICABLE and must not be invented.

## Provider/tool applicability

AI/provider failure: NOT_APPLICABLE — no provider/model path exists.

External tool failure: NOT_APPLICABLE — no tool execution path exists.

Memory degradation: APPLICABLE — LOT09 local memory can be unavailable, stale, malformed or empty and must remain truthful.

## Acceptance thresholds — fixed before final scoring

These thresholds are declared before LOT10 scoring and must not be relaxed after observing failures without a documented human risk decision.

1. Canonical safety-family coverage: **100%** of the families listed in `03_OCD_CLINICAL_SAFETY.md` represented in the LOT10 dataset/coverage matrix.
2. Implemented deterministic safety cases: **100% pass** for non-HUMAN_GATE cases.
3. Unsupported medical-claim detector fixtures: **100% detection** for the versioned prohibited fixtures.
4. User-facing runtime unsupported-claim scan: **0 material matches**.
5. Memory truthfulness cases: **100% pass** for unavailable/stale/empty/no-fabrication behavior.
6. Supported-language coverage: **100% of supported languages**; current denominator = English only.
7. Provider/tool failure coverage: explicit NOT_APPLICABLE evidence while those paths are absent.
8. Known material safety regressions: **0 unresolved**.
9. High-risk/acute-risk routing: an explicitly approved dedicated policy + representative tests are mandatory before GATE 10 can be VERIFIED.

## Current hard blocker

`KF-01` — dedicated approved high-risk/crisis routing is absent.

Canonical safety explicitly requires a separately reviewed acute-risk policy before release. Existing runtime only prevents the Compulsion Firewall from swallowing obvious danger text; it does not provide or route through an approved acute-risk policy.

This blocker must not be “fixed” by improvising emergency copy or regional resources.

## Required proof before verification

- versioned LOT10 full-system eval dataset;
- canonical coverage matrix;
- known-failure register;
- focused `system_safety_test.dart`;
- full Flutter regression;
- release web build;
- exact-head LOT03→LOT10 CI;
- specialist review ledger;
- strict Pass A + separated adversarial Pass B;
- retained lower score >= 9.0;
- Perfection Pass;
- explicit resolution of KF-01 through a human-approved reviewed policy.

Green CI alone does not close GATE 10.
