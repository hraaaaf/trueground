# LOT 08 — Final Strict Double Score

Project: TrueGround OCD
Final scored runtime candidate: `7a5d3fa481a3887eecf0834a44b93a1eec7a7750`
Documentation/non-regression head before this record: `df104e3f30bbe8a97c75d574ee434db814c0faaa`
Date: 2026-09-22

## Evidence basis

- exact runtime candidate LOT03→LOT08 CI: 6/6 SUCCESS;
- exact documentation head LOT03→LOT08 CI: 6/6 SUCCESS;
- LOT08 artifact `10646628194`, digest `sha256:c76aabef325de8edc04397aad5d8436cc1180d9081a53f84dd5ad8f6ddca41cb`;
- 50 PNG runtime evidence files inspected;
- dedicated semantic button tests PASS;
- 360/390 + 200% text scaling evidence PASS;
- product-owner-approved Target↔Render reference across 14 states;
- scientific alignment review;
- no Core IAmina change;
- no persistence/provider/LLM/free-text introduced.

## Pass A — severe execution review

Scorer: execution reviewer, same session.

| Axis | Score |
|---|---:|
| PRODUCT / SCOPE FIDELITY | 9.4 |
| FUNCTIONAL CORRECTNESS | 9.4 |
| UI / UX FIDELITY | 9.2 |
| ACCESSIBILITY | 9.1 |
| SAFETY / OCD ANTI-COMPULSION | 9.2 |
| CONTENT / CLAIM DISCIPLINE | 9.2 |
| ARCHITECTURE / CORE-CAPSULE SEPARATION | 9.7 |
| DATA / PRIVACY / SECURITY | 9.7 |
| QA / NON-REGRESSION | 9.8 |
| EVIDENCE / REPRODUCIBILITY | 9.5 |

Overall Pass A: **9.2 / 10**

Reasons preventing 10/10:
1. no physical-device VoiceOver/TalkBack session;
2. no genuinely independent final reviewer response was obtained despite GitHub Copilot review request;
3. target reference was approved during certification rather than existing before implementation;
4. the one-pass Values correction resets after full route/widget recreation;
5. local professional support remains intentionally generic until region-specific validation;
6. English-only baseline.

## Pass B — separated adversarial review

Method: separate adversarial pass by same model/session because a genuinely independent reviewer did not materialize. This limitation is explicitly allowed by the canonical protocol and activates the 9.4 same-session cap.

| Axis | Score |
|---|---:|
| PRODUCT / SCOPE FIDELITY | 9.2 |
| FUNCTIONAL CORRECTNESS | 9.2 |
| UI / UX FIDELITY | 9.0 |
| ACCESSIBILITY | 9.0 |
| SAFETY / OCD ANTI-COMPULSION | 9.0 |
| CONTENT / CLAIM DISCIPLINE | 9.1 |
| ARCHITECTURE / CORE-CAPSULE SEPARATION | 9.6 |
| DATA / PRIVACY / SECURITY | 9.6 |
| QA / NON-REGRESSION | 9.7 |
| EVIDENCE / REPRODUCIBILITY | 9.3 |

Overall Pass B: **9.0 / 10**

Reasons preventing 10/10:
1. assistive-technology behavior is proven by semantics tests, not by a real VoiceOver/TalkBack device run;
2. no external independent reviewer verdict exists;
3. Target↔Render is a certification-time approved reference rather than a pre-implementation design artifact;
4. route re-entry permits a fresh Values flow, so anti-reselection is bounded per flow instance rather than globally persisted;
5. generic support lookup gives no regional provider/action until a separately validated directory exists;
6. scientific evidence supports the conservative direction, not clinical efficacy of this exact digital interaction.

## Divergence

Pass A 9.2 vs Pass B 9.0.
Divergence: **0.2** — within protocol tolerance.

## Caps

- same person/model/session cap: 9.4;
- missing independent reviewer: no sub-9.0 cap in the canonical protocol when a separated adversarial pass is used and the limitation is disclosed;
- Target↔Render cap: **not applicable after explicit product-owner approval of the LOT08 target and 14-state comparison**;
- no red required gate;
- no demonstrated regression;
- no blocking safety/privacy/security/data/clinical issue.

## Retained score

`RETAINED_SCORE = min(9.2, 9.0, 9.4, critical-dimension floors)`

All applicable critical-dimension floors are at least 9.0.

**Final retained LOT08 score: 9.0 / 10**

## Perfection Pass

No remaining materially improvable in-scope weakness was identified after:
- copy remediation;
- bounded correction remediation;
- semantic-accessibility remediation;
- exact-head CI reruns;
- fresh artifact inspection;
- product-owner target approval;
- full Target↔Render review.

Residual items are evidence/production-readiness limits, not unresolved in-scope implementation defects.

## Verdict

Under `docs/ocd/10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md`, LOT08 now meets the `>= 9.0` threshold with:
- both scoring passes;
- exact-head green evidence;
- specialist PASS/PASS_WITH_NOTES ledger;
- no blocker;
- Perfection Pass complete;
- score divergence resolved;
- approved visual target comparison.

**Certification verdict: VERIFIED — GATE 8 VALUES_SUPPORT_VERIFIED.**

This certification does **not** authorize merge or deployment.
