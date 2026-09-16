import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trueground/app/trueground_app.dart';
import 'package:trueground/shell/app_shell.dart';

Future<void> _useSurface(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

void main() {
  testWidgets('canonical navigation changes shell destinations', (
    tester,
  ) async {
    await _useSurface(tester, const Size(390, 844));
    await tester.pumpWidget(const TrueGroundApp());
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Loop'), findsOneWidget);
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('Support'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    await tester.tap(find.text('Loop'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('screen-loop')), findsOneWidget);

    await tester.tap(find.text('Practice').first);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('screen-practice')), findsOneWidget);

    await tester.tap(find.text('Support').first);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('screen-support')), findsOneWidget);

    await tester.tap(find.text('Profile').first);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('screen-profile')), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  for (final width in <double>[360, 390]) {
    testWidgets('shell renders without overflow at ${width.toInt()} px', (
      tester,
    ) async {
      await _useSurface(tester, Size(width, 800));
      await tester.pumpWidget(const TrueGroundApp());
      await tester.pumpAndSettle();

      expect(find.byKey(AppShell.captureKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('critical navigation survives 200% text scaling', (tester) async {
    await _useSurface(tester, const Size(360, 800));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(const TrueGroundApp());
    await tester.pumpAndSettle();

    expect(find.byKey(AppShell.captureKey), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
