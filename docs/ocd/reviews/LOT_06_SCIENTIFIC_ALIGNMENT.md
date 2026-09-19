# LOT 06 — Scientific alignment review

Date: 2026-09-18
Scope: Compulsion Firewall product-safety direction only.
Status: EVIDENCE REVIEW — NOT CLINICAL VALIDATION

## Question

Is it scientifically defensible for TrueGround to avoid giving fresh certainty when a session shows a high-confidence repeated reassurance/checking/rumination pattern, while preserving ordinary information, clarification and human-support paths?

## Cross-source findings

1. NICE CG31 recommends CBT/ERP for OCD and explicitly addresses reducing family/carer involvement in compulsions, avoidance and reassurance seeking in a sensitive, supportive manner.
2. Parrish & Radomsky (2010, PMID 19939622) experimentally examined repeated reassurance and repeated checking as related compulsive behaviours.
3. Starcevic et al. (2012, PMID 22776755) found reassurance seeking common in an OCD sample and closely associated with checking compulsions.
4. Halldorsson et al. (2015, PMID 26433701) reported that reassurance can produce short-term relief followed by return of discomfort and renewed reassurance urge.
5. Halldorsson & Salkovskis (2023, DOI 10.1016/j.jocrd.2023.100783) frame excessive reassurance seeking as a safety-seeking behaviour and emphasize distinguishing reassurance from supportive responses.
6. Causier & Salkovskis (2025, PMID 39232282) experimentally compared reassurance with emotional support; support was more acceptable and reduced anticipated reassurance-seeking urge.
7. Strauss et al. (2020, PMID 31901881) meta-analysed repeated checking and supports treating checking as a meaningful repetitive behaviour rather than reducing it to a single threat cue.
8. Hermida-Barros et al. (2024, PMID 38621516) found family accommodation associated with OCD severity and reduced after CBT, supporting caution around participation in rituals/reassurance.
9. Golden & Aboujaoude (2026, DOI 10.1038/s41746-026-02531-7) propose a transdiagnostic model in which general-purpose AI chatbots may reinforce reassurance, checking, confessing and extended analysis through low-friction repetition and short-term relief.
10. Occhino-Moede et al. (2026, PMID 41643128) qualitatively report that information platforms, including LLMs, can facilitate checking and reassurance-seeking for some people with OCD.

## Product conclusion

The evidence supports the safety direction of NOT supplying repeated fresh certainty when the same reassurance/checking function reappears. It also supports preserving supportive, non-shaming alternatives rather than merely refusing.

LOT06 therefore uses:
- cautious behavioural wording ("may be"), never diagnosis;
- a bounded session window;
- subject + interaction-function evidence before redirecting;
- no automatic block of the first reassurance-like turn;
- false-positive escape paths for genuine context changes;
- redirection to the existing bounded Loop;
- human-support escape preserved;
- no longitudinal memory until privacy/memory gates are verified.

## What the evidence does NOT establish

- It does not validate this classifier as a diagnostic instrument.
- It does not prove TrueGround treats OCD.
- It does not justify labeling every repeated question as a compulsion.
- It does not justify withholding ordinary factual information indiscriminately.
- It does not validate autonomous ERP or crisis handling.
- The 2026 AI paper is a mechanistic/perspective framework, not an RCT of TrueGround.
- The 2026 technology study is qualitative and should not be interpreted as causal efficacy evidence.

## Engineering implication

False-positive resistance is a safety requirement, not a convenience metric. The firewall should require evidence that the topic/function repeats, remain auditable through non-sensitive reason codes, and fail toward bounded support rather than stronger certainty.
