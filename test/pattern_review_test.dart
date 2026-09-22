import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trueground/patterns/pattern_memory_store.dart';
import 'package:trueground/patterns/pattern_review_screen.dart';

class _FakePatternMemoryStore implements PatternMemoryStore {
  List<PatternRecord> records = <PatternRecord>[];
  bool failReads = false;

  @override
  Future<void> append(PatternEventKind kind, {required DateTime occurredAt}) async {
    records.add(PatternRecord(kind: kind, occurredAt: occurredAt));
  }

  @override
  Future<void> deleteAll() async {
    records.clear();
  }

  @override
  Future<void> deleteKind(PatternEventKind kind) async {
    records.removeWhere((record) => record.kind == kind);
  }

  @override
  Future<List<PatternRecord>> readRecords({required DateTime now}) async {
    if (failReads) throw StateError('memory unavailable');
    return List<PatternRecord>.unmodifiable(records);
  }
}

Future<void> _pump(
  WidgetTester tester, {
  required PatternMemoryStore store,
  Size size = const Size(390, 844),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: PatternReviewScreen(
          memoryStore: store,
          now: () => DateTime.utc(2026, 9, 22, 12),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('retention duration is product storage policy, not a clinical schedule', () {
    expect(patternMemoryRetention, const Duration(days: 30));
    expect(patternMemoryMaxRecords, 30);
  });

  testWidgets('empty history is reported without invented pattern', (tester) async {
    await _pump(tester, store: _FakePatternMemoryStore());

    expect(find.byKey(PatternReviewScreen.emptyKey), findsOneWidget);
    expect(find.textContaining('will not infer a pattern'), findsOneWidget);
    expect(find.textContaining('severity'), findsOneWidget);
    expect(find.textContaining('streak'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unavailable memory is disclosed and history is not fabricated', (
    tester,
  ) async {
    final store = _FakePatternMemoryStore()..failReads = true;
    await _pump(tester, store: store);

    expect(find.byKey(PatternReviewScreen.unavailableKey), findsOneWidget);
    expect(find.textContaining('could not be checked'), findsOneWidget);
    expect(find.textContaining('will not guess'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('review shows bounded unique types without counts dates or trend', (
    tester,
  ) async {
    final store = _FakePatternMemoryStore()
      ..records = <PatternRecord>[
        PatternRecord(
          kind: PatternEventKind.pausePractice,
          occurredAt: DateTime.utc(2026, 9, 20),
        ),
        PatternRecord(
          kind: PatternEventKind.pausePractice,
          occurredAt: DateTime.utc(2026, 9, 21),
        ),
        PatternRecord(
          kind: PatternEventKind.valuesStep,
          occurredAt: DateTime.utc(2026, 9, 22),
        ),
      ];

    await _pump(tester, store: store);

    expect(find.byKey(PatternReviewScreen.loadedKey), findsOneWidget);
    expect(find.text('Paused before an urge-driven action'), findsOneWidget);
    expect(find.text('Chose a values-based next step'), findsOneWidget);
    expect(find.textContaining('2 times'), findsNothing);
    expect(find.textContaining('September'), findsNothing);
    expect(find.textContaining('better'), findsOneWidget);
    expect(find.textContaining('score'), findsOneWidget);
    expect(find.textContaining('trend'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('one activity type can be removed without deleting others', (
    tester,
  ) async {
    final store = _FakePatternMemoryStore()
      ..records = <PatternRecord>[
        PatternRecord(
          kind: PatternEventKind.pausePractice,
          occurredAt: DateTime.utc(2026, 9, 20),
        ),
        PatternRecord(
          kind: PatternEventKind.valuesStep,
          occurredAt: DateTime.utc(2026, 9, 21),
        ),
      ];

    await _pump(tester, store: store);
    final removeButtons = find.text('Remove');
    expect(removeButtons, findsNWidgets(2));
    await tester.tap(removeButtons.first);
    await tester.pumpAndSettle();

    expect(store.records.length, 1);
    expect(find.text('Chose a values-based next step'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('delete all clears saved activity', (tester) async {
    final store = _FakePatternMemoryStore()
      ..records = <PatternRecord>[
        PatternRecord(
          kind: PatternEventKind.pausePractice,
          occurredAt: DateTime.utc(2026, 9, 20),
        ),
      ];

    await _pump(tester, store: store);
    await tester.tap(find.byKey(const ValueKey('pattern-delete-all')));
    await tester.pumpAndSettle();

    expect(store.records, isEmpty);
    expect(find.byKey(PatternReviewScreen.emptyKey), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in <Size>[const Size(360, 800), const Size(390, 844)]) {
    testWidgets('pattern review is reachable at 200% text on ${size.width}', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final store = _FakePatternMemoryStore()
        ..records = <PatternRecord>[
          PatternRecord(
            kind: PatternEventKind.uncertaintyPractice,
            occurredAt: DateTime.utc(2026, 9, 21),
          ),
        ];

      await _pump(tester, store: store, size: size);
      await tester.scrollUntilVisible(
        find.text('Finish review'),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Finish review').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
