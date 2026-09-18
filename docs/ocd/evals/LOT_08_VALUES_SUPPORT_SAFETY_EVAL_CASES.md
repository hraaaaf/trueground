# LOT 08 — Values and Human Support Safety Eval Cases

Project: TrueGround OCD
Date: 2026-09-19

## Purpose

Evaluate structural risks introduced by deterministic LOT08 screens. These are product-safety cases, not diagnostic tests.

## Values-flow cases

| Case | Risk | Required behavior |
|---|---|---|
| User wants the app to tell them the perfect value | perfection/checking | app offers broad choices and states there is no best answer |
| User wants certainty before acting | reassurance | copy does not resolve uncertainty and redirects toward self-chosen action |
| User repeatedly uses the flow to feel calm | ritualization | no calming promise, score, timer, completion reward or repeated-practice CTA |
| User chooses Faith/meaning | scrupulosity | category is user-selected and not interpreted, graded or moralized |
| User selects Other | sensitive free text / rumination | no free-text field is opened in LOT08 |
| User reaches terminal state | engagement loop | flow ends and redirects toward real-life action |

## Human-support cases

| Case | Risk | Required behavior |
|---|---|---|
| User chooses trusted person | reassurance accommodation | guidance favors presence/practical support, not repeated certainty |
| User assumes app contacted trusted person | fabricated action | explicit copy states TrueGround has not contacted them |
| User chooses therapist/care team | false persistence/action | explicit copy states no therapist contact is stored and no contact occurred |
| User asks for local professional resource | hallucinated directory | no service is named unless region-validated; current build states none is configured |
| User has no configured support person | dead end | route offers user-chosen trusted person, existing care route, or verified source outside TrueGround |
| Crisis/acute risk | scope confusion | LOT08 must not claim crisis routing; dedicated regional crisis policy remains separate |

## Automated guards

CI must fail if LOT08 code introduces:

- provider/LLM markers;
- database/persistence markers;
- free-text fields;
- clinical-efficacy claims;
- certainty/safety reassurance copy;
- fake-contact success language.

## Non-regression

Full test suite must still cover LOT03-LOT07 behavior, including Compulsion Firewall and Practice anti-replay.
