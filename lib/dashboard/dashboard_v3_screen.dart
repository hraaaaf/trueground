import 'dart:ui' show ImageFilter;

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final compactPhone = constraints.maxWidth <= 370;

        return SingleChildScrollView(
          key: screenKey,
          padding: EdgeInsets.fromLTRB(
            compactPhone ? 16 : 18,
            10,
            compactPhone ? 16 : 18,
            14,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const _BrandHeader(),
                  const SizedBox(height: 13),
                  const Text(
                    'Good evening',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 15.5,
                      height: 1.15,
                      color: TrueGroundColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Semantics(
                    header: true,
                    child: Text(
                      'Choose your next move.',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: compactPhone ? 29 : 32,
                        height: 1.02,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.55,
                        color: TrueGroundColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Make room for uncertainty.\nChoose what matters.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.22,
                      color: TrueGroundColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _PrimaryActionCard(
                    compact: compactPhone,
                    onTap: () => context.go('/loop'),
                  ),
                  const SizedBox(height: 10),
                  _PracticeActions(
                    stacked: stackedCards,
                    compact: compactPhone,
                  ),
                  const SizedBox(height: 8),
                  _ValuesActions(stacked: stackedCards, compact: compactPhone),
                  const SizedBox(height: 8),
                  const _ReviewCard(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final usesLargeTextLayout = MediaQuery.textScalerOf(context).scale(1) > 1.4;

    const mark = SizedBox(
      width: 34,
      height: 34,
      child: CustomPaint(painter: _LeafMarkPainter()),
    );
    const wordmark = Text(
      'TrueGround',
      style: TextStyle(
        fontFamily: 'serif',
        fontSize: 26,
        height: 1,
        fontWeight: FontWeight.w600,
        color: TrueGroundColors.primary,
      ),
    );
    const themeIcon = ExcludeSemantics(
      child: Icon(
        Icons.dark_mode_rounded,
        size: 23,
        color: TrueGroundColors.primary,
      ),
    );

    return Semantics(
      container: true,
      label: 'TrueGround',
      excludeSemantics: true,
      child: usesLargeTextLayout
          ? const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                mark,
                SizedBox(width: 6),
                Expanded(child: wordmark),
                SizedBox(width: 8),
                themeIcon,
              ],
            )
          : const SizedBox(
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[mark, SizedBox(width: 6), wordmark],
                  ),
                  Align(alignment: Alignment.centerRight, child: themeIcon),
                ],
              ),
            ),
    );
  }
}

class _PrimaryActionCard extends StatelessWidget {
  const _PrimaryActionCard({required this.compact, required this.onTap});

  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: "I'm stuck in a loop. Notice the urge. Pause before the ritual.",
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: TrueGroundColors.heroBlue.withValues(alpha: 0.26),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: compact ? 126 : 132),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      TrueGroundColors.primary,
                      TrueGroundColors.heroBlue,
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.72),
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: <Widget>[
                    const Positioned.fill(
                      child: CustomPaint(painter: _HeroBackdropPainter()),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                Colors.white.withValues(alpha: 0.16),
                                Colors.white.withValues(alpha: 0.02),
                                Colors.white.withValues(alpha: 0.08),
                              ],
                              stops: const <double>[0, 0.52, 1],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 18,
                      right: 18,
                      child: Container(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.58),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: TrueGroundColors.heroIconBlue.withValues(
                                alpha: 0.94,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 9,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.keyboard_double_arrow_down_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "I'm stuck in a loop",
                                  style: TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 22.5,
                                    height: 1.08,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Notice the urge. Pause before the ritual.',
                                  style: TextStyle(
                                    fontSize: 13.2,
                                    height: 1.22,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          const ExcludeSemantics(
                            child: Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white,
                              size: 26,
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
        ),
      ),
    );
  }
}

class _PracticeActions extends StatelessWidget {
  const _PracticeActions({required this.stacked, required this.compact});

  final bool stacked;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      _MiniActionCard(
        icon: Icons.pause_rounded,
        title: 'Pause the ritual',
        description: 'Create space between the urge and the action.',
        compact: compact,
        onTap: () => context.go('/practice'),
      ),
      _MiniActionCard(
        icon: Icons.eco_outlined,
        title: 'Practice uncertainty',
        description: 'Guided exercises to build tolerance, not certainty.',
        compact: compact,
        onTap: () => context.go('/practice'),
      ),
      _MiniActionCard(
        icon: Icons.bar_chart_rounded,
        title: 'Continue planned practice',
        description: 'Return to your ERP exercises at your pace.',
        compact: compact,
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
      height: compact ? 206 : 196,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _withHorizontalGaps(cards),
      ),
    );
  }
}

class _ValuesActions extends StatelessWidget {
  const _ValuesActions({required this.stacked, required this.compact});

  final bool stacked;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      _DetailCard(
        icon: Icons.explore_outlined,
        title: 'Return to what matters',
        description: 'Work • Family • Rest • Faith • Friends',
        compact: compact,
      ),
      _DetailCard(
        icon: Icons.groups_2_outlined,
        title: 'Need a person, not an answer?',
        description: 'Find support from a therapist or a trusted person.',
        compact: compact,
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
      height: compact ? 154 : 158,
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
    required this.compact,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String description;
  final bool compact;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $description',
      excludeSemantics: true,
      child: _GlassPanel(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            compact ? 11 : 13,
            compact ? 12 : 13,
            compact ? 9 : 11,
            compact ? 10 : 11,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final title = Text(
                this.title,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: compact ? 14.5 : 16.5,
                  height: 1.05,
                  fontWeight: FontWeight.w600,
                  color: TrueGroundColors.primary,
                ),
              );
              final description = Text(
                this.description,
                style: TextStyle(
                  fontSize: compact ? 10.4 : 11.5,
                  height: 1.2,
                  color: TrueGroundColors.inkMuted,
                ),
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _RoundIcon(icon: icon, compact: true),
                  const SizedBox(height: 8),
                  if (constraints.hasBoundedHeight)
                    SizedBox(
                      height: compact ? 50 : 52,
                      child: Align(alignment: Alignment.topLeft, child: title),
                    )
                  else
                    title,
                  const SizedBox(height: 4),
                  if (constraints.hasBoundedHeight)
                    SizedBox(
                      height: compact ? 54 : 48,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: description,
                      ),
                    )
                  else
                    description,
                  if (constraints.hasBoundedHeight)
                    const Spacer()
                  else
                    const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.bottomLeft,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 19,
                      color: TrueGroundColors.inkMuted,
                    ),
                  ),
                ],
              );
            },
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
    required this.compact,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String description;
  final bool compact;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final content = LayoutBuilder(
      builder: (context, constraints) {
        final title = Text(
          this.title,
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: compact ? 14.2 : 16.5,
            height: 1.05,
            fontWeight: FontWeight.w600,
            color: TrueGroundColors.primary,
          ),
        );
        final description = Text(
          this.description,
          style: TextStyle(
            fontSize: compact ? 10.2 : 11.5,
            height: 1.18,
            color: TrueGroundColors.inkMuted,
          ),
        );
        return Padding(
          padding: EdgeInsets.fromLTRB(
            compact ? 11 : 13,
            compact ? 10 : 11,
            compact ? 11 : 13,
            compact ? 10 : 11,
          ),
          child: Column(
            mainAxisAlignment: constraints.hasBoundedHeight
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _RoundIcon(icon: icon, compact: true),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 19,
                    color: TrueGroundColors.inkMuted,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (constraints.hasBoundedHeight)
                SizedBox(
                  height: compact ? 34 : 38,
                  child: Align(alignment: Alignment.topLeft, child: title),
                )
              else
                title,
              const SizedBox(height: 4),
              if (constraints.hasBoundedHeight)
                SizedBox(
                  height: compact ? 40 : 42,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: description,
                  ),
                )
              else
                description,
            ],
          ),
        );
      },
    );
    return Semantics(
      button: onTap != null,
      label: '$title. $description',
      excludeSemantics: true,
      child: _GlassPanel(onTap: onTap, child: content),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard();
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Review patterns when useful. Look at recurring themes, without judgment.',
      excludeSemantics: true,
      child: _GlassPanel(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 68),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: <Widget>[
                _RoundIcon(icon: Icons.bar_chart_rounded, compact: true),
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
                          height: 1.08,
                          fontWeight: FontWeight.w600,
                          color: TrueGroundColors.primary,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Look at recurring themes, without judgment.',
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.16,
                          color: TrueGroundColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: TrueGroundColors.inkMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(20);
    final materialChild = Material(
      type: MaterialType.transparency,
      child: onTap == null ? child : InkWell(onTap: onTap, child: child),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: TrueGroundColors.primary.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 9),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.68),
            blurRadius: 8,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 11, sigmaY: 11),
          child: Stack(
            fit: StackFit.passthrough,
            children: <Widget>[
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        Colors.white.withValues(alpha: 0.56),
                        Colors.white.withValues(alpha: 0.30),
                      ],
                    ),
                    borderRadius: borderRadius,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.98),
                      width: 1.35,
                    ),
                  ),
                ),
              ),
              materialChild,
              Positioned(
                top: 1,
                left: 14,
                right: 14,
                child: IgnorePointer(
                  child: Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, this.compact = false});

  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 42.0 : 46.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.42),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.86),
          width: 1,
        ),
      ),
      child: Icon(icon, size: compact ? 21 : 24, color: TrueGroundColors.teal),
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
