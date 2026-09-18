# LOT 07 — Strict Double Score

Project: TrueGround OCD
Lot: LOT 07 — Practice experience + LOT07C anti-replay persistence
Scored runtime candidate: 6c3354f4bd12452db063f7be085d33f07c450556
Date: 2026-09-18

Method: two deliberately separated review passes over the same exact candidate and evidence set. Pass B is adversarial and instructed to find why Pass A is too generous. Both passes remain within the same model/session, therefore they are not genuinely independent and the governance cap of 9.4 applies.

## PASS A — Severe execution review

| Axis | Score |
|---|---:|
| PRODUCT / SCOPE FIDELITY | 9.6 |
| FUNCTIONAL CORRECTNESS | 9.5 |
| UI / UX FIDELITY | 9.2 |
| ACCESSIBILITY | 9.3 |
| SAFETY / OCD ANTI-COMPULSION | 9.4 |
| CONTENT / CLAIM DISCIPLINE | 9.4 |
| ARCHITECTURE / CORE-CAPSULE SEPARATION | 9.6 |
| DATA / PRIVACY / SECURITY | 9.3 |
| QA / NON-REGRESSION | 9.6 |
| EVIDENCE / REPRODUCIBILITY | 9.5 |

PASS A execution score: **9.4 / 10**.

Reasons preventing 10/10:
1. No independent OCD-clinician sign-off of exact micro-copy.
2. No real-user study testing whether the Practice surface itself can become ritualized.
3. The two-hour window is a product UX convention, not a clinically validated treatment interval.
4. Shared preferences is intentionally local and lightweight, not a tamper-resistant safety/security boundary.
5. Internal-state widget screenshots prove geometry but not complete production typography fidelity.
6. No physical-device manual validation is recorded.
7. English-only baseline.
8. Pass A is not an independent external review.

Material improvement over the prior candidate:
- restart no longer resets the anti-replay guard;
- expiry is exact at +2h;
- no cooldown countdown or frequency instruction is exposed;
- storage-read failure fails closed;
- persistence is limited to two technical timestamps;
- runtime/store clock are injectable for deterministic tests.

## PASS B — Adversarial review

| Axis | Score |
|---|---:|
| PRODUCT / SCOPE FIDELITY | 9.4 |
| FUNCTIONAL CORRECTNESS | 9.4 |
| UI / UX FIDELITY | 9.0 |
| ACCESSIBILITY | 9.2 |
| SAFETY / OCD ANTI-COMPULSION | 9.2 |
| CONTENT / CLAIM DISCIPLINE | 9.2 |
| ARCHITECTURE / CORE-CAPSULE SEPARATION | 9.5 |
| DATA / PRIVACY / SECURITY | 9.1 |
| QA / NON-REGRESSION | 9.5 |
| EVIDENCE / REPRODUCIBILITY | 9.3 |

PASS B adversarial score: **9.2 / 10**.

Reasons preventing 10/10:
1. The app still relies on the user to honor the urgent-safety exclusion; it cannot decide whether an external check is objectively required.
2. A two-hour anti-replay interval can be defended as UX friction but not as an evidence-based clinical dose.
3. Device clock changes can affect expiry. This is documented and acceptable only because the feature is not a security or treatment-enforcement boundary.
4. A local write failure cannot guarantee cross-restart persistence, although the current session remains guarded.
5. No real-user evidence shows that disabled cards, completion labels, or re-entry behavior will not themselves become checking cues.
6. Exact micro-copy still lacks independent specialist sign-off.
7. Pass B is adversarial but not genuinely independent.

Adversarial conclusion:
The persistence correction removes the most concrete prior product weakness without expanding TrueGround into longitudinal OCD tracking. No material in-scope defect is evident in the exact candidate. The remaining limitations are primarily clinical-validation, human-factors and external-review gaps rather than hidden implementation defects.

## Divergence and retained score

- Pass A: 9.4
- Pass B: 9.2
- Divergence: 0.2 — below the 0.5 investigation threshold.
- Same-session governance cap: 9.4.
- Lowest critical-dimension score: 9.1 (data/privacy/security), with no binary gate failure.

**RETAINED STRICT SCORE = 9.20 / 10.**

Threshold result: exceeds the 9.0 Gate-verification threshold, provided documentation-final exact-head LOT03/04/05/06/07 remains green.

## Evidence

Exact candidate 6c3354f4bd12452db063f7be085d33f07c450556:
- LOT03 run 35401819625 — SUCCESS
- LOT04 run 35401819670 — SUCCESS
- LOT05 run 35401819630 — SUCCESS
- LOT06 run 35401819649 — SUCCESS
- LOT07 run 35401819639 — SUCCESS
- focused Practice: 16 / 16
- full suite: 81 / 81
- flutter analyze: no issues
- release web build: SUCCESS
- LOT07 visual artifact: 10570517748
- artifact digest: sha256:ed9a7497b235e6b9c10212d3951537d99f7cccc44aa3fa1d92d4974f83181f64
- readable before/after web captures at 360 / 390 px
- internal-state geometry captures at 360 / 390 px
- exact boundary, restart, expiry and storage-failure tests green.

## Certification boundary

This score does not authorize merge, deployment, production treatment claims, autonomous ERP, broader persistence, analytics, provider introduction, IAmina Core modification, real-user data changes, or production configuration changes.
