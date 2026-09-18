# LOT 05 — STRICT DOUBLE SCORE

Date: 2026-09-18
Candidate scored: runtime `a46db908d9f4a3f6a50024b356247d660ce60ec8`
Closeout branch before governance-only edits: `8ace7a78e732810709fe52aec268a5a821630b74`
Method: diagnostic axis scoring plus hard critical-dimension floor under the hardened doctrine. Means may be shown for context but do not certify the lot.

## PASS A — SEVERE REVIEW

| Axis | Score |
|---|---:|
| Product / scope fidelity | 9.7 |
| Functional correctness | 9.7 |
| UI / UX fidelity | 9.3 |
| Accessibility | 9.2 |
| Safety / OCD anti-compulsion | 9.4 |
| Content / claim discipline | 9.5 |
| Architecture / Core-capsule separation | 9.8 |
| Data / privacy / security | 9.4 |
| QA / non-regression | 9.7 |
| Evidence / reproducibility | 9.7 |

Diagnostic mean A: **9.54 / 10**

Critical-dimension floor A: **9.20 / 10** (Accessibility)

Retained Pass A score: **9.20 / 10**

Reasons preventing 10/10:
1. Support is still a placeholder destination, so the visible human-support escape is not a complete support capability.
2. Practice is still a placeholder; `Practice uncertainty` transitions correctly but does not deliver the later practice experience.
3. Dedicated crisis/acute-risk policy is not implemented; LOT 05 correctly avoids claiming it.
4. Gate 4 is not fully verified, even though LOT 05 avoids dependent data/provider behavior.
5. Native-device VoiceOver/TalkBack and hardware-keyboard traversal are not proven.
6. Final screenshots cover the entry state at 360/390, while later flow states are proven primarily through widget tests rather than equivalent visual artifacts.

Material finding: none requiring a LOT 05 runtime change.

## PASS B — ADVERSARIAL SECOND REVIEW

This is a deliberately separate adversarial pass with a fresh rubric emphasis. No separate external reviewer capability was used, so this is **not represented as human/agent independence**. Its explicit job was to find reasons Pass A was too generous.

| Axis | Score |
|---|---:|
| Product / scope fidelity | 9.5 |
| Functional correctness | 9.5 |
| UI / UX fidelity | 9.0 |
| Accessibility | 8.9 |
| Safety / OCD anti-compulsion | 9.1 |
| Content / claim discipline | 9.2 |
| Architecture / Core-capsule separation | 9.8 |
| Data / privacy / security | 9.1 |
| QA / non-regression | 9.5 |
| Evidence / reproducibility | 9.3 |

Diagnostic mean B: **9.29 / 10**

Critical-dimension floor B: **8.90 / 10** (Accessibility)

Retained Pass B score: **8.90 / 10**

Reasons preventing 10/10:
1. A user selecting human support lands on a placeholder; the route is correct but the end-to-end support outcome is intentionally incomplete.
2. A user selecting Practice lands on a placeholder; this weakens perceived completion even though the LOT 05 boundary is respected.
3. The genuine acute-risk case is explicitly blocked for production, so the product is not end-to-end safety complete.
4. Gate 4 remains unverified; local-only architecture contains the risk but does not remove the platform-level evidence gap.
5. Accessibility proof is automated/widget-level rather than native assistive-technology proof.
6. Only entry-state 360/390 screenshots are retained as formal visual evidence; action and completion states lack equivalent screenshot evidence.
7. The phrase `Therapist or trusted person.` is deliberately terse; it is safe and canonical but has not had independent clinical copy validation.
8. The flow permits returning to `Choose a different pattern` before completion. This is bounded and not a restart loop, but an adversarial reviewer should watch whether repeated pattern switching becomes checking behavior in later usability testing.

Material finding: no current-scope defect severe enough to require a runtime change. Items 1–5 are documented capability/evidence limits; item 8 should be observed in future behavioral/usability evaluation rather than expanded into LOT 06 logic here.

## RETAINED SCORE

`min(Pass A retained 9.20, Pass B retained 8.90, applicable caps) = 8.90 / 10`

Same-executor cap: `9.40 / 10` (not the limiting factor).

**Retained strict score: 8.90 / 10**

No averaging of the two overall scores is permitted.

## DISPOSITION

- Runtime change required by scoring: NO.
- UI recapture required by scoring: NO, because no runtime/UI file changed.
- Exact-head CI after governance/documentation changes: REQUIRED, but green CI alone cannot restore VERIFIED while the retained score remains below the mandatory `9.0/10` threshold.
- Merge authorization: NOT GRANTED.
- Deployment authorization: NOT GRANTED.


## HARDENED-DOCTRINE CONSEQUENCE

Under the hardened global-style scoring rule, LOT 05 is **NOT_VERIFIED** at `8.90 / 10`.

This is intentionally stricter than the earlier arithmetic-mean interpretation. Accessibility is a critical dimension for this lot, and a weak critical dimension may not be hidden by stronger architecture/QA scores.

To reach `VERIFIED`, LOT 05 requires a new evidence/remediation pass that legitimately lifts the retained critical floor to at least `9.0/10`, followed by fresh exact-head evidence and both scores again.
