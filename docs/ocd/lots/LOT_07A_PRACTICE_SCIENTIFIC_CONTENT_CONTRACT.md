# LOT 07A — Practice Scientific & Content Contract

Status: PROPOSED / SCIENCE-ALIGNED PROTOTYPE BOUNDARY
Date: 2026-09-18
Repository: hraaaaf/trueground
Parent lot: LOT 07 — Practice experience
Target implementation step: LOT 07B — Practice Experience Implementation

## SUPERSESSION NOTE — LOT07C

The original LOT07A persistence clauses below describe the pre-LOT07C prototype boundary. They are superseded only for anti-replay persistence by docs/ocd/lots/LOT_07C_ANTI_REPLAY_PERSISTENCE_CONTRACT.md, which authorizes two local completion timestamps and a hidden 2-hour UX anti-replay window. No saved treatment plan, OCD content history, analytics, or broader persistence is authorized.

## GOAL

Define the exact behavior and copy boundary for the first TrueGround Practice experience before runtime implementation.

This contract exists to prevent LOT07 from silently becoming an autonomous ERP engine or from inventing therapeutic content during UI implementation.

## SUCCESS

LOT07B may proceed without another product decision only if it implements this contract narrowly:

- adults-only V1 scope;
- local/deterministic behavior;
- no provider or generic LLM;
- no persistent practice history;
- no exposure generation;
- no exposure hierarchy;
- no personalized treatment recommendation;
- no anxiety/distress scoring;
- no streaks, badges, competitive counts or completion pressure;
- no promise of calm, certainty, symptom reduction or treatment efficacy;
- no diagnostic language;
- no medical or physical-safety advice;
- clear start and end;
- no automatic replay;
- no "do it again until it feels right" behavior;
- no IAmina Core change.

## SCIENTIFIC INTERPRETATION BOUNDARY

### What is well supported

The evidence base supports CBT with exposure and response prevention (ERP) as a first-line psychological treatment for OCD.

NICE CG31 explicitly includes ERP in low-intensity CBT options for some adults and also requires appropriate training and supervision for professionals delivering psychological treatment.

Systematic review/meta-analysis evidence supports CBT incorporating ERP for OCD.

Internet-based CBT for OCD has evidence of benefit, including structured self-help formats, but this does not validate arbitrary app-generated exposure tasks.

### What is relevant but not sufficient for a treatment claim

Intolerance of uncertainty is strongly associated with OCD and can change during treatment, but current reviews do not establish that increasing uncertainty tolerance is a necessary or sufficient mechanism of OCD improvement.

Reassurance seeking can function similarly to checking and can provide short-term relief without resolving the longer-term loop.

Inhibitory-learning models caution against using within-session anxiety reduction as the required marker that exposure "worked".

### What remains weak or insufficiently specific

Evidence for simple ritual-delay procedures exists but is much smaller and older than the broader ERP evidence base.

Therefore TrueGround MUST NOT claim that a brief app pause is itself an evidence-based OCD treatment or that a particular timer duration is therapeutically validated.

LOT07B will deliberately avoid a countdown duration because the repository contains no validated duration and a repeatable timer could itself become ritualized.

## INTENDED POPULATION

Current V1 product scope:

- adults;
- users seeking structured support around OCD-related patterns;
- diagnosis is not assumed;
- users may or may not already be receiving professional care.

This contract does not expand age coverage.

## GLOBAL PRACTICE RULES

Every Practice tool implemented under this contract MUST:

1. be user-initiated;
2. have a finite start and end;
3. avoid open-ended free text;
4. avoid asking the user to prove or rate success;
5. avoid distress/anxiety ratings;
6. avoid reassurance or certainty about the feared outcome;
7. avoid interpreting intrusive thoughts as intent;
8. avoid deciding whether a specific real-world risk is safe;
9. avoid medical, legal, emergency or physical-safety decision support;
10. provide an immediate Exit path;
11. avoid automatic replay;
12. avoid a prominent "again" action after completion;
13. avoid saving history or transmitting content;
14. avoid analytics containing OCD-sensitive free text;
15. never require the user to feel calmer before the practice can end.

## PHYSICAL-SAFETY BOUNDARY

Practice MUST NOT instruct the user to delay, ignore or stop objectively required safety behavior.

Examples outside the allowed autonomous practice scope include:

- medication dosing or medical-device checks;
- acute medical symptoms;
- driving or machinery safety;
- fire, gas, electrical or environmental hazards;
- safeguarding another person;
- legally required or professionally required verification;
- any situation where the app would need domain expertise to determine whether a check is reasonable.

LOT07B will not collect enough context to adjudicate these cases.

User-facing copy must therefore make clear that the practice is not for urgent safety or medical decisions. That boundary must remain visible on the active instruction steps where the user is asked to leave a question unresolved.

## SURFACE 1 — PAUSE THE RITUAL

### Product purpose

Create one small interruption between an urge and a user-chosen action without deciding whether the behavior is a compulsion and without promising symptom relief.

### Allowed behavior

The flow is a deterministic, user-paced micro-practice.

No countdown is shown.

The user sees one short sequence:

1. **Start**
   - Title: `Pause the ritual`
   - Supporting copy:
     `If you already recognize an urge to check, repeat, neutralize or seek reassurance, you can choose a brief pause before acting.`
   - Safety note:
     `Not for urgent safety, medical or emergency decisions.`
   - CTA: `Start a brief pause`

2. **Pause**
   - Primary copy:
     `Leave the question unanswered for this moment.`
   - Secondary copy:
     `You do not need to decide whether the feared outcome is safe here, and you do not need to feel calm before moving on.`
   - CTA: `Continue`
   - Secondary action: `Exit practice`

3. **End**
   - Primary copy:
     `Practice ends here.`
   - Secondary copy:
     `TrueGround does not grade how the pause went. Choose your next ordinary action when you leave.`
   - Primary CTA: `Return to Home`
   - No replay CTA.

### Explicitly forbidden

- timer/countdown;
- "wait until your anxiety falls";
- "the urge will pass";
- "you are safe";
- "nothing bad will happen";
- "you did it correctly";
- "resist for X minutes";
- repeated breathing instructions used as a neutralizing ritual;
- therapist simulation;
- generated exposure;
- requiring the user to abstain from a behavior the app cannot safely classify.

### Repetition control

Within the active app session, once this micro-practice is completed, the Practice surface should not present a prominent direct replay.

If the same branch state remains mounted, the completed state should display:

`Pause finished for now.`

with navigation away from the practice rather than `Repeat`.

This is an anti-ritual UX guard, not longitudinal tracking.

No persisted cooldown is introduced.

## SURFACE 2 — PRACTICE UNCERTAINTY

### Product purpose

Offer a brief non-personalized exercise in leaving a question unresolved without generating an exposure task or claiming that uncertainty tolerance itself will reduce OCD symptoms.

### Allowed behavior

The flow contains no free-text description of the obsession and no generated answer.

1. **Start**
   - Title: `Practice uncertainty`
   - Supporting copy:
     `This is a brief practice in leaving a question unresolved — not in proving that a feared outcome is safe or unsafe.`
   - CTA: `Begin`

2. **Notice**
   - Copy:
     `Notice the pull to get a definite answer.`
   - Supporting copy:
     `You do not need to analyze the question here.`
   - CTA: `Continue`
   - Secondary action: `Exit practice`

3. **Choose**
   - Copy:
     `For this moment, choose not to solve the uncertainty in TrueGround.`
   - Neutral stance shown once:
     `I may not know for sure right now.`
   - CTA: `Finish practice`

4. **End**
   - Primary copy:
     `Practice ends here.`
   - Secondary copy:
     `No rating is needed. You can return to what you were going to do next.`
   - Primary CTA: `Return to Home`
   - No replay CTA.

### Explicitly forbidden

- asking the user to enter the feared scenario;
- generating "maybe X will happen" statements from user content;
- instructing deliberate exposure to a trigger;
- hierarchy construction;
- probability estimates;
- certainty scores;
- anxiety scores;
- checking whether anxiety decreased;
- repeating the neutral stance multiple times;
- encouraging the user to use the phrase until it feels right;
- presenting the phrase as a mantra, guarantee or safety signal;
- claim that uncertainty practice treats OCD or proves recovery.

### Compulsion-risk note

The neutral stance is displayed once as framing, not as a repetition exercise.

LOT07B MUST NOT add a repeat counter, copy button, audio loop or "say this 10 times" behavior.

## SURFACE 3 — CONTINUE PLANNED PRACTICE

### Repository truth

No approved saved-practice persistence currently exists.

LOT07B MUST NOT simulate or imply remembered practice history.

### Required current behavior

The surface is an honest empty/degraded state:

- Title: `Continue planned practice`
- Primary copy:
  `No saved practice is available in this version.`
- Secondary copy:
  `Nothing has been stored to resume yet.`
- Actions:
  - `Back to Practice`
  - `Return to Home`

No fake "recent practice", placeholder date, streak, completion history or inferred plan.

### Future boundary

A future resume feature requires separate approval of:

- persistence/data model;
- ownership and deletion;
- practice authorship;
- whether plans are user-authored, clinician-authored or product-authored;
- safety review of stored content;
- longitudinal compulsion-risk controls.

## COMPLETION SEMANTICS

Completion means only:

`the bounded UI flow reached its terminal state`.

It MUST NOT mean:

- ritual successfully prevented;
- anxiety reduced;
- exposure completed;
- therapeutic target achieved;
- user improved;
- OCD symptoms changed.

No completion percentage is shown.

## RESTART / "ONE MORE TIME" POLICY

LOT07B must not invite repetition.

After a completed practice:

- no `Again` button;
- no celebratory score;
- no count of successful sessions;
- no streak;
- no recommendation to repeat until calm or certain;
- no "one more round".

If the user manually navigates away and back during the same mounted app session, an ephemeral completed state may discourage immediate replay without storing longitudinal history.

A legitimate app restart begins a fresh non-persisted session.

## FALSE-POSITIVE / LEGITIMATE RETRY POLICY

The UI must not label a retry as compulsive.

Legitimate reasons include:

- accessibility retry;
- accidental navigation;
- UI failure;
- user correction;
- app restart.

The product can remove replay affordances without diagnosing the user's reason.

## PROVIDER / TOOL / DATA STATE

For LOT07B under this contract:

- AI provider: NOT USED;
- external tool: NOT USED;
- persistence: NOT USED;
- analytics: NOT INTRODUCED;
- account state: NOT REQUIRED;
- network: NOT REQUIRED;
- real user data: NOT USED.

Provider failure is therefore NOT_APPLICABLE.

The safe degraded state is local and deterministic.

## CORE / CAPSULE ARCHITECTURE

All behavior defined here is OCD-capsule-specific.

Implementation belongs under a dedicated Practice/OCD module.

No OCD-specific term or policy from this contract may be moved into generic IAmina Core.

Any proposed IAmina Core change remains a HUMAN GATE.

## CLAIMS POLICY

Allowed product descriptions:

- `brief practice`;
- `create space before acting`;
- `leave a question unresolved for this moment`;
- `return to your next activity`.

Forbidden without separate validation:

- `treats OCD`;
- `clinically proven`;
- `prescribed for you`;
- `this is ERP for you`;
- `your anxiety will decrease`;
- `this will prevent a compulsion`;
- `this retrains your brain`;
- `this proves you are improving`;
- any efficacy percentage.

## LOT07B ACCEPTANCE CONTRACT

LOT07B may implement this contract without introducing a new clinical product decision if all of the following remain true:

- deterministic local content only;
- no user-generated exposure content;
- no model-generated content;
- no personalized exposure;
- no hierarchy;
- no safety-risk adjudication;
- no persistence;
- no clinical claim;
- no timer;
- no score;
- no repeated mantra;
- no Core change.

If implementation requires any of those, STOP -> HUMAN GATE.

## REQUIRED LOT07B TESTS

At minimum:

1. Practice route no longer uses the generic placeholder.
2. Three surfaces are visible and reachable.
3. Pause has finite start -> pause -> end.
4. Pause has no timer.
5. Pause does not promise calm/certainty.
6. Pause has no replay CTA after completion.
7. Uncertainty has finite start -> notice -> choose -> end.
8. Uncertainty has no free-text exposure input.
9. Uncertainty does not repeat the neutral stance.
10. Uncertainty does not ask for anxiety/distress rating.
11. Continue planned practice truthfully reports no persistence.
12. No fake practice history appears.
13. Exit/back works from every non-terminal state.
14. Bottom navigation remains functional.
15. LOT05 Loop -> Practice handoff remains valid.
16. LOT06 Compulsion Firewall remains unchanged.
17. No provider dependency.
18. No storage/analytics dependency.
19. No IAmina Core change.
20. 360 px layout.
21. 390 px layout.
22. 200% text scaling.
23. touch targets/accessibility semantics.
24. no overflow/cutoff.
25. no streak/badge/count.
26. no unsupported diagnostic/therapeutic claim.

## REFERENCES

1. NICE. Obsessive-compulsive disorder and body dysmorphic disorder: treatment. Clinical guideline CG31. Recommendation 1.5.1.1 and section 1.5.2. Current NICE web version checked 2026-09-18.
2. Reid JE, Laws KR, Drummond L, Vismara M, Grancini B, Mpavaenda D, Fineberg NA. Cognitive behavioural therapy with exposure and response prevention in the treatment of obsessive-compulsive disorder: a systematic review and meta-analysis of randomised controlled trials. Compr Psychiatry. 2021;106:152223. PMID: 33618297.
3. Polak M, Tanzer NK. Internet-Based Cognitive Behavioural Treatments for Obsessive-Compulsive Disorder: A Systematic Review and Meta-Analysis. Clin Psychol Psychother. 2024;31(3):e2989. PMID: 38769929. DOI: 10.1002/cpp.2989.
4. Knowles KA, Olatunji BO. Intolerance of Uncertainty as a Cognitive Vulnerability for Obsessive-Compulsive Disorder: A Qualitative Review. Clin Psychol (New York). 2023;30(3):317-330. PMID: 39431164. DOI: 10.1037/cps0000150.
5. Craske MG, Treanor M, Conway CC, Zbozinek T, Vervliet B. Maximizing exposure therapy: an inhibitory learning approach. Behav Res Ther. 2014;58:10-23. PMID: 24864005. DOI: 10.1016/j.brat.2014.04.006.
6. Salkovskis PM, Kobori O. Reassuringly calm? Self-reported patterns of responses to reassurance seeking in obsessive compulsive disorder. J Behav Ther Exp Psychiatry. 2015;49(Pt B):203-208. PMID: 26433701. DOI: 10.1016/j.jbtep.2015.09.002.
7. Parrish CL, Radomsky AS. Why do people seek reassurance and check repeatedly? An investigation of factors involved in compulsive behavior in OCD. J Anxiety Disord. 2010;24(2):211-222. PMID: 19939622.
8. Junginger J, Head S. Time series analysis of obsessional behavior and mood during self-imposed delay and response prevention. Behav Res Ther. 1991;29(6):521-530. PMID: 1759952. DOI: 10.1016/0005-7967(91)90002-K.

## EVIDENCE LIMITATIONS

- This contract is not independent clinician sign-off.
- It does not establish efficacy of the proposed TrueGround micro-practices.
- Evidence for ERP as a treatment is much stronger than evidence for any specific TrueGround micro-flow.
- The response-delay study is a very small older time-series study and cannot justify a fixed timer or efficacy claim.
- Intolerance-of-uncertainty evidence supports relevance, not a claim that this micro-practice is a validated mechanism-specific treatment.
- Digital CBT evidence does not validate unrestricted or automatically generated ERP.
- Crisis/regional support policy remains outside LOT07 and is not solved by this contract.

## STATE

This contract authorizes only a science-constrained prototype implementation boundary for LOT07B.

It does not authorize:

- production clinical claims;
- autonomous ERP;
- generated exposures;
- clinician substitution;
- merge;
- deployment;
- production data/config changes.
