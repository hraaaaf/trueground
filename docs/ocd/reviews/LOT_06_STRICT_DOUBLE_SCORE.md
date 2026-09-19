# LOT 06 — Strict double score

Date: 2026-09-18
Implementation candidate: `60d0facb4d66f393051a5bf49987caca801911b8`
Specialist-review commit: `c62f4e82e8f2ddedd5bde450effcf64f20fcd797`

Method limitation: both passes were performed by the same model/session. Pass B is a separately executed adversarial review, not an independent reviewer. Mandatory cap: 9.4.

## PASS A — Severe execution review

| Axis | Score | Basis |
|---|---:|---|
| PRODUCT / SCOPE FIDELITY | 9.4 | Matches Phase 6 capability; no Core/provider/persistence/UI scope expansion |
| FUNCTIONAL CORRECTNESS | 9.3 | 32 focused tests; bounded session, paraphrase, false positives, repeated attempts |
| UI / UX FIDELITY | NOT_APPLICABLE | No UI delta |
| ACCESSIBILITY | NOT_APPLICABLE | No UI delta; prior UI regression remains green |
| SAFETY / OCD ANTI-COMPULSION | 9.2 | No fresh repeated certainty; cautious redirect; support preserved |
| CONTENT / CLAIM DISCIPLINE | 9.4 | No diagnosis/treatment/efficacy claim; cautious behavioral wording |
| ARCHITECTURE / CORE-CAPSULE SEPARATION | 9.4 | Capsule-only; zero Core modification; CI guard |
| DATA / PRIVACY / SECURITY | 9.4 | Session RAM only; bounded/resettable; no persistence/provider/analytics |
| QA / NON-REGRESSION | 9.4 | LOT03/04/05/06 exact candidate green; 65 full tests |
| EVIDENCE / REPRODUCIBILITY | 9.2 | Versioned eval + science review + exact run IDs + build |

EXECUTION_SCORE: **9.2 / 10**

Reasons preventing 10/10:
1. No genuinely independent reviewer or human OCD clinician validation.
2. Deterministic lexical/canonical-token matching can miss novel semantic paraphrases.
3. The adversarial corpus is synthetic rather than a representative de-identified real-user dataset.
4. The policy/evals are English-only.
5. Longitudinal repetition is intentionally absent until memory/privacy gates are verified.
6. Crisis handling is deliberately separate and not validated by LOT06.
7. No production free-text conversational entrypoint is added; this lot proves the policy capability and LOT05 handoff contract.

Material findings: all eight material in-scope findings recorded in `LOT_06_SPECIALIST_REVIEW.md` were fixed and re-proven before this pass.

## PASS B — Adversarial review

Fresh adversarial question: what would make PASS A too generous even though CI is green?

| Axis | Score | Adversarial deduction |
|---|---:|---|
| PRODUCT / SCOPE FIDELITY | 9.2 | Capability is intentionally not a live conversational integration |
| FUNCTIONAL CORRECTNESS | 9.0 | Heuristic semantics remain finite and can miss unseen distant paraphrases |
| UI / UX FIDELITY | NOT_APPLICABLE | No UI delta |
| ACCESSIBILITY | NOT_APPLICABLE | No UI delta |
| SAFETY / OCD ANTI-COMPULSION | 9.0 | Strong bounded behavior, but no independent clinical validation / representative safety corpus |
| CONTENT / CLAIM DISCIPLINE | 9.2 | Cautious copy; clinical acceptability not independently reviewed |
| ARCHITECTURE / CORE-CAPSULE SEPARATION | 9.4 | No observed boundary leak |
| DATA / PRIVACY / SECURITY | 9.3 | Ephemeral text/tokens are processed in RAM; no persistence/export |
| QA / NON-REGRESSION | 9.3 | Strong automated evidence; no real-user/runtime provider integration exists to test |
| EVIDENCE / REPRODUCIBILITY | 9.0 | Reproducible CI/evals, but synthetic corpus and same-session scoring limit certainty |

ADVERSARIAL_SCORE: **9.0 / 10**

Reasons preventing 10/10:
1. Same-session adversarial review is not independent.
2. Novel synonym chains or cross-theme semantic paraphrases can evade deterministic matching.
3. False-positive performance has not been statistically estimated on a representative corpus.
4. English-only coverage prevents claiming multilingual safety equivalence.
5. Human-support and emergency escapes are policy boundaries; downstream future behavior is not part of LOT06.
6. Audit privacy is proven structurally and by guards, not through a production observability stack because none is introduced.
7. Longitudinal behavior is untested by design because implementing it before Gate4 would violate the roadmap/privacy constraint.
8. Real-device/user interaction validation is absent because LOT06 introduces no new UI surface.

## Divergence check

PASS A: 9.2
PASS B: 9.0
Divergence: 0.2 → below the 0.5 investigation threshold.

## Perfection Pass

Material weaknesses found and fixed before scoring:
- previous-turn-only detection → bounded-session scan;
- fake context-change bypass;
- normalization/colon mismatch;
- generic verify/confirm false positives;
- unrelated certainty escalation false positive;
- overly hard redirect wording;
- missing repeated-attempt/finite-loop/session-expiry proof;
- formatter non-compliance.

Remaining items are external/deferred/out-of-scope limitations listed above; no materially improvable in-scope weakness is knowingly left unresolved.

## Retained score

Applicable cap: same model/session = 9.4.

Critical floors include OCD safety, architecture, privacy, QA/evidence.

`RETAINED_SCORE = min(9.2, 9.0, 9.4, critical dimensions) = 9.0 / 10`

RETained strict score: **9.00 / 10**

This score does not authorize merge or deployment.
