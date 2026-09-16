import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trueground/design/app_theme.dart';
import 'package:trueground/states/app_state_panel.dart';

const _captureKey = ValueKey('state-gallery-capture');

Widget _gallery({VoidCallback? onRetry}) {
  return MaterialApp(
    theme: TrueGroundTheme.light,
    home: Scaffold(
      body: RepaintBoundary(
        key: _captureKey,
        child: SingleChildScrollView(
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
    ),
  );
}

Future<void> _captureStates(WidgetTester tester) async {
  final boundary = tester.firstRenderObject<RenderRepaintBoundary>(
    find.byKey(_captureKey),
  );
  final image = await boundary.toImage(pixelRatio: 1);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  final directory = Directory('build/lot03/screenshots');
  await directory.create(recursive: true);
  await File('${directory.path}/states_390.png').writeAsBytes(
    data!.buffer.asUint8List(),
  );
}

void main() {
  testWidgets('loading empty and error conventions are explicit', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var retryPressed = false;
    await tester.pumpWidget(_gallery(onRetry: () => retryPressed = true));
    await tester.pumpAndSettle();

    expect(find.text('Loading'), findsOneWidget);
    expect(find.text('Nothing here yet'), findsOneWidget);
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(retryPressed, isTrue);
    expect(tester.takeException(), isNull);

    await _captureStates(tester);
  });
}
