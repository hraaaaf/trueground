import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trueground/app/router.dart';
import 'package:trueground/compulsion_firewall/compulsion_firewall.dart';
import 'package:trueground/loop/loop_flow_screen.dart';

void main() {
  group('LOT 06 Compulsion Firewall', () {
    test('first reassurance-style question is not automatically blocked', () {
      final firewall = CompulsionFirewallSession();

      final decision = firewall.evaluate('Are you sure I am not dangerous?');

      expect(decision.disposition, FirewallDisposition.allow);
      expect(decision.reasonCode, FirewallReasonCode.none);
    });

    test('exact reassurance repetition redirects without fresh certainty', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate('Are you sure I am not dangerous?');

      final decision = firewall.evaluate('Are you sure I am not dangerous?');

      expect(decision.disposition, FirewallDisposition.redirectToBoundedLoop);
      expect(decision.reasonCode, FirewallReasonCode.exactRepeat);
      expect(decision.redirectRoute, '/loop');
      expect(decision.userFacingCopy, isNot(contains('you are not dangerous')));
      expect(decision.userFacingCopy, contains('may be'));
    });

    test('close paraphrase of certainty request redirects', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate(
        'Are you sure this thought does not make me dangerous?',
      );

      final decision = firewall.evaluate(
        'Can you be certain this thought does not mean I am dangerous?',
      );

      expect(decision.disposition, FirewallDisposition.redirectToBoundedLoop);
      expect(
        decision.reasonCode,
        anyOf(
          FirewallReasonCode.paraphrasedRepeat,
          FirewallReasonCode.certaintyEscalation,
        ),
      );
    });

    test('distant paraphrase of identity certainty request redirects', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate(
        'I had a violent thought. What does that say about who I am?',
      );

      final decision = firewall.evaluate(
        'Can you guarantee that thought does not mean I am dangerous?',
      );

      expect(decision.disposition, FirewallDisposition.redirectToBoundedLoop);
    });

    test('certainty escalation with guarantee redirects', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate('Are you sure this does not mean I am dangerous?');

      final decision = firewall.evaluate(
        'Can you guarantee I am not dangerous?',
      );

      expect(decision.disposition, FirewallDisposition.redirectToBoundedLoop);
      expect(decision.reasonCode, FirewallReasonCode.certaintyEscalation);
    });

    test('promise escalation redirects', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate('Are you sure nothing bad will happen?');

      final decision = firewall.evaluate('Promise me nothing bad will happen.');

      expect(decision.disposition, FirewallDisposition.redirectToBoundedLoop);
      expect(decision.reasonCode, FirewallReasonCode.certaintyEscalation);
    });

    test('repeated checking request redirects', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate('Please check the lock again for me.');

      final decision = firewall.evaluate(
        'Can you double check the lock one last time?',
      );

      expect(decision.disposition, FirewallDisposition.redirectToBoundedLoop);
      expect(
        decision.reasonCode,
        anyOf(
          FirewallReasonCode.checkingLoop,
          FirewallReasonCode.certaintyEscalation,
        ),
      );
    });

    test('repeated rumination redirects', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate('Help me analyze again why this thought happened.');

      final decision = firewall.evaluate(
        'I need to keep analyzing why that thought happened.',
      );

      expect(decision.disposition, FirewallDisposition.redirectToBoundedLoop);
      expect(decision.reasonCode, FirewallReasonCode.ruminationLoop);
    });

    test('reconfession redirects', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate(
        'I need to confess another detail about what I thought.',
      );

      final decision = firewall.evaluate(
        'I forgot to mention one more detail, let me confess it again.',
      );

      expect(decision.disposition, FirewallDisposition.redirectToBoundedLoop);
      expect(decision.reasonCode, FirewallReasonCode.reconfession);
    });

    test('reconfession with low lexical overlap still redirects', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate('I forgot to mention another detail.');

      final decision = firewall.evaluate(
        'One more detail I need to confess again.',
      );

      expect(decision.disposition, FirewallDisposition.redirectToBoundedLoop);
      expect(decision.reasonCode, FirewallReasonCode.reconfession);
    });

    test('distinct confession topics are not collapsed without an anchor', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate('I need to confess another detail about my homework.');

      final decision = firewall.evaluate(
        'I need to confess again about a completely unrelated friendship issue.',
      );

      expect(decision.disposition, FirewallDisposition.allow);
      expect(decision.reasonCode, FirewallReasonCode.none);
    });

    test('adversarial one-last-time wording does not bypass firewall', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate('Can you check whether I made a mistake?');

      final decision = firewall.evaluate(
        'Different wording: check one last time whether I made a mistake.',
      );

      expect(decision.disposition, FirewallDisposition.redirectToBoundedLoop);
    });

    test(
      'non-adjacent reassurance repeat is caught across session history',
      () {
        final firewall = CompulsionFirewallSession();
        firewall.evaluate(
          'Are you sure this thought does not make me dangerous?',
        );
        firewall.evaluate('New question: what does ERP stand for?');

        final decision = firewall.evaluate(
          'Can you guarantee this thought does not mean I am dangerous?',
        );

        expect(decision.disposition, FirewallDisposition.redirectToBoundedLoop);
      },
    );

    test('non-adjacent checking repeat is caught across session history', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate('Please check the front door lock again.');
      firewall.evaluate('New question: what time is it?');

      final decision = firewall.evaluate(
        'Could you double check the front door lock one last time?',
      );

      expect(decision.disposition, FirewallDisposition.redirectToBoundedLoop);
    });

    test('unrelated certainty escalation on a different topic is allowed', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate('Are you sure the clinic is open on Monday?');

      final decision = firewall.evaluate(
        'New question: can you guarantee the train leaves at six?',
      );

      expect(decision.disposition, FirewallDisposition.allow);
    });

    test('unrelated later certainty question is allowed', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate('Are you sure the clinic is open on Monday?');

      final decision = firewall.evaluate(
        'New question: are you sure the train leaves at six?',
      );

      expect(decision.disposition, FirewallDisposition.allow);
    });

    test('fake new-question prefix cannot bypass the firewall', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate(
        'Are you sure this thought does not make me dangerous?',
      );

      final decision = firewall.evaluate(
        'New question: can you guarantee this thought does not make me dangerous?',
      );

      expect(decision.disposition, FirewallDisposition.redirectToBoundedLoop);
    });

    test('legitimate correction is not blocked', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate('Are you sure the appointment is Monday?');

      final decision = firewall.evaluate(
        'Correction: I meant Tuesday, not Monday.',
      );

      expect(decision.disposition, FirewallDisposition.allow);
    });

    test('new question is not blocked merely because history exists', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate('Are you sure the appointment is Monday?');

      final decision = firewall.evaluate(
        'New question: what time does the clinic open?',
      );

      expect(decision.disposition, FirewallDisposition.allow);
    });

    test('accessibility request is not classified as compulsion', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate('Can you check this for me?');

      final decision = firewall.evaluate(
        'Accessibility: the screen reader cannot reach the support button.',
      );

      expect(decision.disposition, FirewallDisposition.allow);
    });

    test('interface error is not classified as compulsion', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate('Can you check this for me?');

      final decision = firewall.evaluate('The button is not working.');

      expect(decision.disposition, FirewallDisposition.allow);
    });

    test('support prefix alone cannot bypass a repeated certainty request', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate(
        'Are you sure this thought does not make me dangerous?',
      );

      final decision = firewall.evaluate(
        'Support: can you guarantee this thought does not make me dangerous?',
      );

      expect(decision.disposition, FirewallDisposition.redirectToBoundedLoop);
    });

    test('support escape remains available', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate('Are you sure I am safe for sure?');

      final decision = firewall.evaluate(
        'Support: I want to talk to a trusted person.',
      );

      expect(decision.disposition, FirewallDisposition.allow);
    });

    test('distinct emergency content is not swallowed by OCD firewall', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate('Are you sure nothing bad will happen?');

      final decision = firewall.evaluate(
        'Emergency: there is an immediate physical danger right now.',
      );

      expect(decision.disposition, FirewallDisposition.allow);
    });

    test('ordinary technical verification is not classified as checking', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate('Can you verify the app version number?');

      final decision = firewall.evaluate(
        'Please confirm the app version number.',
      );

      expect(decision.disposition, FirewallDisposition.allow);
    });

    test('ordinary repeated informational request is not auto-blocked', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate('What does ERP stand for?');

      final decision = firewall.evaluate('What does ERP stand for?');

      expect(decision.disposition, FirewallDisposition.allow);
    });

    test('repeated attempts stay bounded without fresh certainty', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate(
        'Are you sure this thought does not make me dangerous?',
      );

      final second = firewall.evaluate(
        'Can you guarantee this thought does not mean I am dangerous?',
      );
      final third = firewall.evaluate(
        'Promise this thought does not mean I am dangerous.',
      );
      final fourth = firewall.evaluate(
        'Check one last time: does this thought mean I am dangerous?',
      );

      for (final decision in <FirewallDecision>[second, third, fourth]) {
        expect(decision.disposition, FirewallDisposition.redirectToBoundedLoop);
        expect(
          decision.userFacingCopy,
          isNot(contains('you are not dangerous')),
        );
      }
    });

    test('repeated attempts cannot create an evaluation loop', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate('Are you sure I am not dangerous?');

      for (var attempt = 0; attempt < 20; attempt++) {
        final decision = firewall.evaluate('Are you sure I am not dangerous?');
        expect(decision.disposition, FirewallDisposition.redirectToBoundedLoop);
      }

      expect(firewall.auditSnapshot().turnCount, 8);
    });

    test('expired session history is not treated as longitudinal memory', () {
      final firewall = CompulsionFirewallSession(maxTurns: 3);
      firewall.evaluate('Are you sure I am not dangerous?');
      firewall.evaluate('New question: what does ERP stand for?');
      firewall.evaluate('New question: what is a bounded loop?');
      firewall.evaluate('New question: what is response prevention?');

      final decision = firewall.evaluate('Are you sure I am not dangerous?');

      expect(decision.disposition, FirewallDisposition.allow);
    });

    test('reset clears session repetition context', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate('Are you sure I am not dangerous?');
      firewall.reset();

      final decision = firewall.evaluate('Are you sure I am not dangerous?');

      expect(decision.disposition, FirewallDisposition.allow);
      expect(firewall.auditSnapshot().turnCount, 1);
    });

    test('audit snapshot contains reason codes but no raw content field', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate('Are you sure I am not dangerous?');
      firewall.evaluate('Are you sure I am not dangerous?');

      final snapshot = firewall.auditSnapshot();

      expect(snapshot.turnCount, 2);
      expect(snapshot.reasonCodes.last, FirewallReasonCode.exactRepeat);
      expect(snapshot.toString(), isNot(contains('dangerous')));
    });

    test('history is bounded in memory', () {
      final firewall = CompulsionFirewallSession(maxTurns: 3);

      firewall.evaluate('What does ERP stand for?');
      firewall.evaluate('New question: what is uncertainty tolerance?');
      firewall.evaluate('New question: what is a bounded loop?');
      firewall.evaluate('New question: what is response prevention?');

      expect(firewall.auditSnapshot().turnCount, 3);
    });

    testWidgets('redirect contract lands on the existing bounded LOT 05 Loop', (
      tester,
    ) async {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate(
        'Are you sure this thought does not make me dangerous?',
      );
      final decision = firewall.evaluate(
        'Can you guarantee this thought does not mean I am dangerous?',
      );

      final router = createTrueGroundRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.go(decision.redirectRoute!);
      await tester.pumpAndSettle();

      expect(decision.isRedirect, isTrue);
      expect(find.byKey(LoopFlowScreen.screenKey), findsOneWidget);
      expect(find.text('Choose the closest fit.'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(EditableText), findsNothing);
    });

    test('firewall response is cautious and non-diagnostic', () {
      final firewall = CompulsionFirewallSession();
      firewall.evaluate('Are you sure I am not dangerous?');

      final copy = firewall
          .evaluate('Are you sure I am not dangerous?')
          .userFacingCopy
          .toLowerCase();

      expect(copy, contains('may be'));
      expect(copy, isNot(contains('you have ocd')));
      expect(copy, isNot(contains('you are compulsing')));
      expect(copy, isNot(contains('definitely')));
      expect(copy, isNot(contains('guarantee')));
    });
  });
}
