import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design/app_theme.dart';
import '../localization/trueground_locale.dart';
import 'pattern_memory_store.dart';

class PatternReviewScreen extends StatefulWidget {
  const PatternReviewScreen({super.key, this.memoryStore, this.now});

  final PatternMemoryStore? memoryStore;
  final DateTime Function()? now;

  static const screenKey = ValueKey('screen-pattern-review');
  static const loadedKey = ValueKey('pattern-review-loaded');
  static const emptyKey = ValueKey('pattern-review-empty');
  static const unavailableKey = ValueKey('pattern-review-unavailable');

  @override
  State<PatternReviewScreen> createState() => _PatternReviewScreenState();
}

class _PatternReviewScreenState extends State<PatternReviewScreen> {
  late final PatternMemoryStore _memoryStore =
      widget.memoryStore ?? SharedPreferencesPatternMemoryStore();

  bool _loading = true;
  bool _unavailable = false;
  List<PatternRecord> _records = const <PatternRecord>[];

  DateTime _now() => (widget.now ?? DateTime.now)().toUtc();

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final records = await _memoryStore.readRecords(now: _now());
      if (!mounted) return;
      setState(() {
        _records = records;
        _loading = false;
        _unavailable = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _records = const <PatternRecord>[];
        _loading = false;
        _unavailable = true;
      });
    }
  }

  List<PatternEventKind> get _kinds {
    final seen = <PatternEventKind>{};
    final ordered = <PatternEventKind>[];
    for (final record in _records.reversed) {
      if (seen.add(record.kind)) {
        ordered.add(record.kind);
      }
    }
    return ordered.take(3).toList(growable: false);
  }

  Future<void> _deleteKind(PatternEventKind kind) async {
    try {
      await _memoryStore.deleteKind(kind);
      await _load();
    } catch (_) {
      if (!mounted) return;
      setState(() => _unavailable = true);
    }
  }

  Future<void> _deleteAll() async {
    try {
      await _memoryStore.deleteAll();
      await _load();
    } catch (_) {
      if (!mounted) return;
      setState(() => _unavailable = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: PatternReviewScreen.screenKey,
      padding: const EdgeInsets.all(TrueGroundSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'TrueGround',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: TrueGroundColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: TrueGroundSpacing.lg),
              Semantics(
                header: true,
                child: Text(
                  context.tr('Review patterns when useful'),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: TrueGroundSpacing.sm),
              Text(
                context.tr(
                  'This is a brief look at saved activity on this device. It is not a diagnosis, severity score, progress grade or prediction.',
                ),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: TrueGroundSpacing.md),
              Card(
                color: TrueGroundColors.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(TrueGroundSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(
                        Icons.lock_outline_rounded,
                        color: TrueGroundColors.primary,
                      ),
                      const SizedBox(width: TrueGroundSpacing.sm),
                      Expanded(
                        child: Text(
                          context.tr(
                            'TrueGround stores only structured activity types and timestamps for this review. No thought, fear, trigger or free-text content is saved here. Records expire after 30 days.',
                          ),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: TrueGroundSpacing.lg),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_unavailable)
                _Unavailable(onHome: () => context.go('/'))
              else if (_records.isEmpty)
                _Empty(onHome: () => context.go('/'))
              else
                _Loaded(
                  kinds: _kinds,
                  onDeleteKind: _deleteKind,
                  onDeleteAll: _deleteAll,
                  onHome: () => context.go('/'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({
    required this.kinds,
    required this.onDeleteKind,
    required this.onDeleteAll,
    required this.onHome,
  });

  final List<PatternEventKind> kinds;
  final Future<void> Function(PatternEventKind kind) onDeleteKind;
  final Future<void> Function() onDeleteAll;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: PatternReviewScreen.loadedKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          context.tr('Recent saved activity includes:'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: TrueGroundSpacing.sm),
        for (final kind in kinds) ...<Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: TrueGroundColors.surface,
              borderRadius: BorderRadius.circular(TrueGroundRadii.card),
              border: Border.all(color: TrueGroundColors.outline),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: TrueGroundColors.primary.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(TrueGroundSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: TrueGroundColors.iconWash,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.history_rounded,
                          size: 19,
                          color: TrueGroundColors.primary,
                        ),
                      ),
                      const SizedBox(width: TrueGroundSpacing.sm),
                      Expanded(
                        child: Text(
                          context.tr(kind.userLabel),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TrueGroundSpacing.xs),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      key: ValueKey('pattern-remove-${kind.storageValue}'),
                      onPressed: () => onDeleteKind(kind),
                      child: Text(context.tr('Remove this type')),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: TrueGroundSpacing.sm),
        ],
        Text(
          context.tr(
            'No frequency, streak, trend or better/worse conclusion is shown. You do not need to keep checking this screen.',
          ),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: TrueGroundSpacing.lg),
        FilledButton(onPressed: onHome, child: Text(context.tr('Finish review'))),
        const SizedBox(height: TrueGroundSpacing.sm),
        Container(
          padding: const EdgeInsets.only(top: TrueGroundSpacing.xs),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: TrueGroundColors.outline)),
          ),
          child: TextButton.icon(
            key: const ValueKey('pattern-delete-all'),
            onPressed: onDeleteAll,
            icon: const Icon(Icons.delete_outline_rounded, size: 19),
            label: Text(context.tr('Delete all saved activity')),
          ),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onHome});

  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: PatternReviewScreen.emptyKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          context.tr('No saved activity is available to review.'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: TrueGroundSpacing.sm),
        Text(
          context.tr('TrueGround will not infer a pattern from missing history.'),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: TrueGroundSpacing.lg),
        FilledButton(onPressed: onHome, child: Text(context.tr('Back to Home'))),
      ],
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.onHome});

  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: PatternReviewScreen.unavailableKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          context.tr('Saved activity could not be checked.'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: TrueGroundSpacing.sm),
        Text(
          context.tr('TrueGround will not guess what your history contains.'),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: TrueGroundSpacing.lg),
        FilledButton(onPressed: onHome, child: const Text('Back to Home')),
      ],
    );
  }
}
