# LOT 06 — HANDOVER

Project: TrueGround OCD
Repository: hraaaaf/trueground
Lot: LOT 06 — Compulsion Firewall
Date: 2026-09-18
Branch: `lot/06-compulsion-firewall`
Base branch: `lot/04-dashboard-v3-static`
Base SHA: `9dd32fe57298eee0c543d298fa36df9f05cebf48`
Implementation candidate: `60d0facb4d66f393051a5bf49987caca801911b8`
Repository HEAD immediately before this handover commit: `e2fa58615184b53d2b72f3447f53ad6b927bc798`
PR: #14 — OPEN / DRAFT / MERGEABLE at last inspection
Merge authorization: NOT GRANTED
Deployment authorization: NOT GRANTED

## GOAL

Build an OCD-capsule Compulsion Firewall that recognizes high-confidence session-level repetition associated with reassurance seeking, checking, rumination, certainty escalation and reconfession, then redirects without supplying fresh certainty or claiming to diagnose intent.

## SUCCESS

Met on the implementation candidate:
- exact repetition handled;
- close and distant paraphrase cases handled;
- non-adjacent repetition across a bounded session handled;
- certainty escalation handled;
- repeated checking, rumination and reconfession handled;
- repeated attempts remain bounded;
- false-positive cases for correction, new topic, accessibility, UI error, support, emergency and ordinary technical verification remain available;
- reset and bounded expiry exist;
- no longitudinal inference;
- redirect contract reaches the existing LOT05 bounded Loop;
- no fresh reassurance text is returned by the firewall;
- no diagnosis/treatment/efficacy claim;
- no provider, persistence, analytics, new dependency or IAmina Core change.

## PROOF

Implementation candidate `60d0fac...`:
- LOT03 run 35351151790 — SUCCESS;
- LOT04 run 35351151750 — SUCCESS;
- LOT05 run 35351151856 — SUCCESS;
- LOT06 run 35351151764 — SUCCESS;
- format: 19 files, 0 changed;
- static analysis: no issues;
- focused LOT06: 32 tests passed;
- full suite: 65 tests passed;
- release web build: SUCCESS.

Versioned evidence:
- `docs/ocd/evals/LOT_06_COMPULSION_FIREWALL_EVAL_CASES.md`;
- `docs/ocd/reviews/LOT_06_SCIENTIFIC_ALIGNMENT.md`;
- `docs/ocd/reviews/LOT_06_SPECIALIST_REVIEW.md`;
- `docs/ocd/reviews/LOT_06_STRICT_DOUBLE_SCORE.md`.

## Scientific alignment

Cross-source evidence reviewed includes:
- NICE CG31;
- Parrish & Radomsky (2010), PMID 19939622;
- Starcevic et al. (2012), PMID 22776755;
- Halldorsson et al. (2015), PMID 26433701;
- Halldorsson & Salkovskis (2023), DOI 10.1016/j.jocrd.2023.100783;
- Causier & Salkovskis (2025), PMID 39232282;
- Strauss et al. (2020), PMID 31901881;
- Hermida-Barros et al. (2024), PMID 38621516;
- Golden & Aboujaoude (2026), DOI 10.1038/s41746-026-02531-7;
- Occhino-Moede et al. (2026), PMID 41643128.

Conclusion is deliberately narrow: evidence supports avoiding repeated fresh certainty and preserving supportive alternatives; it does NOT clinically validate this classifier or establish treatment efficacy.

## What was done

- Added deterministic, local `CompulsionFirewallSession`.
- Added bounded in-memory session context.
- Added cautious internal reason codes.
- Added exact/paraphrase/session-history detection.
- Added false-positive protection and explicit escape boundaries.
- Added LOT05 `/loop` handoff contract.
- Added privacy/isolation CI guards.
- Added versioned adversarial eval set.
- Added scientific alignment review.
- Completed Perfection Pass.
- Completed mandatory specialist review.
- Completed mandatory strict double scoring.

## What was NOT done

- No merge.
- No deployment.
- No production mutation.
- No real user data.
- No DB, auth, secrets or provider changes.
- No longitudinal memory.
- No new UI.
- No crisis-policy implementation.
- No autonomous ERP.
- No IAmina Core modification.
- No claim that the classifier diagnoses OCD/compulsion.
- No independent clinician validation.
- No multilingual safety equivalence claim.

## Files changed

- `.github/workflows/lot06_compulsion_firewall.yml`
- `docs/ocd/evals/LOT_06_COMPULSION_FIREWALL_EVAL_CASES.md`
- `docs/ocd/reviews/LOT_06_SCIENTIFIC_ALIGNMENT.md`
- `docs/ocd/reviews/LOT_06_SPECIALIST_REVIEW.md`
- `docs/ocd/reviews/LOT_06_STRICT_DOUBLE_SCORE.md`
- `lib/compulsion_firewall/compulsion_firewall.dart`
- `test/compulsion_firewall_test.dart`
- `docs/ocd/handovers/LOT_06_HANDOVER.md`

## Perfection Pass findings fixed

1. Previous-turn-only matching → bounded-session scan.
2. `New question:` bypass → hardened.
3. Colon-normalization mismatch → fixed.
4. Generic check/verify/confirm false positives → narrowed.
5. Unrelated certainty escalation false positive → topic evidence required.
6. Hard refusal tone → supportive bounded copy.
7. Multiple-attempt / finite-loop / session-expiry evidence → explicit tests.
8. Dart formatting → exact formatter output applied.

## Specialist review ledger

| Role | Verdict | Evidence |
|---|---|---|
| AI_EVAL_AGENT | PASS_WITH_NOTES | 32 focused adversarial tests |
| OCD_SAFETY_AGENT | PASS_WITH_NOTES | scientific alignment + no fresh certainty/diagnosis |
| ARCHITECTURE_AGENT | PASS | capsule-only, no Core change |
| QA_NON_REGRESSION_AGENT | PASS | LOT03/04/05/06 + 65 full tests |
| DATA_PRIVACY_SECURITY_AGENT | PASS_WITH_NOTES | bounded RAM, no persistence/provider/analytics |
| CONTENT_COPY_AGENT | PASS_WITH_NOTES | cautious non-shaming redirect |
| ACCESSIBILITY_AGENT | NOT_APPLICABLE new UI | no UI delta; prior UI regressions green |

## Strict double score

PASS A — Severe execution review: **9.2 / 10**
PASS B — Adversarial review: **9.0 / 10**

Independence limitation: same model/session; Pass B is adversarial but not independent.
Same-session cap: 9.4.
Divergence: 0.2.

Retained strict score: **9.00 / 10**.

## Current risks / limitations

- deterministic heuristics can miss unseen semantic paraphrases;
- English-only baseline;
- synthetic adversarial corpus, not representative real-user data;
- no independent OCD clinician signoff;
- no longitudinal memory until Gate4/memory/privacy rules permit it;
- human-support/crisis downstream policy is outside LOT06;
- no new production conversational entrypoint is introduced.

These are deferred/external or scope-boundary limitations; no known materially improvable in-scope weakness remains after the Perfection Pass.

## Repository truth before handover commit

- base: `lot/04-dashboard-v3-static @ 9dd32fe57298eee0c543d298fa36df9f05cebf48`;
- branch: `lot/06-compulsion-firewall`;
- pre-handover HEAD: `e2fa58615184b53d2b72f3447f53ad6b927bc798`;
- divergence: ahead 26 / behind 0;
- PR #14: open, draft, mergeable;
- merged: false;
- deployed: false.

After this handover commit, repository truth and exact-head CI must be rechecked before LOT06 can be called VERIFIED.

## Next lot

Roadmap next phase: PHASE 7 — Practice experience.

LOT07 execution is NOT authorized by the current instruction. Do not create or execute a LOT07 start prompt until the product owner explicitly authorizes that next lot.

## State at handover creation

`VERIFICATION INCOMPLETE` until the documentation-final exact HEAD re-runs LOT03/LOT04/LOT05/LOT06 successfully.

No merge or deployment is authorized.


---

## POST-MERGE ADDENDUM — 2026-09-18

Product-owner merge authorization was subsequently granted for PR #14.

Repository truth after merge:

- PR #14: CLOSED / MERGED;
- merged candidate HEAD: `64872299233576fdefd9134199874a7365e16e0c`;
- merge commit exact: `8015e0dbe46f9b51b67ce0b43affec4687166823`;
- merge target: `lot/04-dashboard-v3-static`;
- deployment: NOT PERFORMED;
- production/data/secrets mutation: NOT PERFORMED.

Final pre-merge exact-head certification on `6487229...`:

- LOT03 run `35351807318` → SUCCESS;
- LOT04 run `35351807313` → SUCCESS;
- LOT05 run `35351807294` → SUCCESS;
- LOT06 run `35351807405` → SUCCESS;
- retained strict score: `9.00 / 10`;
- Gate: `GATE 6 — COMPULSION_FIREWALL_VERIFIED`.

Post-merge workflows were automatically triggered on merge commit `8015e0d...` and must be rechecked live by the LOT07 window. Their state must never be inferred from this addendum.

LOT07 is the next roadmap phase: `PHASE 7 — Practice experience`.

This addendum authorizes preparation of the LOT07 starter prompt only. It does not authorize merge of this documentation branch, deployment, production mutation, or any LOT07 implementation by itself.
