import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trueground/app/router.dart';
import 'package:trueground/design/app_theme.dart';
import 'package:trueground/safety/urgent_support_screen.dart';

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
      final file = File('build/lot10/screenshots/$filename');
      file.parent.createSync(recursive: true);
      file.writeAsBytesSync(bytes.buffer.asUint8List(), flush: true);
    });
  } finally {
    image.dispose();
  }
}

Future<void> _scenario(
  WidgetTester tester,
  Size size, {
  required double textScale,
  required String suffix,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  final router = createTrueGroundRouter()..go('/urgent-support');
  addTearDown(router.dispose);
  final boundaryKey = GlobalKey();

  await tester.pumpWidget(
    RepaintBoundary(
      key: boundaryKey,
      child: MaterialApp.router(
        theme: TrueGroundTheme.light,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();

  expect(find.byKey(UrgentSupportScreen.screenKey), findsOneWidget);
  expect(find.text('Use urgent real-world help'), findsOneWidget);
  expect(tester.takeException(), isNull);

  await _capture(
    tester,
    boundaryKey,
    'urgent_support_${size.width.toInt()}_$suffix.png',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadRoboto);

  for (final size in <Size>[const Size(360, 800), const Size(390, 844)]) {
    testWidgets('LOT10 urgent support visual ${size.width.toInt()} px', (
      tester,
    ) async {
      await _scenario(tester, size, textScale: 1, suffix: 'widget');
    });

    testWidgets(
      'LOT10 urgent support visual 200% text ${size.width.toInt()} px',
      (tester) async {
        await _scenario(
          tester,
          size,
          textScale: 2,
          suffix: 'text200_widget',
        );
      },
    );
  }
}
