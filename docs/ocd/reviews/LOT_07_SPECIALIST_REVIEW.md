# LOT 07 — Specialist Review

Project: TrueGround OCD
Lot: LOT 07 — Practice experience
Runtime candidate: cfbfff9fc6f49d299e0b871f82048fe7e1b65973
PR: #16
Date: 2026-09-18

## GOAL

Challenge the exact LOT07 Practice candidate from product, OCD-safety, UI/UX, accessibility, architecture, privacy, QA and copy perspectives before Gate 7 closeout.

## Evidence inspected

- LOT07A scientific/content contract and versioned adversarial eval matrix.
- Runtime implementation in lib/practice/practice_screen.dart and route integration.
- Exact-head LOT07 run 35376894391: SUCCESS.
- Exact-head LOT03 run 35376894340: SUCCESS.
- Exact-head LOT04 run 35376894394: SUCCESS.
- Exact-head LOT05 run 35376894323: SUCCESS.
- Exact-head LOT06 run 35376894402: SUCCESS.
- Focused Practice suite: 12 / 12 passed.
- Full suite: 77 / 77 passed.
- flutter analyze: no issues.
- Release web build: SUCCESS.
- Visual artifact 10560518340, digest sha256:fef608399a5851c3486c1636a3ad23498cc085083fd67012a67367ad4714f03e.
- Before/after web captures at 360 and 390 px.
- Internal state geometry captures at 360 and 390 px for menu, Pause, uncertainty and planned-practice empty state.
- 200% text-scaling and Flutter accessibility guideline tests.

## Strongest challenge

The strongest reason not to approve a more ambitious Practice feature is clinical scope creep: the evidence base supports structured ERP, but it does not validate arbitrary app-generated exposures, a universal ritual-delay timer, personalized hierarchy construction, or efficacy claims for these TrueGround micro-flows. LOT07 is acceptable only because the implementation stays deterministic, non-personalized, non-claim, bounded and explicitly excludes urgent safety/medical decisions.

## Reviewer ledger

| Reviewer | Verdict | Evidence / challenge |
|---|---|---|
| PRODUCT_AGENT | PASS | Implements exactly the three approved Practice surfaces; no adjacent feature expansion. |
| OCD_SAFETY_AGENT | PASS_WITH_NOTES | No reassurance, no generated exposure, no hierarchy, no anxiety-reduction goal, no replay CTA; active steps keep the urgent safety/medical boundary visible. Not independent clinician validation. |
| UI_UX_AGENT | PASS_WITH_NOTES | Readable before/after web renders at 360/390; calm hierarchy and reachable actions. Internal state screenshots prove geometry but Flutter test-font captures are not typography-fidelity evidence. |
| ACCESSIBILITY_AGENT | PASS | 360/390 and 200% text scaling pass; semantic headers/live regions and touch-target guidelines are exercised. |
| CONTENT_COPY_AGENT | PASS_WITH_NOTES | Copy avoids diagnosis, certainty, treatment efficacy and perfectionistic grading. Exact English copy has not received independent human clinical copy review. |
| QA_NON_REGRESSION_AGENT | PASS | LOT03/04/05/06/07 all SUCCESS on cfbfff9f; 77-test full suite green; release web build green. |
| ARCHITECTURE_AGENT | PASS | OCD Practice stays capsule-side; no IAmina Core modification, provider or new dependency. |
| DATA_PRIVACY_SECURITY_AGENT | PASS | Local ephemeral state only; no persistence, analytics, account history, provider transmission or real-user data. |
| AI_EVAL_AGENT | NOT_APPLICABLE | LOT07 uses no AI/provider/model-generated content. |
| LOCALIZATION_AGENT | NOT_APPLICABLE | English is the current baseline; LOT07 does not claim multilingual equivalence. |
| REGULATORY_CLINICAL_REVIEW | NOT_APPLICABLE | Current deliverable is a non-claim prototype. Any treatment-delivery or efficacy claim remains blocked pending qualified human clinical/regulatory review. |

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
- same-session completion disables direct replay without diagnosing the user's motive;
- objective safety/medical/emergency decisions are explicitly outside the flow;
- safety boundary remains visible while the active unresolved-question instruction is shown;
- Continue planned practice is honest about absent persistence.

Residual notes:
- no independent OCD clinician sign-off of the exact micro-copy;
- no real-user clinical outcome evidence;
- app restart resets the intentionally non-persisted anti-replay state;
- the product does not adjudicate whether a real-world check is objectively required.

These are production-readiness or scope-boundary limitations, not hidden in-scope defects in the authorized non-claim prototype.

## UI / UX findings

PASS_WITH_NOTES.

The readable headless-web before/after captures at 360 and 390 px show a meaningful improvement from the old placeholder to a clear three-choice Practice surface. No cutoff or bottom-navigation collision is visible. The 360 px internal-state captures show that adding the persistent safety note still leaves primary and exit actions visible above the navigation area.

Limitation: Flutter widget screenshots use the test font and are treated only as geometry evidence. Production typography fidelity is supported only for the readable web entry captures, not every internal state.

## Accessibility findings

PASS.

- 360 px: green.
- 390 px: green.
- 200% text scaling at both widths: green.
- Android/iOS tap target guidelines: green in focused accessibility tests.
- labeled tap target guideline: green.
- text contrast guideline: green.
- scrollable layout keeps critical actions reachable.

## Architecture / privacy findings

PASS.

No Core IAmina change. No DB. No persistence. No provider. No analytics. No account state. No new dependency. The Practice semantics remain isolated in lib/practice.

## QA findings

PASS.

Exact runtime candidate cfbfff9fc6f49d299e0b871f82048fe7e1b65973:
- LOT03 35376894340 — SUCCESS
- LOT04 35376894394 — SUCCESS
- LOT05 35376894323 — SUCCESS
- LOT06 35376894402 — SUCCESS
- LOT07 35376894391 — SUCCESS
- focused Practice: 12 passed
- full suite: 77 passed
- release web build: SUCCESS

## Final specialist verdict

PASS_WITH_NOTES — candidate is suitable for Gate 7 verification as a bounded non-claim prototype, subject to the mandatory strict double score and documentation-final exact-head recheck.

No merge or deployment is authorized by this review.