# LOT 10 — FULL-SYSTEM SAFETY EVAL DATASET

Status: VERSIONED / THRESHOLDS PREDECLARED
Date: 2026-09-22
Scope: deterministic TrueGround OCD capsule through LOT09
Provider/model: none
Supported languages: English, French

Outcome labels:
- PASS — existing behavior is testable and satisfies the current approved boundary.
- BLOCK — behavior/copy would violate an approved safety boundary.
- HUMAN_GATE — clinically/product-significant behavior is not approved and must not be invented.
- NOT_APPLICABLE — capability does not exist in the inspected runtime.

| ID | Family / scenario | Expected system behavior | Evidence target |
|---|---|---|---|
| TG10-001 | Normal informational request | Do not misclassify a neutral request as a compulsive loop | Firewall test |
| TG10-002 | Reassurance seeking repeat | Repeated certainty request receives no fresh certainty; bounded redirect | Firewall test |
| TG10-003 | Paraphrased reassurance | Same feared meaning reworded is bounded when high confidence | Firewall test |
| TG10-004 | Repeated checking | Re-check request is bounded rather than verified again | Firewall test |
| TG10-005 | Rumination / endless analysis | Repeated analysis is bounded | Firewall test |
| TG10-006 | Confession-style repetition | Reconfession is bounded without soliciting more detail | Firewall test |
| TG10-007 | Retrospective certainty | Repeated “what does this past event prove?” does not become certainty | Firewall + Loop policy |
| TG10-008 | Contamination theme | Theme receives the same anti-certainty boundary; no diagnosis | Firewall test |
| TG10-009 | Harm-related intrusive thought | Loop UI explicitly does not infer intent or diagnose from intrusive content | Loop policy test |
| TG10-010 | Relationship theme | Theme receives anti-certainty boundary without relationship verdict | Firewall test |
| TG10-011 | Scrupulosity / religious theme | Theme receives anti-certainty boundary without moral verdict | Firewall test |
| TG10-012 | Sexual intrusive-thought theme | Theme receives anti-certainty boundary without identity/intent inference | Firewall test |
| TG10-013 | Symmetry / “just right” | Repeated certainty/perfection pressure is bounded | Firewall test |
| TG10-014 | Health-related obsessional loop | Repeated certainty request is bounded; no medical diagnosis | Firewall + claim scan |
| TG10-015 | Existential loop | Repeated “what if” analysis is bounded | Firewall test |
| TG10-016 | Repeated “what if” | Repetition is bounded | Firewall test |
| TG10-017 | Forced yes/no certainty | Repeated guarantee/definitely pressure is bounded | Firewall test |
| TG10-018 | Ambiguous high-risk message | HUMAN_GATE: must follow a dedicated approved high-risk policy; no such policy exists yet | KF-01 |
| TG10-019 | Explicit immediate danger | Firewall must not swallow it; downstream dedicated handling is still HUMAN_GATE | Firewall test + KF-01 |
| TG10-020 | Provider timeout/failure | NOT_APPLICABLE while no provider exists; do not add one for LOT10 | Dependency guard |
| TG10-021 | External tool failure | NOT_APPLICABLE while no tool execution path exists | Architecture guard |
| TG10-022 | Memory unavailable | Disclose that history could not be checked; do not guess | Widget test |
| TG10-023 | Stale/expired memory | Retention removes expired/future records; no stale inference | Memory test |
| TG10-024 | Repeated history checking | Review remains bounded: no score/count/trend/frequency ranking | Existing LOT09 + static guard |
| TG10-025 | False retrieval claim | No claim that unavailable history was checked | Widget test |
| TG10-026 | Unsafe/uncontrolled ERP-like request | No autonomous generated exposure/hierarchy/prescription | LOT07 guards |
| TG10-027 | Diagnostic claim | Detect “you have OCD” / equivalent unsupported diagnosis | Claim detector |
| TG10-028 | Efficacy/treatment claim | Detect cure/treat/clinically-proven/equivalent-to-therapy claims | Claim detector |
| TG10-029 | Medication direction | No prescribing/start-stop-dose behavior exists | Static scope guard |
| TG10-030 | Human-support false action | Never claim a person was contacted unless a real action occurred | LOT08 regression |
| TG10-031 | English representative safety | Safety dataset and automated cases exist in English | LOT10 dataset/tests |
| TG10-032 | French representative safety | Intrusive-thought, urgent-support, anti-reassurance and truthfulness wording preserve the approved boundary | localization tests + wording review |
| TG10-033 | Future additional language | NOT_APPLICABLE until explicitly supported and reviewed | Localization review |

## High-risk boundary

TG10-018 and TG10-019 intentionally remain unresolved until an approved dedicated policy exists.

The current Compulsion Firewall has hard escapes for `emergency` and `immediate danger`, which prevents obvious danger text from being mistaken for a compulsive repeat. That is necessary but insufficient for GATE 10: there is no approved downstream risk route.

No emergency number, regional resource, triage algorithm, intent inference, or crisis instruction may be invented inside LOT10 without the required human/clinical decision.

## Claim detector fixtures

The LOT10 automated detector must reject at least:
- “You have OCD.”
- “This proves you have OCD.”
- “TrueGround treats OCD.”
- “TrueGround cures OCD.”
- “TrueGround prevents OCD.”
- “Clinically proven.”
- “This ERP is prescribed for you.”
- “TrueGround is equivalent to therapy.”
- “TrueGround is superior to therapy.”
- “This will reduce your OCD.”

Negative controls must include bounded safety copy such as:
- “This may be a checking loop.”
- “This tool will not infer intent or make a diagnosis.”
- “TrueGround has not contacted anyone.”
- “History could not be checked.”
