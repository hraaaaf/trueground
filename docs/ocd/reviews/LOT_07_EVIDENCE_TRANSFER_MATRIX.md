# LOT 07 — Evidence Transfer Matrix

Project: TrueGround OCD
Scope: Practice experience + LOT07C anti-replay
Date: 2026-09-18
Status: EVIDENCE TRANSFER REVIEWED

## GOAL

Replace the broad requirement for a full TrueGround user study with a stricter evidence-transfer model:

1. reuse high-quality external evidence where the behavior is genuinely equivalent;
2. do not re-test established OCD science merely because TrueGround has a new interface;
3. require targeted human validation only where TrueGround introduces a materially new interaction, wording, timing rule, or digital compulsion risk.

This document does NOT claim that TrueGround itself has demonstrated clinical efficacy.

## EVIDENCE TRANSFER LEVELS

- TRANSFERABLE — external evidence directly supports the underlying behavior/design constraint well enough that TrueGround does not need to re-establish the clinical principle from zero.
- PARTIALLY TRANSFERABLE — evidence supports the direction, but TrueGround-specific implementation details can materially alter safety or usability.
- NOT TRANSFERABLE / TRUEGROUND-SPECIFIC — external evidence cannot validate this exact implementation; targeted human review or testing remains required.

## MATRIX

| TrueGround behavior / decision | External evidence | Transfer level | What we may inherit | What we may NOT claim | TrueGround-specific validation still needed |
|---|---|---|---|---|---|
| ERP / response prevention is an evidence-based OCD treatment principle | NICE CG31; Reid et al. 2021 meta-analysis (PMID 33618297) | TRANSFERABLE | Response prevention is a legitimate evidence-based treatment component in structured OCD care. | LOT07 micro-practice itself is validated ERP treatment. | No efficacy study needed merely to re-prove that ERP exists; treatment claims remain separately blocked. |
| Structured low-intensity / self-help digital support is plausible | NICE CG31; Andersson et al. RCT; Polak & Tanzer 2024 meta-analysis (PMID 38769929) | TRANSFERABLE WITH SCOPE LIMIT | Digital/self-help delivery can support structured OCD CBT/ERP. | Any arbitrary digital interaction is effective; unrestricted autonomous ERP is validated. | Validate only TrueGround-specific interaction choices. |
| Brief digital guidance can support out-of-session ERP adherence | OC-Go RCT, Tuerk et al. 2024 (PMID 38418042) | PARTIALLY TRANSFERABLE | Stepwise mobile support around structured ERP can be usable and feasible. | OC-Go efficacy transfers to TrueGround; pediatric clinician-guided findings equal adult autonomous use. | TrueGround wording, autonomy level, and anti-replay interaction. |
| Do not give repeated reassurance / certainty | Salkovskis & Kobori 2015 (PMID 26433701); Starcevic et al. 2012 (PMID 22776755); NICE 1.5.2.9 | TRANSFERABLE | Reassurance seeking can function like checking and is clinically relevant to OCD maintenance patterns. | Every request for clarification is compulsive; withholding support is always correct. | Ensure TrueGround distinguishes supportive tone from certainty/reassurance. |
| Completion must not depend on feeling calm | Craske et al. 2014; Jacoby & Abramowitz 2016 (PMID 27521505) | TRANSFERABLE | Immediate anxiety reduction is not required as the success criterion for exposure learning. | TrueGround’s brief practice produces inhibitory learning or clinical improvement. | Copy review only. |
| Leave uncertainty unresolved without proving safety/unsafety | Knowles & Olatunji 2023 review (PMID 39431164) | PARTIALLY TRANSFERABLE | Intolerance of uncertainty is relevant to OCD and supports avoiding certainty-seeking framing. | Increasing uncertainty tolerance is proven to be the causal mechanism of TrueGround benefit. | Exact phrase and whether users ritualize it. |
| No streaks, progress pressure, repeated metrics, or compulsive UI loops | Occhino-Moede et al. 2026 qualitative technology/OCD study (PMID 41643128) | PARTIALLY TRANSFERABLE, HIGH DESIGN RELEVANCE | Gamification, quantification, notifications and complex/customizable interfaces can become checking/ordering triggers for some people with OCD. | Every metric or notification universally worsens OCD. | TrueGround-specific UI should be reviewed for new checking affordances. |
| No prominent immediate replay after completion | Reassurance/checking literature + digital compulsion evidence | PARTIALLY TRANSFERABLE | Removing immediate repetition affordances is directionally consistent with avoiding checking/repetition loops. | A particular replay block duration is clinically validated. | Exact disabled-state wording and whether the disabled card becomes a checking cue. |
| Persist anti-replay across restart | No direct trial of this exact product behavior found | NOT TRANSFERABLE / TRUEGROUND-SPECIFIC | Persistence may be justified as an internal UX guard against restart-based replay. | Persistence itself is therapeutic. | Functional testing + targeted human-factors review. |
| Two-hour anti-replay window | No direct evidence validating 2h as a clinical interval | NOT TRANSFERABLE / TRUEGROUND-SPECIFIC | Only a product UX convention, hidden from the user. | 2h is an ERP dose, recommended frequency, therapeutic interval, or clinically optimal duration. | Targeted review of perceived restriction/checking behavior; no efficacy study required unless a clinical claim is introduced. |
| Safety note: not for urgent safety, medical or emergency decisions | General clinical risk boundary; LOT07 lacks context to infer objective risk | PARTIALLY TRANSFERABLE | Autonomous Practice must not advise delaying objectively necessary safety actions. | The note guarantees users will classify real-world risk correctly. | Comprehension testing of exact copy, especially in French. |
| No generated/personalized exposure in LOT07 | Digital CBT trials use structured protocols; evidence does not establish unrestricted generative exposure | TRANSFERABLE AS A SAFETY CONSTRAINT | Conservative deterministic scope is justified. | Generative ERP is unsafe in all future designs or impossible to validate. | Any future generative exposure system requires a new evidence and clinical safety gate. |
| Homework/practice adherence matters in structured ERP | Adherence literature; Tuerk et al. OC-Go | TRANSFERABLE WITH CONTEXT | Between-session practice/adherence can matter in structured ERP treatment. | More app use is always better; streaks or frequency pressure are justified. | TrueGround must avoid converting adherence evidence into compulsive engagement mechanics. |

## REVISED VALIDATION MODEL

A broad 'real-user clinical outcome study is mandatory before LOT07 can be accepted' is too coarse.

### Already covered sufficiently by external evidence

TrueGround does NOT need a proprietary study merely to re-establish:
- that ERP/response prevention is an evidence-based OCD treatment principle;
- that structured digital/self-help OCD CBT can be a legitimate delivery format;
- that reassurance/checking is clinically relevant;
- that immediate calm is not a necessary success criterion;
- that quantification/checking-friendly digital mechanics deserve caution.

### Still TrueGround-specific

Before broad real-world release, targeted validation should focus on only these unresolved implementation questions:

1. Does 'Pause finished for now' reduce immediate replay without becoming a new checking cue?
2. Do users understand the disabled state without feeling punished or prescribed a frequency?
3. Does 'I may not know for sure right now.' remain a one-time uncertainty stance rather than becoming a mantra?
4. Is 'Not for urgent safety, medical or emergency decisions.' correctly understood?
5. Does the French localization preserve the non-reassurance / non-prescriptive meaning?
6. Does the 2-hour hidden anti-replay rule produce unexpected workaround/checking behavior?
7. Are there accessibility or navigation patterns that encourage repeated reopening?

These can be assessed with a small targeted human-factors/usability safety validation rather than a de novo clinical efficacy trial.

## WHAT STILL REQUIRES A CLINICAL STUDY

A clinical efficacy study becomes necessary if TrueGround wants to claim any of the following:

- TrueGround treats OCD;
- TrueGround reduces Y-BOCS / OCI-R symptoms;
- the Practice micro-flows are clinically validated ERP;
- the 2-hour rule improves treatment outcomes;
- TrueGround is equivalent or non-inferior to therapist-guided ERP;
- TrueGround prevents relapse or compulsions.

LOT07 makes none of these claims.

## VERDICT

EVIDENCE_TRANSFER: PASS_WITH_TARGETED_GAPS

The scientific literature is sufficient to support the current LOT07 design direction and many of its safety constraints without requiring TrueGround to reproduce established OCD treatment science from zero.

The remaining human-validation requirement is narrowed to TrueGround-specific UX/safety transfer gaps, not broad clinical efficacy.

This verdict does not authorize treatment claims, merge, deployment, autonomous ERP, production data changes, or clinician substitution.

## REFERENCES

1. NICE. Obsessive-compulsive disorder and body dysmorphic disorder: treatment. CG31, recommendations 1.5.1 and 1.5.2.
2. Reid JE et al. Compr Psychiatry. 2021;106:152223. PMID: 33618297.
3. Polak M, Tanzer NK. Clin Psychol Psychother. 2024;31(3):e2989. PMID: 38769929.
4. Andersson E et al. Internet-based CBT for OCD: randomized controlled trial. Psychol Med. 2012.
5. Kyrios M et al. Therapist-assisted internet CBT versus progressive relaxation in OCD. JMIR. 2018.
6. Tuerk PW, McGuire JF, Piacentini J. Behav Ther. 2024;55(2):306-319. PMID: 38418042.
7. Salkovskis PM, Kobori O. J Behav Ther Exp Psychiatry. 2015;49(Pt B):203-208. PMID: 26433701.
8. Starcevic V et al. Psychiatry Res. 2012. PMID: 22776755.
9. Knowles KA, Olatunji BO. Clin Psychol (New York). 2023;30(3):317-330. PMID: 39431164.
10. Jacoby RJ, Abramowitz JS. Clin Psychol Rev. 2016;49:28-40. PMID: 27521505.
11. Occhino-Moede L et al. Interactions of Technology and OCD Symptomatology in Adults: Qualitative Interview Study. PMID: 41643128.
12. Patient adherence to CBT predicts long-term outcome in OCD. PMCID: PMC3951095.
13. Effect of internet-based vs face-to-face CBT for adults with OCD: randomized clinical trial. PMCID: PMC9907343.
