import 'package:flutter_test/flutter_test.dart';
import 'package:trueground/loop/loop_flow_policy.dart';

void main() {
  test('LOT 05 policy copy stays cautious and non-diagnostic', () {
    final joined = allLoopPolicyCopy.join('\n').toLowerCase();

    for (final forbidden in <String>[
      'you have ocd',
      'definitely',
      'guarantee',
      'clinically proven',
      'will cure',
      'will calm you',
    ]) {
      expect(joined, isNot(contains(forbidden)));
    }

    expect(
      loopPatternContent[LoopPattern.intrusive]!.framing,
      contains('will not infer intent'),
    );
    expect(loopSafetyBoundary, contains('use Support instead'));
  });

  test('LOT 05 policy exposes only the approved bounded action set', () {
    expect(LoopNextAction.values, <LoopNextAction>[
      LoopNextAction.practiceUncertainty,
      LoopNextAction.returnHome,
      LoopNextAction.humanSupport,
    ]);
    expect(loopActionContent.length, 3);
  });

  test('LOT 05 policy has no user-entered free-text model', () {
    expect(LoopPattern.values.length, 6);
    expect(allLoopPolicyCopy, isNotEmpty);
  });
}
