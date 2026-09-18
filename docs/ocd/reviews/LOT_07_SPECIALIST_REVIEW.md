# LOT 07 — Specialist Review

Project: TrueGround OCD
Lot: LOT 07 — Practice experience + LOT07C anti-replay persistence
Runtime candidate: 6c3354f4bd12452db063f7be085d33f07c450556
PR: #16
Date: 2026-09-18

## GOAL

Challenge the exact LOT07 Practice candidate from product, OCD-safety, UI/UX, accessibility, architecture, privacy, QA and copy perspectives after the addition of the approved restart-safe anti-replay guard.

## Evidence inspected

- LOT07A scientific/content contract and adversarial eval matrix.
- LOT07C anti-replay persistence contract.
- LOT07 Evidence Transfer Matrix.
- Runtime implementation in `lib/practice/` plus route/app injection.
- Exact-head LOT03 run 35401819625 — SUCCESS.
- Exact-head LOT04 run 35401819670 — SUCCESS.
- Exact-head LOT05 run 35401819630 — SUCCESS.
- Exact-head LOT06 run 35401819649 — SUCCESS.
- Exact-head LOT07 run 35401819639 — SUCCESS.
- Focused Practice suite: 16 / 16 passed.
- Full suite: 81 / 81 passed.
- `flutter analyze`: no issues.
- Release web build: SUCCESS.
- Visual artifact 10570517748.
- Artifact digest: sha256:ed9a7497b235e6b9c10212d3951537d99f7cccc44aa3fa1d92d4974f83181f64.
- Before/after web captures at 360 and 390 px.
- Internal-state geometry captures at 360 and 390 px.
- 200% text-scaling and Flutter accessibility guideline tests.
- Exact 2-hour boundary tests, restart persistence test, expiry test, and storage-read failure test.

## Evidence-transfer conclusion

The literature now closes the broad evidence gap for several underlying design principles. TrueGround does not need to reproduce established evidence for ERP/response prevention, structured digital/self-help OCD support, reassurance/checking risk, or the decision not to use immediate calm as a success criterion. Remaining human validation is narrowed to implementation-specific transfer gaps documented in docs/ocd/reviews/LOT_07_EVIDENCE_TRANSFER_MATRIX.md.

This does not establish TrueGround efficacy.

## Strongest challenge

The main residual risk is not the storage mechanism itself but behavioral interpretation: a two-hour anti-replay window is a product UX guard, not a validated ERP dose, treatment schedule, or clinically optimal interval. The implementation remains acceptable only because the duration is hidden from the user, no countdown or comeback instruction exists, and no efficacy or adherence meaning is attached to the timestamp.

## Reviewer ledger

| Reviewer | Verdict | Evidence / challenge |
|---|---|---|
| PRODUCT_AGENT | PASS | Implements the three approved Practice surfaces plus only the explicitly approved LOT07C guard. |
| OCD_SAFETY_AGENT | PASS_WITH_NOTES | No reassurance, generated exposure, hierarchy, anxiety-reduction goal or replay CTA. Restart-safe anti-replay now persists for 2h without surfacing a therapeutic schedule. Independent clinician sign-off is still absent. |
| UI_UX_AGENT | PASS_WITH_NOTES | Readable 360/390 renders remain stable. No countdown, cooldown timer or exact re-enable time is exposed. Internal screenshots remain geometry evidence rather than complete production typography proof. |
| ACCESSIBILITY_AGENT | PASS | 360/390, 200% text scaling, semantic labels and touch-target guidelines remain green. |
| CONTENT_COPY_AGENT | PASS_WITH_NOTES | Copy avoids diagnosis, certainty, efficacy claims and treatment scheduling. Exact English copy still lacks independent clinician review. |
| QA_NON_REGRESSION_AGENT | PASS | LOT03–LOT07 all SUCCESS on the exact candidate; focused 16/16 and full 81/81 suites green. |
| ARCHITECTURE_AGENT | PASS | Persistence is capsule-side behind `PracticeCompletionStore`; no IAmina Core modification and no provider/database introduced. |
| DATA_PRIVACY_SECURITY_AGENT | PASS_WITH_NOTES | Only two local UTC completion timestamps are stored. No OCD text, score, count, streak, account ID, analytics or cloud sync is introduced. Shared preferences is not a security boundary and device-clock tampering is explicitly outside the threat model. |
| AI_EVAL_AGENT | NOT_APPLICABLE | LOT07 uses no AI/provider/model-generated content. |
| LOCALIZATION_AGENT | NOT_APPLICABLE | English remains the baseline; no multilingual equivalence is claimed. |
| REGULATORY_CLINICAL_REVIEW | NOT_APPLICABLE | Current deliverable remains a non-claim prototype. Qualified human review is required before treatment-delivery or efficacy claims. |

## OCD safety findings

PASS_WITH_NOTES.

Verified safeguards:
- no unrestricted free-text therapist simulation;
- no generated/personalized exposure;
- no exposure hierarchy;
- no timer/countdown;
- no distress/anxiety rating;
- no success grading;
- no streak, badge, score or competitive count;
- no promise of immediate calm or certainty;
- no automatic replay or prominent Again action;
- uncertainty stance appears once, not as a mantra loop;
- completion now blocks direct replay across restart for exactly two hours;
- the two-hour interval is not displayed to the user;
- no “come back in two hours” or equivalent instruction;
- objective safety/medical/emergency decisions remain explicitly outside the flow;
- active unresolved-question guidance retains the safety boundary;
- Continue planned practice still does not fabricate a saved treatment plan.

Residual notes:
- no independent OCD clinician sign-off of exact micro-copy;
- no broad de novo user study is required to re-establish already-transferable OCD science; targeted TrueGround-specific usability/safety validation remains for exact wording, disabled-state checking cues, hidden 2-hour behavior, urgent-safety comprehension and localization;
- the two-hour duration is a product anti-replay convention, not a clinically validated dose;
- the app still cannot adjudicate whether a real-world check is objectively required.

## Architecture / privacy findings

PASS_WITH_NOTES.

Approved persistence is narrowly bounded:
- dependency: `shared_preferences 2.5.5`;
- modern `SharedPreferencesAsync` API;
- only two keys:
  - `trueground.practice.pause.completed_at.v1`
  - `trueground.practice.uncertainty.completed_at.v1`
- UTC ISO-8601 timestamps only;
- no symptom content or user-entered content;
- no history list;
- no count/streak;
- no analytics;
- no provider;
- no DB;
- no cloud sync introduced by TrueGround;
- no IAmina Core change.

Storage read failure fails closed for the two Practice surfaces instead of opening a blind replay path. Write failure keeps the in-memory session guard active and does not crash the app.

## QA findings

PASS.

Exact candidate 6c3354f4bd12452db063f7be085d33f07c450556:
- LOT03 35401819625 — SUCCESS
- LOT04 35401819670 — SUCCESS
- LOT05 35401819630 — SUCCESS
- LOT06 35401819649 — SUCCESS
- LOT07 35401819639 — SUCCESS
- focused Practice: 16 passed
- full suite: 81 passed
- static analysis: no issues
- release web build: SUCCESS
- visual artifact: 10570517748
- artifact digest: sha256:ed9a7497b235e6b9c10212d3951537d99f7cccc44aa3fa1d92d4974f83181f64

## Final specialist verdict

PASS_WITH_NOTES — suitable for Gate 7 verification as a bounded non-claim prototype with a narrowly scoped local anti-replay guard.

This review does not authorize merge, deployment, treatment claims, autonomous ERP, broader persistence, analytics, provider introduction, Core modification or production-data mutation.
