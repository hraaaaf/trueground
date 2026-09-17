import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design/app_theme.dart';
import 'loop_flow_policy.dart';

enum _LoopStage { pattern, action, complete }

class LoopFlowScreen extends StatefulWidget {
  const LoopFlowScreen({super.key});

  static const screenKey = ValueKey('screen-loop');
  static const patternStepKey = ValueKey('loop-pattern-step');
  static const actionStepKey = ValueKey('loop-action-step');
  static const completeStepKey = ValueKey('loop-complete-step');
  static const safetySupportKey = ValueKey('loop-safety-support');

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
      case LoopNextAction.returnHome:
        context.go('/');
      case LoopNextAction.humanSupport:
        context.go('/support');
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
              Text(
                'TrueGround',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: TrueGroundColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              Semantics(
                header: true,
                child: Text(
                  "I'm stuck in a loop",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: TrueGroundColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loopBoundedNotice,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              _SafetyBoundary(onSupport: () => context.go('/support')),
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

class _SafetyBoundary extends StatelessWidget {
  const _SafetyBoundary({required this.onSupport});

  final VoidCallback onSupport;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$loopSafetyBoundary Open Support.',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFE9F2F5),
          borderRadius: BorderRadius.circular(TrueGroundRadii.control),
          border: Border.all(color: const Color(0xFFC7DCE4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const ExcludeSemantics(
                child: Icon(
                  Icons.shield_outlined,
                  color: TrueGroundColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      loopSafetyBoundary,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: TrueGroundColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      key: LoopFlowScreen.safetySupportKey,
                      onPressed: onSupport,
                      child: const Text('Open Support'),
                    ),
                  ],
                ),
              ),
            ],
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
            'Choose the closest fit.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Pick one pattern only. You can move on without giving the full story.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        for (final pattern in LoopPattern.values) ...<Widget>[
          _ChoiceCard(
            key: ValueKey('loop-pattern-${pattern.name}'),
            title: loopPatternContent[pattern]!.title,
            helper: loopPatternContent[pattern]!.helper,
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
          child: Text(
            'Notice the pattern',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 10),
        _FramingCard(title: content.title, body: content.framing),
        const SizedBox(height: 18),
        Semantics(
          header: true,
          child: Text(
            'Choose one next move.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'This check-in ends after you choose. It will not keep asking for more detail.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        for (final action in LoopNextAction.values) ...<Widget>[
          _ChoiceCard(
            key: ValueKey('loop-action-${action.name}'),
            title: loopActionContent[action]!.title,
            helper: loopActionContent[action]!.helper,
            onTap: () => onSelected(action),
          ),
          const SizedBox(height: 8),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: onBack,
            child: const Text('Choose a different pattern'),
          ),
        ),
      ],
    );
  }
}

class _CompleteStep extends StatelessWidget {
  const _CompleteStep({
    required this.action,
    required this.onContinue,
  });

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
          child: Text(
            'Next move chosen',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 10),
        _FramingCard(title: content.title, body: loopCompletionCopy),
        const SizedBox(height: 16),
        FilledButton(
          key: const ValueKey('loop-continue-action'),
          onPressed: onContinue,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
          child: Text(content.continueLabel),
        ),
        const SizedBox(height: 10),
        Text(
          'There is no restart button here. If the question still feels unresolved, that does not require another pass through this check-in.',
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
      label: '$title. $helper',
      excludeSemantics: true,
      child: Material(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(TrueGroundRadii.control),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TrueGroundRadii.control),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              child: Row(
                children: <Widget>[
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
