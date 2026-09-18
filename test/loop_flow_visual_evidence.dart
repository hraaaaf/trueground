import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trueground/app/trueground_app.dart';
import 'package:trueground/loop/loop_flow_screen.dart';

Future<void> _capture(
  WidgetTester tester,
  GlobalKey boundaryKey,
  String filename,
) async {
  await tester.pumpAndSettle();
  final boundary =
      boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 1);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  if (bytes == null) {
    throw StateError('Unable to encode visual evidence: $filename');
  }

  final file = File('build/lot05/screenshots/$filename');
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
  image.dispose();
}

Future<void> _jumpToTop(WidgetTester tester) async {
  final scrollable = tester.state<ScrollableState>(
    find.byType(Scrollable).first,
  );
  scrollable.position.jumpTo(0);
  await tester.pumpAndSettle();
}

void main() {
  for (final size in <Size>[const Size(360, 800), const Size(390, 844)]) {
    testWidgets(
      'capture Loop pattern, action, and complete evidence at ${size.width.toInt()} px',
      (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final boundaryKey = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(key: boundaryKey, child: const TrueGroundApp()),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Loop'));
        await tester.pumpAndSettle();

        final width = size.width.toInt();
        expect(find.byKey(LoopFlowScreen.patternStepKey), findsOneWidget);
        await _capture(tester, boundaryKey, 'loop_${width}_pattern_widget.png');

        final certainty = find.byKey(const ValueKey('loop-pattern-certainty'));
        await tester.scrollUntilVisible(
          certainty,
          120,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(certainty);
        await tester.pumpAndSettle();
        await _jumpToTop(tester);

        expect(find.byKey(LoopFlowScreen.actionStepKey), findsOneWidget);
        await _capture(tester, boundaryKey, 'loop_${width}_action_widget.png');

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
        await _jumpToTop(tester);

        expect(find.byKey(LoopFlowScreen.completeStepKey), findsOneWidget);
        await _capture(
          tester,
          boundaryKey,
          'loop_${width}_complete_widget.png',
        );

        expect(tester.takeException(), isNull);
      },
    );
  }
}
