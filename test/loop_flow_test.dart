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

      await tester.tap(find.byKey(ValueKey('loop-pattern-${entry.key}')));
      await tester.pumpAndSettle();

      expect(find.byKey(LoopFlowScreen.actionStepKey), findsOneWidget);
      expect(find.textContaining(entry.value), findsOneWidget);
      expect(find.text('Choose one next move.'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Send'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('immediate-safety boundary routes out to Support', (
    tester,
  ) async {
    await _useSurface(tester, const Size(390, 844));
    await _openLoop(tester);

    expect(
      find.textContaining('immediate danger or unable to stay safe'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(LoopFlowScreen.safetySupportKey));
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
    await tester.tap(
      find.byKey(const ValueKey('loop-action-practiceUncertainty')),
    );
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

    await tester.tap(find.byKey(const ValueKey('loop-pattern-other')));
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

  testWidgets('Loop critical actions remain reachable at 200% text scaling', (
    tester,
  ) async {
    await _useSurface(tester, const Size(360, 800));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _openLoop(tester);

    expect(find.byKey(LoopFlowScreen.screenKey), findsOneWidget);
    expect(find.byKey(LoopFlowScreen.safetySupportKey), findsOneWidget);

    final other = find.byKey(const ValueKey('loop-pattern-other'));
    await tester.scrollUntilVisible(
      other,
      160,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(other.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Loop surface meets Flutter accessibility guidelines', (
    tester,
  ) async {
    await _useSurface(tester, const Size(390, 844));
    final semantics = tester.ensureSemantics();
    try {
      await _openLoop(tester);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });
}
