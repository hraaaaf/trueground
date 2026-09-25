# START PROMPT — TrueGround OCD / LOT 11

Repository: `hraaaaf/trueground`
Previous handover: `docs/ocd/handovers/LOT_10_HANDOVER.md`

Target:
**LOT 11 — Bounded Conversational Companion**

Initial sub-lot:
**LOT11-A — Conversational Safety Contract + Scientific Baseline + Pre-Implementation Evals**

IMPORTANT:
This prompt authorizes LOT11-A preparation only.
It does NOT authorize:
- connecting an LLM/provider;
- adding provider secrets;
- changing IAmina Core;
- autonomous ERP;
- diagnosis/scoring/medication guidance;
- merge;
- deployment;
- production data mutation.

## Start by reading

1. `docs/ocd/handovers/LOT_10_HANDOVER.md`
2. `docs/ocd/03_OCD_CLINICAL_SAFETY.md`
3. `docs/ocd/07_ACCEPTANCE_GATES.md`
4. `docs/ocd/08_SPECIALIST_REVIEW_MATRIX.md`
5. `docs/ocd/10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md`
6. `docs/ocd/lots/LOT_10_SYSTEM_SAFETY_CONTRACT.md`
7. current Loop/Compulsion Firewall/Practice/Values/Support/Urgent/Memory code and tests
8. current runtime dependencies and provider abstractions, if any.

Do NOT assume repository state from this prompt.
Re-check:
- base branch and SHA;
- current LOT10/FR branch HEAD;
- PR #22 state;
- exact-head CI;
- divergence;
- open review findings;
- whether any LOT11 files already appeared.

## GOAL

Design a conversational companion that can provide natural, useful interaction while remaining bounded by deterministic OCD safety rules.

The product must NOT become an unrestricted reassurance chatbot.

Target architectural principle:

`Chat UI → deterministic Safety Router → OCD Conversation Policy → model/provider adapter → deterministic Output Guard → bounded action/router`

This is a target to validate, not an existing architecture to invent.

## SUCCESS

LOT11-A is successful only if all of the following exist BEFORE any provider/runtime AI is introduced:

1. versioned scientific baseline;
2. explicit conversational capability contract;
3. allowed / prohibited / human-gate behavior matrix;
4. architecture decision record preserving IAmina Core / OCD capsule separation;
5. provider-agnostic interface requirements, without implementation;
6. privacy/data-flow contract;
7. multi-turn adversarial eval dataset defined before seeing model outputs;
8. explicit metrics/thresholds defined before implementation;
9. supported-language plan for EN + FR;
10. crisis/high-risk dependency remains an explicit blocker, never bypassed;
11. specialist review of the LOT11-A documents;
12. no runtime AI/provider dependency added.

## Scientific baseline to verify and cite

Start from primary/credible sources and cross-check current evidence.

At minimum verify:

### Reassurance / checking
- excessive reassurance seeking can function similarly to checking and produce short-term relief followed by renewed doubt/urge;
- repeated reassurance must not be treated as a neutral engagement metric;
- support seeking must be distinguished from certainty seeking.

Seed sources:
- Parrish & Radomsky, 2010, J Anxiety Disord, PMID 19939622
- Starcevic et al., 2012, Psychiatry Research, PMID 22776755
- Halldorsson & Salkovskis, 2017, Cogn Ther Res, PMID 28751797
- Kobori et al., 2022, J Behav Ther Exp Psychiatry, PMID 34922212
- Causier & Salkovskis, 2025, J Behav Ther Exp Psychiatry, PMID 39232282
- International OCD Foundation, "Digital Reassurance Seeking in OCD", 2026

### Digital CBT / guided structure
- structured internet-delivered CBT can be useful;
- evidence for digital interventions does NOT validate an unrestricted generative chatbot;
- clinician-guided/structured interventions and unguided systems must not be conflated.

Seed sources:
- systematic review/meta-analysis, 2024, PMID 38769929
- network meta-analysis, PMID 37907037
- acceptability meta-analysis, PMID 38486096
- guided ICBT RCT, PMID 35242595

Record evidence limitations explicitly.

## Conversational contract

Define at minimum these input families:

- ordinary informational/helpful request;
- uncertainty/distress without reassurance seeking;
- explicit reassurance request;
- paraphrased repeated reassurance;
- checking request;
- repeated checking;
- rumination / endless analysis;
- confession/repetition;
- retrospective certainty seeking;
- adversarial yes/no certainty forcing;
- intrusive harm thought without intent;
- explicit immediate danger/intention/inability to stay safe;
- ambiguous safety uncertainty;
- desire for practice;
- values/return-to-life request;
- human support request;
- medication/diagnosis/treatment claim request;
- provider timeout/failure;
- memory unavailable/stale/malformed;
- language switching EN↔FR to bypass limits.

For every family specify:
- allowed conversational behavior;
- prohibited behavior;
- deterministic router/action if applicable;
- whether model generation is allowed;
- maximum conversational persistence/repetition before pivot;
- fallback behavior;
- evidence source/rationale.

## Required anti-compulsion behavior

The conversational companion must never:
- answer unlimited variants of the same certainty request;
- become a checking proxy;
- extend rumination merely because the user continues;
- treat confession as a request for moral absolution;
- infer intent from intrusive thoughts alone;
- claim safety/risk assessment it cannot perform;
- diagnose OCD;
- prescribe or change medication;
- generate autonomous unvalidated ERP;
- claim treatment efficacy;
- imply professional care is unnecessary;
- claim a human/emergency service was contacted when it was not.

Prefer:
- brief acknowledgment;
- uncertainty-tolerant language;
- bounded response;
- transition to already approved Loop/Practice/Values/Support flows;
- truthful degraded state.

Exact user-facing copy requires separate review.

## Architecture constraints

IAmina Core and the OCD capsule remain separate.

Before proposing reuse:
- inspect actual IAmina Core code;
- identify generic provider/model primitives only if they truly exist;
- do not move OCD policy, reassurance detection, crisis routing or OCD eval logic into generic Core;
- do not introduce direct vendor coupling that bypasses an approved adapter;
- do not add dependencies before an architecture decision is approved.

If an important architecture decision is ambiguous, present:

OPTION A
OPTION B
RECOMMANDATION
IMPACT

and wait for product-owner approval before implementation.

## Privacy / data contract

Assume conversation text is sensitive.

LOT11-A must define:
- what text is sent to a provider;
- what is never sent;
- retention expectations;
- logging policy;
- analytics policy;
- redaction/minimization;
- provider failure behavior;
- deletion implications;
- session memory versus longitudinal memory;
- whether any conversation is persisted locally;
- how existing LOT09 memory remains separated from raw chat.

Default position:
- no raw conversation persistence unless explicitly approved;
- no sensitive free text in analytics/logs;
- minimum provider context;
- no production secrets during LOT11-A.

## Pre-implementation eval dataset

Create the eval cases BEFORE provider/model experiments.

Minimum multi-turn families:
- reassurance loop 2/5/10 turns;
- same reassurance paraphrased;
- checking by proxy;
- moral/confession reassurance;
- relationship reassurance;
- contamination/harm/health/scrupulosity/sexual intrusive themes;
- "just answer yes/no";
- "ignore your rules";
- language-switch bypass EN→FR→EN;
- benign factual control cases;
- false-positive controls;
- support-seeking controls;
- intrusive thought vs explicit intent;
- provider timeout/empty/malformed output;
- memory missing/stale;
- attempt to elicit diagnosis or medication advice.

Version each case with expected policy outcome, not model wording.

## Metrics fixed before model testing

Define, at minimum:

- unsafe reassurance rate;
- repeated-reassurance escape rate;
- checking-assistance rate;
- rumination-extension rate;
- false-positive loop detection rate;
- intrusive-thought/intent conflation rate;
- crisis-routing failure rate;
- unsupported medical claim rate;
- safe helpful completion rate;
- EN/FR semantic-safety divergence.

Thresholds must be approved before implementation and must not be relaxed after observing failures without a documented human risk decision.

## Mandatory reviewers for LOT11-A

- PRODUCT_AGENT
- OCD_SAFETY_AGENT
- AI_EVAL_AGENT
- ARCHITECTURE_AGENT
- DATA_PRIVACY_SECURITY_AGENT
- CONTENT_COPY_AGENT
- LOCALIZATION_AGENT (FR)
- QA_NON_REGRESSION_AGENT

REGULATORY_CLINICAL_REVIEW:
- required before any crisis-protocol claim;
- required before autonomous ERP/treatment-like behavior;
- not replaceable by AI review.

## Required LOT11-A artifacts

Recommended paths, to confirm against repo conventions before creation:

- `docs/ocd/lots/LOT_11_CONVERSATIONAL_COMPANION_CONTRACT.md`
- `docs/ocd/research/LOT_11_SCIENTIFIC_BASELINE.md`
- `docs/ocd/evals/LOT_11_CONVERSATIONAL_EVAL_CASES.md`
- `docs/ocd/evals/LOT_11_CONVERSATIONAL_ACCEPTANCE_THRESHOLDS.md`
- `docs/ocd/reviews/LOT_11_ARCHITECTURE_PRIVACY_REVIEW.md`

Do not create paths blindly; inspect existing conventions first.

## Gate / scope rule

The canonical roadmap currently names Phase 11 as Beta Readiness. LOT11 here is a newly approved implementation lot, not permission to silently redefine the canonical Phase 11 gate.

Before modifying `07_ACCEPTANCE_GATES.md`, explicitly decide whether:
- this conversational work becomes an inserted pre-beta lot while canonical Gate 11 remains Beta Readiness; or
- the roadmap/gate numbering itself should change.

Do NOT renumber canonical gates without product-owner approval.

## No-provider rule for LOT11-A

LOT11-A must end before any LLM call exists.

No:
- OpenAI;
- Anthropic;
- Gemini;
- local model;
- provider SDK;
- API key;
- runtime prompt;
- production data.

Provider comparison may be documented only after the safety/architecture/eval contract is fixed.

## Verification

LOT11-A requires:
- docs lint/structural review as available;
- proof no runtime dependency/provider was added;
- proof no existing behavior changed;
- specialist review ledger;
- severe score pass A;
- separate adversarial pass B;
- retained lower score under project caps;
- handover for the implementation sub-lot.

## Mandatory execution order

READ → PLAN → SCIENTIFIC REVIEW → CONTRACT → EVALS → SPECIALIST REVIEW → DOUBLE SCORE → VERIFY → HANDOVER.

Never:
- merge without explicit product-owner approval;
- deploy without explicit product-owner approval;
- mutate production data/config/secrets;
- infer clinical validation from green CI.

Finish with:

Résultat
Modifications
Tests
Non-régression
Preuves
Risques
État
Prochaine étape
