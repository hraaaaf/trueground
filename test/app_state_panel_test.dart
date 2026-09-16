import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trueground/design/app_theme.dart';
import 'package:trueground/states/app_state_panel.dart';

Widget _gallery({VoidCallback? onRetry}) {
  return MaterialApp(
    theme: TrueGroundTheme.light,
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TrueGroundSpacing.md),
        child: Column(
          children: <Widget>[
            const AppStatePanel(kind: AppStateKind.loading),
            const SizedBox(height: TrueGroundSpacing.md),
            const AppStatePanel(kind: AppStateKind.empty),
            const SizedBox(height: TrueGroundSpacing.md),
            AppStatePanel(kind: AppStateKind.error, onRetry: onRetry),
          ],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('loading empty and error conventions are explicit', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var retryPressed = false;
    await tester.pumpWidget(_gallery(onRetry: () => retryPressed = true));
    await tester.pump();

    expect(find.text('Loading'), findsOneWidget);
    expect(find.text('Nothing here yet'), findsOneWidget);
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(retryPressed, isTrue);
    expect(tester.takeException(), isNull);
  });
}
