# LOT11-G — UX Anti-Dependency Review

Date: 2026-10-02
Repository: `hraaaaf/trueground`
Branch: `lot/11g-prehuman-validation`
Certified starting base: `f21881bef53cd952c06304f9451b08ee92279066`

## GOAL

Review the conversational UX for mechanics or wording that could encourage repeated reassurance seeking, checking, rumination, compulsive questioning, ritualisation, or conversational dependency.

This review is a product/safety review. It is not clinical validation and does not establish treatment efficacy.

## ENTRY POINTS REVIEWED

TrueGround exposes the companion through:
- the dashboard **Talk it through** card;
- the floating companion launcher;
- the dedicated `/companion` route reached from the dashboard card.

Two entry points are retained because existing executable tests prove that reopening the companion does not reset the deterministic safety session.

Provider context is intentionally cleared when the popup closes, while OCD safety repetition state survives. This prevents a close/reopen action from becoming a deterministic-loop bypass.

## BOUNDEDNESS

The compact companion is capped at **12 user messages** per open conversation surface.

The 13th message is blocked by the UI and does not reach the provider.

There is no regenerate control, alternate-answer carousel, certainty retry, or automatic provider retry in the companion UX.

## CONFIRMED COPY DEFECT

The previous UI used all three of these stale single-turn statements:
- `One bounded response, then choose your next move.`
- `TrueGround may respond once`
- `Send once`

That wording contradicted the already-shipped bounded multi-turn behavior.

The wording is changed to describe a bounded conversation without implying unlimited access:
- dashboard: `One grounded turn at a time.`
- companion: `Use brief messages. TrueGround can continue a bounded conversation or route you to an existing tool...`
- submit action: `Send`

French copy is updated directly rather than falling back to English.

## ANTI-DEPENDENCY ACCEPTANCE CONDITIONS

The UX passes this review only if all of the following remain true:
1. repeated reassurance/checking/rumination/confession can deterministically leave the companion and pivot to the existing loop route;
2. closing and reopening the popup cannot reset OCD repetition safety state;
3. the provider context remains ephemeral and bounded;
4. the compact surface remains capped at 12 user messages;
5. no regenerate/retry-for-another-answer mechanic exists;
6. no streak, score, countdown, engagement reward, or conversation-frequency reward is introduced;
7. fail-closed states do not invite immediate repeated prompting;
8. EN and FR communicate equivalent boundaries;
9. 360/390/430/768/1280 remain usable;
10. 200% text scaling remains usable without hiding the primary input/action.

## VISUAL PROOF REQUIREMENT

LOT11-G CI must produce before/after screenshots from:
- certified base `f21881b…`;
- current exact HEAD.

Required widths:
- 360
- 390
- 430
- 768
- 1280

Required additional 200% text evidence:
- EN at 360
- FR at 430

No UI conclusion is valid until those artifacts are generated successfully and reviewed.

## CURRENT STATUS

Implementation complete; exact-head visual evidence pending CI at the time this document was created.
