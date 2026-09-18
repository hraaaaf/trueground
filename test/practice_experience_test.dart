import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trueground/app/trueground_app.dart';
import 'package:trueground/practice/practice_screen.dart';

Future<void> _useSurface(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Future<void> _openPractice(WidgetTester tester) async {
  await tester.pumpWidget(const TrueGroundApp());
  await tester.pumpAndSettle();
  await tester.tap(find.text('Practice').first);
  await tester.pumpAndSettle();
}

Future<void> _scrollTo(
  WidgetTester tester,
  Finder finder, {
  double delta = 140,
}) async {
  await tester.scrollUntilVisible(
    finder,
    delta,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Practice entry exposes three bounded surfaces without free text', (
    tester,
  ) async {
    await _useSurface(tester, const Size(390, 844));
    await _openPractice(tester);

    expect(find.byKey(PracticeScreen.screenKey), findsOneWidget);
    expect(find.byKey(PracticeScreen.menuKey), findsOneWidget);
    expect(find.text('Pause the ritual'), findsOneWidget);
    expect(find.text('Practice uncertainty'), findsOneWidget);
    expect(find.text('Continue planned practice'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(EditableText), findsNothing);
    expect(
      find.textContaining('No scores, streaks or anxiety ratings'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Pause is finite, has no timer, and does not require calm', (
    tester,
  ) async {
    await _useSurface(tester, const Size(390, 844));
    await _openPractice(tester);

    await tester.tap(find.byKey(const ValueKey('practice-choice-pause')));
    await tester.pumpAndSettle();

    expect(find.byKey(PracticeScreen.pauseStartKey), findsOneWidget);
    expect(
      find.text('Not for urgent safety, medical or emergency decisions.'),
      findsOneWidget,
    );
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.textContaining('minute'), findsNothing);

    await tester.tap(find.text('Start a brief pause'));
    await tester.pumpAndSettle();

    expect(find.byKey(PracticeScreen.pauseMomentKey), findsOneWidget);
    expect(
      find.textContaining('You do not need to feel calm before moving on'),
      findsOneWidget,
    );
    expect(find.textContaining('you are safe'), findsNothing);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.byKey(PracticeScreen.pauseEndKey), findsOneWidget);
    expect(find.text('Practice ends here.'), findsOneWidget);
    expect(find.textContaining('does not grade'), findsOneWidget);
    expect(find.text('Again'), findsNothing);
    expect(find.text('Repeat'), findsNothing);
    expect(find.textContaining('score to check'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Pause completion discourages direct replay in same app session', (
    tester,
  ) async {
    await _useSurface(tester, const Size(390, 844));
    await _openPractice(tester);

    await tester.tap(find.byKey(const ValueKey('practice-choice-pause')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start a brief pause'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('practice-return-home')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Practice').first);
    await tester.pumpAndSettle();

    expect(find.byKey(PracticeScreen.menuKey), findsOneWidget);
    expect(find.text('Pause finished for now'), findsOneWidget);
    expect(find.text('Pause the ritual'), findsNothing);
    expect(find.textContaining('There is no replay button'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Practice uncertainty is finite and does not generate exposure', (
    tester,
  ) async {
    await _useSurface(tester, const Size(390, 844));
    await _openPractice(tester);

    await tester.tap(
      find.byKey(const ValueKey('practice-choice-uncertainty')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(PracticeScreen.uncertaintyStartKey), findsOneWidget);
    expect(
      find.textContaining(
        'not in proving that a feared outcome is safe or unsafe',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Begin'));
    await tester.pumpAndSettle();
    expect(find.byKey(PracticeScreen.uncertaintyNoticeKey), findsOneWidget);
    expect(find.textContaining('do not need to analyze'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.byKey(PracticeScreen.uncertaintyChooseKey), findsOneWidget);
    expect(find.text('I may not know for sure right now.'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(EditableText), findsNothing);

    await tester.tap(find.text('Finish practice'));
    await tester.pumpAndSettle();
    expect(find.byKey(PracticeScreen.uncertaintyEndKey), findsOneWidget);
    expect(find.textContaining('No rating is needed'), findsOneWidget);
    expect(find.text('Again'), findsNothing);
    expect(find.text('Repeat'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uncertainty neutral stance is shown once', (tester) async {
    await _useSurface(tester, const Size(390, 844));
    await _openPractice(tester);

    await tester.tap(
      find.byKey(const ValueKey('practice-choice-uncertainty')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Begin'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('I may not know for sure right now.'), findsOneWidget);
    expect(find.textContaining('10 times'), findsNothing);
    expect(find.textContaining('until it feels right'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Continue planned practice reports missing persistence honestly', (
    tester,
  ) async {
    await _useSurface(tester, const Size(390, 844));
    await _openPractice(tester);

    final planned = find.byKey(const ValueKey('practice-choice-planned'));
    await _scrollTo(tester, planned);
    await tester.tap(planned);
    await tester.pumpAndSettle();

    expect(find.byKey(PracticeScreen.plannedEmptyKey), findsOneWidget);
    expect(
      find.textContaining('No saved practice is available in this version'),
      findsOneWidget,
    );
    expect(
      find.textContaining('will not pretend to remember'),
      findsOneWidget,
    );
    expect(find.textContaining('Last practiced'), findsNothing);
    expect(find.textContaining('streak'), findsNothing);
    expect(find.byKey(const ValueKey('practice-planned-back')), findsOneWidget);
    expect(find.byKey(const ValueKey('practice-planned-home')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Exit practice returns to menu without marking completion', (
    tester,
  ) async {
    await _useSurface(tester, const Size(390, 844));
    await _openPractice(tester);

    await tester.tap(find.byKey(const ValueKey('practice-choice-pause')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Exit practice'));
    await tester.pumpAndSettle();

    expect(find.byKey(PracticeScreen.menuKey), findsOneWidget);
    expect(find.text('Pause the ritual'), findsOneWidget);
    expect(find.text('Pause finished for now'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Practice copy contains no unsupported efficacy claims', (
    tester,
  ) async {
    await _useSurface(tester, const Size(390, 844));
    await _openPractice(tester);

    final forbidden = <String>[
      'clinically proven',
      'treats OCD',
      'your anxiety should go down',
      'nothing bad will happen',
      'prescribed for you',
      'you did it correctly',
      'you successfully prevented',
    ];

    for (final phrase in forbidden) {
      expect(find.textContaining(phrase, findRichText: true), findsNothing);
    }

    expect(tester.takeException(), isNull);
  });

  for (final size in <Size>[const Size(360, 800), const Size(390, 844)]) {
    testWidgets(
      'Practice menu and states render without overflow at ${size.width.toInt()} px',
      (tester) async {
        await _useSurface(tester, size);
        await _openPractice(tester);

        expect(find.byKey(PracticeScreen.menuKey), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.byKey(const ValueKey('practice-choice-pause')));
        await tester.pumpAndSettle();
        expect(find.byKey(PracticeScreen.pauseStartKey), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Start a brief pause'));
        await tester.pumpAndSettle();
        expect(find.byKey(PracticeScreen.pauseMomentKey), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(find.byKey(PracticeScreen.pauseEndKey), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final size in <Size>[const Size(360, 800), const Size(390, 844)]) {
    testWidgets(
      'Practice remains reachable at 200% text scaling at ${size.width.toInt()} px',
      (tester) async {
        await _useSurface(tester, size);
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        final semantics = tester.ensureSemantics();
        try {
          await _openPractice(tester);

          final pause = find.byKey(const ValueKey('practice-choice-pause'));
          await _scrollTo(tester, pause, delta: 160);
          expect(pause.hitTestable(), findsOneWidget);
          await tester.tap(pause);
          await tester.pumpAndSettle();

          final start = find.text('Start a brief pause');
          await _scrollTo(tester, start, delta: 160);
          expect(start.hitTestable(), findsOneWidget);
          await tester.tap(start);
          await tester.pumpAndSettle();

          final continueButton = find.text('Continue');
          await _scrollTo(tester, continueButton, delta: 160);
          expect(continueButton.hitTestable(), findsOneWidget);

          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          expect(tester.takeException(), isNull);
        } finally {
          semantics.dispose();
        }
      },
    );
  }
}
