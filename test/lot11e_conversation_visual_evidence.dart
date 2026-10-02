import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trueground/app/trueground_app.dart';
import 'package:trueground/conversation/conversation_runtime.dart';
import 'package:trueground/design/app_theme.dart';
import 'package:trueground/localization/trueground_locale.dart';
import 'package:trueground/conversation/conversation_screen.dart';
import 'package:trueground/shell/app_shell.dart';

class _VisualAdapter implements ConversationProviderAdapter {
  const _VisualAdapter({
    this.message =
        'We can leave the question unresolved and choose one small next step.',
    this.language = 'en',
  });

  final String message;
  final String language;

  @override
  Future<ConversationProviderInvocation> generate(
    ConversationProviderRequest request,
  ) async {
    return ConversationProviderInvocation(
      payload: <String, Object?>{
        'schema_version': conversationRuntimeSchemaVersion,
        'message': message,
        'language': language,
        'mode': 'support',
      },
    );
  }
}

class _PendingAdapter implements ConversationProviderAdapter {
  final Completer<ConversationProviderInvocation> completer =
      Completer<ConversationProviderInvocation>();

  @override
  Future<ConversationProviderInvocation> generate(
    ConversationProviderRequest request,
  ) {
    return completer.future;
  }
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

  final bytes = fontFile.readAsBytesSync();
  final loader = FontLoader('Roboto')
    ..addFont(Future.value(ByteData.sublistView(bytes)));
  await loader.load();

  final iconFile = File(
    '${_flutterRoot()}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (!iconFile.existsSync()) {
    throw StateError('Material Icons font not found at ${iconFile.path}');
  }

  final iconBytes = iconFile.readAsBytesSync();
  final iconLoader = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.sublistView(iconBytes)));
  await iconLoader.load();
}

Future<void> _capture(
  WidgetTester tester,
  GlobalKey boundaryKey,
  String filename,
) async {
  final boundary =
      boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = boundary.toImageSync(pixelRatio: 1);
  try {
    await tester.runAsync(() async {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) throw StateError('Unable to encode $filename');
      final file = File('build/lot11e/screenshots/$filename');
      file.parent.createSync(recursive: true);
      file.writeAsBytesSync(bytes.buffer.asUint8List(), flush: true);
    });
  } finally {
    image.dispose();
  }
}

Future<GlobalKey> _open(
  WidgetTester tester,
  Size size,
  ConversationProviderAdapter adapter,
) async {
  await tester.binding.setSurfaceSize(size);
  final boundaryKey = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: boundaryKey,
      child: TrueGroundApp(conversationProviderAdapter: adapter),
    ),
  );
  await tester.pumpAndSettle();

  final entry = find.text('Talk it through');
  await tester.ensureVisible(entry);
  await tester.tap(entry);
  await tester.pumpAndSettle();
  expect(find.byKey(ConversationScreen.screenKey), findsOneWidget);
  return boundaryKey;
}

Future<GlobalKey> _openPopup(
  WidgetTester tester,
  Size size,
  ConversationProviderAdapter adapter,
) async {
  await tester.binding.setSurfaceSize(size);
  final boundaryKey = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: boundaryKey,
      child: TrueGroundApp(conversationProviderAdapter: adapter),
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(AppShell.companionLauncherKey));
  await tester.pumpAndSettle();
  expect(find.byKey(AppShell.companionSheetKey), findsOneWidget);
  expect(find.byKey(ConversationScreen.compactComposerKey), findsOneWidget);
  return boundaryKey;
}


Future<GlobalKey> _openScaledConversation(
  WidgetTester tester,
  Size size,
  TrueGroundLanguage language,
  ConversationProviderAdapter adapter,
) async {
  await tester.binding.setSurfaceSize(size);
  final boundaryKey = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: boundaryKey,
      child: MaterialApp(
        theme: TrueGroundTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: TrueGroundLocaleScope(
          language: language,
          onLanguageChanged: (_) {},
          child: Scaffold(
            body: ConversationScreen(
              runtime: BoundedConversationRuntime(adapter: adapter),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.byKey(ConversationScreen.screenKey), findsOneWidget);
  expect(find.byKey(ConversationScreen.inputKey), findsOneWidget);
  return boundaryKey;
}

Future<void> _submit(WidgetTester tester, String message) async {
  await tester.enterText(find.byKey(ConversationScreen.inputKey), message);
  await tester.pump();
  final submit = find.byKey(ConversationScreen.submitKey);
  await tester.ensureVisible(submit);
  await tester.pumpAndSettle();
  await tester.tap(submit);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadRoboto);

  for (final size in <Size>[
    const Size(390, 844),
    const Size(430, 932),
    const Size(768, 1024),
  ]) {
    final width = size.width.toInt();

    testWidgets('LOT11-E polished popup at $width px', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final boundary = await _openPopup(tester, size, const _VisualAdapter());
      await _capture(tester, boundary, 'popup_${width}_idle.png');

      await _submit(tester, 'Help me choose one useful next step.');
      await tester.pumpAndSettle();
      expect(find.byKey(ConversationScreen.userBubbleKey), findsOneWidget);
      expect(find.byKey(ConversationScreen.generatedKey), findsOneWidget);
      expect(find.byKey(ConversationScreen.inputKey), findsOneWidget);
      await _capture(tester, boundary, 'popup_${width}_generated.png');

      await _submit(tester, 'And what could I do after that?');
      await tester.pumpAndSettle();
      expect(find.byKey(ConversationScreen.generatedKey), findsOneWidget);
      final field = tester.widget<TextField>(
        find.byKey(ConversationScreen.inputKey),
      );
      expect(field.enabled, isTrue);
      await _capture(tester, boundary, 'popup_${width}_second_turn.png');

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('LOT11-E popup keyboard inset at 390 px', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final boundary = await _openPopup(
      tester,
      const Size(390, 844),
      const _VisualAdapter(),
    );
    await tester.tap(find.byKey(ConversationScreen.inputKey));
    await tester.pump();
    tester.view.viewInsets = FakeViewPadding(
      bottom: 300 * tester.view.devicePixelRatio,
    );
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();

    final composerRect = tester.getRect(
      find.byKey(ConversationScreen.compactComposerKey),
    );
    expect(composerRect.bottom, lessThanOrEqualTo(544));
    await _capture(tester, boundary, 'popup_390_keyboard.png');
    expect(tester.takeException(), isNull);
  });

  for (final size in <Size>[
    const Size(360, 800),
    const Size(390, 844),
    const Size(430, 932),
    const Size(768, 1024),
    const Size(1280, 900),
  ]) {
    final width = size.width.toInt();

    testWidgets('LOT11-E visual states at $width px', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));

      var boundary = await _open(tester, size, const _VisualAdapter());
      await _capture(tester, boundary, 'conversation_${width}_idle_en.png');

      final pending = _PendingAdapter();
      boundary = await _open(tester, size, pending);
      await _submit(tester, 'Help me choose one useful next step.');
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byKey(ConversationScreen.loadingKey), findsOneWidget);
      await _capture(tester, boundary, 'conversation_${width}_loading.png');
      pending.completer.complete(
        const ConversationProviderInvocation(
          payload: <String, Object?>{
            'schema_version': conversationRuntimeSchemaVersion,
            'message':
                'We can leave the question unresolved and choose one small next step.',
            'language': 'en',
            'mode': 'support',
          },
        ),
      );
      await tester.pumpAndSettle();

      boundary = await _open(tester, size, const _VisualAdapter());
      await _submit(tester, 'Help me choose one useful next step.');
      await tester.pumpAndSettle();
      expect(find.byKey(ConversationScreen.generatedKey), findsOneWidget);
      await _capture(tester, boundary, 'conversation_${width}_generated.png');

      boundary = await _open(
        tester,
        size,
        const _VisualAdapter(message: 'I guarantee nothing bad will happen.'),
      );
      await _submit(tester, 'Help me choose one useful next step.');
      await tester.pumpAndSettle();
      expect(find.byKey(ConversationScreen.failClosedKey), findsOneWidget);
      await _capture(tester, boundary, 'conversation_${width}_fail_closed.png');

      boundary = await _open(tester, size, const _VisualAdapter());
      await _submit(tester, 'Just answer yes or no: am I definitely safe?');
      await tester.pumpAndSettle();
      await _capture(tester, boundary, 'conversation_${width}_pivot_loop.png');

      boundary = await _open(
        tester,
        size,
        const _VisualAdapter(language: 'fr'),
      );
      await tester.tap(find.text('FR'));
      await tester.pumpAndSettle();
      expect(find.text('Compagnon encadré'), findsOneWidget);
      await _capture(tester, boundary, 'conversation_${width}_idle_fr.png');

      expect(tester.takeException(), isNull);
    });
  }
  for (final entry in <(Size, TrueGroundLanguage, String)>[
    (const Size(360, 800), TrueGroundLanguage.en, 'en'),
    (const Size(430, 932), TrueGroundLanguage.fr, 'fr'),
  ]) {
    final size = entry.$1;
    final language = entry.$2;
    final languageCode = entry.$3;
    final width = size.width.toInt();

    testWidgets(
      'LOT11-G 200 percent text evidence at $width px $languageCode',
      (tester) async {
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final boundary = await _openScaledConversation(
          tester,
          size,
          language,
          const _VisualAdapter(),
        );
        await _capture(
          tester,
          boundary,
          'conversation_${width}_idle_${languageCode}_200pct.png',
        );

        expect(tester.takeException(), isNull);
      },
    );
  }


}
