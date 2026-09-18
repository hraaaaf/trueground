import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trueground/app/trueground_app.dart';
import 'package:trueground/loop/loop_flow_screen.dart';

Future<void> _useSurface(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Future<void> _openLoop(WidgetTester tester) async {
  await tester.pumpWidget(const TrueGroundApp());
  await tester.pumpAndSettle();
  await tester.tap(find.text('Loop'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Loop entry is bounded and has no unrestricted chat composer', (
    tester,
  ) async {
    await _useSurface(tester, const Size(390, 844));
    await _openLoop(tester);

    expect(find.byKey(LoopFlowScreen.screenKey), findsOneWidget);
    expect(find.byKey(LoopFlowScreen.patternStepKey), findsOneWidget);
    expect(find.text('Choose the closest fit.'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(EditableText), findsNothing);
    expect(find.text('Send'), findsNothing);
    expect(find.textContaining('open chat'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  final patternExpectations = <String, String>{
    'certainty': 'This may be a certainty-seeking loop.',
    'checking': 'This may be a checking loop.',
    'rumination': 'This may be a rumination loop.',
    'repetition': 'This may be a repetition loop.',
    'intrusive': 'This tool will not infer intent or make a diagnosis',
    'other': 'We do not need to label the pattern precisely',
  };

  for (final entry in patternExpectations.entries) {
    testWidgets('pattern ${entry.key} receives bounded cautious framing', (
      tester,
    ) async {
      await _useSurface(tester, const Size(390, 844));
      await _openLoop(tester);

      final pattern = find.byKey(ValueKey('loop-pattern-${entry.key}'));
      await tester.scrollUntilVisible(
        pattern,
        120,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(pattern);
      await tester.pumpAndSettle();

      expect(find.byKey(LoopFlowScreen.actionStepKey), findsOneWidget);
      expect(find.textContaining(entry.value), findsOneWidget);
      expect(find.text('Choose one next move.'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Send'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('canonical human-support escape hatch routes to Support', (
    tester,
  ) async {
    await _useSurface(tester, const Size(390, 844));
    await _openLoop(tester);

    expect(find.text('Need a person, not an answer?'), findsOneWidget);
    expect(find.text('Therapist or trusted person.'), findsOneWidget);
    expect(find.textContaining('immediate danger'), findsNothing);

    await tester.tap(find.byKey(LoopFlowScreen.supportEscapeKey));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('screen-support')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('selected next action reaches an explicit end state', (
    tester,
  ) async {
    await _useSurface(tester, const Size(390, 844));
    await _openLoop(tester);

    await tester.tap(find.byKey(const ValueKey('loop-pattern-certainty')));
    await tester.pumpAndSettle();
    final practice = find.byKey(
      const ValueKey('loop-action-practiceUncertainty'),
    );
    await tester.scrollUntilVisible(
      practice,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(practice);
    await tester.pumpAndSettle();

    expect(find.byKey(LoopFlowScreen.completeStepKey), findsOneWidget);
    expect(find.text('Next move chosen'), findsOneWidget);
    expect(find.textContaining('There is no restart button'), findsOneWidget);
    expect(find.text('Start over'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('loop-continue-action')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('screen-practice')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Return Home action exits the bounded flow', (tester) async {
    await _useSurface(tester, const Size(390, 844));
    await _openLoop(tester);

    final other = find.byKey(const ValueKey('loop-pattern-other'));
    await tester.scrollUntilVisible(
      other,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(other);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('loop-action-returnHome')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('loop-continue-action')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('screen-home-dashboard-v3')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  for (final size in <Size>[const Size(360, 800), const Size(390, 844)]) {
    testWidgets(
      'Loop flow renders without overflow at ${size.width.toInt()} px',
      (tester) async {
        await _useSurface(tester, size);
        await _openLoop(tester);

        expect(find.byKey(LoopFlowScreen.screenKey), findsOneWidget);
        expect(find.text('Choose the closest fit.'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final size in <Size>[const Size(360, 800), const Size(390, 844)]) {
    testWidgets(
      'Loop critical actions remain reachable at 200% text scaling at ${size.width.toInt()} px',
      (tester) async {
        await _useSurface(tester, size);
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        final semantics = tester.ensureSemantics();
        try {
          await _openLoop(tester);

          expect(find.byKey(LoopFlowScreen.screenKey), findsOneWidget);
          expect(find.byKey(LoopFlowScreen.supportEscapeKey), findsOneWidget);

          final other = find.byKey(const ValueKey('loop-pattern-other'));
          await tester.scrollUntilVisible(
            other,
            160,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          expect(other.hitTestable(), findsOneWidget);
          await tester.tap(other);
          await tester.pumpAndSettle();

          final returnHome = find.byKey(
            const ValueKey('loop-action-returnHome'),
          );
          await tester.scrollUntilVisible(
            returnHome,
            160,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          expect(returnHome.hitTestable(), findsOneWidget);
          await tester.tap(returnHome);
          await tester.pumpAndSettle();

          final continueAction = find.byKey(
            const ValueKey('loop-continue-action'),
          );
          await tester.scrollUntilVisible(
            continueAction,
            160,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          expect(continueAction.hitTestable(), findsOneWidget);
          expect(find.byKey(LoopFlowScreen.completeStepKey), findsOneWidget);

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

  for (final size in <Size>[const Size(360, 800), const Size(390, 844)]) {
    testWidgets(
      'Loop pattern, action, and complete states meet accessibility guidelines at ${size.width.toInt()} px',
      (tester) async {
        await _useSurface(tester, size);
        final semantics = tester.ensureSemantics();
        try {
          await _openLoop(tester);

          Future<void> expectGuidelines() async {
            await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
            await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
            await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
            await expectLater(tester, meetsGuideline(textContrastGuideline));
            expect(tester.takeException(), isNull);
          }

          await expectGuidelines();

          final certainty = find.byKey(
            const ValueKey('loop-pattern-certainty'),
          );
          await tester.scrollUntilVisible(
            certainty,
            120,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          await tester.tap(certainty);
          await tester.pumpAndSettle();

          expect(find.byKey(LoopFlowScreen.actionStepKey), findsOneWidget);
          await expectGuidelines();

          final practice = find.byKey(
            const ValueKey('loop-action-practiceUncertainty'),
          );
          await tester.scrollUntilVisible(
            practice,
            120,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          await tester.tap(practice);
          await tester.pumpAndSettle();

          expect(find.byKey(LoopFlowScreen.completeStepKey), findsOneWidget);
          await expectGuidelines();
        } finally {
          semantics.dispose();
        }
      },
    );
  }
}
