import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design/app_theme.dart';
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
  late final GoRouter _router = createTrueGroundRouter(
    practiceCompletionStore: widget.practiceCompletionStore,
    practiceNow: widget.practiceNow,
    patternMemoryStore: widget.patternMemoryStore,
    patternNow: widget.patternNow,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TrueGround',
      debugShowCheckedModeBanner: false,
      theme: TrueGroundTheme.light,
      routerConfig: _router,
    );
  }
}
