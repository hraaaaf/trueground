import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:trueground/conversation/conversation_output_guard.dart';
import 'package:trueground/conversation/conversation_safety_policy.dart';

Map<String, dynamic> _loadCorpus() {
  final raw = File(
    'tool/lot11g/pre_human_adversarial_pack.json',
  ).readAsStringSync();
  return jsonDecode(raw) as Map<String, dynamic>;
}

void main() {
  final corpus = _loadCorpus();
  final inputScenarios = (corpus['input_scenarios'] as List<dynamic>)
      .cast<Map<String, dynamic>>();
  final guardScenarios = (corpus['guard_scenarios'] as List<dynamic>)
      .cast<Map<String, dynamic>>();

  test('LOT11-G corpus is frozen at exactly 72 synthetic scenarios', () {
    expect(corpus['schema_version'], 'tg11g.prehuman.adversarial.v1.1');
    expect(corpus['synthetic_only'], isTrue);
    expect(corpus['raw_user_data'], isFalse);
    expect(inputScenarios, hasLength(48));
    expect(guardScenarios, hasLength(24));
    expect(inputScenarios.length + guardScenarios.length, 72);
  });

  group('LOT11-G deterministic pre-model adversarial scenarios', () {
    for (final fixture in inputScenarios) {
      final id = fixture['id'] as String;
      final family = fixture['family'] as String;
      final variant = fixture['variant'] as String;
      final turns = (fixture['turns'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      final expected = (fixture['expected_outcomes'] as List<dynamic>)
          .cast<String>();

      test('$id | $family | $variant', () {
        expect(
          turns.length,
          expected.length,
          reason: '$id must declare one expected outcome per turn',
        );

        final session = ConversationSafetySession();
        for (var index = 0; index < turns.length; index += 1) {
          final turn = turns[index];
          final decision = session.evaluate(
            turn['message'] as String,
            languageCode: turn['language'] as String,
          );
          expect(
            decision.outcome.name,
            expected[index],
            reason:
                '$id turn ${index + 1} violated the frozen LOT11-G safety expectation',
          );
        }
      });
    }
  });

  group('LOT11-G deterministic output-guard adversarial scenarios', () {
    for (final fixture in guardScenarios) {
      final id = fixture['id'] as String;
      final family = fixture['family'] as String;
      final expectedRejected = fixture['expected_rejected'] as bool;

      test('$id | $family', () {
        final result = DeterministicConversationOutputGuard.inspect(
          fixture['output'] as String,
        );
        expect(
          result.isRejected,
          expectedRejected,
          reason:
              '$id output-guard decision diverged from the frozen LOT11-G contract',
        );
      });
    }
  });
}
