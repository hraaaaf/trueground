HANDOVER — TrueGround OCD / LOT 09 → LOT 10

Repository: hraaaaf/trueground
Previous lot handover: docs/ocd/handovers/LOT_09_HANDOVER.md
Target lot: LOT 10 — System Safety
Target gate: GATE 10 — SYSTEM_SAFETY_VERIFIED

IMPORTANT:
This file authorizes preparation of the next-window scope only.
Do not assume LOT09 is VERIFIED from this document.
Before any LOT10 implementation, prove the final LOT09 handover HEAD is exact-head green and confirm current repository truth.

Start by reading, in order:

1. docs/ocd/handovers/LOT_09_HANDOVER.md
2. docs/ocd/03_OCD_CLINICAL_SAFETY.md
3. docs/ocd/07_ACCEPTANCE_GATES.md
4. docs/ocd/08_SPECIALIST_REVIEW_MATRIX.md
5. docs/ocd/10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md
6. existing versioned safety eval datasets, policies, routing logic and test infrastructure discovered by inspection
7. LOT05/LOT06/LOT07/LOT08/LOT09 safety evidence that may already cover part of the system

Do NOT assume any SHA, branch state, PR state, CI result or merge state from LOT09 is still current.

First verify live repository truth:
- current base branch and exact SHA;
- current LOT09 branch/HEAD;
- PR #19 state;
- whether LOT09 was merged after the handover;
- exact-head LOT03→LOT09 checks;
- ahead/behind divergence;
- unresolved reviews/comments/threads;
- whether any new safety/eval implementation appeared after this handover.

If LOT09 final handover HEAD is not exact-head green, STOP LOT10 implementation and repair/close LOT09 first.

Before any modification, state:

GOAL
SUCCESS
PROOF

## LOT10 scope

Build only the approved System Safety scope required by GATE 10.

Canonical mandatory requirements:
- all OCD safety families from `docs/ocd/03_OCD_CLINICAL_SAFETY.md` are represented in the versioned full-system eval set;
- ambiguous high-risk messages follow the dedicated approved routing policy;
- provider/tool/memory failure cases are covered;
- every supported language has representative safety tests;
- unsupported medical claims are detected in evaluation;
- no known material increase in reassurance, checking, rumination, compulsive repetition, unsafe practice guidance or unsupported medical claims remains unresolved.

## Critical inspection rule

Do NOT invent a new safety engine before inspecting what already exists.

First inspect:
- LOT05 bounded-loop tests/evals;
- LOT06 Compulsion Firewall and its safety dataset;
- LOT07 Practice safety/evidence;
- LOT08 Values/Support safety tests;
- LOT09 Memory/Pattern safety evals;
- all current routing/policy/fallback code;
- current supported languages;
- provider/model usage, if any;
- memory/tool failure handling;
- CI workflows and test runners;
- any canonical safety-family taxonomy already encoded in docs/tests.

The goal is a **full-system safety verification layer**, not a parallel second implementation of existing runtime logic.

Prefer:
- extending/reusing versioned eval infrastructure;
- deduplicating only where safe and explicitly justified;
- preserving each lot's runtime behavior;
- adding cross-flow/system-level coverage rather than refactoring proven flows.

No architecture refactor unless a proven LOT10 blocker requires it.

## Mandatory safety families

Derive the exact list from `03_OCD_CLINICAL_SAFETY.md`, not from memory.

At minimum inspect coverage for:
- normal informational requests;
- reassurance seeking;
- repeated/paraphrased reassurance;
- checking;
- rumination;
- confession/repetition;
- ambiguity;
- adversarial certainty seeking;
- memory/session edge cases;
- provider/tool failure;
- unsafe or uncontrolled practice/ERP-like requests;
- unsupported diagnosis/severity/efficacy claims;
- human-support / acute-risk routing boundaries where canonically applicable.

Do not silently broaden clinical behavior.

## Supported-language rule

First inspect which languages the product actually claims to support.

For each genuinely supported language:
- representative safety cases are mandatory;
- semantic safety equivalence must be reviewed;
- LOCALIZATION_AGENT is mandatory.

Do not create a new supported language merely to satisfy LOT10.

If English is the only supported language, record that fact with evidence and mark additional localization review NOT_APPLICABLE rather than inventing translations.

## Provider / AI rule

Do not assume AI is present.

Inspect actual runtime dependencies and code.

If no AI/LLM/provider path exists:
- document AI_EVAL scope around deterministic policy/system behavior;
- do not introduce an LLM merely for LOT10;
- evaluate the deterministic safety system as implemented.

If AI/provider logic exists at LOT10 start:
- inspect exact provider abstraction/data flow;
- include provider failure and adversarial behavior;
- do not change provider/model without separate justification.

## Memory rule

LOT09 established a device-local, single-profile bounded pattern memory.

LOT10 must include system-level safety cases for:
- unavailable memory;
- stale/expired memory;
- repeated history checking;
- false claims of retrieval;
- no cross-user isolation claim where no auth boundary exists.

Do not expand stored content or retention in LOT10 unless separately approved.

## Required specialist reviewers

Per `08_SPECIALIST_REVIEW_MATRIX.md`, Phase 10 requires:
- AI_EVAL_AGENT
- OCD_SAFETY_AGENT
- QA_NON_REGRESSION_AGENT
- LOCALIZATION_AGENT per supported language

Also add when materially implicated:
- DATA_PRIVACY_SECURITY_AGENT for memory/provider/data-flow findings;
- ARCHITECTURE_AGENT for cross-layer changes;
- CONTENT_COPY_AGENT for new user-facing safety wording;
- REGULATORY_CLINICAL_REVIEW only if LOT10 introduces/changes diagnostic, treatment, clinically meaningful scoring, crisis protocol, efficacy or autonomous ERP-like behavior.

A reviewer returns one of:
PASS
PASS_WITH_NOTES
CHANGES_REQUIRED
BLOCKED
NOT_APPLICABLE with explicit reason.

## Proof expectations

At minimum:
- versioned full-system eval dataset;
- coverage matrix mapping canonical safety families → test/eval cases;
- explicit thresholds/acceptance criteria defined before final scoring;
- known-failure register;
- provider/tool/memory degraded cases as applicable;
- unsupported-medical-claim detection cases;
- supported-language representative cases;
- full Flutter regression;
- exact-head LOT03→LOT10 CI;
- rerun after every material fix;
- strict Pass A + separated adversarial Pass B;
- retained lower score under all applicable caps;
- final Perfection Pass.

If LOT10 changes material UI/copy:
- add 360/390 evidence;
- 200% text proof;
- accessibility review;
- Target↔Render proof when significant.

If LOT10 is eval/test-only, do not fabricate visual work.

## Blockers

Do not call LOT10 VERIFIED if:
- any canonical safety family lacks representative evidence;
- thresholds were invented after seeing failures without documented rationale;
- known material safety regression remains;
- exact-head required CI is red/stale;
- required specialist verdict is missing;
- unsupported medical claim detection is absent;
- a supported language lacks representative safety evidence;
- either scoring pass is missing;
- retained governed score < 9.0;
- a Perfection Pass finding remains materially improvable in scope.

Any known material increase in:
- reassurance;
- checking;
- rumination;
- compulsive repetition;
- unsafe practice guidance;
- unsupported medical claims

blocks release until fixed or explicitly accepted through a documented human risk decision.

## Architecture boundary

IAmina Core and OCD capsule remain separate.

LOT10 may verify cross-system behavior, but must not move OCD-specific rules into generic Core.

No Core change without:
- inspected necessity;
- explicit architecture review;
- non-regression;
- product-owner approval if material.

## Mandatory execution rules

READ → PLAN → EXECUTE → SPECIALIST REVIEW → DOUBLE SCORE → VERIFY.

- no invented files/routes/tables/interfaces;
- preserve existing behavior;
- no unrequested feature/refactor;
- no new dependency unless proven necessary;
- no real production/user data;
- no production DB/schema/secret/config mutation;
- no merge without explicit product-owner approval;
- no deployment without explicit product-owner approval.

At LOT10 end:
- do NOT start LOT11 in the same window;
- create `docs/ocd/handovers/LOT_10_HANDOVER.md`;
- create `docs/ocd/handovers/LOT_11_START_PROMPT.md` only if LOT11 is explicitly approved.

Finish with:

Résultat
Modifications
Tests
Non-régression
Preuves
Risques
État
Prochaine étape
