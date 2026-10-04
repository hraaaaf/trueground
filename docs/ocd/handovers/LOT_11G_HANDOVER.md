# HANDOVER — TrueGround OCD / LOT11-G → LOT11-H

Date: 2026-10-04
Status: READY WITH CONDITIONS

## Identity

- Repository: `hraaaaf/trueground`
- Lot closed: `LOT11-G — Pre-Human Validation Gate`
- Next approved lot: `LOT11-H — Supervised Alpha / H1`
- Base branch: `main`
- Base SHA at handover: `e1cdd5485e80c3c8bb4f7f5e3bdf695709111d61`
- Working branch: `lot/11g-prehuman-validation`
- HEAD before this handover artifact: `0712054bd987865bb4ccc550c757b31953c98546`
- Runtime safety candidate proven before documentation closeout: `208913d7c1cf3ce3d8ad821b3c0fe9ce22e17dc7`
- PR: none
- Divergence before handover: working branch ahead 856 / behind 0 versus `main`
- Merge authorization: NOT AUTHORIZED
- Deployment authorization: NOT AUTHORIZED

## GOAL

Determine with reproducible evidence whether the current Bounded Conversational Companion is robust enough to proceed to supervised human validation without adding product features.

## SUCCESS

- [x] G1 Provider Reliability & Observability validated with sanitized/fail-closed behavior.
- [x] G2 pre-human adversarial coverage executed with exact production routing/provider/output-guard path where applicable.
- [x] G3 anti-dependency UX and responsive/200% evidence validated.
- [x] G4 human/clinical review package prepared.
- [x] H2 confession/reconfession BLOCKER hardened and retested.
- [x] Exact-head offline gate green after final LOT11-G documentation update.
- [x] No new therapeutic/clinical efficacy claim introduced.
- [ ] Qualified OCD clinical review completed — intentionally deferred to supervised validation; this is a condition, not a LOT11-G claim.

## PROOF

- Runtime exact-head offline: run `37234403037` — SUCCESS.
- Runtime H2-04 live retest: run `37234403039` — SUCCESS; 1 provider call; provider compliance PASS; guard violation none; system safety PASS.
- Final documentation exact-head offline: run `37239243891` — SUCCESS.
- G3 evidence includes required widths and 200% text checks.
- Canonical roadmap records `READY WITH CONDITIONS — PRE-HUMAN VALIDATION GATE PASSED`.

## What was done

- Exercised provider/system safety separately.
- Hardened confession/reconfession handling after independent adversarial review reopened H2-04.
- Preserved deterministic safety authority before and after the provider.
- Added context-aware output-guard coverage for deferred sharing decisions in confession context, with benign controls outside that context.
- Hardened provider instructions against present/deferred reconfession permission.
- Preserved anti-dependency constraints and fail-closed behavior.
- Recorded H2 human/adversarial verdict history rather than hiding superseded findings.
- Re-ran exact-head offline/non-regression/visual evidence after changes.

## What was NOT done

- No merge.
- No deployment.
- No production/user-data/database/secret mutation.
- No clinical efficacy validation.
- No diagnosis/treatment/ERP-autonomy claim.
- No unsupervised patient use authorization.
- No real participant H1 session.
- H2-01 moral/self-checking wording remains a CONCERN.
- H2-03 explanation-before-pivot wording remains a CONCERN.

## Files materially touched during final hardening/closeout

- `api/conversation.mjs`
- `lib/conversation/conversation_output_guard.dart`
- `test/lot11g_pre_human_adversarial_test.dart`
- `test/lot11g_live_provider_system_test.dart`
- `tool/lot11g/server_contract_characterization.mjs`
- `docs/ocd/reviews/LOT_11G_HUMAN_VALIDATION_SESSION_02.md`
- LOT11-G workflow/trigger cleanup files used to bound live-provider quota.

## Tests and non-regression

Final exact-head gate `37239243891` passed:
- dart format check;
- Node syntax;
- Flutter analyze;
- server contract characterization;
- frozen LOT11-G adversarial corpus;
- LOT11-G anti-dependency UX gate;
- LOT11-D/E/F safety regression;
- full Flutter regression;
- G3 before/after visual evidence;
- required 360/390/430/768/1280 evidence;
- EN 360 and FR 430 at 200% text;
- offline gate provider-secret absence.

Live provider proof was intentionally minimal because of quota. No automatic retries.

## Specialist review ledger

| Specialist | Verdict | Evidence | Notes |
| --- | --- | --- | --- |
| PRODUCT_AGENT | PASS_WITH_NOTES | Canonical LOT11-G exit | Proceed only to supervised validation |
| OCD_SAFETY_AGENT | PASS_WITH_NOTES | H2 adversarial + H2-04 hardening | H2-01/H2-03 remain observation targets |
| AI_EVAL_AGENT | PASS | offline corpus + final targeted live retest | Provider and system safety scored separately |
| UI_UX_AGENT | PASS_WITH_NOTES | G3 anti-dependency evidence | Human observation still required |
| ACCESSIBILITY_AGENT | PASS_WITH_NOTES | responsive + 200% evidence | Real-device/human accessibility remains future evidence |
| DATA_PRIVACY_SECURITY_AGENT | PASS_WITH_NOTES | secret-offline + no raw-chat persistence contract | Real participant data handling must remain minimized |
| QA_NON_REGRESSION_AGENT | PASS | run `37239243891` | Exact-head green |
| CONTENT_COPY_AGENT | PASS_WITH_NOTES | H2 review | Watch H2-01/H2-03 |
| LOCALIZATION_AGENT | PASS_WITH_NOTES | EN/FR gate coverage | Human semantic observation remains required |
| REGULATORY_CLINICAL_REVIEW | NOT_APPLICABLE to LOT11-G certification | no new clinical claim | Qualified OCD review is a LOT11-H condition |

## Current risks / blockers

No known LOT11-G STOP/BLOCKER remains.

Conditions carried into LOT11-H:
1. H2-01 moral/self-checking wording is an explicit observation target.
2. H2-03 explanation-before-pivot wording is an explicit observation target.
3. Any recurrence of reassurance/checking/rumination/confession escalation, fail-open behavior, EN/FR safety divergence, false human action, raw sensitive logging, unsupported diagnosis/medication/ERP/treatment claim triggers STOP.
4. Qualified OCD clinical review remains required before any clinical/treatment claim.
5. Main is far behind the working branch; no merge strategy is authorized by this handover.

## Strict scoring status

LOT11-G has strong execution evidence and an independent adversarial safety review that materially changed the result (H2-04 was reopened, hardened, and re-proven). However the canonical strict-scoring protocol requires two explicit multi-axis scorecards and a retained lower score in the handover before the lot can be called `VERIFIED`.

Therefore this handover does **not** overclaim `VERIFIED`.

Closeout state: `READY WITH CONDITIONS / PRE-HUMAN GATE PASSED`.
Strict-scoring certification state: `VERIFICATION INCOMPLETE` until the two formal scorecards are recorded.

## Repository truth at handover

- Base `main`: `e1cdd5485e80c3c8bb4f7f5e3bdf695709111d61`
- Working branch before handover commit: `0712054bd987865bb4ccc550c757b31953c98546`
- Ahead/behind: 856 / 0
- Open PR: none
- Latest exact-head offline gate before handover artifact: `37239243891` SUCCESS
- Merge: NOT AUTHORIZED
- Deploy: NOT AUTHORIZED

These values are a snapshot and MUST be rechecked before LOT11-H execution.

## Next lot

`LOT11-H — Supervised Alpha / H1`

H1 scope:
- 1–3 adult volunteers;
- accompanied/supervised sessions;
- qualitative observation;
- no interpretation as therapeutic efficacy evidence;
- STOP criteria inherited from LOT11-G;
- no real participant session until protocol, consent/boundaries, data handling, observation rubric and human oversight are ready and explicitly authorized.

## Required next-window artifact

`docs/ocd/handovers/LOT_11H_START_PROMPT.md`
