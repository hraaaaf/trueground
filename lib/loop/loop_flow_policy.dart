import 'package:flutter/foundation.dart';

enum LoopPattern {
  certainty,
  checking,
  rumination,
  repetition,
  intrusive,
  other,
}

@immutable
class LoopPatternContent {
  const LoopPatternContent({
    required this.title,
    required this.helper,
    required this.framing,
  });

  final String title;
  final String helper;
  final String framing;
}

const Map<LoopPattern, LoopPatternContent>
loopPatternContent = <LoopPattern, LoopPatternContent>{
  LoopPattern.certainty: LoopPatternContent(
    title: 'I want certainty',
    helper: 'I keep wanting a definite answer.',
    framing:
        'This may be a certainty-seeking loop. This tool will not settle the question for you.',
  ),
  LoopPattern.checking: LoopPatternContent(
    title: 'I want to check',
    helper: 'I feel pulled to verify again.',
    framing:
        'This may be a checking loop. This tool will not verify the answer for you.',
  ),
  LoopPattern.rumination: LoopPatternContent(
    title: "I'm stuck analyzing",
    helper: 'I keep trying to solve it mentally.',
    framing:
        'This may be a rumination loop. More analysis is not the goal of this check-in.',
  ),
  LoopPattern.repetition: LoopPatternContent(
    title: "I'm repeating or confessing",
    helper: 'I feel pulled to say or ask it again.',
    framing:
        'This may be a repetition loop. You do not need to repeat the details here.',
  ),
  LoopPattern.intrusive: LoopPatternContent(
    title: 'An intrusive thought or image',
    helper: 'It feels urgent or meaningful.',
    framing:
        'This tool will not infer intent or make a diagnosis from an intrusive thought or image.',
  ),
  LoopPattern.other: LoopPatternContent(
    title: 'Something else',
    helper: 'I still want a bounded next step.',
    framing:
        'We do not need to label the pattern precisely to choose a bounded next step.',
  ),
};

enum LoopNextAction { practiceUncertainty, returnHome, humanSupport }

@immutable
class LoopActionContent {
  const LoopActionContent({
    required this.title,
    required this.helper,
    required this.continueLabel,
  });

  final String title;
  final String helper;
  final String continueLabel;
}

const Map<LoopNextAction, LoopActionContent>
loopActionContent = <LoopNextAction, LoopActionContent>{
  LoopNextAction.practiceUncertainty: LoopActionContent(
    title: 'Practice uncertainty',
    helper:
        'Leave the question unresolved for now and move to the Practice area.',
    continueLabel: 'Continue to Practice',
  ),
  LoopNextAction.returnHome: LoopActionContent(
    title: 'End this check-in',
    helper: 'Return Home and put attention back on your day.',
    continueLabel: 'Return Home',
  ),
  LoopNextAction.humanSupport: LoopActionContent(
    title: 'Need a person, not an answer?',
    helper: 'Open Support. The app will not claim that anyone was contacted.',
    continueLabel: 'Open Support',
  ),
};

const String loopSafetyBoundary =
    'This short tool is for loops and urges. If you may be in immediate danger or unable to stay safe, use Support instead.';

const String loopBoundedNotice =
    'This is a bounded check-in, not an open chat. Choose the closest fit. No need to explain every detail.';

const String loopCompletionCopy =
    'Your next move is set. You can end this check-in here instead of reopening the question.';

Iterable<String> get allLoopPolicyCopy sync* {
  yield loopSafetyBoundary;
  yield loopBoundedNotice;
  yield loopCompletionCopy;
  for (final item in loopPatternContent.values) {
    yield item.title;
    yield item.helper;
    yield item.framing;
  }
  for (final item in loopActionContent.values) {
    yield item.title;
    yield item.helper;
    yield item.continueLabel;
  }
}
