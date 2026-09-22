import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trueground/app/trueground_app.dart';
import 'package:trueground/patterns/pattern_memory_store.dart';
import 'package:trueground/patterns/pattern_review_screen.dart';
import 'package:trueground/practice/practice_completion_store.dart';

class _FakePracticeCompletionStore implements PracticeCompletionStore {
  DateTime? pauseCompletedAt;
  DateTime? uncertaintyCompletedAt;

  @override
  Future<DateTime?> readPauseCompletedAt() async => pauseCompletedAt;

  @override
  Future<DateTime?> readUncertaintyCompletedAt() async => uncertaintyCompletedAt;

  @override
  Future<void> writePauseCompletedAt(DateTime completedAt) async {
    pauseCompletedAt = completedAt;
  }

  @override
  Future<void> writeUncertaintyCompletedAt(DateTime completedAt) async {
    uncertaintyCompletedAt = completedAt;
  }
}

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


  test('retention drops expired and future records and caps history', () {
    final now = DateTime.utc(2026, 9, 22, 12);
    final records = <PatternRecord>[
      PatternRecord(
        kind: PatternEventKind.pausePractice,
        occurredAt: now.subtract(const Duration(days: 31)),
      ),
      for (var index = 0; index < 35; index += 1)
        PatternRecord(
          kind: PatternEventKind.valuesStep,
          occurredAt: now.subtract(Duration(hours: index)),
        ),
      PatternRecord(
        kind: PatternEventKind.uncertaintyPractice,
        occurredAt: now.add(const Duration(minutes: 1)),
      ),
    ];

    final retained = retainPatternRecords(records, now: now);

    expect(retained, hasLength(patternMemoryMaxRecords));
    expect(
      retained.any((record) => record.occurredAt.isAfter(now)),
      isFalse,
    );
    expect(
      retained.any(
        (record) =>
            record.occurredAt.isBefore(now.subtract(patternMemoryRetention)),
      ),
      isFalse,
    );
  });

  testWidgets('dashboard card opens bounded pattern review', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final store = _FakePatternMemoryStore();

    await tester.pumpWidget(TrueGroundApp(patternMemoryStore: store));
    await tester.pumpAndSettle();

    final card = find.text('Review patterns when useful');
    await tester.scrollUntilVisible(
      card,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(card);
    await tester.pumpAndSettle();

    expect(find.byKey(PatternReviewScreen.screenKey), findsOneWidget);
    expect(find.byKey(PatternReviewScreen.emptyKey), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('practice completion writes only a structured pattern event', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final store = _FakePatternMemoryStore();

    await tester.pumpWidget(
      TrueGroundApp(
        patternMemoryStore: store,
        practiceCompletionStore: _FakePracticeCompletionStore(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Practice').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('practice-choice-pause')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start a brief pause'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(store.records, hasLength(1));
    expect(store.records.single.kind, PatternEventKind.pausePractice);
    expect(tester.takeException(), isNull);
  });

  testWidgets('values completion writes one structured values event', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final store = _FakePatternMemoryStore();

    await tester.pumpWidget(TrueGroundApp(patternMemoryStore: store));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Return to what matters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Family'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take my next step'));
    await tester.pumpAndSettle();

    expect(store.records, hasLength(1));
    expect(store.records.single.kind, PatternEventKind.valuesStep);
    expect(tester.takeException(), isNull);
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
