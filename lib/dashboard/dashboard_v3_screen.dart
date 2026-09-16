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
              _PrimaryActionCard(onTap: () => context.go('/loop')),
              const SizedBox(height: TrueGroundSpacing.md),
              _ActionCard(
                icon: Icons.pause_circle_outline_rounded,
                title: 'Pause the ritual',
                onTap: () => context.go('/practice'),
              ),
              const SizedBox(height: TrueGroundSpacing.sm),
              _ActionCard(
                icon: Icons.waves_rounded,
                title: 'Practice uncertainty',
                onTap: () => context.go('/practice'),
              ),
              const SizedBox(height: TrueGroundSpacing.sm),
              _ActionCard(
                icon: Icons.play_circle_outline_rounded,
                title: 'Continue planned practice',
                onTap: () => context.go('/practice'),
              ),
              const SizedBox(height: TrueGroundSpacing.md),
              const _StaticCard(
                icon: Icons.favorite_outline_rounded,
                title: 'Return to what matters',
              ),
              const SizedBox(height: TrueGroundSpacing.sm),
              _ActionCard(
                icon: Icons.people_outline_rounded,
                title: 'Need a person, not an answer?',
                onTap: () => context.go('/support'),
                quiet: true,
              ),
              const SizedBox(height: TrueGroundSpacing.md),
              const _StaticCard(
                icon: Icons.history_rounded,
                title: 'Review patterns when useful',
                muted: true,
              ),
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
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(
                      TrueGroundRadii.control,
                    ),
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
                  child: Icon(Icons.arrow_forward_rounded, color: Colors.white),
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
    required this.onTap,
    this.quiet = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool quiet;

  @override
  Widget build(BuildContext context) {
    final background = quiet
        ? TrueGroundColors.surface
        : TrueGroundColors.primaryContainer;

    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(TrueGroundRadii.control),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TrueGroundRadii.control),
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
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
              children: <Widget>[
                Icon(icon, color: TrueGroundColors.primary, size: 24),
                const SizedBox(width: TrueGroundSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
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
    this.muted = false,
  });

  final IconData icon;
  final String title;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(
        horizontal: TrueGroundSpacing.md,
        vertical: TrueGroundSpacing.md,
      ),
      decoration: BoxDecoration(
        color: muted ? TrueGroundColors.surfaceMuted : TrueGroundColors.surface,
        borderRadius: BorderRadius.circular(TrueGroundRadii.control),
        border: muted ? null : Border.all(color: TrueGroundColors.outline),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            color: muted ? TrueGroundColors.inkMuted : TrueGroundColors.primary,
            size: 24,
          ),
          const SizedBox(width: TrueGroundSpacing.md),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
        ],
      ),
    );
  }
}
