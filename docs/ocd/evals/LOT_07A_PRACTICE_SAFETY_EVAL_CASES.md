# LOT 07A — Practice Safety / Content Eval Cases

Status: VERSIONED BASELINE
Date: 2026-09-18
Contract: `docs/ocd/lots/LOT_07A_PRACTICE_SCIENTIFIC_CONTENT_CONTRACT.md`

## PURPOSE

Define adversarial and normal cases that LOT07B must satisfy.

These are product-behavior invariants. They are not a diagnostic or clinical validation dataset.

## OUTCOME LABELS

- `ALLOW`: behavior/copy is inside LOT07A contract.
- `BLOCK`: behavior/copy violates contract.
- `DEGRADE`: honest non-functional/empty state required.
- `EXIT`: practice should end or allow immediate exit without grading.
- `HUMAN_GATE`: would require a new clinical/product decision before implementation.

## PAUSE THE RITUAL

| ID | Scenario | Expected |
|---|---|---|
| P01 | User opens Pause from Practice | ALLOW: finite start state |
| P02 | User starts brief pause | ALLOW: move to one bounded pause state |
| P03 | UI proposes a 5-minute validated timer | BLOCK |
| P04 | UI says "wait until anxiety drops" | BLOCK |
| P05 | UI says "the urge will pass" | BLOCK |
| P06 | UI says "nothing bad will happen" | BLOCK |
| P07 | UI says "you are safe" about feared outcome | BLOCK |
| P08 | UI asks "how anxious are you 0–10?" | BLOCK |
| P09 | UI asks whether user resisted correctly | BLOCK |
| P10 | UI shows a completion streak | BLOCK |
| P11 | UI shows "Repeat" after completion | BLOCK |
| P12 | User exits midway | EXIT without penalty |
| P13 | User manually returns after accidental navigation | ALLOW; no compulsion label |
| P14 | User wants app to decide whether a real safety check is necessary | HUMAN_GATE / unsupported |
| P15 | Practice involves medication/safety equipment verification | HUMAN_GATE / unsupported |
| P16 | User reaches end while still distressed | ALLOW end; no calm requirement |
| P17 | Completion screen says "Practice ends here" | ALLOW |
| P18 | Completion screen says "You successfully prevented a compulsion" | BLOCK |
| P19 | App asks user to breathe until calm | BLOCK |
| P20 | App offers one ordinary navigation-away CTA | ALLOW |

## PRACTICE UNCERTAINTY

| ID | Scenario | Expected |
|---|---|---|
| U01 | User opens Practice uncertainty | ALLOW |
| U02 | UI frames task as leaving a question unresolved | ALLOW |
| U03 | UI asks user to type the feared scenario | BLOCK |
| U04 | Generic model generates an exposure statement | BLOCK |
| U05 | UI estimates probability feared event occurs | BLOCK |
| U06 | UI gives certainty that feared event will not occur | BLOCK |
| U07 | UI shows "I may not know for sure right now" once | ALLOW |
| U08 | UI asks user to repeat phrase 10 times | BLOCK |
| U09 | UI loops phrase as audio | BLOCK |
| U10 | UI says phrase is clinically proven | BLOCK |
| U11 | UI asks whether uncertainty feels lower | BLOCK |
| U12 | UI requires distress to decrease before Finish enables | BLOCK |
| U13 | UI ends without rating | ALLOW |
| U14 | User exits before end | EXIT |
| U15 | UI generates hierarchy from user's obsession | HUMAN_GATE |
| U16 | UI prescribes deliberate contact with feared trigger | HUMAN_GATE |
| U17 | UI states "this treats OCD" | BLOCK |
| U18 | UI states "practice ends here" | ALLOW |
| U19 | UI says "you did it perfectly" | BLOCK |
| U20 | UI offers replay until it feels right | BLOCK |

## CONTINUE PLANNED PRACTICE

| ID | Scenario | Expected |
|---|---|---|
| C01 | No persistence exists | DEGRADE honestly |
| C02 | UI says "No saved practice is available in this version." | ALLOW |
| C03 | UI invents "Last practiced yesterday" | BLOCK |
| C04 | UI invents a default exposure plan | BLOCK |
| C05 | UI displays a fake streak | BLOCK |
| C06 | UI implies cloud history was checked | BLOCK |
| C07 | UI offers Back to Practice | ALLOW |
| C08 | UI offers Return to Home | ALLOW |
| C09 | Implementation adds local database solely for LOT07 | HUMAN_GATE |
| C10 | Implementation adds account/provider history | HUMAN_GATE |

## REPETITION / COMPULSION RISK

| ID | Scenario | Expected |
|---|---|---|
| R01 | Completed practice exposes prominent Again button | BLOCK |
| R02 | Completed practice auto-restarts | BLOCK |
| R03 | User navigates back manually | No diagnosis/shaming |
| R04 | UI says "you are repeating compulsively" based on one retry | BLOCK |
| R05 | Accessibility retry | ALLOW |
| R06 | Retry after UI error | ALLOW |
| R07 | Repeated practice creates score/count | BLOCK |
| R08 | Practice recommends "one more round" | BLOCK |
| R09 | User asks if they practiced enough | No reassurance/correctness feedback |
| R10 | User asks if they did it right | No correctness guarantee |
| R11 | User still feels uncertain at end | End remains enabled |
| R12 | User still feels anxious at end | End remains enabled |

## CLAIM / COPY SAFETY

| ID | Copy | Expected |
|---|---|---|
| K01 | "Create space before acting." | ALLOW |
| K02 | "Leave the question unanswered for this moment." | ALLOW |
| K03 | "You do not need to feel calm before moving on." | ALLOW |
| K04 | "This will reduce your OCD." | BLOCK |
| K05 | "Clinically proven." | BLOCK |
| K06 | "This exposure is prescribed for you." | BLOCK |
| K07 | "Your anxiety should go down." | BLOCK |
| K08 | "Discomfort means it is working." | BLOCK |
| K09 | "TrueGround knows this is a compulsion." | BLOCK |
| K10 | "You may have OCD." as diagnosis from practice use | BLOCK |
| K11 | "Not for urgent safety, medical or emergency decisions." | ALLOW |
| K12 | "Nothing has been stored to resume yet." | ALLOW |

## ARCHITECTURE / DATA

| ID | Change | Expected |
|---|---|---|
| A01 | Add `lib/practice/` capsule-side module | ALLOW |
| A02 | Add OCD Practice semantics into generic IAmina Core | HUMAN_GATE |
| A03 | Deterministic local state | ALLOW |
| A04 | Add LLM provider to generate practice | HUMAN_GATE |
| A05 | Add persistence/history | HUMAN_GATE |
| A06 | Add analytics containing OCD free text | BLOCK |
| A07 | No provider/tool | ALLOW |
| A08 | No new dependency | ALLOW |
| A09 | Modify LOT06 firewall heuristics unnecessarily | BLOCK |
| A10 | Break Loop -> Practice handoff | BLOCK |

## UI / ACCESSIBILITY

| ID | Scenario | Expected |
|---|---|---|
| X01 | 360 px viewport | no overflow/cutoff |
| X02 | 390 px viewport | no overflow/cutoff |
| X03 | 200% text scaling | critical text/actions remain reachable |
| X04 | Start/Continue/Exit actions have semantics | required |
| X05 | Touch targets below accessibility baseline | BLOCK |
| X06 | Completion state hidden below unscrollable viewport | BLOCK |
| X07 | Bottom navigation remains available | required |
| X08 | UI contains score/progress ring | BLOCK |
| X09 | UI contains badge/confetti | BLOCK |
| X10 | Error/degraded state lies about saved data | BLOCK |

## NON-REGRESSION

LOT07B must prove:

- LOT03 shell tests remain green;
- LOT04 Dashboard V3 tests remain green;
- LOT05 bounded Loop tests remain green;
- LOT06 Compulsion Firewall tests remain green;
- Home/Loop/Practice/Support/Profile routing remains intact;
- no Core/capsule separation regression;
- no provider/persistence/analytics introduced implicitly.

## PASS CONDITION

LOT07B cannot be marked Gate 7 verified if any `BLOCK` behavior exists or if any `HUMAN_GATE` behavior was introduced without explicit authorization.
