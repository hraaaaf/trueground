import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trueground/app/trueground_app.dart';
import 'package:trueground/dashboard/dashboard_v3_screen.dart';

Future<void> _useSurface(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

void main() {
  testWidgets('Dashboard V3 contains the LOT 04B target hierarchy', (
    tester,
  ) async {
    await _useSurface(tester, const Size(390, 844));
    await tester.pumpWidget(const TrueGroundApp());
    await tester.pumpAndSettle();

    expect(find.byKey(DashboardV3Screen.screenKey), findsOneWidget);

    for (final text in <String>[
      'Good evening',
      'Choose your next move.',
      'Make room for uncertainty.\nChoose what matters.',
      "I'm stuck in a loop",
      'Notice the urge. Pause before the ritual.',
      'Pause the ritual',
      'Practice uncertainty',
      'Continue planned practice',
      'Return to what matters',
      'Need a person, not an answer?',
      'Review patterns when useful',
    ]) {
      expect(
        find.text(text),
        findsOneWidget,
        reason: 'Missing LOT 04B target copy: $text',
      );
    }

    for (final forbidden in <String>[
      'Mild',
      'Moderate',
      'Severe',
      'Streak',
      'Anxiety score',
      'Reassurance resisted',
    ]) {
      expect(find.textContaining(forbidden), findsNothing);
    }

    expect(tester.takeException(), isNull);
  });

  for (final size in <Size>[const Size(360, 800), const Size(390, 844)]) {
    testWidgets(
      'Dashboard V3 renders target grid without framework exceptions at ${size.width.toInt()} px',
      (tester) async {
        await _useSurface(tester, size);
        await tester.pumpWidget(const TrueGroundApp());
        await tester.pumpAndSettle();

        expect(find.byKey(DashboardV3Screen.screenKey), findsOneWidget);
        expect(find.text('Choose your next move.'), findsOneWidget);
        expect(find.byKey(DashboardV3Screen.practiceGridKey), findsOneWidget);
        expect(find.byKey(DashboardV3Screen.valuesGridKey), findsOneWidget);
        expect(find.text('Practice uncertainty'), findsOneWidget);
        expect(find.text('Continue planned practice'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('final Dashboard V3 content remains reachable at 360 px', (
    tester,
  ) async {
    await _useSurface(tester, const Size(360, 800));
    await tester.pumpWidget(const TrueGroundApp());
    await tester.pumpAndSettle();

    final lastCard = find.text('Review patterns when useful');
    expect(lastCard, findsOneWidget);

    await tester.scrollUntilVisible(
      lastCard,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(lastCard.hitTestable(), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('primary loop CTA opens the bounded Loop flow', (tester) async {
    await _useSurface(tester, const Size(390, 844));
    await tester.pumpWidget(const TrueGroundApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text("I'm stuck in a loop"));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('screen-loop')), findsOneWidget);
    expect(find.text('Choose the closest fit.'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Send'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Dashboard V3 critical hierarchy survives 200% text scaling', (
    tester,
  ) async {
    await _useSurface(tester, const Size(360, 800));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(const TrueGroundApp());
    await tester.pumpAndSettle();

    expect(find.byKey(DashboardV3Screen.screenKey), findsOneWidget);
    expect(find.text('Choose your next move.'), findsOneWidget);
    expect(find.text('Practice uncertainty'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
