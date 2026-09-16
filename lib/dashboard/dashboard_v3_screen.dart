import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design/app_theme.dart';

class DashboardV3Screen extends StatelessWidget {
  const DashboardV3Screen({super.key});

  static const screenKey = ValueKey('screen-home-dashboard-v3');
  static const practiceGridKey = ValueKey('dashboard-practice-grid');
  static const valuesGridKey = ValueKey('dashboard-values-grid');

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final stackedCards = textScale > 1.4;

    return SingleChildScrollView(
      key: screenKey,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _BrandHeader(),
              const SizedBox(height: 14),
              const Text(
                'Good evening',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 15,
                  height: 1.15,
                  color: TrueGroundColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              const Semantics(
                header: true,
                child: Text(
                  'Choose your next move.',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 31,
                    height: 1.04,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                    color: TrueGroundColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Make room for uncertainty.\nChoose what matters.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.28,
                  color: TrueGroundColors.inkMuted,
                ),
              ),
              const SizedBox(height: 18),
              _PrimaryActionCard(onTap: () => context.go('/loop')),
              const SizedBox(height: 12),
              _PracticeActions(stacked: stackedCards),
              const SizedBox(height: 10),
              _ValuesActions(stacked: stackedCards),
              const SizedBox(height: 10),
              const _ReviewCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'TrueGround',
      excludeSemantics: true,
      child: SizedBox(
        height: 42,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: 35,
                  height: 35,
                  child: CustomPaint(painter: _LeafMarkPainter()),
                ),
                SizedBox(width: 7),
                Text(
                  'TrueGround',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 24,
                    height: 1,
                    fontWeight: FontWeight.w600,
                    color: TrueGroundColors.primary,
                  ),
                ),
              ],
            ),
            const Align(
              alignment: Alignment.centerRight,
              child: ExcludeSemantics(
                child: Icon(
                  Icons.dark_mode_rounded,
                  size: 23,
                  color: TrueGroundColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryActionCard extends StatelessWidget {
  const _PrimaryActionCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: "I'm stuck in a loop. Notice the urge. Pause before the ritual.",
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            height: 124,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  TrueGroundColors.primary,
                  TrueGroundColors.heroBlue,
                ],
              ),
            ),
            child: Stack(
              children: <Widget>[
                const Positioned.fill(
                  child: CustomPaint(painter: _HeroBackdropPainter()),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 58,
                        height: 58,
                        decoration: const BoxDecoration(
                          color: TrueGroundColors.heroIconBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.keyboard_double_arrow_down_rounded,
                          color: Colors.white,
                          size: 31,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "I'm stuck in a loop",
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 22,
                                height: 1.1,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 7),
                            Text(
                              'Notice the urge. Pause before the ritual.',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.25,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const ExcludeSemantics(
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PracticeActions extends StatelessWidget {
  const _PracticeActions({required this.stacked});

  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      _MiniActionCard(
        icon: Icons.pause_rounded,
        title: 'Pause the ritual',
        description: 'Create space between the urge and the action.',
        onTap: () => context.go('/practice'),
      ),
      _MiniActionCard(
        icon: Icons.eco_outlined,
        title: 'Practice uncertainty',
        description: 'Guided exercises to build tolerance, not certainty.',
        onTap: () => context.go('/practice'),
      ),
      _MiniActionCard(
        icon: Icons.bar_chart_rounded,
        title: 'Continue planned practice',
        description: 'Return to your ERP exercises at your pace.',
        onTap: () => context.go('/practice'),
      ),
    ];

    if (stacked) {
      return Column(
        key: DashboardV3Screen.practiceGridKey,
        children: _withVerticalGaps(cards),
      );
    }

    return SizedBox(
      key: DashboardV3Screen.practiceGridKey,
      height: 188,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _withHorizontalGaps(cards),
      ),
    );
  }
}

class _ValuesActions extends StatelessWidget {
  const _ValuesActions({required this.stacked});

  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      const _DetailCard(
        icon: Icons.explore_outlined,
        title: 'Return to what matters',
        description: 'Work • Family • Rest • Faith • Friends',
      ),
      _DetailCard(
        icon: Icons.groups_2_outlined,
        title: 'Need a person, not an answer?',
        description: 'Find support from a therapist or a trusted person.',
        onTap: () => context.go('/support'),
      ),
    ];

    if (stacked) {
      return Column(
        key: DashboardV3Screen.valuesGridKey,
        children: _withVerticalGaps(cards),
      );
    }

    return SizedBox(
      key: DashboardV3Screen.valuesGridKey,
      height: 136,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _withHorizontalGaps(cards),
      ),
    );
  }
}

List<Widget> _withHorizontalGaps(List<Widget> children) {
  final result = <Widget>[];
  for (var index = 0; index < children.length; index += 1) {
    if (index > 0) {
      result.add(const SizedBox(width: 8));
    }
    result.add(Expanded(child: children[index]));
  }
  return result;
}

List<Widget> _withVerticalGaps(List<Widget> children) {
  final result = <Widget>[];
  for (var index = 0; index < children.length; index += 1) {
    if (index > 0) {
      result.add(const SizedBox(height: 8));
    }
    result.add(children[index]);
  }
  return result;
}

class _MiniActionCard extends StatelessWidget {
  const _MiniActionCard({
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
      child: Material(
        color: TrueGroundColors.surface,
        elevation: 1,
        shadowColor: TrueGroundColors.primary.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(13, 12, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _RoundIcon(icon: icon),
                const SizedBox(height: 9),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 16,
                    height: 1.08,
                    fontWeight: FontWeight.w600,
                    color: TrueGroundColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 11.2,
                      height: 1.25,
                      color: TrueGroundColors.inkMuted,
                    ),
                  ),
                ),
                const Align(
                  alignment: Alignment.bottomLeft,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: TrueGroundColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(14, 11, 12, 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _RoundIcon(icon: icon, small: true),
              const Spacer(),
              const Icon(
                Icons.chevron_right_rounded,
                size: 21,
                color: TrueGroundColors.inkMuted,
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 15.5,
              height: 1.08,
              fontWeight: FontWeight.w600,
              color: TrueGroundColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 10.7,
              height: 1.22,
              color: TrueGroundColors.inkMuted,
            ),
          ),
        ],
      ),
    );

    return Semantics(
      button: onTap != null,
      label: '$title. $description',
      excludeSemantics: true,
      child: Material(
        color: TrueGroundColors.surface,
        elevation: 1,
        shadowColor: TrueGroundColors.primary.withValues(alpha: 0.1),
        surfaceTintColor: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: onTap == null ? content : InkWell(onTap: onTap, child: content),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Review patterns when useful. Look at recurring themes, without judgment.',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 68),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: TrueGroundColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: TrueGroundColors.primary.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          children: <Widget>[
            _RoundIcon(icon: Icons.bar_chart_rounded, small: true),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Review patterns when useful',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 15.5,
                      height: 1.1,
                      fontWeight: FontWeight.w600,
                      color: TrueGroundColors.primary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Look at recurring themes, without judgment.',
                    style: TextStyle(
                      fontSize: 10.8,
                      height: 1.2,
                      color: TrueGroundColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: TrueGroundColors.inkMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, this.small = false});

  final IconData icon;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final size = small ? 38.0 : 44.0;
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: TrueGroundColors.iconWash,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: small ? 22 : 24, color: TrueGroundColors.teal),
    );
  }
}

class _LeafMarkPainter extends CustomPainter {
  const _LeafMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final navy = Paint()..color = TrueGroundColors.primary;
    final teal = Paint()..color = TrueGroundColors.teal;

    final left = Path()
      ..moveTo(size.width * 0.48, size.height * 0.82)
      ..cubicTo(
        size.width * 0.10,
        size.height * 0.70,
        size.width * 0.10,
        size.height * 0.25,
        size.width * 0.18,
        size.height * 0.18,
      )
      ..cubicTo(
        size.width * 0.42,
        size.height * 0.20,
        size.width * 0.56,
        size.height * 0.42,
        size.width * 0.48,
        size.height * 0.82,
      )
      ..close();

    final right = Path()
      ..moveTo(size.width * 0.50, size.height * 0.82)
      ..cubicTo(
        size.width * 0.48,
        size.height * 0.42,
        size.width * 0.70,
        size.height * 0.15,
        size.width * 0.90,
        size.height * 0.12,
      )
      ..cubicTo(
        size.width * 0.94,
        size.height * 0.40,
        size.width * 0.78,
        size.height * 0.68,
        size.width * 0.50,
        size.height * 0.82,
      )
      ..close();

    canvas.drawPath(left, teal);
    canvas.drawPath(right, navy);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeroBackdropPainter extends CustomPainter {
  const _HeroBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = Colors.white.withValues(alpha: 0.055);
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final ridge = Path()
      ..moveTo(0, size.height * 0.88)
      ..lineTo(size.width * 0.18, size.height * 0.74)
      ..lineTo(size.width * 0.28, size.height * 0.82)
      ..lineTo(size.width * 0.43, size.height * 0.66)
      ..lineTo(size.width * 0.58, size.height * 0.80)
      ..lineTo(size.width * 0.72, size.height * 0.70)
      ..lineTo(size.width, size.height * 0.84)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(ridge, fill);

    final ridgeLine = Path()
      ..moveTo(0, size.height * 0.88)
      ..lineTo(size.width * 0.18, size.height * 0.74)
      ..lineTo(size.width * 0.28, size.height * 0.82)
      ..lineTo(size.width * 0.43, size.height * 0.66)
      ..lineTo(size.width * 0.58, size.height * 0.80)
      ..lineTo(size.width * 0.72, size.height * 0.70)
      ..lineTo(size.width, size.height * 0.84);
    canvas.drawPath(ridgeLine, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
