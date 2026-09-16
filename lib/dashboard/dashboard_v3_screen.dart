import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design/app_theme.dart';

class DashboardV3Screen extends StatelessWidget {
  const DashboardV3Screen({super.key});

  static const screenKey = ValueKey('screen-home-dashboard-v3');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      key: screenKey,
      padding: const EdgeInsets.fromLTRB(
        TrueGroundSpacing.md,
        TrueGroundSpacing.md,
        TrueGroundSpacing.md,
        TrueGroundSpacing.xl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _BrandHeader(),
              const SizedBox(height: TrueGroundSpacing.lg),
              Text(
                'Welcome.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: TrueGroundColors.inkMuted,
                ),
              ),
              const SizedBox(height: TrueGroundSpacing.xs),
              Semantics(
                header: true,
                child: Text(
                  'Choose your next move.',
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: TrueGroundSpacing.sm),
              Text(
                'Make room for uncertainty. Choose what matters.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: TrueGroundColors.inkMuted,
                ),
              ),
              const SizedBox(height: TrueGroundSpacing.lg),
              _PrimaryActionCard(
                onTap: () => context.go('/loop'),
              ),
              const SizedBox(height: TrueGroundSpacing.md),
              _ActionCard(
                icon: Icons.pause_circle_outline_rounded,
                title: 'Pause the ritual',
                description: 'Create a little space before the next move.',
                onTap: () => context.go('/practice'),
              ),
              const SizedBox(height: TrueGroundSpacing.sm),
              _ActionCard(
                icon: Icons.waves_rounded,
                title: 'Practice uncertainty',
                description: 'Practice without needing a perfect answer.',
                onTap: () => context.go('/practice'),
              ),
              const SizedBox(height: TrueGroundSpacing.sm),
              _ActionCard(
                icon: Icons.play_circle_outline_rounded,
                title: 'Continue planned practice',
                description: 'Return to what you already chose to practice.',
                onTap: () => context.go('/practice'),
              ),
              const SizedBox(height: TrueGroundSpacing.md),
              const _StaticCard(
                icon: Icons.favorite_outline_rounded,
                title: 'Return to what matters',
                description: 'Shift attention toward the life you want to be in.',
              ),
              const SizedBox(height: TrueGroundSpacing.sm),
              _ActionCard(
                icon: Icons.people_outline_rounded,
                title: 'Need a person, not an answer?',
                description: 'Human support stays within reach.',
                onTap: () => context.go('/support'),
                quiet: true,
              ),
              const SizedBox(height: TrueGroundSpacing.md),
              const _PatternReviewCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      label: 'TrueGround. Less checking. More living.',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: TrueGroundColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.landscape_rounded,
              color: TrueGroundColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: TrueGroundSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'TrueGround',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: TrueGroundColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Less checking. More living.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionCard extends StatelessWidget {
  const _PrimaryActionCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: "I'm stuck in a loop. Notice the urge. Pause before the ritual.",
      child: Material(
        color: TrueGroundColors.primary,
        borderRadius: BorderRadius.circular(TrueGroundRadii.card),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TrueGroundRadii.card),
          child: Padding(
            padding: const EdgeInsets.all(TrueGroundSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(TrueGroundRadii.control),
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: TrueGroundSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "I'm stuck in a loop",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: TrueGroundSpacing.xs),
                      Text(
                        'Notice the urge. Pause before the ritual.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: TrueGroundSpacing.sm),
                const ExcludeSemantics(
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.quiet = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool quiet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = quiet
        ? TrueGroundColors.surface
        : TrueGroundColors.primaryContainer;

    return Semantics(
      button: true,
      label: '$title. $description',
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(TrueGroundRadii.control),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TrueGroundRadii.control),
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.symmetric(
              horizontal: TrueGroundSpacing.md,
              vertical: TrueGroundSpacing.md,
            ),
            decoration: quiet
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      TrueGroundRadii.control,
                    ),
                    border: Border.all(color: TrueGroundColors.outline),
                  )
                : null,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(icon, color: TrueGroundColors.primary, size: 24),
                const SizedBox(width: TrueGroundSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: TrueGroundSpacing.xs),
                      Text(description, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(width: TrueGroundSpacing.sm),
                const ExcludeSemantics(
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: TrueGroundColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StaticCard extends StatelessWidget {
  const _StaticCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(TrueGroundSpacing.md),
      decoration: BoxDecoration(
        color: TrueGroundColors.surface,
        borderRadius: BorderRadius.circular(TrueGroundRadii.control),
        border: Border.all(color: TrueGroundColors.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: TrueGroundColors.primary, size: 24),
          const SizedBox(width: TrueGroundSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: TrueGroundSpacing.xs),
                Text(description, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PatternReviewCard extends StatelessWidget {
  const _PatternReviewCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TrueGroundSpacing.md,
        vertical: TrueGroundSpacing.md,
      ),
      decoration: BoxDecoration(
        color: TrueGroundColors.surfaceMuted,
        borderRadius: BorderRadius.circular(TrueGroundRadii.control),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.history_rounded,
            size: 22,
            color: TrueGroundColors.inkMuted,
          ),
          const SizedBox(width: TrueGroundSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Review patterns when useful',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: TrueGroundSpacing.xs),
                Text(
                  'Optional, not a scorecard.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
