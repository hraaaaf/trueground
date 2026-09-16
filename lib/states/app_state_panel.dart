import 'package:flutter/material.dart';

import '../design/app_theme.dart';

enum AppStateKind { loading, empty, error }

class AppStatePanel extends StatelessWidget {
  const AppStatePanel({
    required this.kind,
    this.onRetry,
    super.key,
  });

  final AppStateKind kind;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final config = switch (kind) {
      AppStateKind.loading => (
          TrueGroundIcons.loading,
          'Loading',
          'Getting this space ready.',
        ),
      AppStateKind.empty => (
          TrueGroundIcons.empty,
          'Nothing here yet',
          'This space is ready for content when the feature is implemented.',
        ),
      AppStateKind.error => (
          TrueGroundIcons.error,
          'Something went wrong',
          'Try again when you are ready.',
        ),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TrueGroundSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (kind == AppStateKind.loading)
              const Semantics(
                liveRegion: true,
                label: 'Loading',
                child: SizedBox.square(
                  dimension: 32,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              )
            else
              Icon(
                config.$1,
                size: 32,
                color: kind == AppStateKind.error
                    ? TrueGroundColors.error
                    : TrueGroundColors.primary,
              ),
            const SizedBox(height: TrueGroundSpacing.md),
            Text(
              config.$2,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: TrueGroundSpacing.sm),
            Text(
              config.$3,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (kind == AppStateKind.error && onRetry != null) ...<Widget>[
              const SizedBox(height: TrueGroundSpacing.md),
              FilledButton.tonal(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
