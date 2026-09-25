import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design/app_theme.dart';
import '../localization/language_toggle.dart';
import '../localization/trueground_locale.dart';
import '../patterns/pattern_memory_store.dart';
import 'practice_completion_store.dart';

enum _PracticeView {
  menu,
  pauseStart,
  pauseMoment,
  pauseEnd,
  uncertaintyStart,
  uncertaintyNotice,
  uncertaintyChoose,
  uncertaintyEnd,
  plannedEmpty,
}

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({
    super.key,
    this.completionStore,
    this.now,
    this.patternMemoryStore,
  });

  final PracticeCompletionStore? completionStore;
  final DateTime Function()? now;
  final PatternMemoryStore? patternMemoryStore;

  static const screenKey = ValueKey('screen-practice');
  static const menuKey = ValueKey('practice-menu');
  static const pauseStartKey = ValueKey('practice-pause-start');
  static const pauseMomentKey = ValueKey('practice-pause-moment');
  static const pauseEndKey = ValueKey('practice-pause-end');
  static const uncertaintyStartKey = ValueKey('practice-uncertainty-start');
  static const uncertaintyNoticeKey = ValueKey('practice-uncertainty-notice');
  static const uncertaintyChooseKey = ValueKey('practice-uncertainty-choose');
  static const uncertaintyEndKey = ValueKey('practice-uncertainty-end');
  static const plannedEmptyKey = ValueKey('practice-planned-empty');

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  _PracticeView _view = _PracticeView.menu;
  late final PracticeCompletionStore _completionStore =
      widget.completionStore ?? SharedPreferencesPracticeCompletionStore();
  late final PatternMemoryStore _patternMemoryStore =
      widget.patternMemoryStore ?? SharedPreferencesPatternMemoryStore();
  bool _completionStateLoaded = false;
  bool _completionStateUnavailable = false;
  bool _pauseCompleted = false;
  bool _uncertaintyCompleted = false;

  DateTime _now() => (widget.now ?? DateTime.now)().toUtc();

  @override
  void initState() {
    super.initState();
    unawaited(_loadCompletionState());
  }

  Future<void> _loadCompletionState() async {
    try {
      final pauseCompletedAt = await _completionStore.readPauseCompletedAt();
      final uncertaintyCompletedAt = await _completionStore
          .readUncertaintyCompletedAt();
      if (!mounted) {
        return;
      }

      final now = _now();
      setState(() {
        _pauseCompleted = isPracticeAntiReplayActive(
          pauseCompletedAt,
          now: now,
        );
        _uncertaintyCompleted = isPracticeAntiReplayActive(
          uncertaintyCompletedAt,
          now: now,
        );
        _completionStateLoaded = true;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _completionStateLoaded = true;
        _completionStateUnavailable = true;
        _pauseCompleted = true;
        _uncertaintyCompleted = true;
      });
    }
  }

  void _show(_PracticeView view) {
    setState(() {
      _view = view;
    });
  }

  void _completePause() {
    final completedAt = _now();
    setState(() {
      _pauseCompleted = true;
      _view = _PracticeView.pauseEnd;
    });
    unawaited(_persistPauseCompletion(completedAt));
  }

  Future<void> _persistPauseCompletion(DateTime completedAt) async {
    try {
      await _completionStore.writePauseCompletedAt(completedAt);
      await _patternMemoryStore.append(
        PatternEventKind.pausePractice,
        occurredAt: completedAt,
      );
    } catch (_) {
      // The in-session anti-replay state remains active even if local storage
      // is unavailable. No clinical or user-entered data is involved.
    }
  }

  void _completeUncertainty() {
    final completedAt = _now();
    setState(() {
      _uncertaintyCompleted = true;
      _view = _PracticeView.uncertaintyEnd;
    });
    unawaited(_persistUncertaintyCompletion(completedAt));
  }

  Future<void> _persistUncertaintyCompletion(DateTime completedAt) async {
    try {
      await _completionStore.writeUncertaintyCompletedAt(completedAt);
      await _patternMemoryStore.append(
        PatternEventKind.uncertaintyPractice,
        occurredAt: completedAt,
      );
    } catch (_) {
      // Keep the bounded flow usable without crashing; current-session
      // anti-replay remains active.
    }
  }

  void _returnHome(BuildContext context) {
    setState(() {
      _view = _PracticeView.menu;
    });
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: PracticeScreen.screenKey,
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
                  context.tr('Practice'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: TrueGroundColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('Choose one brief practice. Each one has a clear end.'),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 18),
              switch (_view) {
                _PracticeView.menu => _PracticeMenu(
                  completionStateLoaded: _completionStateLoaded,
                  completionStateUnavailable: _completionStateUnavailable,
                  pauseCompleted: _pauseCompleted,
                  uncertaintyCompleted: _uncertaintyCompleted,
                  onPause: () => _show(_PracticeView.pauseStart),
                  onUncertainty: () => _show(_PracticeView.uncertaintyStart),
                  onPlanned: () => _show(_PracticeView.plannedEmpty),
                ),
                _PracticeView.pauseStart => _PracticeStep(
                  key: PracticeScreen.pauseStartKey,
                  title: 'Pause the ritual',
                  body:
                      'If you already recognize an urge to check, repeat, neutralize or seek reassurance, you can choose a brief pause before acting.',
                  note:
                      'Not for urgent safety, medical or emergency decisions.',
                  primaryLabel: 'Start a brief pause',
                  onPrimary: () => _show(_PracticeView.pauseMoment),
                  secondaryLabel: 'Exit practice',
                  onSecondary: () => _show(_PracticeView.menu),
                ),
                _PracticeView.pauseMoment => _PracticeStep(
                  key: PracticeScreen.pauseMomentKey,
                  title: 'Leave the question unanswered for this moment.',
                  body:
                      'You do not need to decide whether the feared outcome is safe here, and you do not need to feel calm before moving on.',
                  note:
                      'Not for urgent safety, medical or emergency decisions.',
                  primaryLabel: 'Continue',
                  onPrimary: _completePause,
                  secondaryLabel: 'Exit practice',
                  onSecondary: () => _show(_PracticeView.menu),
                ),
                _PracticeView.pauseEnd => _PracticeEnd(
                  key: PracticeScreen.pauseEndKey,
                  body:
                      'TrueGround does not grade how the pause went. Choose your next ordinary action when you leave.',
                  onHome: () => _returnHome(context),
                ),
                _PracticeView.uncertaintyStart => _PracticeStep(
                  key: PracticeScreen.uncertaintyStartKey,
                  title: 'Practice uncertainty',
                  body:
                      'This is a brief practice in leaving a question unresolved — not in proving that a feared outcome is safe or unsafe.',
                  note:
                      'Not for urgent safety, medical or emergency decisions.',
                  primaryLabel: 'Begin',
                  onPrimary: () => _show(_PracticeView.uncertaintyNotice),
                  secondaryLabel: 'Exit practice',
                  onSecondary: () => _show(_PracticeView.menu),
                ),
                _PracticeView.uncertaintyNotice => _PracticeStep(
                  key: PracticeScreen.uncertaintyNoticeKey,
                  title: 'Notice the pull to get a definite answer.',
                  body: 'You do not need to analyze the question here.',
                  note:
                      'Not for urgent safety, medical or emergency decisions.',
                  primaryLabel: 'Continue',
                  onPrimary: () => _show(_PracticeView.uncertaintyChoose),
                  secondaryLabel: 'Exit practice',
                  onSecondary: () => _show(_PracticeView.menu),
                ),
                _PracticeView.uncertaintyChoose => _PracticeStep(
                  key: PracticeScreen.uncertaintyChooseKey,
                  title:
                      'For this moment, choose not to solve the uncertainty in TrueGround.',
                  body: 'I may not know for sure right now.',
                  note:
                      'Not for urgent safety, medical or emergency decisions.',
                  primaryLabel: 'Finish practice',
                  onPrimary: _completeUncertainty,
                  secondaryLabel: 'Exit practice',
                  onSecondary: () => _show(_PracticeView.menu),
                ),
                _PracticeView.uncertaintyEnd => _PracticeEnd(
                  key: PracticeScreen.uncertaintyEndKey,
                  body:
                      'No rating is needed. You can return to what you were going to do next.',
                  onHome: () => _returnHome(context),
                ),
                _PracticeView.plannedEmpty => _PlannedPracticeEmpty(
                  key: PracticeScreen.plannedEmptyKey,
                  onBack: () => _show(_PracticeView.menu),
                  onHome: () => _returnHome(context),
                ),
              },
            ],
          ),
        ),
      ),
    );
  }
}

class _PracticeMenu extends StatelessWidget {
  const _PracticeMenu({
    required this.completionStateLoaded,
    required this.completionStateUnavailable,
    required this.pauseCompleted,
    required this.uncertaintyCompleted,
    required this.onPause,
    required this.onUncertainty,
    required this.onPlanned,
  });

  final bool completionStateLoaded;
  final bool completionStateUnavailable;
  final bool pauseCompleted;
  final bool uncertaintyCompleted;
  final VoidCallback onPause;
  final VoidCallback onUncertainty;
  final VoidCallback onPlanned;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: PracticeScreen.menuKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _PracticeChoiceCard(
          key: const ValueKey('practice-choice-pause'),
          icon: Icons.pause_rounded,
          title: pauseCompleted ? 'Pause finished for now' : 'Pause the ritual',
          helper: !completionStateLoaded
              ? 'Checking recent practice availability.'
              : completionStateUnavailable
              ? 'Practice availability could not be checked.'
              : pauseCompleted
              ? 'This practice was recently completed.'
              : 'Create a small space before an urge-driven action.',
          onTap:
              completionStateLoaded &&
                  !completionStateUnavailable &&
                  !pauseCompleted
              ? onPause
              : null,
        ),
        const SizedBox(height: 10),
        _PracticeChoiceCard(
          key: const ValueKey('practice-choice-uncertainty'),
          icon: Icons.eco_outlined,
          title: uncertaintyCompleted
              ? 'Uncertainty practice finished for now'
              : 'Practice uncertainty',
          helper: !completionStateLoaded
              ? 'Checking recent practice availability.'
              : completionStateUnavailable
              ? 'Practice availability could not be checked.'
              : uncertaintyCompleted
              ? 'This practice was recently completed.'
              : 'Leave a question unresolved without trying to prove it safe or unsafe.',
          onTap:
              completionStateLoaded &&
                  !completionStateUnavailable &&
                  !uncertaintyCompleted
              ? onUncertainty
              : null,
        ),
        const SizedBox(height: 10),
        _PracticeChoiceCard(
          key: const ValueKey('practice-choice-planned'),
          icon: Icons.history_rounded,
          title: 'Continue planned practice',
          helper: 'Saved practice is not available yet.',
          onTap: onPlanned,
        ),
        const SizedBox(height: 16),
        Text(
          context.tr('Practice does not diagnose a compulsion or decide whether a real-world safety check is necessary.'),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _PracticeStep extends StatelessWidget {
  const _PracticeStep({
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
    this.note,
    super.key,
  });

  final String title;
  final String body;
  final String? note;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          header: true,
          liveRegion: true,
          child: Text(context.tr(title), style: Theme.of(context).textTheme.titleMedium),
        ),
        const SizedBox(height: 10),
        _PracticePanel(body: body),
        if (note != null) ...<Widget>[
          const SizedBox(height: 12),
          _SafetyNote(text: note!),
        ],
        const SizedBox(height: 18),
        FilledButton(
          onPressed: onPrimary,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          child: Text(context.tr(primaryLabel)),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onSecondary,
          style: TextButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: Text(context.tr(secondaryLabel)),
        ),
      ],
    );
  }
}

class _PracticeEnd extends StatelessWidget {
  const _PracticeEnd({required this.body, required this.onHome, super.key});

  final String body;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          header: true,
          liveRegion: true,
          child: Text(
            context.tr('Practice ends here.'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 10),
        _PracticePanel(body: body),
        const SizedBox(height: 18),
        FilledButton(
          key: const ValueKey('practice-return-home'),
          onPressed: onHome,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          child: Text(context.tr('Return to Home')),
        ),
      ],
    );
  }
}

class _PlannedPracticeEmpty extends StatelessWidget {
  const _PlannedPracticeEmpty({
    required this.onBack,
    required this.onHome,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          header: true,
          liveRegion: true,
          child: Text(
            context.tr('Continue planned practice'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 10),
        _PracticePanel(
          body: context.tr('No saved practice is available in this version.\n\nNothing has been stored to resume yet.'),
        ),
        const SizedBox(height: 18),
        FilledButton(
          key: const ValueKey('practice-planned-back'),
          onPressed: onBack,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          child: Text(context.tr('Back to Practice')),
        ),
        const SizedBox(height: 8),
        TextButton(
          key: const ValueKey('practice-planned-home'),
          onPressed: onHome,
          style: TextButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: Text(context.tr('Return to Home')),
        ),
      ],
    );
  }
}

class _PracticeChoiceCard extends StatelessWidget {
  const _PracticeChoiceCard({
    required this.icon,
    required this.title,
    required this.helper,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String helper;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      button: enabled,
      enabled: enabled,
      label: '${context.tr(title)}. ${context.tr(helper)}',
      excludeSemantics: true,
      child: Material(
        color: enabled
            ? Colors.white.withValues(alpha: 0.92)
            : TrueGroundColors.surfaceMuted,
        borderRadius: BorderRadius.circular(TrueGroundRadii.card),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TrueGroundRadii.card),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 82),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: TrueGroundColors.iconWash,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: TrueGroundColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          context.tr(title),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr(helper),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  if (enabled) ...<Widget>[
                    const SizedBox(width: 10),
                    const ExcludeSemantics(
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: TrueGroundColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PracticePanel extends StatelessWidget {
  const _PracticePanel({required this.body});

  final String body;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Colors.white.withValues(alpha: 0.96),
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
        child: Text(context.tr(body), style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}

class _SafetyNote extends StatelessWidget {
  const _SafetyNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.tr(text),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: TrueGroundColors.primaryContainer.withValues(alpha: 0.60),
          borderRadius: BorderRadius.circular(TrueGroundRadii.control),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const ExcludeSemantics(
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: TrueGroundColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.tr(text),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
