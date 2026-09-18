# LOT 05 — STRICT DOUBLE SCORE

Date: 2026-09-18
Runtime candidate scored: `9870a171dc6e227ddf1349798b2ba5a54aa2f9ec`
Base: `lot/04-dashboard-v3-static @ 2b5f29dba596f99be05b124d093aa751d3a4222d`
Method: final Perfection Pass scoring under the hardened doctrine. Diagnostic means are shown only for context; certification uses the lower critical-dimension-bounded pass.

## PERFECTION PASS REMEDIATION

The previous retained score was `8.90 / 10`, limited by the adversarial Accessibility axis.

Materially improvable in-scope weaknesses were remediated narrowly:

1. Action and completion stage changes now expose explicit `liveRegion` semantics.
2. A focused widget test proves the `Notice the pattern` and `Next move chosen` headings are both headers and live regions.
3. Flutter accessibility guidelines now run on pattern, action and completion states at both 360x800 and 390x844.
4. The 200% text-scale path now runs at both 360x800 and 390x844 through pattern → action → completion and rechecks accessibility guidelines.
5. Six state-layout captures now cover pattern/action/completion at both target widths in addition to the two production-web entry screenshots.

No clinical copy, OCD policy, provider behavior, persistence, auth, analytics, routing destination, IAmina Core logic or dependency was added by this remediation.

### Exact runtime evidence

Candidate: `9870a171dc6e227ddf1349798b2ba5a54aa2f9ec`

Exact-head workflows:
- LOT 03 Flutter shell `35345719952` → SUCCESS;
- LOT 04 Dashboard V3 `35345719962` → SUCCESS;
- LOT 05 Bounded Loop `35345719949` → SUCCESS.

LOT 05:
- format → PASS;
- analyze → PASS;
- client/provider isolation → PASS;
- focused Loop tests → 21/21 PASS;
- full Flutter suite → 33/33 PASS;
- release web build → PASS;
- local smoke → PASS;
- browser 360/390 captures → PASS;
- bounded-state visual harness → 2/2 PASS.

Artifact:
- id `10546049484`;
- digest `sha256:dc249223034c13650f4d593eba1e7be7ad48263d2829988a5f13de29f820cc4d`.

Production-web screenshots:
- `loop_360.png` → `sha256:b60ee01df8c8a20a68207db84c8696511a1d73d65e65a9474b0c027ef406684d`;
- `loop_390.png` → `sha256:877ef717c767aa797d2ffc76d05ca433ac5900cb939a8b572d149a4a9a7564ba`.

Widget state-layout captures:
- 360 action → `sha256:a5216ee34f0b9e8a09d020346ac9399ddc1629ee89b73875c1cb516c5e0f0a82`;
- 360 complete → `sha256:9b65efe992b10a32597afe04d655da06f7ea33e762df59d79983c428ad84bc33`;
- 360 pattern → `sha256:3f46b9148b9be2f4661822b0bd26bd3d520e9fc0d69413948521cb9d08065f4a`;
- 390 action → `sha256:49ba57c2914335c1fc97cde9ccf6a9ebbf2355346fc0bcd416a1fee9854787a0`;
- 390 complete → `sha256:4692bc7d371c415494c1f03123765cba418f1bfdde5e53a5295817a55a7bf4e5`;
- 390 pattern → `sha256:bbfa7e30759ed05a3c2041d38e1c16398ed002d44cf111220311ff2d4fb79074`.

The production-web 360/390 captures were downloaded and visually inspected: no overflow, cutoff or shell regression was observed. Widget captures were inspected as geometry/state evidence only because Flutter's test font is not production typography.

## PASS A — SEVERE REVIEW

| Axis | Score |
|---|---:|
| Product / scope fidelity | 9.7 |
| Functional correctness | 9.8 |
| UI / UX fidelity | 9.3 |
| Accessibility | 9.3 |
| Safety / OCD anti-compulsion | 9.4 |
| Content / claim discipline | 9.5 |
| Architecture / Core-capsule separation | 9.8 |
| Data / privacy / security | 9.4 |
| QA / non-regression | 9.8 |
| Evidence / reproducibility | 9.8 |

Diagnostic mean A: **9.58 / 10**

Critical-dimension floor A: **9.30 / 10** (UI/UX and Accessibility)

Retained Pass A score: **9.30 / 10**

Reasons preventing 10/10:
1. Native VoiceOver/TalkBack and hardware-keyboard traversal are not proven on physical devices.
2. Action/completion production-web screenshots are not retained; those states have deterministic widget layout captures plus functional/accessibility tests instead.
3. Support remains a placeholder destination; LOT 05 proves the escape route, not the later support capability.
4. Practice remains a placeholder; LOT 05 proves the transition, not later ERP/practice delivery.
5. Dedicated crisis/acute-risk policy is intentionally not implemented in this lot.
6. Gate 4 remains not fully verified, although LOT 05 avoids all capabilities that depend on it.
7. Product copy has not received independent human clinical validation.

No remaining materially improvable in-scope defect was identified in this pass.

## PASS B — ADVERSARIAL SECOND REVIEW

This is a deliberately separate adversarial pass. It was performed by the same model/session, so it is **not** represented as genuinely independent and the automatic `9.4` cap applies.

| Axis | Score |
|---|---:|
| Product / scope fidelity | 9.5 |
| Functional correctness | 9.6 |
| UI / UX fidelity | 9.0 |
| Accessibility | 9.1 |
| Safety / OCD anti-compulsion | 9.1 |
| Content / claim discipline | 9.2 |
| Architecture / Core-capsule separation | 9.8 |
| Data / privacy / security | 9.1 |
| QA / non-regression | 9.6 |
| Evidence / reproducibility | 9.4 |

Diagnostic mean B: **9.34 / 10**

Critical-dimension floor B: **9.00 / 10** (UI/UX)

Retained Pass B score: **9.00 / 10**

Reasons preventing 10/10:
1. The six added state captures are widget-render geometry evidence, not production-browser typography evidence.
2. Native assistive-technology behavior remains unproven even though semantics, guidelines, two widths and 200% text scale are now strongly covered.
3. `Choose a different pattern` remains a bounded pre-completion correction path; later usability evaluation should watch for compulsive pattern-switching without importing LOT 06 logic here.
4. Human Support and Practice destinations remain intentionally incomplete placeholders.
5. Acute-risk handling is explicitly outside LOT 05 and therefore the product is not end-to-end production safety complete.
6. Gate 4 remains unverified at platform level.
7. The terse support copy has no independent human clinical copy validation.
8. Provider failure is NOT_APPLICABLE only because no provider exists in this local-only lot; a future provider-enabled implementation would need its own degraded-state proof.

No material in-scope defect remains unfixed. Items above are out-of-scope/external limitations or non-blocking evidence uncertainty.

## SCORE DIVERGENCE

Maximum Pass A ↔ Pass B axis gap: **0.4** (Evidence / reproducibility).

No axis divergence exceeds the mandatory `0.5` investigation threshold.

## RETAINED SCORE

`min(Pass A 9.30, Pass B 9.00, same-executor cap 9.40, critical-dimension floors) = 9.00 / 10`

**Retained strict LOT score: 9.00 / 10**

No averaging is used.

## PERFECTION PASS RESULT

- Materially improvable accessibility-transition weakness: FIXED + TESTED.
- Materially improvable viewport/state accessibility evidence gap: FIXED + TESTED.
- Materially improvable later-state layout evidence gap: FIXED with six deterministic state captures.
- Out-of-scope/external limits: retained and documented, not disguised as completed capabilities.
- Runtime candidate exact-head CI: GREEN.
- Runtime scoring threshold: MET at `9.00 / 10`.
- Final documentation closeout exact-head CI: REQUIRED before the repository status is promoted to `VERIFIED`.

## DISPOSITION

Status at this scoring commit:

`READY_FOR_FINAL_EXACT_HEAD_VERIFICATION — RETAINED 9.00/10`

Merge authorization: NOT GRANTED.
Deployment authorization: NOT GRANTED.
LOT 06 authorization: NOT GRANTED.
