# LOT 07 — HANDOVER

Project: TrueGround OCD
Repository: hraaaaf/trueground
Lot: LOT 07 — Practice experience + LOT07C anti-replay persistence
Date: 2026-09-18
Branch: lot/07-practice-experience
Base branch: lot/04-dashboard-v3-static
Base SHA: 3a453ea7d5df6f1eb696b535ab5ca7762e4b0f1c
Runtime candidate: 6c3354f4bd12452db063f7be085d33f07c450556
PR: #16 — OPEN / DRAFT
Merge authorization: NOT GRANTED
Deployment authorization: NOT GRANTED

## GOAL

Deliver a science-constrained bounded Practice experience for Pause the ritual, Practice uncertainty and Continue planned practice, while preventing immediate compulsive replay across app restart without creating a longitudinal OCD record or autonomous ERP engine.

## SUCCESS

Met on runtime candidate 6c3354f4bd12452db063f7be085d33f07c450556:
- /practice is a real bounded Practice screen;
- Pause has finite start -> active -> end states and no timer;
- Practice uncertainty has finite start -> notice -> choose -> end states;
- uncertainty stance is shown once and is not a mantra loop;
- Continue planned practice truthfully reports that no saved treatment plan exists;
- no unrestricted free text;
- no generated/personalized exposure;
- no hierarchy;
- no anxiety/distress rating;
- no streak/badge/score;
- no promise of calm, certainty or treatment efficacy;
- urgent safety/medical/emergency boundary remains visible on active guidance;
- terminal completion disables direct replay;
- anti-replay survives restart;
- anti-replay expires exactly after 2 hours;
- the two-hour duration is not shown to the user;
- no countdown, remaining-time display or frequency prescription;
- only two local UTC completion timestamps are persisted;
- storage-read failure does not open a blind replay path;
- no provider, analytics, DB, cloud sync, account history or IAmina Core change;
- 360 px, 390 px and 200% text scaling remain verified.

## PROOF

Exact runtime candidate 6c3354f4bd12452db063f7be085d33f07c450556:
- LOT03 run 35401819625 — SUCCESS;
- LOT04 run 35401819670 — SUCCESS;
- LOT05 run 35401819630 — SUCCESS;
- LOT06 run 35401819649 — SUCCESS;
- LOT07 run 35401819639 — SUCCESS;
- flutter analyze — no issues;
- focused Practice — 16 / 16 passed;
- full suite — 81 / 81 passed;
- release web build — SUCCESS;
- visual artifact 10570517748;
- artifact digest sha256:ed9a7497b235e6b9c10212d3951537d99f7cccc44aa3fa1d92d4974f83181f64.

Readable web capture checksums:
- before 360: d8adcbb9b1c11865dc04350bfa43ecefadf2b21e9b99e11404a57b4d590fe73c
- after 360: ab299a515f32b63900d092b6ccef19dc493e8ad2ab7ab7ffa28c0257a267bc6f
- before 390: f8fc554548aa62f5bbbe9db471b27e937ed679b1ff00dbff50171fb75c75bf09
- after 390: 9bd3c9801e697011d9ab9cdb76213a009b0397da3a8c217ce89cdc8e8d91810e

Internal-state evidence remains available for menu, Pause, uncertainty and planned-practice empty state at 360/390 px. Widget screenshots are treated as geometry evidence, not full production typography proof.

## Scientific / product boundary

LOT07A established the content boundary after cross-checking OCD/ERP guidance, CBT/ERP evidence, digital-CBT evidence, inhibitory-learning literature, intolerance-of-uncertainty literature and reassurance/checking research.

LOT07C adds a 2-hour anti-replay window solely as a product UX guard against immediate restart/replay. It is not represented as:
- an ERP schedule;
- a recommended practice frequency;
- a therapeutic dose;
- evidence that two hours is clinically optimal.

TrueGround still does not generate exposures, select a hierarchy, decide objective real-world safety, diagnose OCD or claim treatment efficacy.

## Persistence boundary

Approved dependency:
- `shared_preferences 2.5.5`
- `SharedPreferencesAsync`

Only these keys are permitted:
- `trueground.practice.pause.completed_at.v1`
- `trueground.practice.uncertainty.completed_at.v1`

Values are UTC ISO-8601 completion timestamps.

Explicitly not stored:
- obsession/fear text;
- reassurance requests;
- user-entered content;
- anxiety/distress scores;
- counts/streaks;
- exposure hierarchy;
- clinical notes;
- account identifiers;
- analytics;
- symptom history.

## Modifications

Runtime / architecture:
- lib/practice/practice_screen.dart
- lib/practice/practice_completion_store.dart
- lib/app/router.dart
- lib/app/trueground_app.dart
- pubspec.yaml
- pubspec.lock

Tests / CI:
- test/practice_experience_test.dart
- test/practice_visual_evidence.dart
- .github/workflows/lot07_practice_experience.yml

Scientific / safety / governance:
- docs/ocd/lots/LOT_07A_PRACTICE_SCIENTIFIC_CONTENT_CONTRACT.md
- docs/ocd/evals/LOT_07A_PRACTICE_SAFETY_EVAL_CASES.md
- docs/ocd/reviews/LOT_07A_SCIENTIFIC_ALIGNMENT.md
- docs/ocd/lots/LOT_07C_ANTI_REPLAY_PERSISTENCE_CONTRACT.md
- docs/ocd/reviews/LOT_07_SPECIALIST_REVIEW.md
- docs/ocd/reviews/LOT_07_STRICT_DOUBLE_SCORE.md
- docs/ocd/handovers/LOT_07_HANDOVER.md

## Perfection pass

Resolved material findings:
1. Incorrect initial reassurance-paper attribution — corrected.
2. Overly meta anti-compulsion copy — simplified.
3. Case-sensitive test assertion — corrected.
4. Active steps losing urgent-safety boundary — fixed.
5. Format drift — corrected.
6. Restart reset of anti-replay — fixed through narrowly scoped local persistence.
7. Persistence dependency initially conflicted with the LOT07 CI guard — guard narrowed rather than removed.
8. Store/clock injection added so restart/expiry behavior can be tested deterministically.
9. PR description updated so it no longer falsely claims “no persistence”.

No known material implementation defect remains in the authorized prototype scope.

## Specialist review

Current verdict: PASS_WITH_NOTES.

Residual notes:
- no independent OCD-clinician sign-off of exact copy;
- no real-user usability/ritualization study;
- English-only;
- no physical-device manual validation;
- device-clock manipulation is outside the UX guard threat model;
- a local platform-store write failure cannot guarantee cross-restart persistence.

## Strict double score

- PASS A — severe execution: 9.4 / 10
- PASS B — adversarial: 9.2 / 10
- divergence: 0.2
- same-session cap: 9.4
- retained strict score: **9.20 / 10**

## What was NOT done

- PR #16 not merged.
- No deployment.
- No production/data/secrets/config mutation.
- No real-user data.
- No autonomous ERP.
- No generated/personalized exposure.
- No saved treatment-plan model or symptom history.
- No provider / LLM.
- No analytics.
- No IAmina Core modification.
- No diagnosis, prescription or efficacy claim.
- No independent clinician validation.
- No real-user study.
- No French/localized clinical-copy validation.
- No LOT08 start prompt.

## Remaining risks / limitations

- Independent OCD clinician review remains required before treating the copy as clinically production-ready.
- Real-user testing remains required before broad release.
- English-only baseline remains.
- The two-hour anti-replay duration is an explicit product UX guard, not an evidence-based treatment frequency.
- Continue planned practice remains an honest degraded state because no saved treatment plan exists.
- Internal-state widget screenshots prove geometry rather than full production typography fidelity.
- Regional crisis/support and treatment-delivery policy remain outside this lot.

## State

Runtime candidate 6c3354f4bd12452db063f7be085d33f07c450556 has exact-head LOT03/04/05/06/07 SUCCESS evidence.

Because this handover/score/review update itself changes repository HEAD, Gate 7 must receive one final documentation-head CI recheck before the certification comment is refreshed.

PR #16 merge remains a HUMAN GATE.

No deployment is authorized.

## Next lot

LOT08 is NOT authorized and no LOT08 start prompt has been created.
