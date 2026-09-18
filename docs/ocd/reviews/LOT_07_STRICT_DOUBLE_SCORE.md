# LOT 07 — Strict Double Score

Project: TrueGround OCD
Lot: LOT 07 — Practice experience
Scored runtime candidate: cfbfff9fc6f49d299e0b871f82048fe7e1b65973
Date: 2026-09-18

Method: two deliberately separated review passes over the same exact runtime candidate and evidence set. Pass B was instructed to find why Pass A was too generous. Both passes were performed in the same model/session, so they are adversarial but not genuinely independent. The governance cap of 9.4 therefore applies.

## PASS A — Severe execution review

| Axis | Score |
|---|---:|
| PRODUCT / SCOPE FIDELITY | 9.5 |
| FUNCTIONAL CORRECTNESS | 9.4 |
| UI / UX FIDELITY | 9.1 |
| ACCESSIBILITY | 9.3 |
| SAFETY / OCD ANTI-COMPULSION | 9.2 |
| CONTENT / CLAIM DISCIPLINE | 9.3 |
| ARCHITECTURE / CORE-CAPSULE SEPARATION | 9.7 |
| DATA / PRIVACY / SECURITY | 9.7 |
| QA / NON-REGRESSION | 9.4 |
| EVIDENCE / REPRODUCIBILITY | 9.3 |

PASS A execution score: 9.2 / 10.

Reasons preventing 10/10:
1. Exact Practice copy has no independent OCD-clinician sign-off.
2. Internal-state visual evidence uses Flutter's test font, so it proves geometry rather than production typography fidelity.
3. No physical-device manual validation is recorded; evidence is CI widget/headless-web based.
4. Continue planned practice is intentionally an honest degraded state because persistence is not yet approved.
5. English-only baseline; no multilingual safety-equivalence evidence.
6. No independent external reviewer performed this scoring pass.

Material finding during perfection pass:
- the urgent safety/medical boundary initially disappeared after entering an active practice step;
- fixed by keeping the boundary visible during Pause and uncertainty active instructions;
- tests and screenshots were refreshed on cfbfff9f.

## PASS B — Adversarial review

| Axis | Score |
|---|---:|
| PRODUCT / SCOPE FIDELITY | 9.3 |
| FUNCTIONAL CORRECTNESS | 9.2 |
| UI / UX FIDELITY | 9.0 |
| ACCESSIBILITY | 9.1 |
| SAFETY / OCD ANTI-COMPULSION | 9.0 |
| CONTENT / CLAIM DISCIPLINE | 9.1 |
| ARCHITECTURE / CORE-CAPSULE SEPARATION | 9.6 |
| DATA / PRIVACY / SECURITY | 9.6 |
| QA / NON-REGRESSION | 9.3 |
| EVIDENCE / REPRODUCIBILITY | 9.1 |

PASS B adversarial score: 9.0 / 10.

Reasons preventing 10/10:
1. Safety still depends on the user honoring the urgent-safety exclusion; LOT07 intentionally has no classifier capable of deciding whether a real-world check is objectively required.
2. The same-session anti-replay state resets on app restart because longitudinal persistence is deliberately absent.
3. Not every internal state has a production-font browser screenshot; widget captures are geometry-only evidence.
4. There is no real-user usability study testing whether the micro-flow itself can become a checking ritual in the field.
5. Regional crisis/support policy is not implemented inside Practice and remains outside this lot.
6. Pass B is adversarial but not independent from the implementation session.

Adversarial conclusion:
The candidate should not be interpreted as validated ERP or treatment delivery. Within the narrower authorized goal — a deterministic bounded Practice prototype with no generated exposure, persistence, provider or clinical claim — no material in-scope weakness remains after the safety-boundary perfection fix.

## Divergence and retained score

- Pass A: 9.2
- Pass B: 9.0
- Divergence: 0.2 — below the 0.5 investigation threshold.
- Same-session cap: 9.4.
- Lowest critical-dimension score: 9.0.

RETAINED STRICT SCORE = 9.00 / 10.

Threshold result: meets the 9.0 Gate-verification score threshold, provided all binary gates and documentation-final exact-head CI are green.

## Evidence

- LOT03 run 35376894340 — SUCCESS
- LOT04 run 35376894394 — SUCCESS
- LOT05 run 35376894323 — SUCCESS
- LOT06 run 35376894402 — SUCCESS
- LOT07 run 35376894391 — SUCCESS
- LOT07 visual artifact 10560518340
- artifact digest sha256:fef608399a5851c3486c1636a3ad23498cc085083fd67012a67367ad4714f03e
- focused Practice 12 / 12
- full suite 77 / 77
- readable before/after web captures at 360 / 390 px
- internal-state geometry captures at 360 / 390 px

## Certification boundary

This score does not authorize merge, deployment, production treatment claims, autonomous ERP, persistence, provider introduction, Core IAmina modification, or real-user data changes.