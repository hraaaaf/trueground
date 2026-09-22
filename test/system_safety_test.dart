import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trueground/compulsion_firewall/compulsion_firewall.dart';
import 'package:trueground/loop/loop_flow_policy.dart';
import 'package:trueground/patterns/pattern_memory_store.dart';
import 'package:trueground/patterns/pattern_review_screen.dart';

class _UnavailableMemoryStore implements PatternMemoryStore {
  @override
  Future<void> append(
    PatternEventKind kind, {
    required DateTime occurredAt,
  }) async {}

  @override
  Future<void> deleteAll() async {}

  @override
  Future<void> deleteKind(PatternEventKind kind) async {}

  @override
  Future<List<PatternRecord>> readRecords({required DateTime now}) async {
    throw StateError('memory unavailable');
  }
}

bool _containsUnsupportedMedicalClaim(String input) {
  final normalized = input.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  final patterns = <RegExp>[
    RegExp(r'\byou have ocd\b'),
    RegExp(r'\bthis proves you have ocd\b'),
    RegExp(r'\btrueground (treats|cures|prevents) ocd\b'),
    RegExp(r'\bclinically proven\b'),
    RegExp(r'\bthis erp is prescribed for you\b'),
    RegExp(r'\btrueground is (equivalent|superior) to therapy\b'),
    RegExp(r'\bthis will reduce your ocd\b'),
  ];
  return patterns.any((pattern) => pattern.hasMatch(normalized));
}

Iterable<File> _dartFilesUnder(String root) sync* {
  final directory = Directory(root);
  if (!directory.existsSync()) return;
  for (final entity in directory.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      yield entity;
    }
  }
}

void _expectRepeatedLoopIsBounded(String first, String second) {
  final session = CompulsionFirewallSession();
  expect(session.evaluate(first).isRedirect, isFalse);
  final decision = session.evaluate(second);
  expect(decision.isRedirect, isTrue);
  expect(decision.redirectRoute, '/loop');
  expect(decision.userFacingCopy.toLowerCase(), isNot(contains('guarantee')));
  expect(decision.userFacingCopy.toLowerCase(), isNot(contains('definitely safe')));
}

void main() {
  group('LOT10 canonical deterministic safety families', () {
    test('neutral informational repetition remains allowed', () {
      final session = CompulsionFirewallSession();
      expect(session.evaluate('Where is the support screen?').isRedirect, isFalse);
      expect(session.evaluate('Where is the support screen?').isRedirect, isFalse);
    });

    test('reassurance, checking, rumination and confession repeats are bounded', () {
      final cases = <(String, String)>[
        ('Are you sure I am not dangerous?', 'Can you guarantee I am not dangerous?'),
        ('Please check again that I locked the door.', 'Double check that I locked the door.'),
        ('I need to analyze again what this means.', 'Keep analyzing what this means for me.'),
        ('I forgot to mention another detail.', 'One more detail I need to confess again.'),
        ('What if this means something terrible?', 'What if this means something terrible?'),
      ];
      for (final pair in cases) {
        _expectRepeatedLoopIsBounded(pair.$1, pair.$2);
      }
    });

    test('canonical OCD themes stay inside the same anti-certainty boundary', () {
      final themeCases = <String>[
        'Are you sure contamination means I am dangerous?',
        'Are you sure this harm thought means I am dangerous?',
        'Are you sure this relationship doubt means I am dangerous?',
        'Are you sure this religious thought means I am a bad person?',
        'Are you sure this sexual intrusive thought means I am dangerous?',
        'Are you sure things being uneven means something bad?',
        'Are you sure this health fear means I am definitely ill?',
        'Are you sure this existential doubt has a definite answer?',
      ];
      for (final message in themeCases) {
        _expectRepeatedLoopIsBounded(message, message);
      }
    });

    test('intrusive-thought policy does not infer intent or diagnosis', () {
      final copy = loopPatternContent[LoopPattern.intrusive]!.framing.toLowerCase();
      expect(copy, contains('will not infer intent'));
      expect(copy, contains('diagnosis'));
    });

    test('explicit immediate danger is not swallowed by the compulsion firewall', () {
      final session = CompulsionFirewallSession();
      session.evaluate('Are you sure I am not dangerous?');
      final danger = session.evaluate('I am in immediate danger and need support');
      expect(danger.isRedirect, isFalse);
    });
  });

  group('LOT10 memory truthfulness', () {
    test('stale and future records are excluded from bounded memory', () {
      final now = DateTime.utc(2026, 9, 22, 12);
      final retained = retainPatternRecords(
        <PatternRecord>[
          PatternRecord(
            kind: PatternEventKind.pausePractice,
            occurredAt: now.subtract(const Duration(days: 31)),
          ),
          PatternRecord(
            kind: PatternEventKind.valuesStep,
            occurredAt: now.subtract(const Duration(hours: 1)),
          ),
          PatternRecord(
            kind: PatternEventKind.uncertaintyPractice,
            occurredAt: now.add(const Duration(minutes: 1)),
          ),
        ],
        now: now,
      );
      expect(retained, hasLength(1));
      expect(retained.single.kind, PatternEventKind.valuesStep);
    });

    testWidgets('unavailable memory is disclosed without false retrieval', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternReviewScreen(
              memoryStore: _UnavailableMemoryStore(),
              now: () => DateTime.utc(2026, 9, 22, 12),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(PatternReviewScreen.unavailableKey), findsOneWidget);
      expect(find.textContaining('could not be checked'), findsOneWidget);
      expect(find.textContaining('will not guess'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('LOT10 unsupported medical claim detection', () {
    test('versioned prohibited fixtures are detected', () {
      const prohibited = <String>[
        'You have OCD.',
        'This proves you have OCD.',
        'TrueGround treats OCD.',
        'TrueGround cures OCD.',
        'TrueGround prevents OCD.',
        'Clinically proven.',
        'This ERP is prescribed for you.',
        'TrueGround is equivalent to therapy.',
        'TrueGround is superior to therapy.',
        'This will reduce your OCD.',
      ];
      for (final value in prohibited) {
        expect(_containsUnsupportedMedicalClaim(value), isTrue, reason: value);
      }
    });

    test('bounded negative controls are not flagged', () {
      const safe = <String>[
        'This may be a checking loop.',
        'This tool will not infer intent or make a diagnosis.',
        'TrueGround has not contacted anyone.',
        'History could not be checked.',
      ];
      for (final value in safe) {
        expect(_containsUnsupportedMedicalClaim(value), isFalse, reason: value);
      }
    });

    test('current user-facing runtime has no prohibited fixture match', () {
      final hits = <String>[];
      for (final file in _dartFilesUnder('lib')) {
        final source = file.readAsStringSync();
        if (_containsUnsupportedMedicalClaim(source)) {
          hits.add(file.path);
        }
      }
      expect(hits, isEmpty, reason: 'Unsupported medical claim markers: $hits');
    });
  });

  group('LOT10 provider, tool and language applicability', () {
    test('runtime does not introduce an AI/provider dependency', () {
      final pubspec = File('pubspec.yaml').readAsStringSync().toLowerCase();
      for (final marker in <String>[
        'openai',
        'anthropic',
        'gemini',
        'firebase_ai',
        'google_generative_ai',
      ]) {
        expect(pubspec, isNot(contains(marker)), reason: marker);
      }
    });

    test('current build has no localization runtime dependency', () {
      final pubspec = File('pubspec.yaml').readAsStringSync().toLowerCase();
      expect(pubspec, isNot(contains('flutter_localizations')));
      expect(Directory('lib/l10n').existsSync(), isFalse);
    });
  });
}
