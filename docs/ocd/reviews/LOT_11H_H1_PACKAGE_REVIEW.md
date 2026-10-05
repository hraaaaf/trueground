# LOT11-H — H1 Package Specialist & Adversarial Review

Date: 2026-10-05
Repository: `hraaaaf/trueground`
Branch: `lot/11h-supervised-alpha-h1`
Package candidate reviewed: `5029de573cc0ed42892e3897f18fb6e60b2a6562`
Scope: pre-participant H1 documentation + deterministic/offline validation harness only
Status: READY FOR EXACT-HEAD VERIFICATION — REAL PARTICIPANTS REMAIN NO-GO

## GOAL

Challenge the LOT11-H H1 supervised-alpha package before any real volunteer is exposed to TrueGround.

The review asks whether the package is sufficiently bounded, auditable, privacy-minimized and explicit about the non-clinical boundary. It does not simulate a qualified clinical sign-off and does not authorize a participant, merge or deployment.

## SUCCESS

This review succeeds only if:

- every mandatory H1 preparation item from `LOT_11H_START_PROMPT.md` is represented;
- inherited LOT11-G STOP conditions are preserved without weakening;
- H2-01 and H2-03 remain explicit observation targets;
- H2-04 recurrence is an immediate STOP;
- participant-facing EN/FR wording does not introduce diagnosis, treatment, efficacy, medication, autonomous ERP or false emergency-service claims;
- the facilitator cannot legitimately interpret the protocol as permission to provoke symptoms;
- the data plan minimizes identifiers and raw sensitive content;
- the unresolved real-user provider privacy gate is exposed as a HARD NO-GO rather than assumed satisfied;
- H1→H2 progression is explicit, non-automatic and requires Product Owner authorization;
- no product runtime, Core IAmina code, production configuration, secrets or real user data are modified.

## ARTIFACTS REVIEWED

- `docs/ocd/lots/LOT_11H_H1_SUPERVISED_ALPHA_PROTOCOL.md`
- `docs/ocd/templates/LOT_11H_H1_PARTICIPANT_INFO_CONSENT.md`
- `docs/ocd/templates/LOT_11H_H1_SESSION_RECORD.md`
- `tool/lot11h/validate_h1_package.py`
- `.github/workflows/lot11h_h1_package.yml`

Canonical constraints cross-checked:
- `docs/ocd/handovers/LOT_11G_HANDOVER.md`
- `docs/ocd/handovers/LOT_11H_START_PROMPT.md`
- `docs/ocd/reviews/LOT_11G_HUMAN_REVIEW_PACK.md`
- `docs/ocd/reviews/LOT_11G_HUMAN_VALIDATION_SESSION_02.md`
- `docs/ocd/03_OCD_CLINICAL_SAFETY.md`
- `docs/ocd/05_DATA_PRIVACY_SECURITY.md`
- `docs/ocd/lots/LOT_11_CONVERSATIONAL_COMPANION_CONTRACT.md`
- `docs/ocd/lots/LOT_11_CLOUD_PROVIDER_DECISION_GATE.md`
- `docs/ocd/10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md`

## MATERIAL FINDING 1 — REAL-USER PROVIDER PRIVACY GATE

The canonical cloud-provider decision explicitly withheld authorization for real user data until the actual provider organization/configuration, retention mode, contractual/data-transfer position, subprocessors, deletion semantics and logging path are reviewed.

The H1 package therefore correctly makes real participant execution a HARD NO-GO until the actual Groq organization/project is verified, including ZDR on the inference path actually used.

Public provider documentation cannot prove the account-level setting.

Verdict: **PASS for package truthfulness / BLOCKING CONDITION for participant execution.**

## MATERIAL FINDING 2 — DEBRIEF COULD BECOME META-CHECKING

Initial H1 debrief wording was useful for product observation but could have invited a participant to reconstruct feared content or judge whether they had reacted “correctly.”

Correction applied before this review candidate:
- ask each debrief question once;
- accept a brief product-level answer;
- do not reconstruct feared content;
- do not seek certainty about the participant’s reaction;
- skip a question if it appears to increase checking, rumination or confession pressure;
- replace “good/bad person” wording with neutral “identity/moral self-checking.”

Verdict after correction: **PASS_WITH_NOTES.**

This is a useful example of H2-01 protection applying to the research process itself, not only generated model text.

## MATERIAL FINDING 3 — DATA-MINIMIZED OBSERVATION

The session record avoids raw chat and requires structured product/safety outcome codes. Participant names, contact data, diagnosis and medication lists are excluded from the H1 observation record by default.

A proposed maximum 30-day retention for structured H1 notes is deliberately not treated as approved. Storage location and retention require Product Owner/privacy approval before H1.

Verdict: **PASS_WITH_NOTES.**

## MATERIAL FINDING 4 — NON-CLINICAL BOUNDARY

The package repeatedly states that H1 is a supervised product alpha, not a clinical trial, diagnosis, treatment, medication service, autonomous ERP session, emergency service or evidence of therapeutic efficacy.

No symptom-improvement scale is used as an H1 success metric.

Verdict: **PASS.**

## MATERIAL FINDING 5 — FACILITATOR AUTHORITY

The facilitator may observe and stop the product session but may not:
- reassure on behalf of the model;
- coach a PASS;
- diagnose;
- prescribe treatment;
- provoke symptoms;
- use the model as urgent-risk authority;
- claim external contact that did not happen.

Verdict: **PASS.**

## SPECIALIST REVIEW LEDGER

| Reviewer | Verdict | Evidence / rationale |
| --- | --- | --- |
| PRODUCT_AGENT | PASS_WITH_NOTES | Scope stays H1 preparation; participant use and H2 remain separately human-authorized. |
| OCD_SAFETY_AGENT | PASS_WITH_NOTES | All inherited STOPs preserved; H2-01/H2-03 explicit; H2-04 recurrence STOP; debrief meta-checking hardened. |
| UI_UX_AGENT | PASS_WITH_NOTES | Participant flow is bounded and plain-language; actual facilitated usability remains unobserved until H1. |
| ACCESSIBILITY_AGENT | PASS_WITH_NOTES | Text materials are structurally simple and bilingual; no real participant/assistive-tech evidence exists yet. |
| DATA_PRIVACY_SECURITY_AGENT | PASS_WITH_NOTES | Strong minimization and no-raw-text rules; actual Groq account ZDR/DPA/jurisdiction and note storage/retention remain hard preflight items. |
| QA_NON_REGRESSION_AGENT | PASS_WITH_NOTES | No product runtime diff. Offline H1 workflow covers package validator, analyze, LOT11-G/F safety regression and full Flutter regression; final exact-head result is still required after this review artifact. |
| CONTENT_COPY_AGENT | PASS_WITH_NOTES | No diagnostic/treatment/efficacy promise; readability must still be observed with participants. |
| LOCALIZATION_AGENT | PASS_WITH_NOTES | EN/FR participant boundaries are semantically aligned in this review; independent/native participant interpretation is not yet evidence. |
| AI_EVAL_AGENT | NOT_APPLICABLE | No provider prompt/model/runtime behavior changed in H1 package preparation; inherited deterministic safety regression remains required. |
| ARCHITECTURE_AGENT | NOT_APPLICABLE | No runtime architecture or IAmina Core change. |
| REGULATORY_CLINICAL_REVIEW | NOT_APPLICABLE to this package scope | H1 introduces no clinical claim, diagnostic function, medication guidance, autonomous ERP or new crisis protocol. Human-qualified review remains mandatory if any such boundary is crossed later. |

No AI review above is represented as qualified clinical sign-off.

## PASS A — SEVERE EXECUTION SCORE

Method: evidence-led review of the authorized pre-participant package scope.

| Axis | Score |
| --- | ---: |
| PRODUCT / SCOPE FIDELITY | 9.6 |
| FUNCTIONAL CORRECTNESS | 9.3 |
| UI / UX FIDELITY | 9.1 |
| ACCESSIBILITY | 9.0 |
| SAFETY / OCD ANTI-COMPULSION | 9.3 |
| CONTENT / CLAIM DISCIPLINE | 9.6 |
| ARCHITECTURE / CORE-CAPSULE SEPARATION | 9.8 |
| DATA / PRIVACY / SECURITY | 9.1 |
| QA / NON-REGRESSION | 9.2 |
| EVIDENCE / REPRODUCIBILITY | 9.3 |

Overall severe score before final exact-head CI: **9.1/10**.

Reasons preventing 10/10:
1. The actual Groq organization/project ZDR setting is not repository-verifiable yet.
2. Jurisdiction-specific DPA/data-transfer/subprocessor review is not completed for a participant session.
3. Structured H1 note storage location and retention period are not yet human-approved.
4. No real participant has tested consent comprehension or facilitator flow.
5. No real participant/accessibility or assistive-technology evidence exists.
6. H2-01 and H2-03 remain inherited known observation concerns.
7. Exact-head CI must still pass after this final review artifact.

## PASS B — ADVERSARIAL SCORE

Method: separate same-session pass whose explicit purpose is to find why Pass A is too generous. It is not claimed as genuinely independent; the canonical same-session cap of 9.4 applies.

| Axis | Score |
| --- | ---: |
| PRODUCT / SCOPE FIDELITY | 9.4 |
| FUNCTIONAL CORRECTNESS | 9.1 |
| UI / UX FIDELITY | 8.9 |
| ACCESSIBILITY | 8.8 |
| SAFETY / OCD ANTI-COMPULSION | 9.0 |
| CONTENT / CLAIM DISCIPLINE | 9.4 |
| ARCHITECTURE / CORE-CAPSULE SEPARATION | 9.7 |
| DATA / PRIVACY / SECURITY | 8.9 |
| QA / NON-REGRESSION | 9.0 |
| EVIDENCE / REPRODUCIBILITY | 9.1 |

Adversarial score before final exact-head CI: **8.8/10**, driven by the accessibility critical-dimension floor.

Reasons preventing 10/10:
1. A written consent package can be semantically correct yet still be misunderstood in a live facilitated setting.
2. EN/FR same-session copy review does not prove equivalent interpretation by real participants.
3. The external-provider privacy gate depends on account/configuration evidence not present in the repository.
4. The human/local urgent escalation procedure is intentionally not invented here and still must be supplied per session jurisdiction.
5. The 1–3 person H1 sample can surface defects but cannot establish population safety or therapeutic efficacy.
6. Facilitator behavior itself can create reassurance/coaching risk; only supervised observation can test whether the script is practical.
7. H2-01 and H2-03 are known residual behavioral concerns from LOT11-G.
8. Final exact-head CI after the review artifact is not yet evidence.

Pass-B-specific finding:
- The debrief itself could have become a meta-checking surface. That material in-scope weakness was corrected before scoring this candidate.

Disagreement with Pass A:
- Pass B deducts more for accessibility and live comprehension because static Markdown cannot prove a participant can process the material under real conditions.
- Pass B also treats unresolved actual-provider configuration as a larger privacy/evidence deduction.
- No axis disagreement exceeds 0.5.

## RETAINED PRE-EXECUTION SCORE

`min(Pass A 9.1, Pass B 8.8, same-session cap 9.4, critical-dimension floors) = 8.8/10`

This score is deliberately **not** a failed product verdict. Under the strict protocol it means:

- the pre-participant package is materially strong;
- it cannot yet be called LOT11-H `VERIFIED`;
- real participant execution remains NO-GO;
- missing evidence is mainly external/live evidence that H1 itself is designed to obtain, plus the mandatory provider privacy preflight.

No score can override the provider-privacy hard gate.

## PERFECTION PASS

Remaining weaknesses were separated into:

Materially improvable now:
- debrief meta-checking risk → corrected;
- exact non-clinical consent wording → made explicit;
- deterministic package completeness → validator added;
- CI secret assertion self-match risk → corrected.

External / intentionally deferred before a participant:
- actual Groq organization ZDR/config evidence;
- jurisdiction-specific privacy/transfer review;
- human/local incident procedure;
- approved structured-note storage/retention;
- live participant comprehension/usability/accessibility;
- actual H1 behavioral observations.

## CURRENT VERDICT

**PACKAGE REVIEW: PASS_WITH_NOTES / READY FOR EXACT-HEAD OFFLINE VERIFICATION.**

**REAL PARTICIPANT H1: NO-GO.**

Real H1 may not start until all hard preflight items are satisfied and the Product Owner explicitly authorizes participant execution.
