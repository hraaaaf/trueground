# LOT 07 — HANDOVER

Project: TrueGround OCD
Repository: hraaaaf/trueground
Lot: LOT 07 — Practice experience
Date: 2026-09-18
Branch: lot/07-practice-experience
Base branch: lot/04-dashboard-v3-static
Base SHA: 3a453ea7d5df6f1eb696b535ab5ca7762e4b0f1c
Runtime candidate: cfbfff9fc6f49d299e0b871f82048fe7e1b65973
PR: #16 — OPEN / DRAFT at handover preparation
Merge authorization: NOT GRANTED
Deployment authorization: NOT GRANTED

## GOAL

Replace the Practice placeholder with a science-constrained, bounded OCD-capsule experience for Pause the ritual, Practice uncertainty and Continue planned practice without silently creating an autonomous ERP engine.

## SUCCESS

Met on runtime candidate cfbfff9f:
- /practice is a real bounded Practice screen, not a placeholder;
- Pause has finite start -> active -> end states and no timer;
- Practice uncertainty has finite start -> notice -> choose -> end states;
- uncertainty stance is shown once and is not a mantra/repetition loop;
- Continue planned practice truthfully reports that persistence does not exist;
- no unrestricted free text;
- no generated/personalized exposure;
- no hierarchy;
- no anxiety/distress rating;
- no streaks/badges/scores;
- no promise of calm, certainty or treatment efficacy;
- no replay CTA after completion;
- same-session completion disables immediate direct replay;
- urgent safety/medical/emergency boundary remains visible on active instruction steps;
- no provider, persistence, analytics, account state, real-user data or IAmina Core modification;
- 360 px, 390 px and 200% text scaling behavior verified.

## PROOF

Exact runtime candidate cfbfff9fc6f49d299e0b871f82048fe7e1b65973:
- LOT03 run 35376894340 — SUCCESS;
- LOT04 run 35376894394 — SUCCESS;
- LOT05 run 35376894323 — SUCCESS;
- LOT06 run 35376894402 — SUCCESS;
- LOT07 run 35376894391 — SUCCESS;
- flutter analyze — no issues;
- focused Practice — 12 / 12 passed;
- full suite — 77 / 77 passed;
- release web build — SUCCESS;
- visual artifact 10560518340;
- artifact digest sha256:fef608399a5851c3486c1636a3ad23498cc085083fd67012a67367ad4714f03e.

Readable web capture checksums:
- before 360: d8adcbb9b1c11865dc04350bfa43ecefadf2b21e9b99e11404a57b4d590fe73c
- after 360: ab299a515f32b63900d092b6ccef19dc493e8ad2ab7ab7ffa28c0257a267bc6f
- before 390: f8fc554548aa62f5bbbe9db471b27e937ed679b1ff00dbff50171fb75c75bf09
- after 390: 9bd3c9801e697011d9ab9cdb76213a009b0397da3a8c217ce89cdc8e8d91810e

Internal-state geometry evidence is also versioned in the workflow artifact for menu, Pause, uncertainty and planned-practice empty state at 360 and 390 px. Flutter test-font screenshots are not treated as production typography-fidelity proof.

## Scientific boundary

LOT07A established a conservative implementation contract after cross-checking guideline, ERP/CBT, digital-CBT, intolerance-of-uncertainty, inhibitory-learning, reassurance-seeking and ritual-delay evidence.

The implementation deliberately does NOT claim that the TrueGround micro-flows are clinically validated ERP treatment. It does not generate exposures, select a hierarchy, adjudicate objective physical safety, or promise symptom/anxiety reduction.

Production treatment claims or treatment-like expansion require qualified human clinical/regulatory review and a new explicit decision.

## Modifications

Runtime / routing:
- lib/practice/practice_screen.dart
- lib/app/router.dart

Tests / CI:
- test/practice_experience_test.dart
- test/practice_visual_evidence.dart
- .github/workflows/lot07_practice_experience.yml

Scientific / safety evidence:
- docs/ocd/lots/LOT_07A_PRACTICE_SCIENTIFIC_CONTENT_CONTRACT.md
- docs/ocd/evals/LOT_07A_PRACTICE_SAFETY_EVAL_CASES.md
- docs/ocd/reviews/LOT_07A_SCIENTIFIC_ALIGNMENT.md
- docs/ocd/reviews/LOT_07_SPECIALIST_REVIEW.md
- docs/ocd/reviews/LOT_07_STRICT_DOUBLE_SCORE.md
- docs/ocd/handovers/LOT_07_HANDOVER.md

## Perfection Pass

Material findings and disposition:
1. Incorrect initial bibliographic attribution for the 2015 reassurance paper — corrected before closeout.
2. Anti-compulsion guard copy was initially too meta — simplified to calmer product language.
3. One test assertion was case-sensitive rather than behavior-sensitive — corrected without runtime change.
4. Active practice steps initially lost the urgent safety/medical boundary — fixed; boundary now persists where unresolved-question guidance is shown.
5. Dart format drift after safety assertions — exact formatter output applied.
6. Every affected test, build and screenshot proof rerun after the final runtime fix.

No known materially improvable in-scope weakness remains after the final perfection pass.

## Specialist review

See docs/ocd/reviews/LOT_07_SPECIALIST_REVIEW.md.

Summary:
- PRODUCT_AGENT — PASS
- OCD_SAFETY_AGENT — PASS_WITH_NOTES
- UI_UX_AGENT — PASS_WITH_NOTES
- ACCESSIBILITY_AGENT — PASS
- CONTENT_COPY_AGENT — PASS_WITH_NOTES
- QA_NON_REGRESSION_AGENT — PASS
- ARCHITECTURE_AGENT — PASS
- DATA_PRIVACY_SECURITY_AGENT — PASS
- AI_EVAL_AGENT — NOT_APPLICABLE
- LOCALIZATION_AGENT — NOT_APPLICABLE
- REGULATORY_CLINICAL_REVIEW — NOT_APPLICABLE for the non-claim prototype; required before treatment claims.

## Strict double score

- PASS A — Severe execution review: 9.2 / 10
- PASS B — Adversarial review: 9.0 / 10
- Independence limitation: same model/session; Pass B is adversarial but not genuinely independent.
- Same-session cap: 9.4.
- Divergence: 0.2.
- Retained strict score: 9.00 / 10.

## What was NOT done

- No merge of PR #16.
- No deployment.
- No production/data/secrets/config mutation.
- No real user data.
- No autonomous ERP.
- No generated or personalized exposure.
- No persistence or saved-practice model.
- No provider / LLM.
- No analytics.
- No IAmina Core modification.
- No diagnosis, prescription or efficacy claim.
- No independent clinician validation.
- No LOT08 start prompt.

## Remaining risks / limitations

- Exact copy has not received independent OCD-clinician sign-off.
- English-only baseline.
- No real-user usability or clinical outcome evidence.
- Same-session anti-replay state intentionally resets after app restart.
- Continue planned practice remains an honest degraded state until persistence is separately approved.
- Regional crisis/support and treatment-delivery policy remain outside this lot.
- Internal-state widget screenshots prove geometry but not production typography fidelity.

## State at handover documentation creation

Runtime candidate cfbfff9f meets the implementation and scoring criteria for Gate 7.

Final state remains VERIFICATION INCOMPLETE until this documentation-final commit itself has fresh exact-head LOT03/04/05/06/07 SUCCESS results.

After those runs complete, certification should be recorded on PR #16 without changing repository HEAD.

## Next lot

LOT08 is NOT authorized and no LOT08 start prompt has been created.

PR #16 merge remains a HUMAN GATE.

No deployment is authorized.