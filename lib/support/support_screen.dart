import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design/app_theme.dart';

enum _SupportStep { menu, trustedPerson, careTeam, localProfessional }

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  static const screenKey = ValueKey('screen-support');
  static const menuKey = ValueKey('support-menu');
  static const trustedPersonKey = ValueKey('support-trusted-person');
  static const careTeamKey = ValueKey('support-care-team');
  static const localProfessionalKey = ValueKey('support-local-professional');

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  _SupportStep _step = _SupportStep.menu;

  void _open(_SupportStep step) {
    setState(() {
      _step = step;
    });
  }

  void _backToMenu() {
    setState(() {
      _step = _SupportStep.menu;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: SupportScreen.screenKey,
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
                  'Need a person, not an answer?',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: TrueGroundSpacing.sm),
              Text(
                'Choose a real-world route. TrueGround does not place calls, '
                'send messages, or notify anyone from this screen.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: TrueGroundSpacing.lg),
              if (_step == _SupportStep.menu)
                _SupportMenu(onOpen: _open)
              else if (_step == _SupportStep.trustedPerson)
                _TrustedPersonStep(onBack: _backToMenu)
              else if (_step == _SupportStep.careTeam)
                _CareTeamStep(onBack: _backToMenu)
              else
                _LocalProfessionalStep(onBack: _backToMenu),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportMenu extends StatelessWidget {
  const _SupportMenu({required this.onOpen});

  final ValueChanged<_SupportStep> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: SupportScreen.menuKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SupportChoiceCard(
          icon: Icons.people_outline_rounded,
          title: 'Someone I trust',
          description:
              'Choose a friend, family member, partner, community member, or '
              'another person you already know.',
          onTap: () => onOpen(_SupportStep.trustedPerson),
        ),
        const SizedBox(height: TrueGroundSpacing.sm),
        _SupportChoiceCard(
          icon: Icons.health_and_safety_outlined,
          title: 'My therapist or care team',
          description: 'Use the contact route you already have.',
          onTap: () => onOpen(_SupportStep.careTeam),
        ),
        const SizedBox(height: TrueGroundSpacing.sm),
        _SupportChoiceCard(
          icon: Icons.local_hospital_outlined,
          title: 'Find professional support outside TrueGround',
          description:
              'Use a verified local health service or professional directory.',
          onTap: () => onOpen(_SupportStep.localProfessional),
        ),
      ],
    );
  }
}

class _TrustedPersonStep extends StatelessWidget {
  const _TrustedPersonStep({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return _SupportDetail(
      key: SupportScreen.trustedPersonKey,
      title: 'Reach someone you trust',
      paragraphs: const <String>[
        'Choose the person yourself and use the phone or messaging route you '
            'normally use. TrueGround has not contacted them.',
        'Ask for company or practical support rather than repeated certainty '
            'about the obsession. A trusted person does not need to solve the '
            'uncertainty for you.',
      ],
      onBack: onBack,
    );
  }
}

class _CareTeamStep extends StatelessWidget {
  const _CareTeamStep({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return _SupportDetail(
      key: SupportScreen.careTeamKey,
      title: 'Use your existing care route',
      paragraphs: const <String>[
        'Use the contact route you already have with your therapist, clinician, '
            'clinic, or care team.',
        'TrueGround does not store a therapist or care-team contact in this '
            'build and has not contacted anyone.',
      ],
      onBack: onBack,
    );
  }
}

class _LocalProfessionalStep extends StatelessWidget {
  const _LocalProfessionalStep({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return _SupportDetail(
      key: SupportScreen.localProfessionalKey,
      title: 'Use a verified local source',
      paragraphs: const <String>[
        'Look outside TrueGround for a verified local health service or '
            'professional directory.',
        'TrueGround does not currently provide a local directory. Use a health '
            'service or professional directory you can verify outside the app.',
      ],
      onBack: onBack,
    );
  }
}

class _SupportDetail extends StatelessWidget {
  const _SupportDetail({
    required this.title,
    required this.paragraphs,
    required this.onBack,
    super.key,
  });

  final String title;
  final List<String> paragraphs;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: TrueGroundSpacing.md),
        for (final paragraph in paragraphs) ...<Widget>[
          Text(paragraph, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: TrueGroundSpacing.md),
        ],
        OutlinedButton(
          onPressed: onBack,
          child: const Text('Back to support choices'),
        ),
        const SizedBox(height: TrueGroundSpacing.sm),
        TextButton(
          onPressed: () => context.go('/'),
          child: const Text('Back to Home'),
        ),
      ],
    );
  }
}

class _SupportChoiceCard extends StatelessWidget {
  const _SupportChoiceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $description',
      excludeSemantics: true,
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(TrueGroundRadii.card),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(TrueGroundSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(icon, color: TrueGroundColors.primary),
                const SizedBox(width: TrueGroundSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: TrueGroundSpacing.xs),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
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
