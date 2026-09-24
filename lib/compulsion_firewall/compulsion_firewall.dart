enum FirewallDisposition { allow, redirectToBoundedLoop }

enum FirewallReasonCode {
  none,
  exactRepeat,
  paraphrasedRepeat,
  certaintyEscalation,
  checkingLoop,
  ruminationLoop,
  reconfession,
}

class FirewallDecision {
  const FirewallDecision({
    required this.disposition,
    required this.reasonCode,
    required this.userFacingCopy,
    this.redirectRoute,
  });

  final FirewallDisposition disposition;
  final FirewallReasonCode reasonCode;
  final String userFacingCopy;
  final String? redirectRoute;

  bool get isRedirect =>
      disposition == FirewallDisposition.redirectToBoundedLoop;
}

class FirewallAuditSnapshot {
  const FirewallAuditSnapshot({
    required this.turnCount,
    required this.reasonCodes,
  });

  final int turnCount;
  final List<FirewallReasonCode> reasonCodes;
}

class CompulsionFirewallSession {
  CompulsionFirewallSession({this.maxTurns = 8}) : assert(maxTurns > 1);

  final int maxTurns;
  final List<_Turn> _turns = <_Turn>[];
  final List<FirewallReasonCode> _reasonCodes = <FirewallReasonCode>[];

  FirewallDecision evaluate(String rawMessage) {
    final current = _Turn.fromRaw(rawMessage);

    if (current.normalized.isEmpty || _isHardEscape(current.normalized)) {
      return _rememberAndReturn(current, _allow());
    }

    if (_turns.isEmpty) {
      return _rememberAndReturn(current, _allow());
    }

    if (_isExplicitContextChange(current.normalized) &&
        current.riskFamily == _RiskFamily.none) {
      return _rememberAndReturn(current, _allow());
    }

    for (final previous in _turns.reversed) {
      final reason = _reasonAgainst(current, previous);
      if (reason != null) {
        return _rememberAndReturn(current, _redirect(reason));
      }
    }

    return _rememberAndReturn(current, _allow());
  }

  FirewallReasonCode? _reasonAgainst(_Turn current, _Turn previous) {
    final similarity = _jaccard(current.tokens, previous.tokens);
    final sameRiskFamily =
        current.riskFamily != _RiskFamily.none &&
        current.riskFamily == previous.riskFamily;

    if (current.normalized == previous.normalized &&
        current.riskFamily != _RiskFamily.none) {
      return FirewallReasonCode.exactRepeat;
    }

    if (_hasCertaintyEscalation(current.normalized) &&
        (_sharesTopic(current, previous) ||
            (sameRiskFamily && similarity >= 0.30))) {
      return FirewallReasonCode.certaintyEscalation;
    }

    if (current.riskFamily == _RiskFamily.checking &&
        previous.riskFamily == _RiskFamily.checking &&
        _relatedEnough(current, previous, similarity)) {
      return FirewallReasonCode.checkingLoop;
    }

    if (current.riskFamily == _RiskFamily.rumination &&
        previous.riskFamily == _RiskFamily.rumination &&
        _relatedEnough(current, previous, similarity)) {
      return FirewallReasonCode.ruminationLoop;
    }

    if (current.riskFamily == _RiskFamily.confession &&
        previous.riskFamily == _RiskFamily.confession &&
        (_sharesConfessionTopic(current, previous) ||
            _isReconfessionContinuation(current, previous))) {
      return FirewallReasonCode.reconfession;
    }

    if (sameRiskFamily &&
        current.riskFamily != _RiskFamily.confession &&
        similarity >= 0.42) {
      return FirewallReasonCode.paraphrasedRepeat;
    }

    if (current.riskFamily != _RiskFamily.none &&
        previous.riskFamily != _RiskFamily.none &&
        !(current.riskFamily == _RiskFamily.confession &&
            previous.riskFamily == _RiskFamily.confession) &&
        similarity >= 0.58) {
      return FirewallReasonCode.paraphrasedRepeat;
    }

    return null;
  }

  void reset() {
    _turns.clear();
    _reasonCodes.clear();
  }

  FirewallAuditSnapshot auditSnapshot() {
    return FirewallAuditSnapshot(
      turnCount: _turns.length,
      reasonCodes: List<FirewallReasonCode>.unmodifiable(_reasonCodes),
    );
  }

  FirewallDecision _rememberAndReturn(_Turn turn, FirewallDecision decision) {
    _turns.add(turn);
    _reasonCodes.add(decision.reasonCode);
    if (_turns.length > maxTurns) {
      _turns.removeAt(0);
      _reasonCodes.removeAt(0);
    }
    return decision;
  }

  static FirewallDecision _allow() {
    return const FirewallDecision(
      disposition: FirewallDisposition.allow,
      reasonCode: FirewallReasonCode.none,
      userFacingCopy: '',
    );
  }

  static FirewallDecision _redirect(FirewallReasonCode reasonCode) {
    return FirewallDecision(
      disposition: FirewallDisposition.redirectToBoundedLoop,
      reasonCode: reasonCode,
      redirectRoute: '/loop',
      userFacingCopy:
          'This may be the same question or analysis loop returning. '
          'Rather than trying to settle it again, choose one bounded next step. '
          'Human support remains available.',
    );
  }
}

enum _RiskFamily { none, certainty, checking, rumination, confession }

class _Turn {
  const _Turn({
    required this.normalized,
    required this.tokens,
    required this.riskFamily,
  });

  factory _Turn.fromRaw(String raw) {
    final normalized = _normalize(raw);
    final tokens = _semanticTokens(normalized);
    return _Turn(
      normalized: normalized,
      tokens: tokens,
      riskFamily: _riskFamilyFor(normalized),
    );
  }

  final String normalized;
  final Set<String> tokens;
  final _RiskFamily riskFamily;
}

String _normalize(String input) {
  return input
      .toLowerCase()
      .replaceAll(RegExp(r"[^a-z0-9\s']"), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

Set<String> _semanticTokens(String normalized) {
  const stopWords = <String>{
    'a',
    'an',
    'and',
    'are',
    'be',
    'but',
    'can',
    'could',
    'do',
    'for',
    'i',
    'if',
    'in',
    'is',
    'it',
    'me',
    'my',
    'of',
    'on',
    'or',
    'please',
    'so',
    'that',
    'the',
    'this',
    'to',
    'you',
  };
  return normalized
      .split(' ')
      .where((token) => token.length > 2 && !stopWords.contains(token))
      .map(_canonicalTopicToken)
      .toSet();
}

String _canonicalTopicToken(String token) {
  if (const <String>{
    'dangerous',
    'unsafe',
    'violent',
    'monster',
    'harmful',
  }.contains(token)) {
    return 'harm-identity';
  }
  return token;
}

_RiskFamily _riskFamilyFor(String text) {
  if (_containsAny(text, const <String>[
    'confess',
    'confession',
    'tell you again',
    'forgot to mention',
    'another detail',
    'one more detail',
    'admit again',
  ])) {
    return _RiskFamily.confession;
  }
  if (_containsAny(text, const <String>[
    'check again',
    'double check',
    'recheck',
    'verify again',
    'confirm again',
    'make sure',
    'check one last time',
  ])) {
    return _RiskFamily.checking;
  }
  if (_containsAny(text, const <String>[
    'analyze again',
    'keep analyzing',
    'keep thinking',
    'think through again',
    'figure this out',
    'explain again',
    'what if',
    'why does this mean',
  ])) {
    return _RiskFamily.rumination;
  }
  if (_containsAny(text, const <String>[
    'are you sure',
    'certain',
    'certainty',
    'guarantee',
    'promise',
    '100 sure',
    'definitely',
    'dangerous',
    'bad person',
    'safe for sure',
    'what does this say about me',
    'what does that say about me',
    'does this mean i am',
    'does that mean i am',
    'what kind of person',
    'who i am',
  ])) {
    return _RiskFamily.certainty;
  }
  if (_containsAny(text, const <String>[
    'analyze',
    'ruminate',
    'figure out',
    'think through',
  ])) {
    return _RiskFamily.rumination;
  }
  return _RiskFamily.none;
}

bool _hasCertaintyEscalation(String text) {
  return _containsAny(text, const <String>[
    '100 sure',
    'are you absolutely sure',
    'guarantee',
    'promise',
    'one last time',
    'double check',
    'check one last time',
    'definitely',
  ]);
}

bool _isHardEscape(String text) {
  if (_containsAny(text, const <String>[
    'accessibility ',
    'screen reader',
    'button is not working',
    'app error',
    'emergency ',
    'immediate danger',
  ])) {
    return true;
  }

  return text.contains('support ') &&
      _containsAny(text, const <String>[
        'trusted person',
        'therapist',
        'human support',
        'talk to a person',
        'talk to someone',
      ]);
}

bool _isExplicitContextChange(String text) {
  return _containsAny(text, const <String>[
    'correction ',
    'i meant ',
    'new question ',
    'different question ',
    'new information ',
  ]);
}

bool _relatedEnough(_Turn current, _Turn previous, double similarity) {
  return similarity >= 0.30 || _sharesTopic(current, previous);
}

bool _isReconfessionContinuation(_Turn current, _Turn previous) {
  final overlap = current.tokens.intersection(previous.tokens);
  final hasContinuationMarker = _containsAny(current.normalized, const <String>[
    'again',
    'one more detail',
    'another detail',
    'forgot to mention',
    'tell you again',
    'admit again',
  ]);
  final sharesConfessionAnchor = overlap.contains('detail');

  return hasContinuationMarker && sharesConfessionAnchor;
}

bool _sharesConfessionTopic(_Turn current, _Turn previous) {
  const genericConfessionTokens = <String>{
    'about',
    'admit',
    'again',
    'another',
    'confess',
    'confession',
    'detail',
    'forgot',
    'mention',
    'more',
    'need',
    'one',
    'thought',
  };
  final currentTopics = current.tokens.difference(genericConfessionTokens);
  final previousTopics = previous.tokens.difference(genericConfessionTokens);

  return currentTopics.intersection(previousTopics).isNotEmpty;
}

bool _sharesTopic(_Turn current, _Turn previous) {
  if (current.tokens.isEmpty || previous.tokens.isEmpty) {
    return false;
  }
  final overlap = current.tokens.intersection(previous.tokens);
  return overlap.length >= 2;
}

double _jaccard(Set<String> a, Set<String> b) {
  if (a.isEmpty || b.isEmpty) {
    return 0;
  }
  final intersection = a.intersection(b).length;
  final union = a.union(b).length;
  return intersection / union;
}

bool _containsAny(String text, List<String> needles) {
  for (final needle in needles) {
    if (text.contains(needle)) {
      return true;
    }
  }
  return false;
}
