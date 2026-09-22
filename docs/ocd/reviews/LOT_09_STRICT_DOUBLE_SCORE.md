# LOT 09 — Final Strict Double Score

Project: TrueGround OCD
Runtime candidate: `f2e523002f5e8c3bec5aefcabdc7b03539235317`
Certification documentation head will be the commit containing this record.
Date: 2026-09-22

## Evidence basis

- exact runtime candidate LOT03→LOT09 CI: 7/7 SUCCESS;
- LOT09 run `35735170514`: SUCCESS;
- LOT09 artifact `10696909997`;
- artifact digest: `sha256:4a4c8ea95f1edb4137a080c0ef4a38d6319eec039953982dc9aa4f29bfd0177b`;
- 6 exact-head PNG evidence files inspected;
- 360/390 + 200% text-scaling evidence PASS;
- focused storage/retrieval/retention/deletion/degraded-memory tests PASS;
- full Flutter regression PASS;
- release web build PASS;
- no IAmina Core change;
- no AI/LLM/provider path;
- no free-text, intrusive-thought or reassurance-content persistence.

## Pass A — severe execution review

Scorer: execution reviewer, same session.

| Axis | Score |
|---|---:|
| PRODUCT / SCOPE FIDELITY | 9.3 |
| FUNCTIONAL CORRECTNESS | 9.3 |
| UI / UX FIDELITY | 9.1 |
| ACCESSIBILITY | 9.0 |
| SAFETY / OCD ANTI-COMPULSION | 9.2 |
| CONTENT / CLAIM DISCIPLINE | 9.3 |
| ARCHITECTURE / CORE-CAPSULE SEPARATION | 9.8 |
| DATA / PRIVACY / SECURITY | 9.0 |
| QA / NON-REGRESSION | 9.8 |
| EVIDENCE / REPRODUCIBILITY | 9.5 |

Overall Pass A: **9.2 / 10**

Reasons preventing 10/10:
1. no physical-device VoiceOver/TalkBack session;
2. no genuinely independent external reviewer response;
3. no identity/auth exists, so the implementation is intentionally single-profile/device-local and cannot claim cross-user isolation;
4. repeated reopening of the bounded review remains technically possible;
5. retention is intentionally local-product policy, not an account-level privacy lifecycle;
6. English-only baseline.

## Pass B — separated adversarial review

Method: separate adversarial pass by the same model/session because no genuinely independent reviewer materialized. This activates the same-session cap used by the canonical scoring protocol.

Adversarial questions applied:
- Can the screen become a checking ritual?
- Can it be used as reassurance about improvement/worsening?
- Can missing history be misrepresented?
- Can stored content drift into sensitive narrative memory?
- Can deletion be ambiguous or incomplete?
- Can route wiring regress existing LOT08 support?
- Can 200% text break controls?
- Can a false multi-user privacy claim be inferred?

Findings:
- no counts/dates/streaks/trends/severity/better-worse/prediction are exposed;
- no refresh/check-again loop exists;
- empty/unavailable states refuse to infer or pretend;
- stored payload remains activity-kind + timestamp only;
- per-type and delete-all behavior is explicit;
- a real Support routing regression and a real 200% overflow were discovered during adversarial verification and fixed before scoring;
- exact-head 7/7 CI proves the remediated routing and regression state;
- cross-user isolation remains unclaimed because there is no identity/auth boundary.

| Axis | Score |
|---|---:|
| PRODUCT / SCOPE FIDELITY | 9.1 |
| FUNCTIONAL CORRECTNESS | 9.1 |
| UI / UX FIDELITY | 9.0 |
| ACCESSIBILITY | 9.0 |
| SAFETY / OCD ANTI-COMPULSION | 9.0 |
| CONTENT / CLAIM DISCIPLINE | 9.2 |
| ARCHITECTURE / CORE-CAPSULE SEPARATION | 9.7 |
| DATA / PRIVACY / SECURITY | 9.0 |
| QA / NON-REGRESSION | 9.7 |
| EVIDENCE / REPRODUCIBILITY | 9.4 |

Overall Pass B: **9.0 / 10**

Reasons preventing 10/10:
1. assistive-technology evidence is automated, not a physical-device screen-reader session;
2. no independent reviewer verdict exists;
3. no authenticated per-user storage boundary exists in this prototype;
4. device-local review can be reopened repeatedly even though the surface gives no new score, certainty or variable reward;
5. the evidence supports a conservative bounded-review design, not clinical efficacy of the exact interaction.

## Divergence

Pass A 9.2 vs Pass B 9.0.
Divergence: **0.2** — within protocol tolerance.

## Caps

- same model/session cap: 9.4;
- no red required gate on the runtime candidate;
- no demonstrated regression remains after routing remediation;
- no blocking safety/privacy/security/data/clinical claim issue;
- DATA / PRIVACY / SECURITY is held at 9.0 because cross-user isolation is explicitly not available.

## Retained score

`RETAINED_SCORE = min(9.2, 9.0, 9.4, critical-dimension floors)`

All applicable critical-dimension floors are at least 9.0.

**Final retained LOT09 score: 9.0 / 10**

## Perfection Pass

Material in-scope weaknesses found during verification were remediated:
- Dart formatter mismatch;
- 200% horizontal overflow in pattern cards;
- off-screen/non-deterministic interaction tests;
- ambiguous per-type test targeting;
- Support shell routing regression caused by placing `/patterns` in the Support branch.

Residual items are prototype/evidence limitations, not unresolved in-scope implementation defects:
- no auth/multi-user boundary;
- no physical-device screen-reader run;
- no external independent reviewer;
- English-only baseline.

## Verdict

LOT09 meets the strict `>= 9.0` threshold on the runtime candidate with:
- both scoring passes;
- exact-head runtime CI green;
- specialist PASS/PASS_WITH_NOTES ledger;
- no blocker;
- Perfection Pass complete;
- score divergence within tolerance;
- exact-head visual evidence inspected.

**Runtime certification candidate: VERIFIED — GATE 9 MEMORY_PATTERN_REVIEW_VERIFIED.**

Final repository certification still requires the documentation commit containing this record to receive exact-head green CI.

This certification does **not** authorize merge or deployment.
