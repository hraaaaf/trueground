# 08 — SPECIALIST REVIEW MATRIX

Status: DRAFT FOR REVIEW
Date: 2026-09-16

## GOAL

Require the right specialist review for every material product, UX, AI, architecture, privacy, safety and release decision so that no chantier is validated only by the person or agent who built it.

This matrix adds an independent review layer to the project and is governed by `10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md`.

Core rule:

> **BUILD → SCORE → SPECIALIST REVIEW → ADVERSARIAL RE-SCORE → FIX IF NEEDED → VERIFY**

A specialist review is not decorative. If the reviewer identifies a material blocker, the affected gate stays `BLOCKED` or `READY FOR REVIEW` until the issue is resolved or explicitly accepted by the product owner.

Every mandatory specialist review must return both a binary verdict and a severe numerical score `/10` with explicit deductions and evidence.

## Specialist roles

### PRODUCT_AGENT
Checks:
- alignment with the North Star;
- scope discipline;
- user value;
- flow coherence;
- feature creep;
- whether the output solves the intended problem rather than merely adding functionality.

### UI_UX_AGENT
Checks:
- information hierarchy;
- cognitive load;
- navigation;
- interaction clarity;
- mobile ergonomics;
- consistency with Dashboard V3;
- empty/loading/error states;
- risk that the interface encourages checking, perfectionism or compulsive self-monitoring.

### ACCESSIBILITY_AGENT
Checks:
- text scaling;
- contrast;
- focus order;
- labels;
- touch targets;
- screen-reader semantics;
- keyboard/accessibility behavior where relevant.

### OCD_SAFETY_AGENT
Checks:
- reassurance seeking;
- checking;
- rumination;
- confession/repetition loops;
- pressure/perfectionism;
- unsafe or unsupported ERP-like behavior;
- wording likely to reinforce compulsions;
- distinction between intrusive thought and genuine acute-risk disclosures.

This is a safety review role. It does not replace qualified clinical validation when clinical claims or treatment-like behavior are introduced.

### AI_EVAL_AGENT
Checks:
- prompt/policy behavior;
- repetition handling;
- false-positive loop detection;
- provider/model failure paths;
- adversarial prompts;
- memory/context edge cases;
- unsupported medical claims;
- regression against versioned eval sets.

### ARCHITECTURE_AGENT
Checks:
- IAmina Core / OCD capsule separation;
- dependency direction;
- unnecessary coupling;
- reuse versus client-specific logic;
- maintainability;
- provider abstraction;
- failure isolation;
- architectural drift.

### DATA_PRIVACY_SECURITY_AGENT
Checks:
- tenant/client isolation;
- auth/authorization;
- sensitive-data minimization;
- logs/analytics leakage;
- secret handling;
- provider data flow;
- deletion/retention implications;
- unsafe real-data operations.

### QA_NON_REGRESSION_AGENT
Checks:
- happy path;
- edge cases;
- failure states;
- regression risk;
- viewport/device behavior;
- exact test evidence;
- whether the stated result matches observable behavior.

### CONTENT_COPY_AGENT
Checks:
- clarity;
- tone;
- consistency;
- no shaming;
- no false certainty;
- no unsupported medical wording;
- no copy that encourages repeated self-analysis or reassurance.

### LOCALIZATION_AGENT
Required only for supported non-source languages.
Checks:
- semantic equivalence;
- cultural meaning;
- safety equivalence;
- OCD-specific language patterns;
- escalation/support copy.

### REGULATORY_CLINICAL_REVIEW
Human-qualified review, not an AI substitute, required when the product introduces or changes:
- diagnostic claims;
- treatment claims;
- autonomous ERP-like treatment behavior;
- medication guidance;
- clinically meaningful scoring;
- crisis protocol;
- claims of clinical efficacy.

## Review severity

Every specialist review returns exactly one result:

- `PASS` — no material issue found.
- `PASS_WITH_NOTES` — acceptable now; non-blocking improvements documented.
- `CHANGES_REQUIRED` — material issue must be fixed before verification.
- `BLOCKED` — unsafe, unverified or fundamentally inconsistent with canonical requirements.
- `NOT_APPLICABLE` — only with explicit reason.

And every applicable review also returns:

- `SCORE /10` using the severe scale in `10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md`;
- strongest deductions;
- direct evidence;
- highest-impact in-scope improvement.

Recommended consistency:

- `PASS` normally requires score `>=9.0`;
- `PASS_WITH_NOTES` normally maps to `8.5–8.9` or to `>=9.0` with genuinely minor notes;
- `CHANGES_REQUIRED` normally applies below `8.5`;
- `BLOCKED` applies whenever a blocker exists regardless of the numerical average.

A specialist score is not allowed to average away a blocker.

No silent review or unscored mandatory review is allowed.

## Mandatory review table by change type

| Change / flow | Mandatory primary reviewer | Mandatory secondary reviewer(s) | Typical blocker |
|---|---|---|---|
| North Star / product scope | PRODUCT_AGENT | OCD_SAFETY_AGENT, UI_UX_AGENT | drift from product thesis or unsafe engagement model |
| Dashboard / screen / component | UI_UX_AGENT | ACCESSIBILITY_AGENT, OCD_SAFETY_AGENT | cognitive overload, compulsive monitoring, inaccessible UI |
| Navigation / user flow | UI_UX_AGENT | PRODUCT_AGENT, QA_NON_REGRESSION_AGENT | dead end, confusing hierarchy, flow mismatch |
| Copy / microcopy | CONTENT_COPY_AGENT | OCD_SAFETY_AGENT | reassurance, certainty, shame, unsupported clinical claim |
| `I'm stuck in a loop` flow | OCD_SAFETY_AGENT | UI_UX_AGENT, AI_EVAL_AGENT, QA_NON_REGRESSION_AGENT | reassurance loop, endless chat, unsafe routing |
| Compulsion Firewall | AI_EVAL_AGENT | OCD_SAFETY_AGENT, ARCHITECTURE_AGENT | repeated certainty, high false positives, unsafe fallback |
| Practice / uncertainty exercise | OCD_SAFETY_AGENT | UI_UX_AGENT, CONTENT_COPY_AGENT | pressure, uncontrolled exposure, unsupported therapeutic behavior |
| ERP-like capability | REGULATORY_CLINICAL_REVIEW | OCD_SAFETY_AGENT, AI_EVAL_AGENT | unvalidated treatment behavior |
| Values / return-to-life flow | PRODUCT_AGENT | OCD_SAFETY_AGENT, UI_UX_AGENT | moral prescription, covert reassurance, excess friction |
| Human-support / crisis routing | OCD_SAFETY_AGENT | REGULATORY_CLINICAL_REVIEW where applicable, QA_NON_REGRESSION_AGENT | incorrect escalation, false claim of contacting support |
| Memory / pattern review | DATA_PRIVACY_SECURITY_AGENT | OCD_SAFETY_AGENT, AI_EVAL_AGENT | privacy leak, compulsive checking surface, false inference |
| Auth / tenant / user access | DATA_PRIVACY_SECURITY_AGENT | QA_NON_REGRESSION_AGENT | cross-user/client access |
| Database / schema / persistence | DATA_PRIVACY_SECURITY_AGENT | ARCHITECTURE_AGENT, QA_NON_REGRESSION_AGENT | real-data risk, migration incompatibility |
| IAmina Core change | ARCHITECTURE_AGENT | QA_NON_REGRESSION_AGENT, DATA_PRIVACY_SECURITY_AGENT as relevant | OCD-specific leakage into Core |
| OCD capsule architecture | ARCHITECTURE_AGENT | OCD_SAFETY_AGENT, QA_NON_REGRESSION_AGENT | boundary violation or unsafe coupling |
| LLM/model/provider change | AI_EVAL_AGENT | OCD_SAFETY_AGENT, DATA_PRIVACY_SECURITY_AGENT | safety regression, data-flow change |
| Prompt/policy change | AI_EVAL_AGENT | OCD_SAFETY_AGENT | anti-reassurance regression |
| Analytics / telemetry | DATA_PRIVACY_SECURITY_AGENT | PRODUCT_AGENT | sensitive content leakage or dark-pattern engagement metric |
| New dependency | ARCHITECTURE_AGENT | DATA_PRIVACY_SECURITY_AGENT | unnecessary package or security/licensing concern |
| Accessibility-sensitive UI | ACCESSIBILITY_AGENT | UI_UX_AGENT, QA_NON_REGRESSION_AGENT | unusable text scaling/focus/labels |
| Translation / new language | LOCALIZATION_AGENT | OCD_SAFETY_AGENT, CONTENT_COPY_AGENT | safety meaning changes in translation |
| Beta readiness | QA_NON_REGRESSION_AGENT | all specialist roles relevant to changed surfaces | incomplete evidence or unresolved blocker |
| Release / merge decision | PRODUCT_AGENT | QA_NON_REGRESSION_AGENT + relevant blocker owners | exact HEAD/CI/risk state not proven |

## Mandatory review by roadmap phase

| Phase | Mandatory specialist checks before phase can be VERIFIED |
|---|---|
| Phase 0 — Canonical foundation | PRODUCT_AGENT + OCD_SAFETY_AGENT + ARCHITECTURE_AGENT |
| Phase 1 — Existing-system inspection | ARCHITECTURE_AGENT + DATA_PRIVACY_SECURITY_AGENT |
| Phase 2 — App shell | UI_UX_AGENT + ACCESSIBILITY_AGENT + QA_NON_REGRESSION_AGENT |
| Phase 3 — Dashboard V3 | UI_UX_AGENT + OCD_SAFETY_AGENT + ACCESSIBILITY_AGENT + QA_NON_REGRESSION_AGENT |
| Phase 4 — Data/privacy foundation | DATA_PRIVACY_SECURITY_AGENT + ARCHITECTURE_AGENT + QA_NON_REGRESSION_AGENT |
| Phase 5 — Bounded Loop flow | OCD_SAFETY_AGENT + AI_EVAL_AGENT + UI_UX_AGENT + QA_NON_REGRESSION_AGENT |
| Phase 6 — Compulsion Firewall | AI_EVAL_AGENT + OCD_SAFETY_AGENT + ARCHITECTURE_AGENT + QA_NON_REGRESSION_AGENT |
| Phase 7 — Practice | OCD_SAFETY_AGENT + UI_UX_AGENT + CONTENT_COPY_AGENT + AI_EVAL_AGENT where AI is used |
| Phase 8 — Values/support | PRODUCT_AGENT + OCD_SAFETY_AGENT + UI_UX_AGENT + CONTENT_COPY_AGENT |
| Phase 9 — Memory/pattern review | DATA_PRIVACY_SECURITY_AGENT + OCD_SAFETY_AGENT + AI_EVAL_AGENT + UI_UX_AGENT |
| Phase 10 — System safety | AI_EVAL_AGENT + OCD_SAFETY_AGENT + QA_NON_REGRESSION_AGENT + LOCALIZATION_AGENT per supported language |
| Phase 11 — Beta readiness | QA_NON_REGRESSION_AGENT + UI_UX_AGENT + ACCESSIBILITY_AGENT + DATA_PRIVACY_SECURITY_AGENT + OCD_SAFETY_AGENT |
| Phase 12 — Release decision | PRODUCT_AGENT + QA_NON_REGRESSION_AGENT + all unresolved blocker owners + explicit product-owner approval |

## Per-flow review card

Every material flow must have a review card using this structure:

```text
FLOW:
OWNER:
COMMIT / PR:

GOAL:
SUCCESS:
PROOF:

EXECUTION_SCORE: x.x/10
EXECUTION_DEDUCTIONS:

SPECIALIST CHECKS
[ ] PRODUCT_AGENT
[ ] UI_UX_AGENT
[ ] ACCESSIBILITY_AGENT
[ ] OCD_SAFETY_AGENT
[ ] AI_EVAL_AGENT
[ ] ARCHITECTURE_AGENT
[ ] DATA_PRIVACY_SECURITY_AGENT
[ ] QA_NON_REGRESSION_AGENT
[ ] CONTENT_COPY_AGENT
[ ] LOCALIZATION_AGENT
[ ] REGULATORY_CLINICAL_REVIEW

For each checked reviewer:
RESULT: PASS | PASS_WITH_NOTES | CHANGES_REQUIRED | BLOCKED | NOT_APPLICABLE
SCORE: x.x/10
EVIDENCE:
DEDUCTIONS:
BLOCKERS:
HIGHEST_IMPACT_IN_SCOPE_IMPROVEMENT:
NOTES:

ADVERSARIAL_SCORE: x.x/10
FINAL_STAGE_SCORE: min(EXECUTION_SCORE, ADVERSARIAL_SCORE)
SCORE_DELTA:
DELTA_GT_0_5_INVESTIGATED: YES | NO | N/A
PERFECTION_PASS:
RE_SCORE_AFTER_FIXES:

FINAL STATUS:
NOT STARTED | IN PROGRESS | BLOCKED | READY FOR REVIEW | VERIFIED
```

Only relevant roles are checked. `NOT_APPLICABLE` must state why.

Use `templates/STRICT_SCORECARD_TEMPLATE.md` for the full dimension-level scorecard when the stage is material.

## Independence rule

Whenever practical, the specialist reviewer must not merely repeat the implementation agent's reasoning.

The reviewer should inspect the actual artifact, code, screenshots, flow or eval output independently and actively try to invalidate the work.

Review prompt principle:

> **Find the strongest reason this should NOT be approved, and score it lower if the evidence justifies that.**

Only after that challenge should the reviewer return PASS.

If no separate specialist execution runtime is available, the same agent may perform a clearly separated adversarial pass, but must disclose that it is not independent human review and must still use the lower justified score.

## UX-specific rule

Any material UI/UX change requires the UI_UX_AGENT to review the rendered result, not only source code.

Required evidence where relevant:
- target/reference;
- actual screenshot;
- 360 px;
- 390 px;
- additional supported widths;
- loading/empty/error states;
- accessibility behavior.

For target-driven UI, visual-fidelity scoring without direct target/render comparison is subject to the hard cap in `10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md`.

For OCD-facing UI, OCD_SAFETY_AGENT review is mandatory whenever the screen contains:
- scores;
- progress;
- reminders;
- repeated prompts;
- symptom language;
- reassurance-related copy;
- practice/exposure-like behavior;
- journaling or pattern review.

## AI-specific rule

No AI change may be accepted from manual conversation testing alone.

AI_EVAL_AGENT must review a versioned evaluation set and report:
- normal cases;
- reassurance cases;
- paraphrased repeats;
- ambiguous cases;
- adversarial cases;
- failure/degraded cases;
- regression versus previous accepted behavior.

OCD_SAFETY_AGENT then reviews the behavioral implications independently and scores the relevant safety dimensions separately.

## Clinical/regulatory boundary

AI specialist reviews can help find risk, inconsistency and regressions, but they do not constitute medical-device clearance, clinical validation or professional clinical sign-off.

When a feature crosses the clinical boundary defined above, human-qualified review becomes a mandatory blocker before production claims or release.

A high numerical score cannot substitute for required human-qualified validation.

## Gate integration

A gate in `07_ACCEPTANCE_GATES.md` cannot become `VERIFIED` until every mandatory reviewer from this matrix has one of:

- `PASS`;
- `PASS_WITH_NOTES`;
- `NOT_APPLICABLE` with explicit justification.

And until:

- every mandatory applicable reviewer has recorded a severe score `/10`;
- the stage and lot thresholds in `10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md` are met;
- no hard score cap or blocker contradicts the claimed status.

`CHANGES_REQUIRED` or `BLOCKED` prevents verification regardless of numerical score.

## Final rule

**The builder never gets the final word on its own work.**

Specialist review must challenge the artifact from the perspective most capable of finding its failure mode before product-owner approval.

When uncertain between two defensible scores, use the lower score until stronger evidence justifies the higher one.
