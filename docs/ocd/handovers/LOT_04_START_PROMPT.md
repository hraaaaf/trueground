# START PROMPT — TrueGround OCD / LOT 04

HANDOVER — TrueGround OCD / LOT 03 → LOT 04

Repository: `hraaaaf/trueground`
Previous lot handover: `docs/ocd/handovers/LOT_03_HANDOVER.md`
Previous specialist review: `docs/ocd/reviews/LOT_03_SPECIALIST_REVIEW.md`
Target lot: `LOT 04 — Dashboard V3 static target`
Roadmap phase: `PHASE 3 — Dashboard V3 static target`
Acceptance gate: `GATE 3 — DASHBOARD_V3_VERIFIED`
Authorization: product owner explicitly authorized LOT 04 on 2026-09-16, after the LOT 03 handover snapshot was written.

IMPORTANT: the LOT 03 handover correctly recorded that LOT 04 had not yet been authorized at its snapshot time. This starter prompt is the later authorization record. It does NOT authorize merge, deployment, production mutation or any work beyond LOT 04.

## START HERE — READ IN ORDER

Before any modification, read these files from the CURRENT repository state:

1. `docs/ocd/handovers/LOT_03_HANDOVER.md`
2. `docs/ocd/reviews/LOT_03_SPECIALIST_REVIEW.md`
3. `docs/ocd/01_PRODUCT_NORTH_STAR.md`
4. `docs/ocd/02_OCD_PRODUCT_SPEC.md`
5. `docs/ocd/03_OCD_CLINICAL_SAFETY.md`
6. `docs/ocd/06_ROADMAP_TO_TARGET.md`
7. `docs/ocd/07_ACCEPTANCE_GATES.md`
8. `docs/ocd/08_SPECIALIST_REVIEW_MATRIX.md`
9. `docs/ocd/09_LOT_WINDOW_HANDOVER_PROTOCOL.md`
10. `docs/ocd/assets/DASHBOARD_TARGET_V3.md`
11. `docs/ocd/assets/dashboard_target_v3.jpg.b64`

Then inspect the ACTUAL LOT 03 implementation before changing it:

- `lib/app/router.dart`
- `lib/app/trueground_app.dart`
- `lib/design/app_theme.dart`
- `lib/shell/app_shell.dart`
- `lib/shell/shell_placeholder_screen.dart`
- `lib/states/app_state_panel.dart`
- current tests and workflow files.

Do not infer implementation details from this prompt when the repository can be inspected directly.

## FIRST ACTION — VERIFY REPOSITORY TRUTH

Do NOT assume any SHA, branch, PR state or CI result below is still current.

Re-check live GitHub state first:

- default branch and SHA;
- LOT 03/base branch and SHA;
- intended LOT 04 working branch and exact HEAD;
- PR #5 and exact state if it still exists;
- whether LOT 03 has been merged or remains stacked;
- ahead/behind divergence;
- mergeability;
- current CI/checks attached to the exact relevant HEAD;
- unresolved comments/review threads;
- changed-file list.

Historical LOT 03 facts to use only as cross-checks, never as assumptions:

- LOT 03 branch: `lot/03-app-shell-design-foundation`;
- PR #5 was OPEN / DRAFT / NOT MERGED at closeout;
- final closeout HEAD before this prompt was created: `54b5cd1d8d939b4621a62b5d071d2fdd789e0ddc`;
- CI run #9 / id `35087630958` was SUCCESS on that HEAD;
- final LOT 03 visual artifact id was `10443370515`;
- LOT 03 Gate 2 was technically VERIFIED;
- no deployment was performed.

If live repository state materially differs, STOP and report the difference before implementation.

## GOAL → SUCCESS → PROOF

Before modifying files, restate these three headings using evidence from the live repository.

### GOAL

Reproduce the approved Dashboard V3 static product hierarchy inside the verified LOT 03 Flutter shell, without introducing clinical behavior, AI behavior, data persistence or future-lot logic.

The target is the canonical product direction documented in `docs/ocd/assets/DASHBOARD_TARGET_V3.md`:

- `Less checking. More living.`
- `Choose your next move.`
- `Make room for uncertainty. Choose what matters.`
- primary action: `I'm stuck in a loop`;
- `Notice the urge. Pause before the ritual.`;
- `Pause the ritual`;
- `Practice uncertainty`;
- `Continue planned practice`;
- `Return to what matters`;
- `Need a person, not an answer?`;
- `Review patterns when useful`;
- bottom navigation `Home / Loop / Practice / Support / Profile`.

### SUCCESS

LOT 04 succeeds only if all of the following are demonstrated:

- the Home screen matches the canonical V3 hierarchy and calm visual density;
- existing canonical bottom navigation remains intact and functional;
- no score-heavy/checking-heavy home UI is introduced;
- no default OCD severity badge;
- no streaks;
- no daily completion pressure;
- no reassurance-resisted counter;
- no competitive exposure count;
- no prominent home anxiety/progress graph;
- the screen has no overflow/cutoff at required mobile widths;
- text scaling/accessibility does not destroy critical navigation/hierarchy;
- loading/empty/error conventions remain coherent where applicable;
- the implementation does not require production infrastructure;
- no LOT 05+ behavior is silently implemented;
- existing LOT 03 tests/non-regression remain green or are deliberately updated with equivalent/better coverage;
- mandatory specialist reviews are recorded with no unresolved `CHANGES_REQUIRED` or `BLOCKED` verdict.

### PROOF

Minimum proof required before Gate 3 can be called VERIFIED:

- exact commit SHA;
- current PR/diff evidence;
- static analysis and relevant Flutter tests;
- real rendered screenshots at **360 px** and **390 px** mobile widths;
- explicit visual comparison against the canonical Dashboard V3 target;
- accessibility checks including text scaling and critical tap targets/labels;
- non-regression of LOT 03 shell/navigation/state conventions;
- specialist review ledger;
- documented limitations/risks.

A green CI alone is NOT completion.

## CANONICAL VISUAL TARGET RULE

Decode and inspect the actual committed preview before implementing:

```bash
base64 -d docs/ocd/assets/dashboard_target_v3.jpg.b64 > dashboard_target_v3.jpg
```

Canonical target metadata currently documents:

- committed preview: `512 × 341`;
- decoded preview SHA-256: `117f1121fa2cec0d3319d5e2c93cf514ec5f40be3a05950ed7b8b89db97210a5`;
- approved source mockup originally generated at `1536 × 1024`, but the full-resolution original is not committed.

Therefore:

- match **product logic, hierarchy, visual density, spacing language and anti-grading philosophy first**;
- do not invent details that cannot be recovered from the committed reference;
- do NOT claim pixel-perfect equivalence while the full-resolution canonical source is unavailable;
- document this limitation in LOT 04 review/closeout.

If a material visual choice is genuinely ambiguous and changes product meaning, do not improvise. Present:

OPTION A
OPTION B
RECOMMENDATION
IMPACT

and wait for product-owner validation before implementing that decision.

## LOT 04 SCOPE — ALLOWED

LOT 04 may modify only what is necessary to reproduce Dashboard V3 statically and preserve the verified shell.

Allowed work includes:

- replace the current Home placeholder with the Dashboard V3 static hierarchy;
- refine/add design tokens only where required by the approved target;
- create small reusable presentation components needed by this dashboard;
- preserve and, if necessary, refine responsive behavior for 360/390 widths;
- preserve semantics/accessibility and improve them where required by the target;
- add/update widget/golden/screenshot-oriented tests appropriate to the static dashboard;
- update CI proof only where required for LOT 04 screenshots/tests;
- add LOT 04 review/handover documentation at closeout.

Prefer small, isolated, auditable changes. Do not refactor LOT 03 architecture merely because a cleaner abstraction is imaginable.

## LOT 04 SCOPE — FORBIDDEN

Do NOT implement:

- bounded Loop flow logic (LOT 05);
- unrestricted chat;
- reassurance detection or responses;
- checking/rumination classifiers;
- Compulsion Firewall;
- ERP engine or exposure planning;
- practice-session business logic;
- values flow business logic;
- human-support/crisis routing behavior;
- pattern-review/memory behavior;
- AI/model/provider integration;
- prompts or AI evaluation sets;
- auth;
- database/persistence;
- Firebase/Supabase;
- analytics/telemetry;
- real-user data;
- medical/diagnostic/treatment claims;
- IAmina Core source changes;
- Diabetes runtime/data/auth reuse;
- unrelated dependency additions;
- deployment of any kind.

No production, Vercel, TestFlight, Play Store or other external deployment is authorized.

## ACTION / ROUTING AMBIGUITY RULE

Phase 3 is a static Dashboard target. Some V3 cards visually imply future flows that belong to later phases.

Do NOT invent future clinical/product behavior just to make a card “do something”.

Existing LOT 03 canonical bottom navigation should remain functional.

For Dashboard action cards:

- if canonical docs explicitly define a safe existing route that does not implement future-lot behavior, it may be wired to that existing placeholder route;
- if routing semantics are not explicitly supported by inspected evidence, keep LOT 04 within static presentation scope and raise the ambiguity before adding behavior;
- never implement LOT 05+ flow logic as a shortcut to satisfy a tap interaction.

## MANDATORY SPECIALIST REVIEWS

From `docs/ocd/08_SPECIALIST_REVIEW_MATRIX.md`, Phase 3 requires all of:

1. `UI_UX_AGENT`
   - inspect actual rendered output, not only source;
   - compare hierarchy, density, spacing, navigation and ergonomics against Dashboard V3;
   - inspect 360 px and 390 px renders;
   - explicitly assess checking/perfectionism/self-monitoring risk.

2. `OCD_SAFETY_AGENT`
   - inspect all user-facing home copy and presentation;
   - challenge reassurance, checking, rumination, symptom-monitoring and perfectionism reinforcement;
   - verify anti-target metrics are absent;
   - do not convert this review into a clinical efficacy claim.

3. `ACCESSIBILITY_AGENT`
   - text scaling;
   - contrast;
   - labels/semantics;
   - touch targets;
   - focus/keyboard behavior where relevant;
   - critical navigation at required sizes.

4. `QA_NON_REGRESSION_AGENT`
   - navigation still works;
   - no overflow/cutoff;
   - viewport evidence;
   - exact tests/CI;
   - LOT 03 functionality remains intact;
   - stated result matches actual rendered behavior.

Because the Dashboard contains meaningful product copy, also run a `CONTENT_COPY_AGENT` adversarial pass even though it is not listed as a Phase 3 minimum. Treat any material reassurance/certainty/shaming/unsupported-medical-copy finding as blocking until resolved.

Each review must use one of:

- `PASS`
- `PASS_WITH_NOTES`
- `CHANGES_REQUIRED`
- `BLOCKED`
- `NOT_APPLICABLE` with explicit justification.

Review principle:

> Find the strongest reason this should NOT be approved.

## OCD PRODUCT SAFETY GUARDRAILS FOR THIS STATIC SCREEN

Dashboard V3 exists specifically to move away from compulsive monitoring.

Do not introduce UI that encourages repeated checking through:

- severity/status grading;
- “how am I doing?” loops;
- daily streaks;
- ritual-resistance counts;
- competitive/completion scoring;
- anxiety trend monitoring;
- prominent progress percentages;
- repeated reassurance copy;
- pressure to complete every card/task;
- “perfect day” framing.

The philosophy to preserve is:

**Less checking. More living.**

This is product direction, not a therapeutic promise.

## EXISTING LOT 03 FOUNDATION — PRESERVE

Do not rebuild the shell from scratch unless live inspection proves it necessary.

LOT 03 established:

- Flutter/Dart;
- `go_router`;
- isolated TrueGround runtime;
- canonical five-destination shell;
- design tokens/theme primitives;
- generic loading/empty/error state convention;
- accessibility baseline;
- 360/390 responsive baseline;
- 200% text-scaling coverage;
- CI format/analyze/isolation/test/build/local-smoke/visual-capture proof.

Preserve these unless the approved Dashboard target requires a small justified change.

Any new dependency is an architecture/security decision: avoid it unless truly necessary and review it before addition.

## NON-REGRESSION REQUIREMENTS

At minimum, re-run or preserve equivalent proof for:

- `dart format --output=none --set-exit-if-changed lib test`;
- `flutter analyze`;
- client-isolation guard;
- `flutter test`;
- canonical navigation behavior;
- 360 px layout;
- 390 px layout;
- 200% text scaling;
- accessibility guideline checks;
- `flutter build web --release`;
- local served-build smoke;
- rendered visual evidence.

Do not delete passing LOT 03 tests simply because the Home placeholder changes. Update only assertions invalidated by the intended Dashboard replacement and preserve the behavior each test was protecting.

## BRANCH / PR DISCIPLINE

LOT 04 must remain one coherent objective.

Before creating a branch or PR, inspect the current stacked-branch situation.

Do not assume LOT 04 should branch from `main`, from `lot/01-iamina-core-inspection`, or directly from LOT 03 until live Git history proves the correct base.

If PR #5 is not merged when the LOT 04 window begins, choose a branch/PR structure that preserves the LOT 03 dependency cleanly and explain it before writing code.

Do not merge any PR without explicit product-owner approval.

## STOP CONDITIONS

Stop and report instead of improvising if:

- repository state materially differs from the handover;
- LOT 03 evidence is no longer reproducible;
- required Dashboard V3 source/reference is missing or corrupted;
- a material visual/product choice is ambiguous;
- implementation would require crossing into LOT 05+ behavior;
- a mandatory specialist returns `CHANGES_REQUIRED` or `BLOCKED`;
- a dependency/architecture/data decision outside LOT 04 becomes necessary.

## LOT 04 CLOSEOUT

Do NOT start LOT 05 in the LOT 04 window.

At LOT 04 end, create:

- `docs/ocd/reviews/LOT_04_SPECIALIST_REVIEW.md`
- `docs/ocd/handovers/LOT_04_HANDOVER.md`
- `docs/ocd/handovers/LOT_05_START_PROMPT.md` only if LOT 05 has been explicitly authorized by the product owner.

Record exact repository truth at closeout:

- branch;
- base;
- HEAD SHA;
- PR state;
- ahead/behind;
- CI/checks on exact HEAD;
- unresolved review threads;
- screenshot/artifact identity;
- merge/deploy authorization state.

Finish the chantier with exactly these headings:

### Résultat
### Modifications
### Tests
### Non-régression
### Preuves
### Risques
### État
### Prochaine étape

## NON-AUTHORIZATIONS

LOT 04 authorization means only that LOT 04 may start in a fresh window after live verification.

It does NOT authorize:

- merge of PR #5 or any future PR;
- deployment;
- production configuration/data/schema mutation;
- IAmina Core modification;
- LOT 05 execution;
- clinical claims;
- release.

Follow throughout:

**READ → PLAN → EXECUTE → SPECIALIST REVIEW → VERIFY → HANDOVER.**
