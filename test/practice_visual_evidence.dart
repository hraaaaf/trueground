import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trueground/app/trueground_app.dart';
import 'package:trueground/practice/practice_completion_store.dart';
import 'package:trueground/practice/practice_screen.dart';

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

      final file = File('build/lot07/screenshots/$filename');
      file.parent.createSync(recursive: true);
      file.writeAsBytesSync(bytes.buffer.asUint8List(), flush: true);
    });
  } finally {
    image.dispose();
  }
}

Future<void> _jumpToTop(WidgetTester tester) async {
  final scrollable = tester.state<ScrollableState>(
    find.byType(Scrollable).first,
  );
  scrollable.position.jumpTo(0);
  await tester.pumpAndSettle();
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

class _EmptyPracticeCompletionStore implements PracticeCompletionStore {
  @override
  Future<DateTime?> readPauseCompletedAt() async => null;

  @override
  Future<DateTime?> readUncertaintyCompletedAt() async => null;

  @override
  Future<void> writePauseCompletedAt(DateTime completedAt) async {}

  @override
  Future<void> writeUncertaintyCompletedAt(DateTime completedAt) async {}
}

void main() {
  for (final size in <Size>[const Size(360, 800), const Size(390, 844)]) {
    testWidgets('capture Practice states at ${size.width.toInt()} px', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: TrueGroundApp(
            practiceCompletionStore: _EmptyPracticeCompletionStore(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Practice').first);
      await tester.pumpAndSettle();

      final width = size.width.toInt();

      expect(find.byKey(PracticeScreen.menuKey), findsOneWidget);
      await _capture(tester, boundaryKey, 'practice_${width}_menu_widget.png');

      await tester.tap(find.byKey(const ValueKey('practice-choice-pause')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start a brief pause'));
      await tester.pumpAndSettle();
      await _jumpToTop(tester);

      expect(find.byKey(PracticeScreen.pauseMomentKey), findsOneWidget);
      await _capture(tester, boundaryKey, 'practice_${width}_pause_widget.png');

      await _tapScrollable(tester, find.text('Exit practice'));
      await _tapScrollable(
        tester,
        find.byKey(const ValueKey('practice-choice-uncertainty')),
      );
      await tester.tap(find.text('Begin'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await _jumpToTop(tester);

      expect(find.byKey(PracticeScreen.uncertaintyChooseKey), findsOneWidget);
      await _capture(
        tester,
        boundaryKey,
        'practice_${width}_uncertainty_widget.png',
      );

      await _tapScrollable(tester, find.text('Exit practice'));
      final planned = find.byKey(const ValueKey('practice-choice-planned'));
      await tester.scrollUntilVisible(
        planned,
        140,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(planned);
      await tester.pumpAndSettle();
      await _jumpToTop(tester);

      expect(find.byKey(PracticeScreen.plannedEmptyKey), findsOneWidget);
      await _capture(
        tester,
        boundaryKey,
        'practice_${width}_planned_empty_widget.png',
      );

      expect(tester.takeException(), isNull);
    });
  }
}
