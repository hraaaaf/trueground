import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design/app_theme.dart';

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
                    ),
                  ),
                  const SizedBox(height: TrueGroundSpacing.lg),
                  Semantics(
                    header: true,
                    child: Text(
                      'Use urgent real-world help',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: TrueGroundSpacing.md),
                  Text(
                    'TrueGround cannot determine whether this is an emergency '
                    'or assess your immediate safety.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: TrueGroundSpacing.md),
                  Text(
                    'If there is immediate danger, or you cannot stay safe, '
                    'contact the emergency services available where you are or '
                    'go to the nearest emergency department now.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: TrueGroundSpacing.md),
                  Text(
                    'If possible, stay with or contact a trusted person or '
                    'health professional while you get urgent help.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: TrueGroundSpacing.md),
                  Text(
                    'TrueGround has not contacted anyone or dispatched help for you.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: TrueGroundSpacing.lg),
                  OutlinedButton(
                    onPressed: () => context.go('/support'),
                    child: const Text('Open regular Support'),
                  ),
                  const SizedBox(height: TrueGroundSpacing.sm),
                  TextButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Back to Home'),
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
