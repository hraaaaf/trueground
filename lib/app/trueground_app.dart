import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../design/app_theme.dart';
import '../localization/trueground_locale.dart';
import '../patterns/pattern_memory_store.dart';
import '../practice/practice_completion_store.dart';
import 'router.dart';

class TrueGroundApp extends StatefulWidget {
  const TrueGroundApp({
    super.key,
    this.practiceCompletionStore,
    this.practiceNow,
    this.patternMemoryStore,
    this.patternNow,
  });

  final PracticeCompletionStore? practiceCompletionStore;
  final DateTime Function()? practiceNow;
  final PatternMemoryStore? patternMemoryStore;
  final DateTime Function()? patternNow;

  @override
  State<TrueGroundApp> createState() => _TrueGroundAppState();
}

class _TrueGroundAppState extends State<TrueGroundApp> {
  static const String _languageKey = 'trueground.language.v1';

  late final GoRouter _router = createTrueGroundRouter(
    practiceCompletionStore: widget.practiceCompletionStore,
    practiceNow: widget.practiceNow,
    patternMemoryStore: widget.patternMemoryStore,
    patternNow: widget.patternNow,
  );

  SharedPreferencesAsync? _preferences;
  TrueGroundLanguage _language = TrueGroundLanguage.en;

  @override
  void initState() {
    super.initState();
    unawaited(_loadLanguage());
  }

  Future<void> _loadLanguage() async {
    try {
      final preferences = _preferences ??= SharedPreferencesAsync();
      final saved = await preferences.getString(_languageKey);
      if (!mounted) return;
      setState(() {
        _language = TrueGroundLanguageCode.fromCode(saved);
      });
    } catch (_) {
      // English remains the deterministic fallback when local preferences fail.
    }
  }

  void _setLanguage(TrueGroundLanguage language) {
    if (_language == language) return;
    setState(() {
      _language = language;
    });
    unawaited(_persistLanguage(language));
  }

  Future<void> _persistLanguage(TrueGroundLanguage language) async {
    try {
      final preferences = _preferences ??= SharedPreferencesAsync();
      await preferences.setString(_languageKey, language.code);
    } catch (_) {
      // The selected language remains active for the current session.
    }
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TrueGroundLocaleScope(
      language: _language,
      onLanguageChanged: _setLanguage,
      child: MaterialApp.router(
        title: 'TrueGround',
        debugShowCheckedModeBanner: false,
        theme: TrueGroundTheme.light,
        routerConfig: _router,
      ),
    );
  }
}
