# START PROMPT — TrueGround OCD / LOT11-H — Supervised Alpha H1

Repository: `hraaaaf/trueground`
Previous lot handover: `docs/ocd/handovers/LOT_11G_HANDOVER.md`
Target lot: `LOT11-H — Supervised Alpha / H1`

Start by reading the previous handover and every canonical file it references.

Do NOT trust stale SHAs. Verify:
- `main` SHA;
- working branch and exact HEAD;
- ahead/behind;
- PR state;
- CI/checks;
- unresolved review findings.

Before modification state:

GOAL
SUCCESS
PROOF

## H1 GOAL

Prepare and execute only the approved first supervised alpha stage for 1–3 adult volunteers, with accompanied sessions and qualitative observation.

H1 is not a clinical trial and must not be described as proof of therapeutic efficacy, diagnosis, treatment readiness or unsupervised patient safety.

## Mandatory preparation before any real participant

Create/review an auditable H1 package containing:
1. participant eligibility/exclusion boundaries appropriate to the non-clinical supervised product test;
2. plain-language informed participation/consent and product-boundary script;
3. explicit statement that TrueGround is not emergency care, diagnosis or autonomous treatment;
4. facilitator script that does not coach the model or provide reassurance;
5. session flow and bounded duration;
6. scenario/use guidance without inducing symptoms or prescribing ERP;
7. observation rubric using product/safety outcomes, not symptom-improvement claims;
8. STOP criteria inherited from `LOT_11G_HUMAN_REVIEW_PACK.md`;
9. explicit observation targets for H2-01 moral/self-checking and H2-03 explanation-before-pivot;
10. privacy/data-minimization plan: no raw-chat persistence by default, no raw sensitive text in routine logs/analytics, no unnecessary participant identifiers;
11. incident/escalation procedure and post-session debrief;
12. decision rule for whether H1 may progress to H2 (10–20 controlled users).

Do not recruit or run a participant merely because documentation exists. Human product-owner authorization is required before real H1 execution.

## Required reviewers

At minimum:
- PRODUCT_AGENT;
- OCD_SAFETY_AGENT;
- UI_UX_AGENT where participant-facing flow/copy is involved;
- ACCESSIBILITY_AGENT where participant-facing flow/copy is involved;
- DATA_PRIVACY_SECURITY_AGENT;
- QA_NON_REGRESSION_AGENT;
- CONTENT_COPY_AGENT;
- LOCALIZATION_AGENT for EN/FR participant-facing material;
- REGULATORY_CLINICAL_REVIEW whenever the protocol, wording or behavior crosses the clinical boundary.

## Hard STOP

Stop H1 immediately if any LOT11-G STOP criterion occurs, including:
- exposed reassurance/certainty that reinforces the loop;
- checking instructions;
- escalating rumination/confession;
- repeated loop bypass;
- fail-open provider behavior;
- EN/FR safety divergence;
- raw sensitive content unexpectedly persisted/logged;
- unsupported diagnosis, medication, autonomous ERP/treatment or emergency assessment;
- false claim that a human/service was contacted.

## Architecture and scope

- IAmina Core and OCD capsule remain separate.
- Model never owns safety routing.
- No new feature is authorized merely to make H1 easier.
- Prefer documentation/harness-only preparation unless a proven blocker requires a narrowly scoped product fix.
- Any product/safety fix discovered during H1 reopens exact-head tests before continuing participants.

## Quota

Groq is quota-constrained.
- Do not use synthetic provider calls when offline/deterministic evidence is sufficient.
- No automatic retry.
- Real H1 conversation calls must be bounded by the approved session protocol.
- Do not run extra provider tests simply to obtain prettier evidence.

## Governance

READ → PLAN → EXECUTE → SPECIALIST REVIEW → DOUBLE SCORE → VERIFY.

Before LOT11-H can be called VERIFIED, apply `docs/ocd/10_STRICT_SCORING_AND_PERFECTION_PROTOCOL.md`:
- severe score A;
- independent/adversarial score B;
- retain the lower score;
- minimum five concrete reasons preventing 10/10 per pass;
- fix/retest material in-scope weaknesses;
- exact-head CI after final changes.

Never merge or deploy without explicit product-owner approval.
Never mutate real user data, production data, secrets or production configuration without explicit approval.

Finish LOT11-H with:
Résultat
Modifications
Tests
Non-régression
Preuves
Risques
État
Prochaine étape
