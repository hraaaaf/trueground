# LOT 07A — Scientific Alignment Review

Status: REVIEWED / PROTOTYPE-SCOPE ALIGNMENT ONLY
Date: 2026-09-18
Parent contract: `docs/ocd/lots/LOT_07A_PRACTICE_SCIENTIFIC_CONTENT_CONTRACT.md`

## GOAL

Cross-check the proposed TrueGround Practice contract against multiple evidence types before runtime implementation.

This review asks a narrow question:

> Can LOT07B implement the proposed deterministic micro-practices without presenting them as autonomous ERP, personalized treatment, or clinically validated therapy?

## SOURCES REVIEWED

### A. Guideline / professional guidance

1. NICE CG31 — Obsessive-compulsive disorder and body dysmorphic disorder: treatment.
   - Current web recommendations checked 2026-09-18.
   - Relevant points:
     - low-intensity CBT including ERP may be offered to some adults;
     - structured self-help can be part of low-intensity CBT;
     - professionals delivering psychological treatment should have appropriate training and supervision.

2. International OCD Foundation — Exposure and Response Prevention (ERP).
   - Current educational treatment guidance checked 2026-09-18.
   - Relevant points:
     - ERP is a first-line OCD treatment;
     - exposure and response prevention are planned and structured;
     - therapist guidance is typical, especially during initiation;
     - exposure practice should not be coerced.

### B. Systematic reviews / meta-analyses

3. Reid JE et al. 2021.
   `Cognitive behavioural therapy with exposure and response prevention in the treatment of obsessive-compulsive disorder: a systematic review and meta-analysis of randomised controlled trials.`
   Compr Psychiatry. 106:152223.
   PMID: 33618297.
   DOI: 10.1016/j.comppsych.2021.152223.

   Interpretation:
   ERP-containing CBT has a substantial evidence base. This supports the importance of response prevention as a treatment component but does not validate arbitrary app-authored exposure tasks or a specific micro-timer.

4. Polak M, Tanzer NK. 2024.
   `Internet-Based Cognitive Behavioural Treatments for Obsessive-Compulsive Disorder: A Systematic Review and Meta-Analysis.`
   Clin Psychol Psychother. 31(3):e2989.
   PMID: 38769929.
   DOI: 10.1002/cpp.2989.

   Interpretation:
   Structured internet-delivered CBT for OCD can be beneficial. The evidence concerns defined CBT programs/trials, not unrestricted generative practice content.

### C. Mechanism / conceptual evidence

5. Knowles KA, Olatunji BO. 2023.
   `Intolerance of Uncertainty as a Cognitive Vulnerability for Obsessive-Compulsive Disorder: A Qualitative Review.`
   Clin Psychol (New York). 30(3):317-330.
   PMID: 39431164.
   DOI: 10.1037/cps0000150.

   Interpretation:
   Intolerance of uncertainty is consistently associated with OCD and often changes during treatment, but evidence is insufficient to state that increasing uncertainty tolerance is a necessary or sufficient mechanism of OCD improvement.

6. Craske MG et al. 2014.
   `Maximizing exposure therapy: an inhibitory learning approach.`
   Behav Res Ther. 58:10-23.
   PMID: 24864005.
   DOI: 10.1016/j.brat.2014.04.006.

   Interpretation:
   Immediate fear/anxiety reduction during an exposure is not a reliable required marker of therapeutic learning. Therefore TrueGround must not use "feel calmer" as the completion rule for Practice.

7. Jacoby RJ, Abramowitz JS. 2016.
   `Inhibitory learning approaches to exposure therapy: A critical review and translation to obsessive-compulsive disorder.`
   Clin Psychol Rev. 49:28-40.
   PMID: 27521505.
   DOI: 10.1016/j.cpr.2016.07.001.

   Interpretation:
   Habituation-only framing is too narrow, and exposure design is more complex than a generic timer or simple distress-reduction loop.

### D. Reassurance / checking evidence

8. Parrish CL, Radomsky AS. 2010.
   `Why do people seek reassurance and check repeatedly? An investigation of factors involved in compulsive behavior in OCD and depression.`
   J Anxiety Disord. 24(2):211-222.
   PMID: 19939622.
   DOI: 10.1016/j.janxdis.2009.10.010.

9. Salkovskis PM, Kobori O. 2015.
   `Reassuringly calm? Self-reported patterns of responses to reassurance seeking in obsessive compulsive disorder.`
   J Behav Ther Exp Psychiatry. 49(Pt B):203-208.
   PMID: 26433701.
   DOI: 10.1016/j.jbtep.2015.09.002.

   Interpretation:
   Reassurance can function similarly to checking and may produce short-term relief while the broader uncertainty/checking cycle returns. This supports avoiding fresh certainty as Practice feedback.

### E. Ritual-delay evidence

10. Junginger J, Head S. 1991.
    `Time series analysis of obsessional behavior and mood during self-imposed delay and response prevention.`
    Behav Res Ther. 29(6):521-530.
    PMID: 1759952.
    DOI: 10.1016/0005-7967(91)90002-K.

    Interpretation:
    Self-imposed delay has some historical support, but the study is tiny and old. It is not adequate evidence for a universal app countdown duration or an efficacy claim.

## EVIDENCE-STRENGTH SUMMARY

| Question | Evidence strength for LOT07A decision | Decision |
|---|---|---|
| Is ERP/response prevention evidence-based for OCD? | Strong | Respect the principle, but do not impersonate a full ERP protocol. |
| Can structured low-intensity/self-help CBT exist? | Moderate to strong | A bounded digital support tool is plausible, but content must remain structured and controlled. |
| Is intolerance of uncertainty relevant to OCD? | Moderate | Use cautious non-causal language; no mechanism/efficacy claim. |
| Must anxiety fall during practice for the practice to count? | No | Never gate completion on distress reduction. |
| Is repeated reassurance/checking a relevant compulsion risk? | Moderate | Do not give fresh certainty or invite checking after Practice. |
| Is a specific ritual-delay timer clinically established? | Weak | Do not choose a timer duration or present a countdown as validated. |
| Does digital-CBT evidence justify generic LLM exposure generation? | No | Explicitly forbidden. |

## DECISION 1 — NO AUTONOMOUS EXPOSURE GENERATION

### Finding

The strongest treatment evidence supports structured ERP, not uncontrolled model-generated exposures.

### LOT07A decision

LOT07B will contain:

- no generated exposure;
- no hierarchy;
- no trigger personalization;
- no free-text feared-scenario entry;
- no probability estimate;
- no clinician simulation.

### Verdict

PASS for prototype boundary.

## DECISION 2 — "PAUSE THE RITUAL" IS NOT A TIMER TREATMENT

### Finding

Response prevention is central to ERP, and very limited evidence exists for self-imposed delay. There is no scientific basis in the inspected evidence for TrueGround to claim that a specific 30-second, 2-minute or 10-minute countdown is therapeutic.

A countdown also creates a plausible OCD-product risk: restarting or checking the timer could become the new ritual.

### LOT07A decision

Use a user-paced, finite UI sequence with no countdown.

The app does not classify the behavior as a compulsion. The user initiates the practice only when they already recognize an urge they want to pause.

### Verdict

PASS_WITH_NOTES.

Note:
This is a conservative product-support interaction, not a validated treatment protocol.

## DECISION 3 — "PRACTICE UNCERTAINTY" MUST NOT BECOME REASSURANCE OR A MANTRA

### Finding

Uncertainty is clearly relevant to OCD, but causal/mechanistic evidence remains incomplete.

A fixed phrase may itself become ritualized if repetition is encouraged.

### LOT07A decision

The neutral stance:

`I may not know for sure right now.`

may appear once in the bounded flow.

The app must not:

- ask the user to repeat it;
- count repetitions;
- loop audio;
- present it until anxiety falls;
- claim it changes OCD symptoms.

### Verdict

PASS_WITH_NOTES.

## DECISION 4 — COMPLETION MUST NOT MEAN "SUCCESSFULLY RESISTED"

### Finding

A perfectionistic completion system risks turning the app into a new checking surface.

Exposure-learning literature also does not justify using immediate anxiety reduction as the success criterion.

### LOT07A decision

"Completed" means only that the UI reached its end state.

No rating, success badge, streak, "you resisted", anxiety delta or correctness check.

### Verdict

PASS.

## DECISION 5 — HONEST EMPTY STATE FOR SAVED PRACTICE

### Finding

The repository has no approved saved-practice persistence.

### LOT07A decision

`Continue planned practice` must explicitly state that no saved practice is available.

No fake dates, inferred history or simulated memory.

### Verdict

PASS.

## DECISION 6 — PHYSICAL SAFETY IS OUTSIDE AUTONOMOUS PRACTICE

### Finding

A product cannot safely tell a user to delay every form of checking without understanding whether the check addresses an objective safety, medical, legal or professional responsibility.

### LOT07A decision

Practice includes a concise boundary:

`Not for urgent safety, medical or emergency decisions.`

No contextual adjudication is attempted in LOT07B.

### Verdict

PASS_WITH_NOTES.

Limitation:
A future richer practice engine would require a dedicated safety/escalation policy and potentially clinical review.

## DECISION 7 — NO PROVIDER IS SAFER FOR THIS LOT

### Finding

Nothing in the Gate 7 minimum scope requires a model or provider.

Introducing generation would enlarge the safety surface without solving a required product need.

### LOT07A decision

LOT07B is local and deterministic.

### Verdict

PASS.

## DECISION 8 — PRACTICE MUST NOT BYPASS LOT06

### Finding

LOT06 exists to avoid fresh reassurance/checking reinforcement.

A Practice tool that tells users they are safe, correct, improving or sufficiently certain would undermine the firewall even without calling it directly.

### LOT07A decision

LOT07B contains no certainty feedback, reassurance, outcome prediction or correctness grading.

### Verdict

PASS.

## STRONGEST REASONS NOT TO APPROVE A MORE AMBITIOUS VERSION

1. No independent OCD clinician has validated TrueGround's exact Practice copy.
2. No crisis/escalation policy is yet complete for production.
3. No physical-safety classifier exists.
4. No approved exposure-authoring/hierarchy system exists.
5. No validated longitudinal saved-practice model exists.
6. No real-user clinical outcome evidence exists for these micro-flows.
7. The specific ritual-delay evidence is weak and cannot justify a therapeutic countdown.
8. Uncertainty-tolerance evidence is relevant but not sufficient for a causal efficacy claim.
9. Repetition of a "coping phrase" can itself become ritualized.
10. A generative model would increase safety variance with no need in current Gate 7 scope.

## SCIENTIFIC CLAIM VERDICT

The following statement is supported:

> LOT07B may implement a bounded, deterministic, non-personalized Practice prototype that avoids reassurance, avoids anxiety-reduction goals, and does not generate exposures.

The following statement is NOT supported:

> TrueGround's LOT07 micro-practices are clinically validated ERP treatment.

The following statement is NOT supported:

> These practices will reduce OCD symptoms, anxiety, compulsions or relapse.

## SPECIALIST-STYLE REVIEW

OCD_SAFETY_AGENT: PASS_WITH_NOTES

Evidence:
- strict non-reassurance copy boundary;
- no anxiety-reduction success criterion;
- no generated exposure;
- no hierarchy;
- no score/streak;
- physical-safety exclusion;
- no replay CTA.

Notes:
- not independent clinician validation;
- production clinical claims remain blocked.

CONTENT_COPY_AGENT: PASS_WITH_NOTES

Evidence:
- no diagnostic copy;
- no efficacy promise;
- no "safe"/"nothing bad will happen" reassurance;
- no punitive or perfectionistic copy.

Notes:
- final rendered copy must be re-reviewed after LOT07B UI implementation.

ARCHITECTURE_AGENT: PASS

Evidence:
- no Core change;
- no provider;
- no persistence;
- OCD semantics stay capsule-side.

DATA_PRIVACY_SECURITY_AGENT: PASS

Evidence:
- no data collection introduced by contract;
- no persistence;
- no analytics;
- no user content transmission.

REGULATORY_CLINICAL_REVIEW: BLOCKED_FOR_PRODUCTION_CLAIMS / NOT_REQUIRED_FOR_NON_CLAIM_PROTOTYPE

Reason:
Human-qualified clinical review remains required before representing the feature as treatment delivery or making clinical efficacy claims.

## FINAL 07A SCIENTIFIC VERDICT

`PASS_WITH_NOTES — PROCEED TO LOT07B PROTOTYPE IMPLEMENTATION WITHIN CONTRACT`

This verdict does not authorize:

- treatment claims;
- generated/personalized ERP;
- production release;
- merge;
- deployment.


## EVIDENCE TRANSFER UPDATE

See docs/ocd/reviews/LOT_07_EVIDENCE_TRANSFER_MATRIX.md.

The broad residual statement 'no real-user clinical outcome evidence exists for these micro-flows' is retained only as a claims boundary, not as a requirement to reproduce established OCD science before LOT07 acceptance.

External evidence is considered transferable for ERP/response-prevention principles, structured digital/self-help delivery, non-reassurance design, non-habituation success criteria, and caution around checking-friendly digital mechanics.

Targeted TrueGround-specific human validation remains appropriate for exact wording, disabled-state interpretation, hidden 2-hour anti-replay behavior, urgent-safety comprehension, ritualization of the uncertainty phrase, and French localization.

This update does not convert LOT07 into a clinically validated treatment and does not authorize efficacy claims.
