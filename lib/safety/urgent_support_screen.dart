import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design/app_theme.dart';
import '../localization/trueground_locale.dart';

class UrgentSupportScreen extends StatelessWidget {
  const UrgentSupportScreen({super.key});

  static const screenKey = ValueKey('screen-urgent-support');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TrueGroundColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          key: screenKey,
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
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: TrueGroundColors.iconWash,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.health_and_safety_outlined,
                      color: TrueGroundColors.primary,
                    ),
                  ),
                  const SizedBox(height: TrueGroundSpacing.md),
                  Semantics(
                    header: true,
                    child: Text(
                      context.tr('Use urgent real-world help'),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: TrueGroundSpacing.sm),
                  Text(
                    context.tr(
                      'TrueGround cannot determine whether this is an emergency or assess your immediate safety.',
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: TrueGroundSpacing.lg),
                  _UrgentActionCard(
                    icon: Icons.local_hospital_outlined,
                    child: Text(
                      context.tr(
                        'If there is immediate danger, or you cannot stay safe, contact the emergency services available where you are or go to the nearest emergency department now.',
                      ),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: TrueGroundSpacing.sm),
                  _UrgentActionCard(
                    icon: Icons.people_outline_rounded,
                    child: Text(
                      context.tr(
                        'If possible, stay with or contact a trusted person or health professional while you get urgent help.',
                      ),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: TrueGroundSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(TrueGroundSpacing.md),
                    decoration: BoxDecoration(
                      color: TrueGroundColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(
                        TrueGroundRadii.control,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 20,
                          color: TrueGroundColors.inkMuted,
                        ),
                        const SizedBox(width: TrueGroundSpacing.sm),
                        Expanded(
                          child: Text(
                            context.tr('TrueGround has not contacted anyone or dispatched help for you.'),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: TrueGroundSpacing.lg),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/support'),
                    icon: const Icon(Icons.people_outline_rounded),
                    label: Text(context.tr('Open regular Support')),
                  ),
                  const SizedBox(height: TrueGroundSpacing.sm),
                  TextButton(
                    onPressed: () => context.go('/'),
                    child: Text(context.tr('Back to Home')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UrgentActionCard extends StatelessWidget {
  const _UrgentActionCard({required this.icon, required this.child});

  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: TrueGroundColors.surface,
        borderRadius: BorderRadius.circular(TrueGroundRadii.card),
        border: Border.all(color: TrueGroundColors.outline),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: TrueGroundColors.primary.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(TrueGroundSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: TrueGroundColors.iconWash,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: TrueGroundColors.primary),
            ),
            const SizedBox(width: TrueGroundSpacing.md),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
