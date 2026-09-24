import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design/app_theme.dart';
import '../patterns/pattern_memory_store.dart';

enum _ValuesStep { chooseArea, chooseAction, leaveFlow }

class ValuesScreen extends StatefulWidget {
  const ValuesScreen({super.key, this.memoryStore, this.now});

  final PatternMemoryStore? memoryStore;
  final DateTime Function()? now;

  static const screenKey = ValueKey('screen-values');
  static const chooseAreaKey = ValueKey('values-choose-area');
  static const chooseActionKey = ValueKey('values-choose-action');
  static const leaveFlowKey = ValueKey('values-leave-flow');

  @override
  State<ValuesScreen> createState() => _ValuesScreenState();
}

class _ValuesScreenState extends State<ValuesScreen> {
  static const List<String> _areas = <String>[
    'Work or study',
    'Family',
    'Friends or community',
    'Rest or care',
    'Faith or meaning',
    'Home or daily life',
    'Something else that matters',
  ];

  final ScrollController _scrollController = ScrollController();
  late final PatternMemoryStore _memoryStore =
      widget.memoryStore ?? SharedPreferencesPatternMemoryStore();
  _ValuesStep _step = _ValuesStep.chooseArea;
  String? _selectedArea;
  bool _correctionUsed = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _moveTo(_ValuesStep step) {
    setState(() {
      _step = step;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  void _chooseArea(String area) {
    _selectedArea = area;
    _moveTo(_ValuesStep.chooseAction);
  }

  void _confirmNextStep() {
    _moveTo(_ValuesStep.leaveFlow);
    _persistCompletion();
  }

  Future<void> _persistCompletion() async {
    try {
      await _memoryStore.append(
        PatternEventKind.valuesStep,
        occurredAt: (widget.now ?? DateTime.now)().toUtc(),
      );
    } catch (_) {
      // Values remains usable if local pattern memory is unavailable.
    }
  }

  void _chooseAgain() {
    _correctionUsed = true;
    _selectedArea = null;
    _moveTo(_ValuesStep.chooseArea);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      key: ValuesScreen.screenKey,
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
                  'Return to what matters',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: TrueGroundSpacing.sm),
              Text(
                'Choose a direction that matters to you, then take the next '
                'step outside this flow.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: TrueGroundSpacing.md),
              const _BoundaryCard(),
              const SizedBox(height: TrueGroundSpacing.lg),
              if (_step == _ValuesStep.chooseArea)
                _ChooseAreaStep(onSelected: _chooseArea)
              else if (_step == _ValuesStep.chooseAction)
                _ChooseActionStep(
                  area: _selectedArea!,
                  onConfirm: _confirmNextStep,
                  onBack: _correctionUsed ? null : _chooseAgain,
                )
              else
                _LeaveFlowStep(area: _selectedArea!),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoundaryCard extends StatelessWidget {
  const _BoundaryCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: TrueGroundColors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(TrueGroundSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(Icons.explore_outlined, color: TrueGroundColors.primary),
            const SizedBox(width: TrueGroundSpacing.sm),
            Expanded(
              child: Text(
                'This is not a way to prove you are safe or make uncertainty '
                'disappear. The app will not choose your values or generate the '
                'perfect action for you.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: TrueGroundColors.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChooseAreaStep extends StatelessWidget {
  const _ChooseAreaStep({required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValuesScreen.chooseAreaKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Pick one area for right now.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: TrueGroundSpacing.xs),
        Text(
          'There is no best answer. Choose the one you want to move toward.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: TrueGroundSpacing.md),
        for (final area in _ValuesScreenState._areas) ...<Widget>[
          _ChoiceCard(label: area, onTap: () => onSelected(area)),
          const SizedBox(height: TrueGroundSpacing.sm),
        ],
      ],
    );
  }
}

class _ChooseActionStep extends StatelessWidget {
  const _ChooseActionStep({
    required this.area,
    required this.onConfirm,
    required this.onBack,
  });

  final String area;
  final VoidCallback onConfirm;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValuesScreen.chooseActionKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('You chose', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: TrueGroundSpacing.xs),
        Text(area, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: TrueGroundSpacing.md),
        Text(
          'Keep the next step ordinary and yours.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: TrueGroundSpacing.xs),
        Text(
          'Pick one small action yourself. It does not need to feel certain '
          'or perfect before you leave this flow.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: TrueGroundSpacing.lg),
        FilledButton(
          onPressed: onConfirm,
          child: const Text('Take my next step'),
        ),
        const SizedBox(height: TrueGroundSpacing.sm),
        TextButton(
          onPressed: () => context.go('/'),
          child: const Text('Leave for now'),
        ),
        if (onBack != null)
          TextButton(
            onPressed: onBack,
            child: const Text('I tapped the wrong area'),
          ),
      ],
    );
  }
}

class _LeaveFlowStep extends StatelessWidget {
  const _LeaveFlowStep({required this.area});

  final String area;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValuesScreen.leaveFlowKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Take the step outside TrueGround.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: TrueGroundSpacing.sm),
        Text(
          area,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: TrueGroundColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: TrueGroundSpacing.sm),
        Text(
          'Uncertainty does not have to be settled first. This flow ends here '
          'so the next move can happen in real life.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: TrueGroundSpacing.lg),
        FilledButton(
          onPressed: () => context.go('/'),
          child: const Text('Back to Home'),
        ),
      ],
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: TrueGroundColors.surface,
          borderRadius: BorderRadius.circular(TrueGroundRadii.card),
          border: Border.all(color: TrueGroundColors.outline),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: TrueGroundColors.primary.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(TrueGroundRadii.card),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TrueGroundSpacing.md,
              vertical: 14,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: TrueGroundColors.iconWash,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.north_east_rounded,
                    size: 18,
                    color: TrueGroundColors.primary,
                  ),
                ),
                const SizedBox(width: TrueGroundSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(width: TrueGroundSpacing.sm),
                const Icon(
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
