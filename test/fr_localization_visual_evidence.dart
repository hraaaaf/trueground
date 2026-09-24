import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trueground/dashboard/dashboard_v3_screen.dart';
import 'package:trueground/design/app_theme.dart';
import 'package:trueground/localization/trueground_locale.dart';
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
        throw StateError('Unable to encode FR visual evidence: $filename');
      }
      final file = File('build/fr/screenshots/$filename');
      file.parent.createSync(recursive: true);
      file.writeAsBytesSync(bytes.buffer.asUint8List(), flush: true);
    });
  } finally {
    image.dispose();
  }
}

Future<void> _pumpFrench(
  WidgetTester tester,
  Widget child,
  Size size, {
  required double textScale,
  required String filename,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  final boundaryKey = GlobalKey();

  await tester.pumpWidget(
    TrueGroundLocaleScope(
      language: TrueGroundLanguage.fr,
      onLanguageChanged: (_) {},
      child: RepaintBoundary(
        key: boundaryKey,
        child: MaterialApp(
          theme: TrueGroundTheme.light,
          home: child,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);

  await _capture(tester, boundaryKey, filename);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadRoboto);

  for (final size in <Size>[const Size(360, 800), const Size(390, 844)]) {
    for (final scale in <double>[1, 2]) {
      final suffix = scale == 1 ? 'widget' : 'text200_widget';

      testWidgets(
        'FR dashboard visual ${size.width.toInt()} px scale $scale',
        (tester) async {
          await _pumpFrench(
            tester,
            const DashboardV3Screen(),
            size,
            textScale: scale,
            filename:
                'fr_dashboard_${size.width.toInt()}_$suffix.png',
          );

          expect(
            find.text('Choisissez votre prochaine action.'),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'FR urgent support visual ${size.width.toInt()} px scale $scale',
        (tester) async {
          await _pumpFrench(
            tester,
            const UrgentSupportScreen(),
            size,
            textScale: scale,
            filename:
                'fr_urgent_support_${size.width.toInt()}_$suffix.png',
          );

          expect(
            find.text('Faites appel à une aide urgente dans la vie réelle'),
            findsOneWidget,
          );
        },
      );
    }
  }
}
