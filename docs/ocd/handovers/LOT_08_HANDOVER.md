# LOT 08 — HANDOVER

Project: TrueGround OCD
Repository: hraaaaf/trueground
Lot: LOT 08 — Values and Human Support
Date: 2026-09-22
Branch: lot/08-values-human-support
Base branch: lot/04-dashboard-v3-static
Certified product base: 25f08540b3f8d3bd53147f069b83e2da6f53d320
Runtime candidate before handover docs: 7a5d3fa481a3887eecf0834a44b93a1eec7a7750
PR: #17 — OPEN / DRAFT / mergeable
Merge authorization: NOT GRANTED
Deployment authorization: NOT GRANTED

> Note on handover identity: this document records the exact runtime candidate proven before handover documentation was added. Because committing the handover changes branch HEAD, the next window MUST re-read live repository state and must not infer that the runtime SHA above is still branch HEAD.

## GOAL

Deliver two bounded LOT08 surfaces:
- `Return to what matters` — a finite, user-led values-oriented flow that does not decide the user's values or become a checking/perfection tool;
- `Need a person, not an answer?` — a truthful route to real-world support that does not fake contact, persist contacts, fabricate regional resources or recruit others into repeated reassurance.

## SUCCESS

Met on runtime candidate `7a5d3fa481a3887eecf0834a44b93a1eec7a7750`:
- Values flow is finite and session-only.
- No free text.
- No LLM/provider behavior.
- No score, streak, timer, badge or completion pressure.
- No treatment, certainty, calm, safety or efficacy claim.
- One ordinary correction path is allowed once per widget lifecycle; repeated reselection is not exposed inside the same flow instance.
- Terminal state pushes action outside TrueGround rather than inviting replay.
- Trusted-person copy favors presence/practical support rather than repeated certainty.
- Care-team route is truthful about no stored contact and no contact action.
- Local professional route is generic and explicitly states TrueGround does not currently provide a local directory.
- No fabricated regional service.
- No Core IAmina modification.
- Values and Support choice cards expose a single named, actionable semantic button to assistive technologies.
- 360 px / 390 px and 200% text scaling evidence is present.

## PROOF

Exact runtime candidate `7a5d3fa481a3887eecf0834a44b93a1eec7a7750`:
- LOT03 run `35616493747` — SUCCESS
- LOT04 run `35616493711` — SUCCESS
- LOT05 run `35616493717` — SUCCESS
- LOT06 run `35616493698` — SUCCESS
- LOT07 run `35616493665` — SUCCESS
- LOT08 run `35616493655` — SUCCESS
- LOT08 artifact `10646628194`
- artifact size: 5,903,035 bytes
- artifact digest: `sha256:c76aabef325de8edc04397aad5d8436cc1180d9081a53f84dd5ad8f6ddca41cb`
- 50 PNG evidence files inspected.
- Browser capture and widget capture both present.
- Dedicated semantics tests prove named actionable buttons.
- Full Flutter/widget/accessibility regression passed.
- Release web build passed.

## Scientific boundary

Scientific alignment was checked against:
- Lee EB, 2025, PMID 40738526.
- Twohig MP et al., ACT + ERP RCT, PMID 29966992.
- 2023 ACT systematic review, PMID 37863582.
- Angelakis/Pseftogianni experiential avoidance meta-analysis, PMID 33866051.
- NICE CG31.

Product conclusion:
- evidence supports conservative values-oriented / ACT-related processes as complementary design context;
- evidence does NOT validate TrueGround as ACT;
- evidence does NOT establish superiority over ERP;
- LOT08 does NOT introduce a treatment claim, diagnosis, crisis protocol or efficacy promise.

## What was done

Runtime / UI:
- `lib/values/values_screen.dart`
- `lib/support/support_screen.dart`
- `lib/app/router.dart`
- `lib/dashboard/dashboard_v3_screen.dart`

Tests / CI / evidence:
- `test/values_support_test.dart`
- `test/values_support_visual_evidence.dart`
- `.github/workflows/lot08_values_support.yml`
- `.github/scripts/lot08_browser_capture.mjs`

Scientific / safety / governance:
- `docs/ocd/lots/LOT_08_VALUES_SUPPORT_CONTRACT.md`
- `docs/ocd/evals/LOT_08_VALUES_SUPPORT_SAFETY_EVAL_CASES.md`
- `docs/ocd/reviews/LOT_08_SCIENTIFIC_ALIGNMENT.md`

## What was NOT done

- PR #17 not merged.
- No deployment.
- No production/data/secrets/config mutation.
- No trusted-person or therapist contact persistence.
- No automatic call/SMS/message.
- No regional support directory.
- No crisis-routing claim.
- No LLM/provider behavior.
- No user-entered free text.
- No longitudinal Values history.
- No real VoiceOver/TalkBack device validation.
- No genuinely independent final specialist reviewer.
- No pre-approved Target↔Render asset for LOT08.
- LOT09 implementation not started in this window.

## Tests and non-regression

Confirmed on exact runtime candidate:
- format check PASS;
- static analysis PASS;
- LOT08 isolation/copy guard PASS;
- focused LOT08 tests PASS;
- full widget/accessibility regression PASS;
- web release build PASS;
- browser before/after and state capture PASS;
- visual evidence capture PASS;
- artifact upload PASS;
- LOT03→LOT08 exact-head non-regression 6/6 SUCCESS.

## Specialist review ledger

Required Phase 8 roles:
- PRODUCT_AGENT — PASS_WITH_NOTES
  - scope is finite and user-led; no feature creep.
- OCD_SAFETY_AGENT — PASS_WITH_NOTES
  - no reassurance/certainty promise; repeated reselection bounded; trusted-person copy avoids repeated certainty.
- UI_UX_AGENT — PASS_WITH_NOTES
  - 360/390 layouts readable and stable; no visual overflow found.
- CONTENT_COPY_AGENT — PASS_WITH_NOTES
  - no shaming, clinical promise or fake contact; local directory wording simplified.

Accessibility-sensitive UI:
- ACCESSIBILITY_AGENT — PASS_WITH_NOTES
  - 200% text scaling and semantic-button tests pass; no real VoiceOver/TalkBack device proof.
- QA_NON_REGRESSION_AGENT — PASS
  - exact-head 6/6 LOT03→LOT08 green.

Independent reviewer status:
- genuinely independent final review remains unavailable in current tool path.
- PR #17 currently has 0 reviews and 0 review threads.

## Strict double score

Pass A — severe execution review:
- overall: 9.0 / 10

Pass B — separated adversarial review, same model/session and explicitly NOT independent:
- overall: 8.7 / 10

Divergence:
- 0.3 — within protocol tolerance.

Governance caps:
- same-session review cap: 9.4.
- significant UI without real approved Target↔Render: visual-fidelity cap 7.5.

Because UI is a critical dimension for this lot, retained governed LOT08 score:
- **7.5 / 10**

Therefore canonical state:
- **NOT_VERIFIED / VERIFICATION INCOMPLETE**

This is a governance/evidence limitation, not a known blocking safety/privacy/architecture defect.

## Perfection pass

Resolved in-scope findings:
1. Technical local-support wording simplified.
2. Empty first wording commit detected and corrected rather than falsely accepted.
3. Repeated Values reselection reduced to one correction within the flow lifecycle.
4. Stale tests updated after copy change.
5. Formatting gate failure fixed exactly.
6. Named semantic buttons added for Values and Support cards.
7. Semantic activation added after double-checking `excludeSemantics`.
8. SemanticsHandle cleanup failure fixed in tests.
9. Exact-head CI rerun after final code changes.
10. Fresh visual artifact inspected after accessibility changes.

Residual limits:
- no real Target↔Render asset;
- no genuinely independent reviewer;
- no real VoiceOver/TalkBack device run;
- route recreation can restart a new Values flow;
- local support remains intentionally generic until regional validation.

## Repository truth at handover start

Before creating this handover:
- base product SHA: `25f08540b3f8d3bd53147f069b83e2da6f53d320`;
- runtime candidate: `7a5d3fa481a3887eecf0834a44b93a1eec7a7750`;
- PR #17: OPEN / DRAFT / mergeable;
- reviews: 0;
- review threads: 0;
- exact-head LOT03→LOT08: 6/6 SUCCESS;
- merge authorization: none;
- deploy authorization: none.

The act of committing this handover changes branch HEAD. The next window MUST verify live HEAD, PR, CI and divergence again.

## Current risks / blockers

No blocking runtime defect identified in the authorized prototype scope.

Verification blockers under current governance:
- missing approved real Target↔Render for significant UI;
- missing genuinely independent final specialist review;
- no real assistive-technology device validation.

These limits prevent `VERIFIED` under the canonical scoring protocol but do not by themselves authorize or prohibit merge. Merge remains a separate human gate.

## Next lot

Recommended next lot:
- **LOT 09 — Memory / Pattern Review**

Target acceptance gate:
- **GATE 9 — MEMORY_PATTERN_REVIEW_VERIFIED**

LOT09 must not infer any persistence model, memory API, schema, deletion behavior or retrieval boundary. It must inspect the existing repository and canonical data/privacy constraints first.

LOT09 implementation must start only in a fresh window using `docs/ocd/handovers/LOT_09_START_PROMPT.md`.

## State

LOT08 execution stopping point:
- **VERIFICATION INCOMPLETE**
- technically green on runtime candidate;
- handover authorized;
- merge not authorized;
- deploy not authorized.
