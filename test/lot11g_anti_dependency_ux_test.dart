import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:trueground/conversation/conversation_screen.dart';
import 'package:trueground/localization/trueground_locale.dart';

void main() {
  test('LOT11-G companion copy matches bounded multi-turn behavior', () {
    final conversationSource = File(
      'lib/conversation/conversation_screen.dart',
    ).readAsStringSync();
    final dashboardSource = File(
      'lib/dashboard/dashboard_v3_screen.dart',
    ).readAsStringSync();
    final localeSource = File(
      'lib/localization/trueground_locale.dart',
    ).readAsStringSync();

    const stale = <String>[
      'One bounded response, then choose your next move.',
      'TrueGround may respond once',
      'Send once',
    ];
    for (final marker in stale) {
      expect(conversationSource, isNot(contains(marker)), reason: marker);
      expect(dashboardSource, isNot(contains(marker)), reason: marker);
      expect(localeSource, isNot(contains(marker)), reason: marker);
    }

    expect(
      conversationSource,
      contains(
        'Use brief messages. TrueGround can continue a bounded conversation',
      ),
    );
    expect(dashboardSource, contains('One grounded turn at a time.'));
    expect(conversationSource, contains("context.tr('Send')"));
  });

  test('LOT11-G anti-dependency session remains explicitly bounded', () {
    expect(ConversationScreen.compactSessionMaxUserMessages, 12);

    final source = File(
      'lib/conversation/conversation_screen.dart',
    ).readAsStringSync();
    for (final marker in <String>[
      'regenerate',
      'retry response',
      'try another answer',
      'ask again for certainty',
    ]) {
      expect(source.toLowerCase(), isNot(contains(marker)), reason: marker);
    }
  });

  test('LOT11-G updated companion copy has direct French coverage', () {
    const english =
        'Use brief messages. TrueGround can continue a bounded conversation or route you to an existing tool. It will not provide certainty, diagnosis, medication changes, or emergency assessment.';
    expect(
      translateTrueGround(TrueGroundLanguage.fr, english),
      'Écrivez des messages brefs. TrueGround peut poursuivre une conversation encadrée ou vous orienter vers un outil existant. Il ne donne ni certitude, ni diagnostic, ni conseil médicamenteux, ni évaluation d’urgence.',
    );
    expect(
      translateTrueGround(
        TrueGroundLanguage.fr,
        'One grounded turn at a time.',
      ),
      'Un tour concret à la fois.',
    );
    expect(translateTrueGround(TrueGroundLanguage.fr, 'Send'), 'Envoyer');
  });
}
