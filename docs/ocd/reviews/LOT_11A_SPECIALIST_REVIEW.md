# LOT 11A — SPECIALIST REVIEW

Project: TrueGround OCD
Lot: LOT11-A — Conversational Safety Contract + Scientific Baseline + Pre-Implementation Evals
Date: 2026-09-25
Review type: role-based adversarial review in the same assistant session
Independent human/clinician review: NOT PERFORMED
Runtime provider/model: NONE

## GOAL

Challenge the LOT11-A documentation as if it were about to become the specification for a future AI runtime, while refusing to infer safety from fluency, documentation volume, green CI or reviewer self-consistency.

## Review independence disclosure

The mandatory reviewer roles below were executed as distinct adversarial lenses, but they are **not genuinely independent human reviewers** because they were performed in the same model/session.

Consequences:
- strict-score ceiling remains 9.4/10;
- no clinical/regulatory sign-off is implied;
- REGULATORY_CLINICAL_REVIEW cannot be simulated or replaced here;
- any future crisis-protocol claim or treatment-like behavior remains human-gated.

## Evidence inspected

- `docs/ocd/research/LOT_11_SCIENTIFIC_BASELINE.md`
- `docs/ocd/lots/LOT_11_CONVERSATIONAL_COMPANION_CONTRACT.md`
- `docs/ocd/evals/LOT_11_CONVERSATIONAL_EVAL_CASES.md`
- `docs/ocd/evals/LOT_11_CONVERSATIONAL_ACCEPTANCE_THRESHOLDS.md`
- `docs/ocd/reviews/LOT_11_ARCHITECTURE_PRIVACY_REVIEW.md`
- canonical clinical-safety / architecture / data-privacy / acceptance-gate / strict-scoring docs
- current deterministic Flutter runtime and tests through LOT10
- current dependencies
- current `CompulsionFirewallSession`
- current `HighRiskBoundary`
- current EN/FR localization layer
- LOT09 structured memory
- LOT10 handover and open blocker state
- current scientific sources referenced in the baseline.

## Findings discovered during adversarial review and corrected before scoring

### F-11A-01 — current safety classifiers are English-centric

Finding:
The current `CompulsionFirewallSession` and `HighRiskBoundary` use English lexical markers. UI translation does not make them multilingual.

Risk:
A future French chat could bypass a router that appears safe in English.

Correction:
The LOT11 contract and architecture review now explicitly state that the current components are **not proven EN/FR conversational routers**. Direct FR and EN↔FR→EN eval evidence is mandatory before runtime claims.

Status:
CLOSED FOR LOT11-A DOCUMENTATION.
OPEN AS LOT11-B IMPLEMENTATION REQUIREMENT.

### F-11A-02 — deterministic Output Guard could be overclaimed

Finding:
A "deterministic Output Guard" label could create a false sense that lexical/rule checks semantically validate arbitrary model text.

Risk:
Unsafe paraphrases could pass a superficial guard.

Correction:
The contract now states that Output Guard is defense in depth only. Disallowed capabilities must be blocked before model invocation and the whole composed system must pass adversarial evals.

Status:
CLOSED FOR LOT11-A DOCUMENTATION.

### F-11A-03 — intended population was initially implicit

Finding:
The earlier Practice contract was adults-only, but an open chat specification could silently broaden perceived scope.

Correction:
LOT11-A now explicitly inherits the adults-only V1 boundary and forbids silent pediatric expansion.

Status:
CLOSED FOR LOT11-A DOCUMENTATION.
Future pediatric use requires separate safeguarding/clinical/privacy/content review.

### F-11A-04 — privacy wording needed one canonical rule

Finding:
The no-persistence intent existed but used different wording across files.

Correction:
Both contract and architecture/privacy review now state:
**NO RAW CHAT PERSISTENCE BY DEFAULT.**

Status:
CLOSED.

### F-11A-05 — professional-organization commentary must not become app treatment content

Finding:
The IOCDF 2026 digital-reassurance article includes concrete self-help examples such as timers/exposure suggestions.

Risk:
Citing the article could be misread as approval to import those examples into TrueGround.

Correction:
Scientific baseline now explicitly says those examples are not imported; LOT07 no-autonomous-ERP/no-unvalidated-timer boundaries remain controlling.

Status:
CLOSED.

### F-11A-06 — scientific baseline risked confirmation bias on GenAI evidence

Finding:
The first baseline emphasized validation/safety gaps in generative mental-health AI but did not explicitly surface recent positive evidence, including a GenAI mental-health chatbot meta-analysis and a 2026 randomized CBT-app trial.

Risk:
A safety specification can become scientifically weaker if it cherry-picks only adverse or cautionary evidence.

Correction:
The baseline now includes:
- PMID 41401240, a 2025 systematic review/meta-analysis of GenAI mental-health chatbots, with a small average effect across 14 RCTs but moderate risk of bias and wide uncertainty;
- PMID 41540194, a 2026 RCT in 540 adults with anxiety/depression symptoms showing higher engagement with a GenAI-enabled CBT app but no overall additional symptom reduction versus digital workbooks;
- the existing reviews documenting validation and safeguard gaps.

The interpretation is now explicitly two-sided: promising mental-health evidence exists, but it is not OCD-specific and does not validate unrestricted reassurance-sensitive chat.

Status:
CLOSED BEFORE RESCORING.

## Reviewer ledger

| Reviewer | Verdict | Strongest challenge / evidence |
|---|---|---|
| PRODUCT_AGENT | PASS_WITH_NOTES | Product value is credible only if conversation remains genuinely helpful after anti-reassurance limits. HELP >=90% prevents a refusal-only product. Exact conversational UX is not yet designed. |
| OCD_SAFETY_AGENT | PASS_WITH_NOTES | Anti-reassurance/checking/rumination/confession boundaries are explicit; support is distinguished from certainty. Crisis policy remains human-gated and current classifiers are not yet multilingual-ready. |
| AI_EVAL_AGENT | PASS | 70 pre-model cases are versioned before provider outputs, including 2/5/10-turn loops, paraphrases, false positives, output attacks, failures, memory and EN/FR bypass. Thresholds are frozen independently of provider performance. |
| ARCHITECTURE_AGENT | PASS_WITH_NOTES | Safety remains capsule-owned and pre/post model. No existing Core adapter is invented. Actual IAmina Core implementation was not inspected for reuse in this window, so no Core reuse claim is permitted. |
| DATA_PRIVACY_SECURITY_AGENT | PASS_WITH_NOTES | No raw-chat persistence by default, no sensitive free text in routine logs/analytics, LOT09 memory separated. Provider retention/training/residency cannot be approved until a candidate is selected. |
| CONTENT_COPY_AGENT | PASS_WITH_NOTES | Documents avoid diagnosis/efficacy/medication claims and mark exact user-facing copy as future-reviewed. No generative production copy exists yet. |
| LOCALIZATION_AGENT_FR | PASS_WITH_NOTES | Direct matched EN/FR and cross-language bypass cases are specified. This is a plan/eval contract, not proof that runtime FR safety exists. |
| QA_NON_REGRESSION_AGENT | PASS_WITH_NOTES | Compare evidence shows LOT11-A substantive diff is docs-only. Structural assertions pass. Exact-head workflow evidence still belongs to final VERIFY and must not be inferred from the prior app baseline. |
| REGULATORY_CLINICAL_REVIEW | NOT_APPLICABLE TO DOCS-ONLY CLOSEOUT / REQUIRED BEFORE RUNTIME CLAIM | Cannot be replaced by this review. Mandatory before crisis-protocol claim and before autonomous ERP/treatment-like behavior. |

## PRODUCT_AGENT detail

Strengths:
- bounded conversation is positioned as a capability layer around existing Loop/Practice/Values/Support, not a replacement;
- ordinary helpful requests remain possible;
- human support is treated as success, not failure;
- refusal-only behavior is explicitly disallowed by the HELP metric;
- canonical Gate 11 numbering is preserved.

Residual:
- no chat UI, pacing, composer behavior or user study exists yet;
- a strong policy can still feel repetitive or punitive in implementation;
- LOT11-B needs UX evaluation of pivot timing without rewarding compulsive persistence.

Verdict:
**PASS_WITH_NOTES.**

## OCD_SAFETY_AGENT detail

Strengths:
- reassurance, checking, rumination and confession are distinct policy families;
- repeated paraphrases and cross-language bypass are tested;
- emotional/practical support is not automatically blocked;
- intrusive thought alone is not treated as intent;
- explicit acute-risk language overrides an existing loop state;
- autonomous ERP, diagnosis and medication directions are prohibited.

Residual:
- the first bounded model-generated support response can still accidentally reassure; pre-model mode + Output Guard + whole-system eval are all required;
- the two-turn pivot is a product safety bound, not a validated clinical dose;
- no clinician has approved exact future chat wording;
- high-risk policy remains unresolved.

Verdict:
**PASS_WITH_NOTES.**

## AI_EVAL_AGENT detail

Strengths:
- cases were authored before provider outputs;
- expected outcomes are policy labels rather than target prose;
- long-loop persistence is explicit;
- false-positive controls prevent "block everything" gaming;
- HELP prevents "refuse everything" gaming;
- provider/output/memory failures are first-class;
- critical metrics do not average away one known violation.

Residual:
- the 70-case set is curated and finite;
- no model distribution/temperature/repeated-run protocol exists yet because provider selection is out of scope;
- future stochastic evaluation must predeclare number of runs/seeds/config before testing;
- broader benign robustness coverage will be needed before product release.

Verdict:
**PASS.**

## ARCHITECTURE_AGENT detail

Strengths:
- proposed flow is capability-gated before provider and guarded after provider;
- model never owns crisis/repetition routing;
- OCD policy/evals remain capsule-side;
- provider interface is requirements-only;
- no Core extraction was performed.

Residual:
- actual IAmina Core code was not inspected in this window;
- therefore LOT11-B must not claim reuse until the Core implementation is inspected;
- a provider adapter should remain as narrow as possible in the first experiment;
- Output Guard semantics must not become a second opaque AI model without a separately approved architecture decision.

Verdict:
**PASS_WITH_NOTES.**

## DATA_PRIVACY_SECURITY_AGENT detail

Strengths:
- raw chat transient by default;
- raw prompt/response excluded from routine analytics/logs;
- provider context minimized;
- Pattern Memory remains structured and separate;
- no secrets/provider introduced;
- provider terms are recognized as a security/privacy decision.

Residual:
- provider-specific retention, training, geography and subprocessor facts are unknown;
- deletion semantics cannot be finalized until provider/data paths exist;
- session semantic fingerprints must remain non-persistent by default unless separately approved.

Verdict:
**PASS_WITH_NOTES.**

## CONTENT_COPY_AGENT detail

Strengths:
- certainty, diagnosis, efficacy, medication and false-contact claims are explicitly forbidden;
- support language is allowed without settling the feared proposition;
- scientific uncertainty/limitations are visible.

Residual:
- no final conversational microcopy has been written or clinically reviewed;
- French tone equivalence is not proven merely by policy equivalence;
- deterministic fallback copy must later be reviewed separately.

Verdict:
**PASS_WITH_NOTES.**

## LOCALIZATION_AGENT_FR detail

Strengths:
- matched critical pairs exist;
- EN→FR→EN state persistence is required;
- FR is not treated as a translated UI-only concern;
- current English-only classifier limitation is explicitly documented.

Residual:
- no implemented multilingual router exists;
- no native/qualified FR clinical copy review exists yet;
- code-level normalization/tokenization strategy is not approved.

Verdict:
**PASS_WITH_NOTES.**

## QA_NON_REGRESSION_AGENT detail

Evidence:
- LOT11-A branch began from exact handover head `7e5f56af8767c5888f1938ac73c16a39b1cd417a`;
- pre-review compare showed only the five required `docs/ocd/**` artifacts changed;
- no `lib/`, `test/`, workflow, dependency, secret, DB or config file was changed by the substantive LOT11-A work;
- structural review confirmed:
  - five required artifacts present;
  - referenced scientific PMIDs present;
  - no-provider rule explicit;
  - Core/capsule boundary explicit;
  - EN-only classifier limitation explicit;
  - population boundary explicit;
  - Output Guard defense-in-depth rule explicit;
  - 70 unique case IDs `TG11-001` → `TG11-070`;
  - 2/5/10-turn reassurance loops;
  - cross-language cases;
  - critical thresholds and crisis HUMAN_GATE.

Residual:
Exact-head workflows must still be checked on the final documentation candidate. Prior LOT03→LOT10 green status cannot be presented as proof for a later SHA.

Verdict:
**PASS_WITH_NOTES pending final VERIFY.**

## Strongest remaining reasons NOT to authorize runtime AI

1. crisis/high-risk policy lacks required qualified human validation;
2. current deterministic classifiers are English-centric;
3. no provider privacy/security terms have been reviewed;
4. no provider/model has passed the frozen eval set;
5. no exact conversational copy has been clinically reviewed;
6. no actual IAmina Core provider primitive has been inspected for reuse;
7. no real-user safety/usability evidence exists for the conversational experience;
8. adults-only scope must remain enforced and cannot silently expand.

## Specialist conclusion

**PASS_WITH_NOTES for LOT11-A documentation quality.**

This means the specification is suitable to proceed to strict scoring and final verification.

It does **not** mean:
- runtime AI is safe;
- crisis handling is clinically validated;
- a provider may now be connected automatically;
- Core changes are authorized;
- merge or deployment is authorized.

The next mandatory steps are:
`DOUBLE SCORE → VERIFY → HANDOVER`.
