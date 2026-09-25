import 'package:flutter/material.dart';

import '../design/app_theme.dart';
import 'trueground_locale.dart';

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  static const toggleKey = ValueKey('language-toggle');

  @override
  Widget build(BuildContext context) {
    final scope = TrueGroundLocaleScope.maybeOf(context);
    if (scope == null) {
      return const SizedBox.shrink();
    }
    return Semantics(
      key: toggleKey,
      container: true,
      label: context.tr('Language'),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: TrueGroundColors.outline.withValues(alpha: 0.9),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: TrueGroundColors.primary.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _LanguageSegment(
                label: 'FR',
                selected: scope.language == TrueGroundLanguage.fr,
                onTap: () => scope.onLanguageChanged(TrueGroundLanguage.fr),
              ),
              _LanguageSegment(
                label: 'EN',
                selected: scope.language == TrueGroundLanguage.en,
                onTap: () => scope.onLanguageChanged(TrueGroundLanguage.en),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageSegment extends StatelessWidget {
  const _LanguageSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          constraints: const BoxConstraints(minWidth: 38, minHeight: 32),
          padding: const EdgeInsets.symmetric(horizontal: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? TrueGroundColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            textScaler: TextScaler.noScaling,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: selected ? Colors.white : TrueGroundColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
