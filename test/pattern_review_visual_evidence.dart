import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trueground/patterns/pattern_memory_store.dart';
import 'package:trueground/patterns/pattern_review_screen.dart';

class _VisualPatternMemoryStore implements PatternMemoryStore {
  _VisualPatternMemoryStore(this.records);

  final List<PatternRecord> records;

  @override
  Future<void> append(PatternEventKind kind, {required DateTime occurredAt}) async {}

  @override
  Future<void> deleteAll() async => records.clear();

  @override
  Future<void> deleteKind(PatternEventKind kind) async {
    records.removeWhere((record) => record.kind == kind);
  }

  @override
  Future<List<PatternRecord>> readRecords({required DateTime now}) async =>
      List<PatternRecord>.unmodifiable(records);
}

String _flutterRoot() {
  final configured = Platform.environment['FLUTTER_ROOT'];
  if (configured != null && configured.isNotEmpty) return configured;
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
  final loader = FontLoader('Roboto')
    ..addFont(Future.value(ByteData.sublistView(fontFile.readAsBytesSync())));
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
      if (bytes == null) throw StateError('Unable to encode $filename');
      final file = File('build/lot09/screenshots/$filename');
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
  required String suffix,
  required List<PatternRecord> records,
  double textScaleFactor = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  tester.platformDispatcher.textScaleFactorTestValue = textScaleFactor;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  final boundaryKey = GlobalKey();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: RepaintBoundary(
          key: boundaryKey,
          child: PatternReviewScreen(
            memoryStore: _VisualPatternMemoryStore(records),
            now: () => DateTime.utc(2026, 9, 22, 12),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  await _capture(
    tester,
    boundaryKey,
    'pattern_${size.width.toInt()}_$suffix.png',
  );
  expect(tester.takeException(), isNull);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadRoboto);

  for (final size in <Size>[const Size(360, 800), const Size(390, 844)]) {
    testWidgets('capture loaded LOT09 state at ${size.width.toInt()} px', (
      tester,
    ) async {
      await _scenario(
        tester,
        size,
        suffix: 'loaded_widget',
        records: <PatternRecord>[
          PatternRecord(
            kind: PatternEventKind.pausePractice,
            occurredAt: DateTime.utc(2026, 9, 20),
          ),
          PatternRecord(
            kind: PatternEventKind.valuesStep,
            occurredAt: DateTime.utc(2026, 9, 21),
          ),
        ],
      );
    });

    testWidgets('capture empty LOT09 state at ${size.width.toInt()} px', (
      tester,
    ) async {
      await _scenario(
        tester,
        size,
        suffix: 'empty_widget',
        records: <PatternRecord>[],
      );
    });

    testWidgets('capture LOT09 loaded state at 200% text and '
        '${size.width.toInt()} px', (tester) async {
      await _scenario(
        tester,
        size,
        suffix: 'loaded_text200_widget',
        textScaleFactor: 2,
        records: <PatternRecord>[
          PatternRecord(
            kind: PatternEventKind.uncertaintyPractice,
            occurredAt: DateTime.utc(2026, 9, 21),
          ),
        ],
      );
    });
  }
}
