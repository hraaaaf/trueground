import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trueground/app/trueground_app.dart';
import 'package:trueground/support/support_screen.dart';
import 'package:trueground/values/values_screen.dart';

Future<void> _capture(
  WidgetTester tester,
  GlobalKey boundaryKey,
  String filename,
) async {
  await tester.pumpAndSettle();
  final boundary =
      boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = boundary.toImageSync(pixelRatio: 1);
  try {
    await tester.runAsync(() async {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) {
        throw StateError('Unable to encode visual evidence: $filename');
      }

      final file = File('build/lot08/screenshots/$filename');
      file.parent.createSync(recursive: true);
      file.writeAsBytesSync(bytes.buffer.asUint8List(), flush: true);
    });
  } finally {
    image.dispose();
  }
}

void main() {
  for (final size in <Size>[const Size(360, 800), const Size(390, 844)]) {
    testWidgets('capture LOT08 states at ${size.width.toInt()} px', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(key: boundaryKey, child: const TrueGroundApp()),
      );
      await tester.pumpAndSettle();

      final width = size.width.toInt();

      await tester.tap(find.text('Return to what matters'));
      await tester.pumpAndSettle();
      expect(find.byKey(ValuesScreen.chooseAreaKey), findsOneWidget);
      await _capture(tester, boundaryKey, 'values_${width}_choose_widget.png');

      final family = find.text('Family');
      await tester.scrollUntilVisible(
        family,
        120,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(family);
      await tester.pumpAndSettle();
      expect(find.byKey(ValuesScreen.chooseActionKey), findsOneWidget);
      await _capture(tester, boundaryKey, 'values_${width}_action_widget.png');

      await tester.tap(find.text('Support').first);
      await tester.pumpAndSettle();
      expect(find.byKey(SupportScreen.menuKey), findsOneWidget);
      await _capture(tester, boundaryKey, 'support_${width}_menu_widget.png');

      await tester.tap(find.text('Someone I trust'));
      await tester.pumpAndSettle();
      expect(find.byKey(SupportScreen.trustedPersonKey), findsOneWidget);
      await _capture(
        tester,
        boundaryKey,
        'support_${width}_trusted_widget.png',
      );

      expect(tester.takeException(), isNull);
    });
  }
}
