enum OutputGuardDisposition { allow, reject }

enum OutputGuardViolation {
  none,
  emptyOutput,
  certaintyGuarantee,
  reassuranceReinforcement,
  checkingReinforcement,
  ruminationReinforcement,
  reconfessionSolicitation,
  intrusiveThoughtIntentInference,
  unsupportedDiagnosis,
  medicationInstruction,
  treatmentEfficacyClaim,
  autonomousExposure,
  falseHumanContactClaim,
  unsupportedCrisisAssessment,
  fabricatedMemoryClaim,
  dismissesProfessionalCare,
}

class OutputGuardDecision {
  const OutputGuardDecision({
    required this.disposition,
    required this.violation,
  });

  final OutputGuardDisposition disposition;
  final OutputGuardViolation violation;

  bool get isRejected => disposition == OutputGuardDisposition.reject;
}

abstract final class DeterministicConversationOutputGuard {
  static OutputGuardDecision inspect(String rawOutput) {
    final text = _normalize(rawOutput);

    if (text.isEmpty) {
      return const OutputGuardDecision(
        disposition: OutputGuardDisposition.reject,
        violation: OutputGuardViolation.emptyOutput,
      );
    }

    if (_containsAny(text, const <String>[
      'i guarantee nothing bad will happen',
      'i guarantee you are safe',
      'you are definitely safe',
      'you are certainly safe',
      'i promise nothing bad will happen',
      'je garantis que rien de mauvais n arrivera',
      'je garantis que tu es en securite',
      'tu es definitivement en securite',
    ])) {
      return _reject(OutputGuardViolation.certaintyGuarantee);
    }

    if (_startsWithAny(text, const <String>[
      'yes you are a good person',
      'you are a good person',
      'no you are not a bad person',
      'you are not a bad person',
      'oui tu es une bonne personne',
      'tu es une bonne personne',
      'non tu n es pas une mauvaise personne',
      'tu n es pas une mauvaise personne',
      'you are morally okay',
      'there is nothing wrong with you',
      'tu es quelqu un de bien',
      'il n y a rien de mauvais chez toi',
    ])) {
      return _reject(OutputGuardViolation.reassuranceReinforcement);
    }

    if (_containsUnprotectedCheckingDirective(text)) {
      return _reject(OutputGuardViolation.checkingReinforcement);
    }

    if (_matchesAny(text, <RegExp>[
      RegExp(
        r'^(check|double check|verify)\b.*\b(again|one more time|last time)\b.*\b(to be sure|to make sure|for certainty)\b',
      ),
      RegExp(
        r'^(verifie|reverifie)\b.*\b(encore|a nouveau|une derniere fois)\b.*\b(pour etre sur|pour t assurer|pour verifier)\b',
      ),
      RegExp(r'^(look|check)\b.*\b(lock)\b.*\b(another time|again)\b'),
      RegExp(
        r'^(regarde|verifie)\b.*\b(serrure)\b.*\b(encore|une autre fois)\b',
      ),
      RegExp(
        r'^(regarde|verifie)\b.*\b(encore|une autre fois)\b.*\b(serrure)\b',
      ),
    ])) {
      return _reject(OutputGuardViolation.checkingReinforcement);
    }

    if (_matchesAny(text, <RegExp>[
      RegExp(
        r'^(keep analyzing|analyze again|keep thinking|continue analyzing)\b.*\b(until|exactly|what it means)\b',
      ),
      RegExp(
        r'^(continue a analyser|continue d analyser|analyse encore|continue a y penser)\b.*\b(jusqu a|exactement|ce que ca signifie|ce que cela signifie)\b',
      ),
      RegExp(r'^(go over|revisit)\b.*\b(thought)\b.*\b(until|completely)\b'),
      RegExp(r'^(reprends|revois)\b.*\b(pensee)\b.*\b(jusqu a|completement)\b'),
    ])) {
      return _reject(OutputGuardViolation.ruminationReinforcement);
    }

    if (_matchesAny(text, <RegExp>[
      RegExp(
        r'^(tell me|share)\b.*\b(one more detail|another detail|more details)\b.*\b(sure|certain|certainty|know for sure)\b',
      ),
      RegExp(
        r'^(dis moi|partage)\b.*\b(encore un detail|un autre detail|plus de details)\b.*\b(sur|certains|certitude)\b',
      ),
      RegExp(
        r'^(tell me|share)\b.*\b(other thing|one more thing)\b.*\b(sure|certainty|know)\b',
      ),
      RegExp(
        r'^(dis moi|partage)\b.*\b(autre chose|encore quelque chose)\b.*\b(certitude|sache|savoir)\b',
      ),
      RegExp(
        r'^(dis moi|partage)\b.*\b(fait d autre|as fait d autre)\b.*\b(certitude|sache|savoir)\b',
      ),
    ])) {
      return _reject(OutputGuardViolation.reconfessionSolicitation);
    }

    if (_containsAny(text, const <String>[
      'this thought means you want to',
      'that thought means you want to',
      'this thought proves you want to',
      'your intrusive thought means you want to',
      'cette pensee signifie que tu veux',
      'cette pensee veut dire que tu veux',
      'cette pensee prouve que tu veux',
      'ta pensee intrusive signifie que tu veux',
    ])) {
      return _reject(OutputGuardViolation.intrusiveThoughtIntentInference);
    }

    final directDiagnosis = <String>['you', 'have', 'ocd'].join(' ');
    if (_containsAny(text, <String>[
      directDiagnosis,
      'you definitely have ocd',
      'you do not have ocd',
      'tu as un toc',
      'tu n as pas de toc',
      'this sounds like ocd',
      'sounds like ocd',
      'this is ocd',
      'ca ressemble clairement a un toc',
      'cela ressemble clairement a un toc',
      'ca ressemble a un toc',
    ])) {
      return _reject(OutputGuardViolation.unsupportedDiagnosis);
    }

    if (_containsAny(text, const <String>[
      'increase your ssri dose',
      'increase your dose tonight',
      'stop your medication tonight',
      'stop taking your medication',
      'start taking this medication',
      'you should take a higher ssri dose',
      'take a higher ssri dose',
      'take more of your ssri',
      'augmente ta dose',
      'tu devrais prendre une dose plus elevee de ton isrs',
      'prendre une dose plus elevee de ton isrs',
      'augmente ton traitement',
      'arrete ton traitement ce soir',
      'arrete de prendre ton traitement',
    ])) {
      return _reject(OutputGuardViolation.medicationInstruction);
    }

    if (_containsAny(text, const <String>[
      'this exercise will reduce your ocd',
      'this will cure your ocd',
      'this exercise is guaranteed to work',
      'cet exercice reduira ton toc',
      'cet exercice guerira ton toc',
      'cet exercice est garanti efficace',
    ])) {
      return _reject(OutputGuardViolation.treatmentEfficacyClaim);
    }

    if (_containsAny(text, const <String>[
      'your exposure hierarchy should be',
      'expose yourself to the following',
      'your first exposure is',
      'start by touching the',
      'then the trash can',
      'ta hierarchie d exposition doit etre',
      'commence par toucher la',
      'puis la poubelle',
      'expose toi aux elements suivants',
      'ta premiere exposition est',
    ])) {
      return _reject(OutputGuardViolation.autonomousExposure);
    }

    if (_containsAny(text, const <String>[
      'i contacted emergency services for you',
      'i called emergency services for you',
      'i contacted your therapist',
      'j ai contacte les secours pour toi',
      'j ai appele les secours pour toi',
      'j ai contacte ton therapeute',
    ])) {
      return _reject(OutputGuardViolation.falseHumanContactClaim);
    }

    if (_containsAny(text, const <String>[
      'you are not in danger',
      'you are definitely not suicidal',
      'you are safe enough to stay here',
      'i think you are safe to stay here',
      'you can stay here safely',
      'tu n es pas en danger',
      'je pense que tu peux rester ici sans danger',
      'tu n es definitivement pas suicidaire',
      'tu peux rester ici en toute securite',
    ])) {
      return _reject(OutputGuardViolation.unsupportedCrisisAssessment);
    }

    if (_containsAny(text, const <String>[
      'i remember what you told me yesterday',
      'i checked our conversation from yesterday',
      'i remember our chat from last week',
      'i remember our conversation from last week',
      'je me souviens de ce que tu m as dit hier',
      'je me souviens de notre discussion de la semaine derniere',
      'j ai verifie notre conversation d hier',
    ])) {
      return _reject(OutputGuardViolation.fabricatedMemoryClaim);
    }

    if (_containsAny(text, const <String>[
      'you do not need professional help',
      'you do not need a clinician',
      'you do not need therapy',
      'tu n as pas besoin d aide professionnelle',
      'tu n as pas besoin de clinicien',
      'tu n as pas besoin de therapie',
    ])) {
      return _reject(OutputGuardViolation.dismissesProfessionalCare);
    }

    return const OutputGuardDecision(
      disposition: OutputGuardDisposition.allow,
      violation: OutputGuardViolation.none,
    );
  }
}

OutputGuardDecision _reject(OutputGuardViolation violation) {
  return OutputGuardDecision(
    disposition: OutputGuardDisposition.reject,
    violation: violation,
  );
}

String _normalize(String input) {
  var text = input.toLowerCase().replaceAll('’', "'");
  const replacements = <String, String>{
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'á': 'a',
    'ã': 'a',
    'å': 'a',
    'ç': 'c',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'î': 'i',
    'ï': 'i',
    'í': 'i',
    'ô': 'o',
    'ö': 'o',
    'ó': 'o',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ú': 'u',
    'ÿ': 'y',
    'œ': 'oe',
  };
  replacements.forEach((from, to) {
    text = text.replaceAll(from, to);
  });
  return text
      .replaceAll(RegExp(r"[^a-z0-9\s']"), ' ')
      .replaceAll("'", ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

bool _containsAny(String text, List<String> needles) {
  for (final needle in needles) {
    if (text.contains(_normalize(needle))) {
      return true;
    }
  }
  return false;
}

bool _startsWithAny(String text, List<String> needles) {
  for (final needle in needles) {
    if (text.startsWith(_normalize(needle))) {
      return true;
    }
  }
  return false;
}


bool _containsUnprotectedCheckingDirective(String text) {
  const directives = <String>[
    'check again',
    'double check',
    'recheck',
    'verify one more time',
    'wash again',
    'clean again',
    'verifie encore',
    'reverifie',
    'verifie une derniere fois',
    'lave encore',
    'nettoie encore',
  ];
  const negations = <String>[
    'do not',
    'don t',
    'cannot',
    'can t',
    'avoid',
    'without',
    'instead of',
    'ne pas',
    'n est pas',
    'evite',
    'sans',
    'plutot que',
  ];
  const protectiveContext = <String>[
    'reduce the need to',
    'reduce your urge to',
    'reduce the urge to',
    'resist the urge to',
    'avoid checking',
    'without checking',
    'not check again',
    'reduire le besoin de',
    'reduire l envie de',
    'resister a l envie de',
    'eviter de verifier',
    'sans reverifier',
    'ne pas reverifier',
    'ne reverifie pas',
  ];

  for (final rawDirective in directives) {
    final directive = _normalize(rawDirective);
    var index = text.indexOf(directive);
    while (index >= 0) {
      final prefixStart = index > 90 ? index - 90 : 0;
      final contextStart = index > 100 ? index - 100 : 0;
      final contextEnd = (index + directive.length + 100) < text.length
          ? index + directive.length + 100
          : text.length;
      final prefix = text.substring(prefixStart, index);
      final context = text.substring(contextStart, contextEnd);
      final negated = negations.any(
        (marker) => prefix.contains(_normalize(marker)),
      );
      final protected = protectiveContext.any(
        (marker) => context.contains(_normalize(marker)),
      );
      if (!negated && !protected) {
        return true;
      }
      index = text.indexOf(directive, index + 1);
    }
  }
  return false;
}

bool _matchesAny(String text, List<RegExp> patterns) {
  for (final pattern in patterns) {
    if (pattern.hasMatch(text)) {
      return true;
    }
  }
  return false;
}
