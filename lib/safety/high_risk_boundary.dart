enum HighRiskBoundaryDisposition { continueOcdFlow, routeToUrgentSupport }

class HighRiskBoundaryDecision {
  const HighRiskBoundaryDecision({required this.disposition, this.route});

  final HighRiskBoundaryDisposition disposition;
  final String? route;

  bool get routesToUrgentSupport =>
      disposition == HighRiskBoundaryDisposition.routeToUrgentSupport;
}

abstract final class HighRiskBoundary {
  static const String urgentSupportRoute = '/urgent-support';

  static HighRiskBoundaryDecision evaluate(String rawMessage) {
    final text = _normalize(rawMessage);

    if (text.isEmpty || _looksLikeIntrusiveThoughtOnly(text)) {
      return const HighRiskBoundaryDecision(
        disposition: HighRiskBoundaryDisposition.continueOcdFlow,
      );
    }

    if (_containsAny(text, _urgentMarkers) ||
        _containsAny(text, _unableToStaySafeMarkers)) {
      return const HighRiskBoundaryDecision(
        disposition: HighRiskBoundaryDisposition.routeToUrgentSupport,
        route: urgentSupportRoute,
      );
    }

    return const HighRiskBoundaryDecision(
      disposition: HighRiskBoundaryDisposition.continueOcdFlow,
    );
  }

  static const List<String> _urgentMarkers = <String>[
    'i am in immediate danger',
    'i am about to kill myself',
    'i am going to kill myself',
    'i plan to kill myself',
    'i am about to hurt myself',
    'i am going to hurt myself',
    'i just tried to kill myself',
    'i just hurt myself badly',
    'i took an overdose',
    'i have overdosed',
    'i am about to hurt someone',
    'i am going to hurt someone',
    'i plan to kill someone',
    'someone is attacking me right now',
    'someone is hurting me right now',
    'this is a medical emergency',
  ];

  static const List<String> _unableToStaySafeMarkers = <String>[
    'i cannot keep myself safe',
    "i can't keep myself safe",
    'i do not think i can stay safe',
    "i don't think i can stay safe",
    'i cannot stay safe right now',
    "i can't stay safe right now",
    'i am not sure i can stay safe',
    "i'm not sure i can stay safe",
    'i do not know if i can keep myself safe',
    "i don't know if i can keep myself safe",
    'i may not be able to stay safe',
  ];

  static const List<String> _intrusiveThoughtMarkers = <String>[
    'what if i hurt',
    'what if i kill',
    'intrusive thought',
    'intrusive image',
    'unwanted thought',
    'unwanted image',
    'does this thought mean',
    'am i dangerous because i thought',
    'am i a bad person because i thought',
  ];

  static bool _looksLikeIntrusiveThoughtOnly(String text) {
    return _containsAny(text, _intrusiveThoughtMarkers) &&
        !_containsAny(text, _urgentMarkers) &&
        !_containsAny(text, _unableToStaySafeMarkers);
  }
}

String _normalize(String input) {
  return input
      .toLowerCase()
      .replaceAll(RegExp(r"[^a-z0-9\s']"), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

bool _containsAny(String text, List<String> needles) {
  for (final needle in needles) {
    if (text.contains(needle)) {
      return true;
    }
  }
  return false;
}
