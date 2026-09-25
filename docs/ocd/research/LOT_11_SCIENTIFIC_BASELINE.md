# LOT 11 — SCIENTIFIC BASELINE FOR A BOUNDED CONVERSATIONAL COMPANION

Status: VERSIONED PRE-IMPLEMENTATION BASELINE
Date: 2026-09-25
Lot: LOT11-A
Runtime AI/provider: NONE
Repository evidence base: `docs/ocd/03_OCD_CLINICAL_SAFETY.md`, LOT07 scientific contract, LOT10 system-safety evidence

## GOAL

Define what the current evidence does and does not justify before TrueGround introduces any generative conversational runtime.

This document supports product-safety decisions. It is not a clinical protocol, does not validate TrueGround as treatment, and does not replace qualified clinical/regulatory review.

## SUCCESS

This baseline is fit for LOT11-A only if it:

- separates excessive reassurance seeking from ordinary emotional/practical support;
- explains why reassurance can overlap functionally with checking;
- distinguishes structured internet-delivered CBT evidence from evidence for open-ended generative chat;
- records limitations and transfer gaps;
- avoids diagnostic, treatment-efficacy, medication or crisis-protocol claims;
- supplies rationale for pre-model deterministic safety boundaries and adversarial evals.

## Evidence hierarchy used

Priority was given to peer-reviewed primary studies, randomized trials, systematic reviews/meta-analyses and established OCD guidance. Professional-organization material is used as supporting interpretation, not as a substitute for primary evidence.

## 1. Excessive reassurance seeking, checking and certainty

### 1.1 Reassurance seeking is clinically relevant in OCD

Parrish & Radomsky (2010, PMID 19939622) examined reassurance seeking in OCD and found greater anxiety/threat around reassurance/checking behavior in the clinical group.

Source:
https://pubmed.ncbi.nlm.nih.gov/19939622/

Starcevic et al. (2012, PMID 22776755) reported interpersonal reassurance seeking in a substantial subset of adults with OCD and an association with checking and greater obsessive symptom burden.

Source:
https://pubmed.ncbi.nlm.nih.gov/22776755/

### 1.2 Reassurance can function similarly to checking

Halldorsson & Salkovskis (2017, PMID 28751797) explicitly distinguish excessive reassurance seeking from ordinary support seeking and discuss its checking-like function.

Source:
https://pubmed.ncbi.nlm.nih.gov/28751797/

Kobori et al. (2022, PMID 34922212) experimentally compared reassurance seeking and compulsive checking. In a non-clinical online sample, both could reduce uncertainty/threat estimates and shift perceived responsibility under some conditions.

Source:
https://pubmed.ncbi.nlm.nih.gov/34922212/

LOT11 interpretation:
- TrueGround must not treat repeated requests for certainty as neutral engagement.
- A conversational system can become a checking proxy even when it never uses the word "check".
- Rephrasing the same feared meaning must therefore remain part of the eval surface.

Limitation:
Kobori et al. was not a clinical efficacy trial of an AI system. Its findings support a mechanism-level safety concern, not a validated chatbot policy.

## 2. Support seeking is not the same as certainty seeking

Causier & Salkovskis (2025; e-publication 2024, PMID 39232282) compared imagined emotional support with reassurance in people with OCD. Emotional support was more acceptable and was associated with a lower anticipated urge to seek further reassurance in this preliminary study.

Source:
https://pubmed.ncbi.nlm.nih.gov/39232282/

LOT11 interpretation:
- The policy must distinguish "stay with me / help me take the next step / I need a person" from "tell me for sure that X is safe / true / impossible."
- Anti-reassurance must not become anti-support.
- A safe response can acknowledge distress, offer practical or emotional support, and redirect toward values/human support without settling the obsession.

Limitations:
- The study is small and does not validate a specific app response.
- "Supportive" wording still requires product evaluation because support can itself become repetitive reassurance if it starts answering the feared proposition.

## 3. Digital reassurance has a specific product risk

The International OCD Foundation's 2026 discussion of digital reassurance seeking describes how search engines, online communities and AI can make reassurance continuously available and easy to repeat.

Source:
https://iocdf.org/blog/2026/07/21/digital-reassurance-seeking-in-ocd/

Parsons et al. (2025, PMID 40795489) examined online versus interpersonal reassurance seeking in OCD. The work supports the relevance of shame/judgment and accessibility when people choose online reassurance channels.

Source:
https://pubmed.ncbi.nlm.nih.gov/40795489/

Transfer caution:
The IOCDF article is expert/professional-organization commentary, not a TrueGround protocol. Its specific self-help examples (including timers or exposure suggestions) are **not imported into the app**; LOT07's existing no-autonomous-ERP/no-unvalidated-timer boundary still governs.

LOT11 interpretation:
- "More messages" is not inherently a success metric.
- The companion must not optimize for reopening an unresolved certainty loop.
- Human-support and values-directed exits remain first-class outcomes, not failures of engagement.

## 4. Structured internet-delivered CBT has evidence of benefit

A 2024 systematic review/meta-analysis (PMID 38769929) found benefit for guided self-help internet CBT for OCD across randomized trials, while follow-up effects and comparators varied.

Source:
https://pubmed.ncbi.nlm.nih.gov/38769929/

A network meta-analysis (PMID 37907037) compared CBT and guided/unguided internet-delivered approaches. It supports internet-delivered options in some contexts while also showing that intervention format and guidance matter.

Source:
https://pubmed.ncbi.nlm.nih.gov/37907037/

An acceptability meta-analysis (PMID 38486096) found generally favorable acceptability for internet-based CBT while noting differences across delivery formats and the underlying evidence base.

Source:
https://pubmed.ncbi.nlm.nih.gov/38486096/

A guided ICBT randomized trial (PMID 35242595) reported improvement relative to treatment as usual in a small Japanese sample.

Source:
https://pubmed.ncbi.nlm.nih.gov/35242595/

### Critical transfer boundary

These studies evaluate structured interventions, not unrestricted generative conversation.

Therefore the evidence supports this statement:

> Structured digital OCD interventions can be useful in defined settings.

It does NOT establish:

> A free-form LLM chatbot is an effective or safe OCD treatment.

LOT11 must not collapse those two propositions.

## 5. Generative AI evidence remains insufficient for treatment claims

Recent systematic/scoping reviews of generative AI and mental-health chatbots describe rapid growth but continued gaps in clinical validation, crisis safeguards, benchmarking, privacy and consistency.

Examples:
- PMID 40948070 — systematic review of generative AI in mental health:
  https://pubmed.ncbi.nlm.nih.gov/40948070/
- PMID 42194487 — scoping review of safety/safeguards in generative-AI mental-health applications:
  https://pubmed.ncbi.nlm.nih.gov/42194487/
- PMID 39423368 — systematic review of LLM use in mental health:
  https://pubmed.ncbi.nlm.nih.gov/39423368/
- PMID 41592221 — review of evaluation/safeguard practices for LLM mental-health chatbots:
  https://pubmed.ncbi.nlm.nih.gov/41592221/

LOT11 interpretation:
- model fluency is not safety evidence;
- manual happy-path conversations are not a sufficient acceptance method;
- deterministic routing, output checks, provider-failure behavior, privacy minimization and versioned adversarial evals must exist before runtime activation;
- no treatment-efficacy claim follows from a provider benchmark.

## 6. Intrusive thoughts and intent

The existing TrueGround clinical-safety contract and LOT10 evidence preserve a necessary distinction: intrusive thoughts alone must not be treated as proof of intent, while explicit immediate danger or inability to stay safe must not be absorbed into ordinary OCD anti-reassurance logic.

NICE OCD guidance is already recorded in the LOT10 evidence trail and remains the reference for this boundary.

Source:
https://www.nice.org.uk/guidance/cg31/chapter/Recommendations

LOT11 interpretation:
- intrusive-thought content alone is not a deterministic reason to infer intent;
- explicit/ambiguous acute-safety language is a separate safety path;
- the exact crisis/high-risk policy remains a human clinical/regulatory gate and is NOT validated by this document.

## 7. What the evidence supports for LOT11-A

Supported as a product-safety design direction:

1. distinguish support from certainty seeking;
2. bound repeated reassurance/checking/rumination rather than answering indefinitely;
3. preserve a no-shame, non-confrontational interaction;
4. route to existing bounded Loop / Practice / Values / Support experiences when appropriate;
5. keep acute-risk handling outside ordinary reassurance logic;
6. evaluate repeated and paraphrased multi-turn behavior, not only single prompts;
7. test language equivalence explicitly;
8. treat provider output as untrusted until it passes deterministic output policy;
9. minimize sensitive text and avoid raw-conversation logging by default.

## 8. What the evidence does NOT support

LOT11-A does not establish that:

- TrueGround diagnoses OCD;
- TrueGround treats, prevents or cures OCD;
- a generative model can assess immediate safety;
- a model can determine whether an intrusive thought represents intent;
- an unrestricted chatbot is equivalent to CBT/ERP or professional care;
- a generated exposure is validated ERP;
- a specific anti-reassurance turn limit is a clinically validated dose;
- a particular model/provider is clinically superior;
- an eval pass predicts real-world clinical outcomes.

## 9. Evidence limitations / transfer gaps

The main limitations that remain relevant to product decisions are:

- several reassurance-mechanism studies are small, experimental or non-clinical;
- support-seeking evidence is promising but does not prescribe exact app copy;
- internet-CBT evidence concerns structured protocols, often with guidance, not arbitrary generative chat;
- generative-AI evidence is heterogeneous and still lacks mature, standardized clinical-safety validation;
- curated eval accuracy is not a population-level clinical error rate;
- EN/FR semantic equivalence requires direct testing rather than translation assumption;
- crisis/high-risk routing requires qualified human review before production claims or reliance.

## 10. Scientific conclusion for LOT11-A

The evidence is sufficient to justify a **bounded conversational architecture with deterministic anti-compulsion controls and pre-implementation evals**.

It is NOT sufficient to justify an unrestricted therapeutic chatbot or to bypass the existing crisis/high-risk human gate.

The scientific baseline therefore supports experimentation only after the contract, privacy boundary, eval cases and fixed thresholds are approved. It does not authorize a provider call by itself.
