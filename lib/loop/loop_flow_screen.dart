import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design/app_theme.dart';
import '../localization/language_toggle.dart';
import '../localization/trueground_locale.dart';
import 'loop_flow_policy.dart';

enum _LoopStage { pattern, action, complete }

class LoopFlowScreen extends StatefulWidget {
  const LoopFlowScreen({super.key});

  static const screenKey = ValueKey('screen-loop');
  static const patternStepKey = ValueKey('loop-pattern-step');
  static const actionStepKey = ValueKey('loop-action-step');
  static const completeStepKey = ValueKey('loop-complete-step');
  static const supportEscapeKey = ValueKey('loop-support-escape');

  @override
  State<LoopFlowScreen> createState() => _LoopFlowScreenState();
}

class _LoopFlowScreenState extends State<LoopFlowScreen> {
  _LoopStage _stage = _LoopStage.pattern;
  LoopPattern? _pattern;
  LoopNextAction? _action;

  void _selectPattern(LoopPattern pattern) {
    setState(() {
      _pattern = pattern;
      _action = null;
      _stage = _LoopStage.action;
    });
  }

  void _selectAction(LoopNextAction action) {
    setState(() {
      _action = action;
      _stage = _LoopStage.complete;
    });
  }

  void _returnToPatterns() {
    setState(() {
      _pattern = null;
      _action = null;
      _stage = _LoopStage.pattern;
    });
  }

  void _continueSelectedAction(BuildContext context) {
    switch (_action) {
      case LoopNextAction.practiceUncertainty:
        context.go('/practice');
        return;
      case LoopNextAction.returnHome:
        context.go('/');
        return;
      case LoopNextAction.humanSupport:
        context.go('/support');
        return;
      case null:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: LoopFlowScreen.screenKey,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'TrueGround',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: TrueGroundColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const LanguageToggle(),
                ],
              ),
              const SizedBox(height: 18),
              Semantics(
                header: true,
                child: Text(
                  context.tr("I'm stuck in a loop"),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: TrueGroundColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr(loopBoundedNotice),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              _SupportEscapeHatch(onSupport: () => context.go('/support')),
              const SizedBox(height: 18),
              switch (_stage) {
                _LoopStage.pattern => _PatternStep(onSelected: _selectPattern),
                _LoopStage.action => _ActionStep(
                  pattern: _pattern!,
                  onSelected: _selectAction,
                  onBack: _returnToPatterns,
                ),
                _LoopStage.complete => _CompleteStep(
                  action: _action!,
                  onContinue: () => _continueSelectedAction(context),
                ),
              },
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportEscapeHatch extends StatelessWidget {
  const _SupportEscapeHatch({required this.onSupport});

  final VoidCallback onSupport;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label:
          '${context.tr(loopSupportTitle)}. ${context.tr(loopSupportHelper)} ${context.tr('Open Support')}.',
      excludeSemantics: true,
      child: Material(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(TrueGroundRadii.control),
        child: InkWell(
          key: LoopFlowScreen.supportEscapeKey,
          onTap: onSupport,
          borderRadius: BorderRadius.circular(TrueGroundRadii.control),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: <Widget>[
                Icon(Icons.groups_2_outlined, color: TrueGroundColors.primary),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        context.tr(loopSupportTitle),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: TrueGroundColors.ink,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        context.tr(loopSupportHelper),
                        style: TextStyle(
                          fontSize: 13,
                          color: TrueGroundColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
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

class _PatternStep extends StatelessWidget {
  const _PatternStep({required this.onSelected});

  final ValueChanged<LoopPattern> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: LoopFlowScreen.patternStepKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(
            context.tr('Choose the closest fit.'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          context.tr(
            'Pick one pattern only. You can move on without giving the full story.',
          ),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        for (final pattern in LoopPattern.values) ...<Widget>[
          _ChoiceCard(
            key: ValueKey('loop-pattern-${pattern.name}'),
            title: context.tr(loopPatternContent[pattern]!.title),
            helper: context.tr(loopPatternContent[pattern]!.helper),
            onTap: () => onSelected(pattern),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _ActionStep extends StatelessWidget {
  const _ActionStep({
    required this.pattern,
    required this.onSelected,
    required this.onBack,
  });

  final LoopPattern pattern;
  final ValueChanged<LoopNextAction> onSelected;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final content = loopPatternContent[pattern]!;
    return Column(
      key: LoopFlowScreen.actionStepKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          header: true,
          liveRegion: true,
          child: Text(
            context.tr('Notice the pattern'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 10),
        _FramingCard(
          title: context.tr(content.title),
          body: context.tr(content.framing),
        ),
        const SizedBox(height: 18),
        Semantics(
          header: true,
          child: Text(
            context.tr('Choose one next move.'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          context.tr(
            'This check-in ends after you choose. It will not keep asking for more detail.',
          ),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        for (final action in LoopNextAction.values) ...<Widget>[
          _ChoiceCard(
            key: ValueKey('loop-action-${action.name}'),
            title: context.tr(loopActionContent[action]!.title),
            helper: context.tr(loopActionContent[action]!.helper),
            onTap: () => onSelected(action),
          ),
          const SizedBox(height: 8),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: onBack,
            child: Text(context.tr('Choose a different pattern')),
          ),
        ),
      ],
    );
  }
}

class _CompleteStep extends StatelessWidget {
  const _CompleteStep({required this.action, required this.onContinue});

  final LoopNextAction action;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final content = loopActionContent[action]!;
    return Column(
      key: LoopFlowScreen.completeStepKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          header: true,
          liveRegion: true,
          child: Text(
            context.tr('Next move chosen'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 10),
        _FramingCard(
          title: context.tr(content.title),
          body: context.tr(loopCompletionCopy),
        ),
        const SizedBox(height: 16),
        FilledButton(
          key: const ValueKey('loop-continue-action'),
          onPressed: onContinue,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          child: Text(context.tr(content.continueLabel)),
        ),
        const SizedBox(height: 10),
        Text(
          context.tr(
            'There is no restart button here. If the question still feels unresolved, that does not require another pass through this check-in.',
          ),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _FramingCard extends StatelessWidget {
  const _FramingCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Colors.white.withValues(alpha: 0.94),
            const Color(0xFFEAF6F7).withValues(alpha: 0.88),
          ],
        ),
        borderRadius: BorderRadius.circular(TrueGroundRadii.card),
        border: Border.all(color: Colors.white),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: TrueGroundColors.primary.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(body, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.title,
    required this.helper,
    required this.onTap,
    super.key,
  });

  final String title;
  final String helper;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${context.tr(title)}. ${context.tr(helper)}',
      excludeSemantics: true,
      child: Material(
        color: TrueGroundColors.surface,
        borderRadius: BorderRadius.circular(TrueGroundRadii.card),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TrueGroundRadii.card),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: TrueGroundColors.iconWash,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_outward_rounded,
                      size: 19,
                      color: TrueGroundColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          helper,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const ExcludeSemantics(
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: TrueGroundColors.primary,
                    ),
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
