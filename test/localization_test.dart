import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trueground/dashboard/dashboard_v3_screen.dart';
import 'package:trueground/localization/trueground_locale.dart';
import 'package:trueground/loop/loop_flow_policy.dart';
import 'package:trueground/patterns/pattern_memory_store.dart';
import 'package:trueground/safety/urgent_support_screen.dart';

void main() {
  group('TrueGround EN/FR localization', () {
    test('English remains the deterministic fallback', () {
      expect(
        translateTrueGround(
          TrueGroundLanguage.en,
          'Need a person, not an answer?',
        ),
        'Need a person, not an answer?',
      );
      expect(
        translateTrueGround(TrueGroundLanguage.fr, 'unknown-copy-key'),
        'unknown-copy-key',
      );
    });

    test('all canonical Loop policy copy has explicit French coverage', () {
      for (final english in allLoopPolicyCopy) {
        expect(
          translateTrueGround(TrueGroundLanguage.fr, english),
          isNot(equals(english)),
          reason: english,
        );
      }
    });

    test('all Pattern Memory user labels have explicit French coverage', () {
      for (final kind in PatternEventKind.values) {
        expect(
          translateTrueGround(TrueGroundLanguage.fr, kind.userLabel),
          isNot(equals(kind.userLabel)),
          reason: kind.userLabel,
        );
      }
    });

    test('French intrusive-thought wording preserves intent/diagnosis boundary', () {
      expect(
        translateTrueGround(
          TrueGroundLanguage.fr,
          'This tool will not infer intent or make a diagnosis from an intrusive thought or image.',
        ),
        'Cet outil ne déduira pas une intention et ne posera pas de diagnostic à partir d’une pensée ou d’une image intrusive.',
      );
    });

    test('French urgent wording does not claim dispatch or risk assessment', () {
      expect(
        translateTrueGround(
          TrueGroundLanguage.fr,
          'TrueGround cannot determine whether this is an emergency or assess your immediate safety.',
        ),
        'TrueGround ne peut pas déterminer s’il s’agit d’une urgence ni évaluer votre sécurité immédiate.',
      );
      expect(
        translateTrueGround(
          TrueGroundLanguage.fr,
          'TrueGround has not contacted anyone or dispatched help for you.',
        ),
        'TrueGround n’a contacté personne et n’a envoyé aucune aide pour vous.',
      );
    });

    testWidgets('French urgent support renders translated safety copy', (
      tester,
    ) async {
      await tester.pumpWidget(
        TrueGroundLocaleScope(
          language: TrueGroundLanguage.fr,
          onLanguageChanged: (_) {},
          child: const MaterialApp(home: UrgentSupportScreen()),
        ),
      );

      expect(find.text('Utilisez une aide urgente dans le monde réel'), findsOneWidget);
      expect(
        find.text(
          'TrueGround ne peut pas déterminer s’il s’agit d’une urgence ni évaluer votre sécurité immédiate.',
        ),
        findsOneWidget,
      );
      expect(find.text('Use urgent real-world help'), findsNothing);
    });

    testWidgets('French dashboard uses flexible layout at 390 px', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        TrueGroundLocaleScope(
          language: TrueGroundLanguage.fr,
          onLanguageChanged: (_) {},
          child: const MaterialApp(home: DashboardV3Screen()),
        ),
      );

      expect(find.text('Choisissez votre prochaine action.'), findsOneWidget);
      expect(find.text('Mettre le rituel en pause'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
