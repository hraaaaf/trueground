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
    ])) {
      return _reject(OutputGuardViolation.reassuranceReinforcement);
    }

    if (_matchesAny(text, <RegExp>[
      RegExp(
        r'^(check|double check|verify)\b.*\b(again|one more time|last time)\b.*\b(to be sure|to make sure|for certainty)\b',
      ),
      RegExp(
        r'^(verifie|reverifie)\b.*\b(encore|a nouveau|une derniere fois)\b.*\b(pour etre sur|pour t assurer|pour verifier)\b',
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
    ])) {
      return _reject(OutputGuardViolation.unsupportedDiagnosis);
    }

    if (_containsAny(text, const <String>[
      'increase your ssri dose',
      'increase your dose tonight',
      'stop your medication tonight',
      'stop taking your medication',
      'start taking this medication',
      'augmente ta dose',
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
      'ta hierarchie d exposition doit etre',
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
      'tu n es pas en danger',
      'tu n es definitivement pas suicidaire',
      'tu peux rester ici en toute securite',
    ])) {
      return _reject(OutputGuardViolation.unsupportedCrisisAssessment);
    }

    if (_containsAny(text, const <String>[
      'i remember what you told me yesterday',
      'i checked our conversation from yesterday',
      'je me souviens de ce que tu m as dit hier',
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

bool _matchesAny(String text, List<RegExp> patterns) {
  for (final pattern in patterns) {
    if (pattern.hasMatch(text)) {
      return true;
    }
  }
  return false;
}
