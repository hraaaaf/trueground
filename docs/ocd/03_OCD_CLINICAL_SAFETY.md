# 03 — OCD CLINICAL SAFETY

Status: DRAFT FOR REVIEW — NOT CLINICALLY VALIDATED
Date: 2026-09-15

## GOAL

Define safety constraints for OCD-specific AI behavior before conversational functionality is treated as production-ready.

This document is a product safety framework, not a clinical protocol. It must be reviewed against current scientific guidance and, where appropriate, by qualified OCD clinicians before production claims or treatment-like behavior are introduced.

## Core safety principle

The system must not inadvertently reinforce compulsive cycles by repeatedly providing certainty, reassurance, checking assistance or endless analysis.

When user satisfaction conflicts with an approved safety rule, the safety rule wins.

## Primary failure modes to test

Every OCD conversational feature must be evaluated against at least:

- reassurance seeking;
- repeated reassurance seeking with paraphrasing;
- checking requests;
- repeated checking after an answer;
- rumination / endless analysis;
- confession-style compulsive disclosure;
- retrospective certainty seeking;
- contamination themes;
- harm-related intrusive thoughts;
- relationship themes;
- scrupulosity/religious themes;
- sexual/intrusive thought themes;
- symmetry / "just right" themes;
- health-related obsessional loops;
- existential loops;
- repeated "what if" questions;
- attempts to force a yes/no certainty answer.

The list is not a diagnosis taxonomy and must not be used to label the user automatically.

## Anti-reassurance rule

The AI must distinguish between useful information and compulsive certainty-seeking behavior where reasonably possible.

It should not endlessly answer variants of the same reassurance request.

The approved behavior should generally favor:

1. recognizing the likely loop with cautious language;
2. declining to provide certainty where that would predictably feed the loop;
3. redirecting to an approved, bounded action;
4. avoiding punitive, shaming or confrontational language;
5. ending or changing the interaction when repetition itself becomes part of the loop.

Exact copy must be validated through evaluation, not improvised ad hoc.

## Repetition memory

If the product uses session or longitudinal memory to detect repeated reassurance seeking:

- memory scope must be explicit;
- the system must not overstate that two questions are "the same" when uncertain;
- sensitive-history access must follow privacy policy;
- repeated-question detection must be testable and auditable;
- users must have appropriate controls over stored data where required.

## ERP-related safety

No autonomous ERP protocol should be shipped merely because a language model can generate exposure ideas.

Before any production ERP engine is considered validated, it requires explicit decisions on:

- intended population;
- clinician/scientific review;
- exposure-generation rules;
- hierarchy construction;
- exclusions and contraindication handling;
- physical-safety boundaries;
- crisis/escalation behavior;
- stopping rules;
- handling of comorbid or ambiguous presentations;
- evaluation methodology;
- product claims.

Until those are validated, the UI may represent future ERP functionality but the system must not present unvalidated generated exercises as clinically prescribed treatment.

## Diagnostic boundary

The product must not automatically state:

- "you have OCD";
- "this proves you have OCD";
- a diagnostic probability presented as medical fact;
- a differential diagnosis;
- that professional assessment is unnecessary.

Screening or questionnaires, if later added, must use validated instruments appropriately and clearly distinguish screening from diagnosis.

## Medication boundary

The system must not:

- prescribe medication;
- recommend starting/stopping/changing dosage;
- imply medication is safe for a specific individual without appropriate medical evaluation;
- override a prescriber.

General educational information requires its own evidence and safety review.

## Crisis and acute-risk handling

A dedicated policy must exist before release for messages involving immediate danger, self-harm, suicide, harm to others, abuse, medical emergencies or inability to stay safe.

Requirements:

- do not treat crisis handling as ordinary OCD reassurance logic;
- do not improvise emergency instructions from generic generation;
- provide approved escalation guidance appropriate to supported regions;
- avoid pretending the app can dispatch emergency help unless such capability truly exists;
- log only what privacy/security policy permits.

The crisis policy itself must be separately reviewed before V1 production release.

## Intrusive thoughts vs intent

The system must be especially careful not to conflate intrusive thoughts with intent, while also not dismissing genuine imminent-risk disclosures merely because the app is OCD-focused.

This distinction must be covered by explicit evaluation cases and escalation rules.

## Language requirements

Safety behavior must remain equivalent across every supported language.

A translation is not considered validated merely because the English version passed evaluation.

Each supported language needs:

- safety prompt/policy review;
- representative evaluation set;
- culturally relevant reassurance/rumination examples;
- red-team testing;
- escalation copy review.

## Prohibited claims without explicit validation

Do not claim that the product:

- diagnoses OCD;
- treats or cures OCD;
- prevents OCD;
- is clinically proven;
- is equivalent or superior to professional therapy;
- delivers validated ERP unless that statement has actually been established and approved.

## Evaluation requirements

For every significant AI change, preserve a versioned evaluation set with:

- normal/helpful requests;
- reassurance-seeking requests;
- paraphrased repeats;
- adversarial prompts;
- ambiguous cases;
- high-risk cases;
- provider timeout/failure;
- context/memory edge cases;
- multilingual cases when supported.

Track at least:

- unsafe reassurance rate;
- missed repetition/loop detection;
- false-positive loop detection;
- crisis-routing failures;
- fabricated clinical claims;
- harmful or shaming responses;
- successful safe completion rate.

Thresholds must be explicitly approved before release.

## Release blocker

Any known behavior that materially increases reassurance, checking, rumination, compulsive repetition, unsafe exposure guidance or unsupported medical claims is a release blocker until resolved or explicitly accepted through a documented risk decision.
