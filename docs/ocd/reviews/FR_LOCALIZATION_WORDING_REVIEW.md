# FR LOCALIZATION — WORDING & SAFETY REVIEW

Status: IMPLEMENTED — TECHNICAL / LOCALIZATION REVIEW PENDING FINAL CI
Date: 2026-09-25
Base: `ui/polish-sub9-screens@50511519f9851f81444a4203dda438446589345a`
Branch: `feat/fr-localization`

## GOAL

Add French as a supported TrueGround interface language without changing OCD behavior, clinical meaning, routing policy, persistence semantics, or IAmina Core.

## SCOPE

Localized surfaces:
- primary navigation;
- Dashboard;
- Loop;
- Practice;
- Values;
- Support;
- Pattern Review;
- Urgent Support;
- generic loading/empty/error states;
- Profile → Language settings.

English remains the deterministic fallback.

Language preference is stored locally with `shared_preferences`. No analytics, account mutation, remote persistence, or production data is involved.

## WORDING PRINCIPLES

1. Preserve uncertainty rather than replacing it with certainty.
2. Preserve non-diagnostic language.
3. Preserve the distinction between intrusive thoughts and intent.
4. Preserve the statement that TrueGround does not contact or dispatch help.
5. Preserve the boundary that urgent-safety decisions are outside ordinary OCD practice flows.
6. Do not add treatment efficacy, diagnosis, severity, prognosis, or medical-device claims.
7. Avoid French wording that sounds prescriptive or morally evaluative.
8. Keep anti-reassurance language neutral and non-shaming.

## HIGH-RISK / CLINICALLY SENSITIVE PAIRS

### Intrusive thoughts vs intent

EN:
> This tool will not infer intent or make a diagnosis from an intrusive thought or image.

FR:
> Cet outil ne déduira pas une intention et ne posera pas de diagnostic à partir d’une pensée ou d’une image intrusive.

Rationale:
- preserves both boundaries;
- does not say intrusive thoughts are harmless;
- does not infer intent;
- does not diagnose.

### Immediate safety assessment boundary

EN:
> TrueGround cannot determine whether this is an emergency or assess your immediate safety.

FR:
> TrueGround ne peut pas déterminer s’il s’agit d’une urgence ni évaluer votre sécurité immédiate.

Rationale:
- preserves inability to assess;
- does not claim clinical risk classification.

### Emergency guidance

EN:
> If there is immediate danger, or you cannot stay safe, contact the emergency services available where you are or go to the nearest emergency department now.

FR:
> S’il existe un danger immédiat, ou si vous ne pouvez pas rester en sécurité, contactez les services d’urgence disponibles là où vous vous trouvez ou rendez-vous dès maintenant au service d’urgence le plus proche.

Rationale:
- no jurisdiction-specific number invented;
- no claim of dispatch;
- same real-world escalation boundary.

### No-contact truthfulness

EN:
> TrueGround has not contacted anyone or dispatched help for you.

FR:
> TrueGround n’a contacté personne et n’a envoyé aucune aide pour vous.

Rationale:
- preserves exact operational truth;
- avoids implying emergency dispatch capability.

### Practice safety boundary

EN:
> Not for urgent safety, medical or emergency decisions.

FR:
> Ne pas utiliser pour des décisions urgentes de sécurité, médicales ou d’urgence.

Rationale:
- maintains exclusion from urgent decision-making;
- does not introduce medical advice.

### Anti-reassurance / uncertainty

EN:
> This may be a certainty-seeking loop. This tool will not settle the question for you.

FR:
> Cela peut ressembler à une boucle de recherche de certitude. Cet outil ne tranchera pas la question à votre place.

Rationale:
- “peut ressembler” preserves uncertainty;
- no diagnosis or certainty claim;
- no reassurance answer.

## ARCHITECTURE

- No new package.
- No change to IAmina Core.
- No change to OCD detection logic.
- No change to routing policy.
- No change to high-risk classifier.
- Localization is applied at render time to canonical English strings.
- Unknown translation keys fall back to the canonical English source.

## TEST REQUIREMENTS

Mandatory before acceptance:
- Dart format;
- static analysis;
- existing LOT03→LOT10 regression;
- dedicated `test/localization_test.dart`;
- FR Dashboard at 390 px;
- FR Urgent Support wording;
- text-scale validation where existing visual jobs cover it;
- no framework exceptions;
- exact-head CI.

## LIMITATIONS

- This is not independent human clinical validation.
- The existing requirement for human-qualified review of the crisis/high-risk protocol remains unchanged.
- French support must not be called clinically validated merely because localization tests pass.
