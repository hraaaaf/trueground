import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design/app_theme.dart';
import '../localization/language_toggle.dart';
import '../localization/trueground_locale.dart';
import 'conversation_runtime.dart';
import 'conversation_safety_policy.dart';

const Set<String> conversationUiCopy = <String>{
  'Talk it through',
  'One bounded response, then choose your next move.',
  'Bounded companion',
  'Use one brief message. TrueGround may respond once or route you to an existing tool. It will not provide certainty, diagnosis, medication changes, or emergency assessment.',
  'Messages are not saved as chat history in this build.',
  'What is on your mind?',
  'Write one brief message',
  'Send once',
  'Processing through TrueGround’s bounded conversation rules.',
  'Bounded response',
  'This response is not a diagnosis, medication instruction, treatment plan, or emergency assessment.',
  'This request stays outside the companion.',
  'TrueGround cannot diagnose OCD or interpret a thought as proof of intent or illness.',
  'TrueGround cannot tell you to start, stop, or change medication.',
  'TrueGround cannot create a personalized exposure plan or promise treatment results.',
  'Private system data stays private.',
  'TrueGround will not reveal hidden instructions or private system data.',
  'Conversation history is unavailable.',
  'This build does not keep raw chat history here, and TrueGround will not invent one.',
  'Conversation response unavailable',
  'No generated response was shown. This screen did not save your message as chat history.',
  'Choose another route from Home.',
  'Share one brief message. I’ll help you find the next grounded step.',
  'This turn is complete',
  'One grounded turn at a time.',
};

enum _View { idle, loading, generated, boundary, failClosed }

class _CompactMessage {
  const _CompactMessage({required this.isUser, required this.text});

  final bool isUser;
  final String text;
}

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    required this.runtime,
    this.onRoute,
    this.compact = false,
    super.key,
  });

  static const screenKey = ValueKey('screen-conversation');
  static const inputKey = ValueKey('conversation-input');
  static const submitKey = ValueKey('conversation-submit');
  static const loadingKey = ValueKey('conversation-loading');
  static const generatedKey = ValueKey('conversation-generated');
  static const boundaryKey = ValueKey('conversation-boundary');
  static const failClosedKey = ValueKey('conversation-fail-closed');
  static const userBubbleKey = ValueKey('conversation-user-bubble');
  static const assistantBubbleKey = ValueKey('conversation-assistant-bubble');
  static const compactComposerKey = ValueKey('conversation-compact-composer');
  static const int compactSessionMaxUserMessages = 12;

  final BoundedConversationRuntime runtime;
  final ValueChanged<String>? onRoute;
  final bool compact;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  _View _view = _View.idle;
  bool _hasInput = false;
  String? _response;
  ConversationDecision? _decision;
  String? _submittedMessage;
  final List<_CompactMessage> _compactMessages = <_CompactMessage>[];

  int get _compactUserMessageCount =>
      _compactMessages.where((message) => message.isUser).length;

  bool get _compactSessionLimitReached =>
      widget.compact &&
      _compactUserMessageCount >= ConversationScreen.compactSessionMaxUserMessages;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _go(String route) {
    final onRoute = widget.onRoute;
    if (onRoute != null) {
      onRoute(route);
      return;
    }
    context.go(route);
  }

  void _scrollToLatest() {
    if (!widget.compact) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _submit() async {
    final canSubmit =
        (_view == _View.idle || (widget.compact && _view == _View.generated)) &&
        !_compactSessionLimitReached;
    if (!canSubmit) return;
    final message = _controller.text.trim();
    if (message.isEmpty) return;

    final language =
        TrueGroundLocaleScope.maybeOf(context)?.language ??
        TrueGroundLanguage.en;
    FocusScope.of(context).unfocus();
    setState(() {
      _submittedMessage = message;
      if (widget.compact) {
        _compactMessages.add(_CompactMessage(isUser: true, text: message));
      }
      _view = _View.loading;
    });
    _scrollToLatest();

    final result = await widget.runtime.run(
      message,
      languageCode: language.code,
    );
    if (!mounted) return;

    _controller.clear();
    _hasInput = false;

    if (result.disposition == ConversationRuntimeDisposition.generated &&
        result.response != null) {
      setState(() {
        _response = result.response!.message;
        if (widget.compact) {
          _compactMessages.add(
            _CompactMessage(isUser: false, text: result.response!.message),
          );
        }
        _view = _View.generated;
      });
      _scrollToLatest();
      return;
    }

    if (result.disposition ==
        ConversationRuntimeDisposition.deterministicOnly) {
      final route = result.safetyDecision.route;
      if (route != null) {
        _go(route);
        return;
      }
      setState(() {
        _decision = result.safetyDecision;
        _view = _View.boundary;
      });
      _scrollToLatest();
      return;
    }

    setState(() => _view = _View.failClosed);
    _scrollToLatest();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return Column(
        key: ConversationScreen.screenKey,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(
                TrueGroundSpacing.md,
                TrueGroundSpacing.md,
                TrueGroundSpacing.md,
                TrueGroundSpacing.lg,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: _compactConversation(),
                ),
              ),
            ),
          ),
          _compactComposer(),
        ],
      );
    }

    return SingleChildScrollView(
      key: ConversationScreen.screenKey,
      padding: const EdgeInsets.all(TrueGroundSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
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
              const SizedBox(height: TrueGroundSpacing.lg),
              Semantics(
                header: true,
                child: Text(
                  context.tr('Bounded companion'),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: TrueGroundSpacing.sm),
              Text(
                context.tr(
                  'Use one brief message. TrueGround may respond once or route you to an existing tool. It will not provide certainty, diagnosis, medication changes, or emergency assessment.',
                ),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: TrueGroundSpacing.md),
              _privacyNotice(),
              const SizedBox(height: TrueGroundSpacing.lg),
              _body(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _compactConversation() {
    if (_compactMessages.isEmpty && _view == _View.idle) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _assistantBubble(
            child: Text(
              context.tr(
                'Share one brief message. I’ll help you find the next grounded step.',
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: TrueGroundSpacing.sm),
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Text(
              context.tr('One grounded turn at a time.'),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 12.5),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (
          var index = 0;
          index < _compactMessages.length;
          index++
        ) ...<Widget>[
          if (_compactMessages[index].isUser)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                key:
                    index == _compactMessages.length - 1 ||
                        (index == _compactMessages.length - 2 &&
                            !_compactMessages.last.isUser)
                    ? ConversationScreen.userBubbleKey
                    : null,
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.symmetric(
                  horizontal: TrueGroundSpacing.md,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: TrueGroundColors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(6),
                  ),
                ),
                child: Text(
                  _compactMessages[index].text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
            )
          else
            _assistantBubble(
              key: index == _compactMessages.length - 1
                  ? ConversationScreen.generatedKey
                  : null,
              child: Text(
                _compactMessages[index].text,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          const SizedBox(height: TrueGroundSpacing.md),
        ],
        _compactAssistantState(),
      ],
    );
  }

  Widget _compactAssistantState() {
    return switch (_view) {
      _View.idle || _View.generated => const SizedBox.shrink(),
      _View.loading => _assistantBubble(
        key: ConversationScreen.loadingKey,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: TrueGroundSpacing.sm),
            Flexible(
              child: Text(
                context.tr(
                  'Processing through TrueGround’s bounded conversation rules.',
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
      _View.boundary => _assistantBubble(
        key: ConversationScreen.boundaryKey,
        child: Text(
          _compactBoundaryMessage(_decision!),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      _View.failClosed => _assistantBubble(
        key: ConversationScreen.failClosedKey,
        child: Text(
          context.tr('Conversation response unavailable'),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    };
  }

  String _compactBoundaryMessage(ConversationDecision decision) {
    if (decision.outcome == ConversationOutcome.privacyBoundary) {
      return context.tr(
        'TrueGround will not reveal hidden instructions or private system data.',
      );
    }
    if (decision.outcome == ConversationOutcome.memoryTruthful) {
      return context.tr(
        'This build does not keep raw chat history here, and TrueGround will not invent one.',
      );
    }
    return switch (decision.reasonCode) {
      ConversationReasonCode.medicationBoundary => context.tr(
        'TrueGround cannot tell you to start, stop, or change medication.',
      ),
      ConversationReasonCode.treatmentBoundary => context.tr(
        'TrueGround cannot create a personalized exposure plan or promise treatment results.',
      ),
      _ => context.tr(
        'TrueGround cannot diagnose OCD or interpret a thought as proof of intent or illness.',
      ),
    };
  }

  Widget _assistantBubble({Key? key, required Widget child}) {
    return Row(
      key: key ?? ConversationScreen.assistantBubbleKey,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: TrueGroundColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.eco_rounded, size: 20, color: Colors.white),
        ),
        const SizedBox(width: TrueGroundSpacing.sm),
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.symmetric(
              horizontal: TrueGroundSpacing.md,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: TrueGroundColors.surface,
              border: Border.all(color: TrueGroundColors.outline),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(6),
              ),
            ),
            child: child,
          ),
        ),
      ],
    );
  }

  Widget _compactComposer() {
    final canSend =
        (_view == _View.idle || _view == _View.generated) &&
        !_compactSessionLimitReached;

    return Container(
      key: ConversationScreen.compactComposerKey,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: const BoxDecoration(
        color: TrueGroundColors.surface,
        border: Border(top: BorderSide(color: TrueGroundColors.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: TextField(
                key: ConversationScreen.inputKey,
                controller: _controller,
                enabled: canSend,
                minLines: 1,
                maxLines: 3,
                textInputAction: TextInputAction.send,
                onChanged: (value) {
                  final next = value.trim().isNotEmpty;
                  if (next != _hasInput) setState(() => _hasInput = next);
                },
                onSubmitted: (_) {
                  if (_hasInput && canSend) _submit();
                },
                decoration: InputDecoration(
                  hintText: context.tr(
                    _compactSessionLimitReached
                        ? 'This conversation is complete for now'
                        : canSend
                        ? 'Write one brief message'
                        : 'This turn is complete',
                  ),
                  filled: true,
                  fillColor: canSend
                      ? TrueGroundColors.background
                      : TrueGroundColors.surfaceMuted,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: TrueGroundSpacing.md,
                    vertical: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: TrueGroundColors.outline,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: TrueGroundColors.outline,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: TrueGroundColors.outline,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: TrueGroundSpacing.sm),
            SizedBox.square(
              dimension: 48,
              child: IconButton.filled(
                key: ConversationScreen.submitKey,
                tooltip: context.tr('Send once'),
                onPressed: canSend && _hasInput ? _submit : null,
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _privacyNotice() {
    return Container(
      padding: const EdgeInsets.all(TrueGroundSpacing.md),
      decoration: BoxDecoration(
        color: TrueGroundColors.surfaceMuted,
        borderRadius: BorderRadius.circular(TrueGroundRadii.control),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.lock_outline_rounded,
            size: 20,
            color: TrueGroundColors.inkMuted,
          ),
          const SizedBox(width: TrueGroundSpacing.sm),
          Expanded(
            child: Text(
              context.tr(
                'Messages are not saved as chat history in this build.',
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    return switch (_view) {
      _View.idle => Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(TrueGroundSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                context.tr('What is on your mind?'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: TrueGroundSpacing.sm),
              TextField(
                key: ConversationScreen.inputKey,
                controller: _controller,
                minLines: 2,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onChanged: (value) {
                  final next = value.trim().isNotEmpty;
                  if (next != _hasInput) setState(() => _hasInput = next);
                },
                onSubmitted: (_) {
                  if (_hasInput) _submit();
                },
                decoration: InputDecoration(
                  labelText: context.tr('Write one brief message'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: TrueGroundSpacing.md),
              FilledButton.icon(
                key: ConversationScreen.submitKey,
                onPressed: _hasInput ? _submit : null,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(context.tr('Send once')),
              ),
            ],
          ),
        ),
      ),
      _View.loading => _panel(
        key: ConversationScreen.loadingKey,
        icon: const SizedBox.square(
          dimension: 28,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
        title: context.tr(
          'Processing through TrueGround’s bounded conversation rules.',
        ),
      ),
      _View.generated => _panel(
        key: ConversationScreen.generatedKey,
        icon: const Icon(Icons.chat_bubble_outline_rounded),
        title: context.tr('Bounded response'),
        body: _response,
        note: context.tr(
          'This response is not a diagnosis, medication instruction, treatment plan, or emergency assessment.',
        ),
        action: context.tr('Return Home'),
        onAction: () => context.go('/'),
      ),
      _View.boundary => _boundaryPanel(_decision!),
      _View.failClosed => _panel(
        key: ConversationScreen.failClosedKey,
        icon: const Icon(Icons.info_outline_rounded),
        title: context.tr('Conversation response unavailable'),
        body: context.tr(
          'No generated response was shown. This screen did not save your message as chat history.',
        ),
        note: context.tr('Choose another route from Home.'),
        action: context.tr('Return Home'),
        onAction: () => context.go('/'),
      ),
    };
  }

  Widget _boundaryPanel(ConversationDecision decision) {
    if (decision.outcome == ConversationOutcome.privacyBoundary) {
      return _panel(
        key: ConversationScreen.boundaryKey,
        icon: const Icon(Icons.lock_outline_rounded),
        title: context.tr('Private system data stays private.'),
        body: context.tr(
          'TrueGround will not reveal hidden instructions or private system data.',
        ),
        note: context.tr('This request stays outside the companion.'),
        action: context.tr('Return Home'),
        onAction: () => context.go('/'),
      );
    }

    if (decision.outcome == ConversationOutcome.memoryTruthful) {
      return _panel(
        key: ConversationScreen.boundaryKey,
        icon: const Icon(Icons.history_toggle_off_rounded),
        title: context.tr('Conversation history is unavailable.'),
        body: context.tr(
          'This build does not keep raw chat history here, and TrueGround will not invent one.',
        ),
        note: context.tr('This request stays outside the companion.'),
        action: context.tr('Return Home'),
        onAction: () => context.go('/'),
      );
    }

    final body = switch (decision.reasonCode) {
      ConversationReasonCode.medicationBoundary => context.tr(
        'TrueGround cannot tell you to start, stop, or change medication.',
      ),
      ConversationReasonCode.treatmentBoundary => context.tr(
        'TrueGround cannot create a personalized exposure plan or promise treatment results.',
      ),
      _ => context.tr(
        'TrueGround cannot diagnose OCD or interpret a thought as proof of intent or illness.',
      ),
    };

    return _panel(
      key: ConversationScreen.boundaryKey,
      icon: const Icon(Icons.health_and_safety_outlined),
      title: context.tr('This request stays outside the companion.'),
      body: body,
      note: context.tr('Choose another route from Home.'),
      action: context.tr('Open Support'),
      onAction: () => context.go('/support'),
    );
  }

  Widget _panel({
    required Key key,
    required Widget icon,
    required String title,
    String? body,
    String? note,
    String? action,
    VoidCallback? onAction,
  }) {
    return Semantics(
      key: key,
      liveRegion: true,
      container: true,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(TrueGroundSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(alignment: Alignment.centerLeft, child: icon),
              const SizedBox(height: TrueGroundSpacing.md),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              if (body != null) ...<Widget>[
                const SizedBox(height: TrueGroundSpacing.sm),
                Text(body, style: Theme.of(context).textTheme.bodyLarge),
              ],
              if (note != null) ...<Widget>[
                const SizedBox(height: TrueGroundSpacing.md),
                Text(note, style: Theme.of(context).textTheme.bodyMedium),
              ],
              if (action != null && onAction != null) ...<Widget>[
                const SizedBox(height: TrueGroundSpacing.lg),
                FilledButton.tonal(onPressed: onAction, child: Text(action)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
