import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trueground/app/trueground_app.dart';
import 'package:trueground/support/support_screen.dart';
import 'package:trueground/values/values_screen.dart';

Future<void> _useSurface(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Future<void> _tapScrollable(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    140,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Return to what matters is user-led and bounded', (tester) async {
    await _useSurface(tester, const Size(390, 844));
    await tester.pumpWidget(const TrueGroundApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Return to what matters'));
    await tester.pumpAndSettle();

    expect(find.byKey(ValuesScreen.screenKey), findsOneWidget);
    expect(find.byKey(ValuesScreen.chooseAreaKey), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.text('Family'), findsOneWidget);
    expect(find.text('Faith or meaning'), findsOneWidget);
    expect(find.text('Something else that matters'), findsOneWidget);

    await tester.tap(find.text('Family'));
    await tester.pumpAndSettle();

    expect(find.byKey(ValuesScreen.chooseActionKey), findsOneWidget);
    expect(find.text('Take my next step'), findsOneWidget);
    expect(find.text('Leave for now'), findsOneWidget);
    expect(find.text('I tapped the wrong area'), findsOneWidget);
    expect(find.text('I know my next step'), findsNothing);
    expect(find.textContaining('certain or perfect'), findsOneWidget);

    await _tapScrollable(tester, find.text('Take my next step'));

    expect(find.byKey(ValuesScreen.leaveFlowKey), findsOneWidget);
    expect(find.text('Family'), findsOneWidget);
    expect(
      find.textContaining('Uncertainty does not have to be settled first'),
      findsOneWidget,
    );
    expect(find.textContaining('feel better'), findsNothing);
    expect(find.textContaining('calm down'), findsNothing);
    expect(find.textContaining('clinically proven'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reselection is a one-pass correction without scoring feedback', (
    tester,
  ) async {
    await _useSurface(tester, const Size(390, 844));
    await tester.pumpWidget(const TrueGroundApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Return to what matters'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Family'));
    await tester.pumpAndSettle();
    expect(find.text('I tapped the wrong area'), findsOneWidget);
    expect(find.textContaining('better choice'), findsNothing);
    expect(find.textContaining('right choice'), findsNothing);
    expect(find.textContaining('attempt'), findsNothing);

    await _tapScrollable(tester, find.text('I tapped the wrong area'));
    expect(find.byKey(ValuesScreen.chooseAreaKey), findsOneWidget);

    await tester.tap(find.text('Family'));
    await tester.pumpAndSettle();
    expect(find.text('Take my next step'), findsOneWidget);
    expect(find.text('Leave for now'), findsOneWidget);
    expect(find.text('I tapped the wrong area'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('values flow has a neutral exit without certainty declaration', (
    tester,
  ) async {
    await _useSurface(tester, const Size(390, 844));
    await tester.pumpWidget(const TrueGroundApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Return to what matters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Family'));
    await tester.pumpAndSettle();
    await _tapScrollable(tester, find.text('Leave for now'));
    expect(find.byKey(ValuesScreen.screenKey), findsNothing);
    expect(find.text('Return to what matters'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('human support route is truthful and does not fake contact', (
    tester,
  ) async {
    await _useSurface(tester, const Size(390, 844));
    await tester.pumpWidget(const TrueGroundApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Need a person, not an answer?'));
    await tester.pumpAndSettle();

    expect(find.byKey(SupportScreen.screenKey), findsOneWidget);
    expect(find.byKey(SupportScreen.menuKey), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Someone I trust'), findsOneWidget);
    expect(find.text('My therapist or care team'), findsOneWidget);
    expect(
      find.text('Find professional support outside TrueGround'),
      findsOneWidget,
    );

    await tester.tap(find.text('Someone I trust'));
    await tester.pumpAndSettle();

    expect(find.byKey(SupportScreen.trustedPersonKey), findsOneWidget);
    expect(find.textContaining('has not contacted them'), findsOneWidget);
    expect(find.textContaining('repeated certainty'), findsOneWidget);
    expect(find.textContaining('contacted successfully'), findsNothing);

    await _tapScrollable(tester, find.text('Back to support choices'));
    await _tapScrollable(tester, find.text('My therapist or care team'));

    expect(find.byKey(SupportScreen.careTeamKey), findsOneWidget);
    expect(find.textContaining('does not store a therapist'), findsOneWidget);
    expect(find.textContaining('has not contacted anyone'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unvalidated regional resources are not fabricated', (
    tester,
  ) async {
    await _useSurface(tester, const Size(390, 844));
    await tester.pumpWidget(const TrueGroundApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Support').first);
    await tester.pumpAndSettle();
    await _tapScrollable(
      tester,
      find.text('Find professional support outside TrueGround'),
    );

    expect(find.byKey(SupportScreen.localProfessionalKey), findsOneWidget);
    expect(
      find.textContaining('does not currently provide a local directory'),
      findsOneWidget,
    );
    expect(
      find.textContaining('you can verify outside the app'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  for (final size in <Size>[const Size(360, 800), const Size(390, 844)]) {
    testWidgets('LOT08 routes render without framework exceptions at '
        '${size.width.toInt()} px', (tester) async {
      await _useSurface(tester, size);
      await tester.pumpWidget(const TrueGroundApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Return to what matters'));
      await tester.pumpAndSettle();
      expect(find.byKey(ValuesScreen.screenKey), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Support').first);
      await tester.pumpAndSettle();
      expect(find.byKey(SupportScreen.screenKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final size in <Size>[const Size(360, 800), const Size(390, 844)]) {
    testWidgets('LOT08 critical routes survive 200% text scaling at '
        '${size.width.toInt()} px', (tester) async {
      await _useSurface(tester, size);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(const TrueGroundApp());
      await tester.pumpAndSettle();

      final valuesCard = find.text('Return to what matters');
      await tester.scrollUntilVisible(
        valuesCard,
        140,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(valuesCard);
      await tester.pumpAndSettle();
      expect(find.byKey(ValuesScreen.screenKey), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _tapScrollable(tester, find.text('Family'));
      expect(find.byKey(ValuesScreen.chooseActionKey), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Support').first);
      await tester.pumpAndSettle();
      expect(find.byKey(SupportScreen.screenKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
