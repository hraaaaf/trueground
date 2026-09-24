import 'package:flutter/material.dart';

enum TrueGroundLanguage { en, fr }

extension TrueGroundLanguageCode on TrueGroundLanguage {
  String get code => switch (this) {
    TrueGroundLanguage.en => 'en',
    TrueGroundLanguage.fr => 'fr',
  };

  String get label => switch (this) {
    TrueGroundLanguage.en => 'English',
    TrueGroundLanguage.fr => 'Français',
  };

  static TrueGroundLanguage fromCode(String? code) {
    return code == 'fr' ? TrueGroundLanguage.fr : TrueGroundLanguage.en;
  }
}

class TrueGroundLocaleScope extends InheritedWidget {
  const TrueGroundLocaleScope({
    required this.language,
    required this.onLanguageChanged,
    required super.child,
    super.key,
  });

  final TrueGroundLanguage language;
  final ValueChanged<TrueGroundLanguage> onLanguageChanged;

  static TrueGroundLocaleScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TrueGroundLocaleScope>();
  }

  static TrueGroundLocaleScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'TrueGroundLocaleScope is missing.');
    return scope!;
  }

  @override
  bool updateShouldNotify(TrueGroundLocaleScope oldWidget) {
    return language != oldWidget.language;
  }
}

String translateTrueGround(TrueGroundLanguage language, String english) {
  if (language == TrueGroundLanguage.en) {
    return english;
  }
  return _fr[english] ?? english;
}

extension TrueGroundTranslation on BuildContext {
  String tr(String english) {
    final language =
        TrueGroundLocaleScope.maybeOf(this)?.language ?? TrueGroundLanguage.en;
    return translateTrueGround(language, english);
  }
}

const Map<String, String> _fr = <String, String>{
  'TrueGround primary navigation': 'Navigation principale TrueGround',
  'Home': 'Accueil',
  'Loop': 'Boucle',
  'Practice': 'Pratique',
  'Support': 'Soutien',
  'Profile': 'Profil',
  'Language': 'Langue',
  'Choose your language': 'Choisissez votre langue',
  'Language changes only the app interface. Your saved activity stays on this device.':
      'Le changement de langue concerne uniquement l’interface de l’app. Vos activités enregistrées restent sur cet appareil.',
  'Good evening': 'Bonsoir',
  'Choose your next move.': 'Choisissez votre prochaine action.',
  'Make room for uncertainty.\nChoose what matters.':
      'Laissez une place à l’incertitude.\nChoisissez ce qui compte.',
  'Pause the ritual': 'Mettre le rituel en pause',
  'Create space\nbetween urge\nand action.':
      'Créer un espace\nentre l’envie\net l’action.',
  'Practice uncertainty': 'Pratiquer l’incertitude',
  'Build tolerance,\nnot certainty.':
      'Développer la tolérance,\npas la certitude.',
  'Continue planned practice': 'Continuer la pratique prévue',
  'Return to planned\npractice at your\npace.':
      'Reprendre la pratique\nprévue à votre\nrythme.',
  'Return to what matters': 'Revenir à ce qui compte',
  'Work • Family • Rest\nFaith • Friends':
      'Travail • Famille • Repos\nFoi • Amis',
  'Need a person, not an answer?': 'Besoin d’une personne, pas d’une réponse ?',
  'Therapist or trusted\nperson.': 'Thérapeute ou personne\nde confiance.',
  'Create space between the urge and the action.':
      'Créer un espace entre l’envie et l’action.',
  'Guided exercises to build tolerance, not certainty.':
      'Des exercices guidés pour développer la tolérance, pas la certitude.',
  'Return to your planned practice at your pace.':
      'Reprenez votre pratique prévue à votre rythme.',
  'Work • Family • Rest • Faith • Friends':
      'Travail • Famille • Repos • Foi • Amis',
  'Find support from a therapist or a trusted person.':
      'Cherchez du soutien auprès d’un thérapeute ou d’une personne de confiance.',
  "I'm stuck in a loop. Notice the urge. Pause before the ritual.":
      'Je suis coincé dans une boucle. Remarquez l’envie. Faites une pause avant le rituel.',
  "I'm stuck in a loop": 'Je suis coincé dans une boucle',
  'Notice the urge. Pause before the ritual.':
      'Remarquez l’envie. Faites une pause avant le rituel.',
  'Review patterns when useful. Look at recurring themes, without judgment.':
      'Revoyez les schémas lorsque c’est utile. Observez les thèmes récurrents, sans jugement.',
  'Review patterns when useful': 'Revoir les schémas lorsque c’est utile',
  'Look at recurring themes, without judgment.':
      'Observer les thèmes récurrents, sans jugement.',

  'Choose the closest fit.': 'Choisissez ce qui s’en rapproche le plus.',
  'Pick one pattern only. You can move on without giving the full story.':
      'Choisissez un seul schéma. Vous pouvez avancer sans raconter toute l’histoire.',
  'Notice the pattern': 'Remarquez le schéma',
  'Choose one next move.': 'Choisissez une prochaine action.',
  'This check-in ends after you choose. It will not keep asking for more detail.':
      'Cette étape se termine après votre choix. Elle ne vous demandera pas davantage de détails.',
  'Choose a different pattern': 'Choisir un autre schéma',
  'Next move chosen': 'Prochaine action choisie',
  'There is no restart button here. If the question still feels unresolved, that does not require another pass through this check-in.':
      'Il n’y a pas de bouton pour recommencer ici. Si la question semble encore non résolue, cela ne nécessite pas un nouveau passage par cette étape.',
  'I want certainty': 'Je veux une certitude',
  'I keep wanting a definite answer.': 'Je continue à vouloir une réponse définitive.',
  'This may be a certainty-seeking loop. This tool will not settle the question for you.':
      'Cela peut ressembler à une boucle de recherche de certitude. Cet outil ne tranchera pas la question à votre place.',
  'I want to check': 'Je veux vérifier',
  'I feel pulled to verify again.': 'Je ressens l’envie de vérifier encore.',
  'This may be a checking loop. This tool will not verify the answer for you.':
      'Cela peut ressembler à une boucle de vérification. Cet outil ne vérifiera pas la réponse à votre place.',
  "I'm stuck analyzing": 'Je suis coincé dans l’analyse',
  'I keep trying to solve it mentally.': 'Je continue à essayer de résoudre la question mentalement.',
  'This may be a rumination loop. More analysis is not the goal of this check-in.':
      'Cela peut ressembler à une boucle de rumination. Le but de cette étape n’est pas d’analyser davantage.',
  "I'm repeating or confessing": 'Je répète ou je ressens le besoin d’avouer',
  'I feel pulled to say or ask it again.':
      'Je ressens l’envie de le redire ou de le redemander.',
  'This may be a repetition loop. You do not need to repeat the details here.':
      'Cela peut ressembler à une boucle de répétition. Vous n’avez pas besoin de répéter les détails ici.',
  'An intrusive thought or image': 'Une pensée ou une image intrusive',
  'It feels urgent or meaningful.': 'Elle semble urgente ou importante.',
  'This tool will not infer intent or make a diagnosis from an intrusive thought or image.':
      'Cet outil ne déduira pas une intention et ne posera pas de diagnostic à partir d’une pensée ou d’une image intrusive.',
  'Something else': 'Autre chose',
  'I still want a bounded next step.': 'Je veux tout de même une prochaine étape limitée.',
  'We do not need to label the pattern precisely to choose a bounded next step.':
      'Il n’est pas nécessaire de nommer précisément le schéma pour choisir une prochaine étape limitée.',
  'Leave the question unresolved for now and move to the Practice area.':
      'Laissez la question sans réponse pour le moment et passez à l’espace Pratique.',
  'Continue to Practice': 'Continuer vers Pratique',
  'End this check-in': 'Terminer cette étape',
  'Return Home and put attention back on your day.':
      'Revenez à l’accueil et reportez votre attention sur votre journée.',
  'Return Home': 'Retour à l’accueil',
  'Open Support. The app will not claim that anyone was contacted.':
      'Ouvrez Soutien. L’app ne prétendra pas qu’une personne a été contactée.',
  'Open Support': 'Ouvrir Soutien',
  'Therapist or trusted person.': 'Thérapeute ou personne de confiance.',
  'This is a bounded check-in, not an open chat. Choose the closest fit. No need to explain every detail.':
      'Il s’agit d’une étape limitée, pas d’un chat ouvert. Choisissez ce qui s’en rapproche le plus. Inutile d’expliquer chaque détail.',
  'Your next move is set. You can end this check-in here instead of reopening the question.':
      'Votre prochaine action est choisie. Vous pouvez terminer cette étape ici au lieu de rouvrir la question.',

  'Choose one brief practice. Each one has a clear end.':
      'Choisissez une pratique brève. Chacune a une fin clairement définie.',
  'If you already recognize an urge to check, repeat, neutralize or seek reassurance, you can choose a brief pause before acting.':
      'Si vous reconnaissez déjà une envie de vérifier, répéter, neutraliser ou chercher à être rassuré, vous pouvez choisir une courte pause avant d’agir.',
  'Not for urgent safety, medical or emergency decisions.':
      'Ne pas utiliser pour des décisions urgentes de sécurité, médicales ou d’urgence.',
  'Start a brief pause': 'Commencer une courte pause',
  'Exit practice': 'Quitter la pratique',
  'Leave the question unanswered for this moment.':
      'Laissez la question sans réponse pour le moment.',
  'You do not need to decide whether the feared outcome is safe here, and you do not need to feel calm before moving on.':
      'Vous n’avez pas besoin de décider ici si l’issue redoutée est sûre, et vous n’avez pas besoin de vous sentir calme avant d’avancer.',
  'Continue': 'Continuer',
  'TrueGround does not grade how the pause went. Choose your next ordinary action when you leave.':
      'TrueGround ne note pas le déroulement de la pause. En quittant cet écran, choisissez votre prochaine action ordinaire.',
  'This is a brief practice in leaving a question unresolved — not in proving that a feared outcome is safe or unsafe.':
      'Il s’agit d’une brève pratique consistant à laisser une question non résolue — et non à prouver qu’une issue redoutée est sûre ou non sûre.',
  'Begin': 'Commencer',
  'Notice the pull to get a definite answer.':
      'Remarquez l’envie d’obtenir une réponse définitive.',
  'You do not need to analyze the question here.':
      'Vous n’avez pas besoin d’analyser la question ici.',
  'For this moment, choose not to solve the uncertainty in TrueGround.':
      'Pour le moment, choisissez de ne pas résoudre l’incertitude dans TrueGround.',
  'I may not know for sure right now.':
      'Il est possible que je ne sache pas avec certitude pour le moment.',
  'Finish practice': 'Terminer la pratique',
  'No rating is needed. You can return to what you were going to do next.':
      'Aucune note n’est nécessaire. Vous pouvez revenir à ce que vous alliez faire ensuite.',
  'Pause finished for now': 'Pause terminée pour le moment',
  'Checking recent practice availability.':
      'Vérification de la disponibilité récente de cette pratique.',
  'Practice availability could not be checked.':
      'La disponibilité de la pratique n’a pas pu être vérifiée.',
  'This practice was recently completed.':
      'Cette pratique a été effectuée récemment.',
  'Create a small space before an urge-driven action.':
      'Créez un petit espace avant une action dictée par l’envie.',
  'Uncertainty practice finished for now':
      'Pratique de l’incertitude terminée pour le moment',
  'Leave a question unresolved without trying to prove it safe or unsafe.':
      'Laissez une question non résolue sans essayer de prouver qu’elle est sûre ou non sûre.',
  'Saved practice is not available yet.':
      'La pratique enregistrée n’est pas encore disponible.',
  'Practice does not diagnose a compulsion or decide whether a real-world safety check is necessary.':
      'Pratique ne diagnostique pas une compulsion et ne décide pas si une vérification de sécurité réelle est nécessaire.',
  'Practice ends here.': 'La pratique se termine ici.',
  'Return to Home': 'Retour à l’accueil',
  'No saved practice is available in this version.\n\nNothing has been stored to resume yet.':
      'Aucune pratique enregistrée n’est disponible dans cette version.\n\nRien n’a encore été enregistré pour être repris.',
  'Back to Practice': 'Retour à Pratique',

  'Choose a real-world route. TrueGround does not place calls, send messages, or notify anyone from this screen.':
      'Choisissez une option dans le monde réel. TrueGround ne passe pas d’appel, n’envoie pas de message et ne prévient personne depuis cet écran.',
  'Someone I trust': 'Une personne en qui j’ai confiance',
  'Choose a friend, family member, partner, community member, or another person you already know.':
      'Choisissez un ami, un membre de votre famille, votre partenaire, une personne de votre communauté ou quelqu’un que vous connaissez déjà.',
  'My therapist or care team': 'Mon thérapeute ou mon équipe de soins',
  'Use the contact route you already have.':
      'Utilisez le moyen de contact que vous avez déjà.',
  'Find professional support outside TrueGround':
      'Trouver un soutien professionnel en dehors de TrueGround',
  'Use a verified local health service or professional directory.':
      'Utilisez un service de santé local vérifié ou un annuaire professionnel.',
  'Reach someone you trust': 'Contactez une personne en qui vous avez confiance',
  'Choose the person yourself and use the phone or messaging route you normally use. TrueGround has not contacted them.':
      'Choisissez vous-même la personne et utilisez le téléphone ou la messagerie que vous utilisez habituellement. TrueGround ne l’a pas contactée.',
  'Ask for company or practical support rather than repeated certainty about the obsession. A trusted person does not need to solve the uncertainty for you.':
      'Demandez de la présence ou un soutien pratique plutôt qu’une certitude répétée au sujet de l’obsession. Une personne de confiance n’a pas besoin de résoudre l’incertitude à votre place.',
  'Use your existing care route': 'Utilisez votre parcours de soins habituel',
  'Use the contact route you already have with your therapist, clinician, clinic, or care team.':
      'Utilisez le moyen de contact que vous avez déjà avec votre thérapeute, votre clinicien, votre clinique ou votre équipe de soins.',
  'TrueGround does not store a therapist or care-team contact in this build and has not contacted anyone.':
      'Dans cette version, TrueGround n’enregistre pas les coordonnées d’un thérapeute ou d’une équipe de soins et n’a contacté personne.',
  'Use a verified local source': 'Utilisez une source locale vérifiée',
  'Look outside TrueGround for a verified local health service or professional directory.':
      'Cherchez en dehors de TrueGround un service de santé local vérifié ou un annuaire professionnel.',
  'TrueGround does not currently provide a local directory. Use a health service or professional directory you can verify outside the app.':
      'TrueGround ne fournit actuellement aucun annuaire local. Utilisez un service de santé ou un annuaire professionnel que vous pouvez vérifier en dehors de l’app.',
  'Back to support choices': 'Retour aux options de soutien',
  'Back to Home': 'Retour à l’accueil',

  'Work or study': 'Travail ou études',
  'Family': 'Famille',
  'Friends or community': 'Amis ou communauté',
  'Rest or care': 'Repos ou soins personnels',
  'Faith or meaning': 'Foi ou sens',
  'Home or daily life': 'Maison ou vie quotidienne',
  'Something else that matters': 'Autre chose qui compte',
  'Choose a direction that matters to you, then take the next step outside this flow.':
      'Choisissez une direction qui compte pour vous, puis faites la prochaine étape en dehors de ce parcours.',
  'This is not a way to prove you are safe or make uncertainty disappear. The app will not choose your values or generate the perfect action for you.':
      'Ce parcours ne sert pas à prouver que vous êtes en sécurité ni à faire disparaître l’incertitude. L’app ne choisira pas vos valeurs et ne générera pas l’action parfaite à votre place.',
  'Pick one area for right now.': 'Choisissez un domaine pour maintenant.',
  'There is no best answer. Choose the one you want to move toward.':
      'Il n’y a pas de meilleure réponse. Choisissez la direction vers laquelle vous souhaitez avancer.',
  'You chose': 'Vous avez choisi',
  'Keep the next step ordinary and yours.':
      'Gardez la prochaine étape simple et personnelle.',
  'Pick one small action yourself. It does not need to feel certain or perfect before you leave this flow.':
      'Choisissez vous-même une petite action. Elle n’a pas besoin de sembler certaine ou parfaite avant de quitter ce parcours.',
  'Take my next step': 'Faire ma prochaine étape',
  'Leave for now': 'Quitter pour le moment',
  'I tapped the wrong area': 'J’ai choisi le mauvais domaine',
  'Take the step outside TrueGround.': 'Faites l’étape en dehors de TrueGround.',
  'Uncertainty does not have to be settled first. This flow ends here so the next move can happen in real life.':
      'L’incertitude n’a pas besoin d’être résolue d’abord. Ce parcours se termine ici afin que la prochaine action puisse avoir lieu dans la vie réelle.',

  'This is a brief look at saved activity on this device. It is not a diagnosis, severity score, progress grade or prediction.':
      'Il s’agit d’un bref aperçu de l’activité enregistrée sur cet appareil. Ce n’est ni un diagnostic, ni un score de sévérité, ni une note de progression, ni une prédiction.',
  'TrueGround stores only structured activity types and timestamps for this review. No thought, fear, trigger or free-text content is saved here. Records expire after 30 days.':
      'Pour cette revue, TrueGround enregistre uniquement des types d’activité structurés et des horodatages. Aucune pensée, peur, déclencheur ou texte libre n’est enregistré ici. Les données expirent après 30 jours.',
  'Recent saved activity includes:': 'L’activité récemment enregistrée comprend :',
  'Remove this type': 'Supprimer ce type',
  'No frequency, streak, trend or better/worse conclusion is shown. You do not need to keep checking this screen.':
      'Aucune fréquence, série, tendance ni conclusion du type « mieux/pire » n’est affichée. Vous n’avez pas besoin de vérifier cet écran à répétition.',
  'Finish review': 'Terminer la revue',
  'Delete all saved activity': 'Supprimer toute l’activité enregistrée',
  'No saved activity is available to review.':
      'Aucune activité enregistrée n’est disponible à revoir.',
  'TrueGround will not infer a pattern from missing history.':
      'TrueGround ne déduira pas de schéma à partir d’un historique manquant.',
  'Saved activity could not be checked.':
      'L’activité enregistrée n’a pas pu être vérifiée.',
  'TrueGround will not guess what your history contains.':
      'TrueGround ne devinera pas le contenu de votre historique.',
  'Paused before an urge-driven action':
      'Pause avant une action dictée par l’envie',
  'Practiced leaving uncertainty unresolved':
      'Pratique consistant à laisser l’incertitude non résolue',
  'Chose a values-based next step':
      'Choix d’une prochaine étape guidée par ses valeurs',

  'Use urgent real-world help': 'Faites appel à une aide urgente dans la vie réelle',
  'TrueGround cannot determine whether this is an emergency or assess your immediate safety.':
      'TrueGround ne peut pas déterminer s’il s’agit d’une urgence ni évaluer votre sécurité immédiate.',
  'If there is immediate danger, or you cannot stay safe, contact the emergency services available where you are or go to the nearest emergency department now.':
      'S’il existe un danger immédiat, ou si vous ne pouvez pas rester en sécurité, contactez les services d’urgence disponibles là où vous vous trouvez ou rendez-vous dès maintenant au service d’urgence le plus proche.',
  'If possible, stay with or contact a trusted person or health professional while you get urgent help.':
      'Si possible, restez avec une personne de confiance ou contactez-la, ou contactez un professionnel de santé pendant que vous cherchez une aide urgente.',
  'TrueGround has not contacted anyone or dispatched help for you.':
      'TrueGround n’a contacté personne et n’a envoyé aucune aide à votre place.',
  'Open regular Support': 'Ouvrir le soutien habituel',

  'Loading': 'Chargement',
  'Getting this space ready.': 'Préparation de cet espace.',
  'Nothing here yet': 'Rien ici pour le moment',
  'This space is ready for content when the feature is implemented.':
      'Cet espace pourra accueillir du contenu lorsque la fonctionnalité sera implémentée.',
  'Something went wrong': 'Un problème est survenu',
  'Try again when you are ready.': 'Réessayez lorsque vous êtes prêt.',
  'Try again': 'Réessayer',
};

