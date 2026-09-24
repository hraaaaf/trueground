import 'package:flutter/material.dart';

import '../design/app_theme.dart';
import 'trueground_locale.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  static const screenKey = ValueKey('screen-language');

  @override
  Widget build(BuildContext context) {
    final scope = TrueGroundLocaleScope.of(context);

    return SingleChildScrollView(
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
              Semantics(
                header: true,
                child: Text(
                  context.tr('Language'),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: TrueGroundSpacing.sm),
              Text(
                context.tr('Choose your language'),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: TrueGroundSpacing.md),
              _LanguageChoice(
                language: TrueGroundLanguage.en,
                selected: scope.language == TrueGroundLanguage.en,
                onTap: () =>
                    scope.onLanguageChanged(TrueGroundLanguage.en),
              ),
              const SizedBox(height: TrueGroundSpacing.sm),
              _LanguageChoice(
                language: TrueGroundLanguage.fr,
                selected: scope.language == TrueGroundLanguage.fr,
                onTap: () =>
                    scope.onLanguageChanged(TrueGroundLanguage.fr),
              ),
              const SizedBox(height: TrueGroundSpacing.lg),
              Card(
                color: TrueGroundColors.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(TrueGroundSpacing.md),
                  child: Text(
                    context.tr(
                      'Language changes only the app interface. Your saved activity stays on this device.',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageChoice extends StatelessWidget {
  const _LanguageChoice({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final TrueGroundLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: language.label,
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TrueGroundRadii.card),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TrueGroundSpacing.md,
              vertical: 14,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    language.label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color: TrueGroundColors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
