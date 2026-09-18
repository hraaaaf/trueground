# LOT 08 — Values and Human Support Contract

Project: TrueGround OCD
Date: 2026-09-19
Target gate: GATE 8 — VALUES_SUPPORT_VERIFIED
Base: 25f08540b3f8d3bd53147f069b83e2da6f53d320

## GOAL

Help the user move from an OCD loop toward a self-chosen real-life direction while preserving a truthful route to real people.

## SUCCESS

LOT08 succeeds only if:

- `Return to what matters` is user-led and finite;
- the app does not decide what the user should value;
- the values flow does not promise calm, certainty, symptom reduction, safety or treatment;
- the values flow does not become a perfection/checking tool;
- no score, timer, streak, badge or completion pressure is introduced;
- `Need a person, not an answer?` opens a real support route rather than a placeholder;
- the app never claims a call/message/contact occurred;
- trusted-person guidance does not encourage reassurance accommodation;
- no therapist/trusted-person contact is persisted;
- no regional resource is fabricated;
- Core IAmina remains untouched.

## PROOF

- focused widget tests;
- full Flutter regression tests;
- routing tests;
- copy/safety guard in CI;
- 360 px and 390 px visual evidence;
- before/after Support-route screenshots;
- scientific alignment review;
- strict double-score after exact-head CI.

## Approved implementation boundary

### Values

Session-only state:

`choose area -> confirm own next step -> leave flow`

The app may offer broad non-ranked categories, including an `other` choice, but must not collect free text or generate a personalized value/action in this lot.

The terminal state must redirect the user toward action outside the flow. It must not congratulate, score, ask for symptom relief, or invite repeated checking.

### Human support

Allowed:

- trusted person chosen by the user;
- therapist/care-team route the user already has;
- generic direction to a verified local source outside TrueGround.

Not allowed in this lot:

- stored contact configuration;
- automatic call/SMS/message;
- claims that anyone was contacted;
- unvalidated regional directories;
- crisis-routing claims;
- provider/LLM behavior.

## Human gates intentionally not crossed

Therapist/trusted-person persistence and region-specific support resources remain unimplemented until explicitly approved and validated.
