# LOT 05 — BOUNDED LOOP SAFETY EVAL CASES

Status: VERSIONED LOT 05 EVAL SET  
Scope: deterministic local-only Bounded Loop flow  
Provider/model: none  
Persistence: none  
Free-text input: none

## Evaluation rule

LOT 05 deliberately avoids unrestricted free text and provider generation. The user chooses one bounded pattern and one approved next action. Repetition detection, paraphrase matching and longitudinal policy belong to LOT 06.

| Case | LOT 05 route | Expected behavior |
|---|---|---|
| Ordinary/ambiguous context | Something else | No diagnosis; one bounded next action |
| Reassurance / certainty seeking | I want certainty | Does not settle the certainty question |
| Checking request | I want to check | Does not verify the answer |
| Rumination / endless analysis | I'm stuck analyzing | Does not invite more analysis |
| Confession / repetition | I'm repeating or confessing | Does not request repeated details |
| Retrospective certainty seeking | I want certainty | Same bounded certainty policy; no historical proof |
| Repeated what-if / yes-no pressure | I want certainty | No free-text channel for repeated certainty interrogation |
| Intrusive thought/image | Intrusive thought or image | Does not infer intent or diagnose from the thought |
| Genuine acute-risk disclosure | BLOCKED for production | No free-text risk assessment exists in LOT 05; persistent Support escape hatch remains visible, but a dedicated reviewed crisis policy is required before release |
| Unsupported medical/diagnostic request | UI boundary | No open text/chat channel exists; no diagnostic answer surface |
| Provider failure | NOT_APPLICABLE | LOT 05 has no provider dependency |
| Persistence/memory failure | NOT_APPLICABLE | LOT 05 stores no longitudinal content |

## Explicit limits

- This is not the LOT 06 Compulsion Firewall.
- It does not detect paraphrased repeats.
- It does not classify raw user text.
- It does not provide regional crisis instructions.
- It does not claim to assess acute risk; production crisis/acute-risk handling remains blocked pending the dedicated reviewed policy.
- It does not diagnose OCD or infer intent.
- Support is a navigation boundary, not proof that a person or emergency service was contacted.
