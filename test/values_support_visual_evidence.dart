import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trueground/app/trueground_app.dart';
import 'package:trueground/support/support_screen.dart';
import 'package:trueground/values/values_screen.dart';

String _flutterRoot() {
  final configured = Platform.environment['FLUTTER_ROOT'];
  if (configured != null && configured.isNotEmpty) {
    return configured;
  }

  var directory = File(Platform.resolvedExecutable).parent;
  for (var index = 0; index < 4; index += 1) {
    directory = directory.parent;
  }
  return directory.path;
}

Future<void> _loadRoboto() async {
  final fontFile = File(
    '${_flutterRoot()}/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf',
  );
  if (!fontFile.existsSync()) {
    throw StateError('Roboto font not found at ${fontFile.path}');
  }

  final bytes = fontFile.readAsBytesSync();
  final loader = FontLoader('Roboto')
    ..addFont(Future.value(ByteData.sublistView(bytes)));
  await loader.load();
}

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

Future<void> _tapScrollable(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    120,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _captureScenario(
  WidgetTester tester,
  Size size, {
  required String suffix,
  double textScaleFactor = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  tester.platformDispatcher.textScaleFactorTestValue = textScaleFactor;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  final boundaryKey = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(key: boundaryKey, child: const TrueGroundApp()),
  );
  await tester.pumpAndSettle();

  final width = size.width.toInt();

  await tester.tap(find.text('Return to what matters'));
  await tester.pumpAndSettle();
  expect(find.byKey(ValuesScreen.chooseAreaKey), findsOneWidget);
  await _capture(tester, boundaryKey, 'values_${width}_choose_$suffix.png');

  await _tapScrollable(tester, find.text('Family'));
  expect(find.byKey(ValuesScreen.chooseActionKey), findsOneWidget);
  await _capture(tester, boundaryKey, 'values_${width}_action_$suffix.png');

  await _tapScrollable(tester, find.text('Take my next step'));
  expect(find.byKey(ValuesScreen.leaveFlowKey), findsOneWidget);
  await _capture(tester, boundaryKey, 'values_${width}_terminal_$suffix.png');

  await tester.tap(find.text('Support').first);
  await tester.pumpAndSettle();
  expect(find.byKey(SupportScreen.menuKey), findsOneWidget);
  await _capture(tester, boundaryKey, 'support_${width}_menu_$suffix.png');

  await _tapScrollable(tester, find.text('Someone I trust'));
  expect(find.byKey(SupportScreen.trustedPersonKey), findsOneWidget);
  await _capture(tester, boundaryKey, 'support_${width}_trusted_$suffix.png');

  await _tapScrollable(tester, find.text('Back to support choices'));
  await _tapScrollable(tester, find.text('My therapist or care team'));
  expect(find.byKey(SupportScreen.careTeamKey), findsOneWidget);
  await _capture(tester, boundaryKey, 'support_${width}_care_$suffix.png');

  await _tapScrollable(tester, find.text('Back to support choices'));
  await _tapScrollable(
    tester,
    find.text('Find professional support outside TrueGround'),
  );
  expect(find.byKey(SupportScreen.localProfessionalKey), findsOneWidget);
  await _capture(tester, boundaryKey, 'support_${width}_local_$suffix.png');

  expect(tester.takeException(), isNull);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(_loadRoboto);

  for (final size in <Size>[const Size(360, 800), const Size(390, 844)]) {
    testWidgets('capture readable LOT08 states at ${size.width.toInt()} px', (
      tester,
    ) async {
      await _captureScenario(tester, size, suffix: 'widget');
    });

    testWidgets('capture readable LOT08 states at 200% text scaling and '
        '${size.width.toInt()} px', (tester) async {
      await _captureScenario(
        tester,
        size,
        suffix: 'text200_widget',
        textScaleFactor: 2,
      );
    });
  }
}
