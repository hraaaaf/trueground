import 'dart:convert';
import 'dart:io';

import 'package:trueground/conversation/conversation_output_guard.dart';

Map<String, Object?> _reconfessionDiagnostic(String raw) {
  final text = raw.toLowerCase().replaceAll(RegExp(r'\\s+'), ' ').trim();
  final candidates = <({String family, RegExp pattern})>[
    (
      family: 'generic_more_detail',
      pattern: RegExp(
        r'\\b(keep talking about it|share more details|give another detail)\\b',
      ),
    ),
    (
      family: 'certainty_detail',
      pattern: RegExp(
        r'\\b(one more detail|another detail|more details|one more thing|other thing)\\b',
      ),
    ),
  ];

  for (final candidate in candidates) {
    final match = candidate.pattern.firstMatch(text);
    if (match == null) continue;

    final prefixStart = match.start > 100 ? match.start - 100 : 0;
    final prefix = text.substring(prefixStart, match.start);
    final negationBefore = <String>[
      'do not',
      "don't",
      'no need to',
      'you do not need to',
      "you don't need to",
      'without',
      'rather than',
      'instead of',
      'avoid',
      'not necessary to',
    ].any(prefix.contains);
    final protectiveBefore = <String>[
      'move forward',
      'let the urge',
      'leave the details',
      'resist the urge',
      'choose not to',
      'you can pause',
    ].any(prefix.contains);

    return <String, Object?>{
      'match_family': candidate.family,
      'position_bucket': match.start < 20
          ? 'start'
          : (match.start < 80 ? 'early' : 'later'),
      'negation_before': negationBefore,
      'protective_before': protectiveBefore,
    };
  }

  return const <String, Object?>{
    'match_family': 'none',
    'position_bucket': 'none',
    'negation_before': false,
    'protective_before': false,
  };
}

Future<void> main() async {
  final raw = await stdin.transform(utf8.decoder).join();
  final decoded = jsonDecode(raw);
  if (decoded is! List) {
    stderr.writeln('Expected a JSON list');
    exitCode = 2;
    return;
  }

  final results = <Map<String, Object?>>[];
  for (final item in decoded) {
    if (item is! Map) {
      stderr.writeln('Invalid item');
      exitCode = 2;
      return;
    }
    final id = item['id'];
    final message = item['message'];
    if (id is! String || message is! String) {
      stderr.writeln('Invalid id/message');
      exitCode = 2;
      return;
    }
    final decision = DeterministicConversationOutputGuard.inspect(message);
    results.add(<String, Object?>{
      'id': id,
      'rejected': decision.isRejected,
      'violation': decision.violation.name,
      if (decision.violation == OutputGuardViolation.reconfessionSolicitation)
        'reconfession_diagnostic': _reconfessionDiagnostic(message),
    });
  }

  stdout.write(jsonEncode(results));
}
