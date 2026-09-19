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
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.4;
    return largeText ? const _AccessibleDashboard() : const _TargetDashboard();
  }
}

class _TargetDashboard extends StatelessWidget {
  const _TargetDashboard();

  static const double _designWidth = 390;
  static const double _designHeight = 760;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: SizedBox(
            height: constraints.maxHeight,
            child: Center(
              child: FittedBox(
                alignment: Alignment.topCenter,
                fit: BoxFit.contain,
                child: SizedBox(
                  key: DashboardV3Screen.screenKey,
                  width: _designWidth,
                  height: _designHeight,
                  child: Stack(
                    children: <Widget>[
                      const Positioned(
                        left: 19,
                        right: 19,
                        top: 10,
                        height: 38,
                        child: _BrandHeader(),
                      ),
                      const Positioned(
                        left: 20,
                        top: 58,
                        child: Text(
                          'Good evening',
                          style: TextStyle(
                            fontSize: 14.2,
                            height: 1,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.15,
                            color: TrueGroundColors.inkMuted,
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 19,
                        right: 19,
                        top: 78,
                        child: Text(
                          'Choose your next move.',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 28.5,
                            height: 1,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.65,
                            color: TrueGroundColors.primary,
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 20,
                        right: 19,
                        top: 112,
                        child: Text(
                          'Make room for uncertainty.\nChoose what matters.',
                          style: TextStyle(
                            fontSize: 15.6,
                            height: 1.25,
                            fontWeight: FontWeight.w400,
                            color: TrueGroundColors.inkMuted,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 19,
                        right: 19,
                        top: 150,
                        height: 102,
                        child: _HeroCard(onTap: () => context.go('/loop')),
                      ),
                      Positioned(
                        key: DashboardV3Screen.practiceGridKey,
                        left: 19,
                        right: 19,
                        top: 280,
                        height: 166,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Expanded(
                              child: _TargetCard(
                                icon: Icons.pause_rounded,
                                title: 'Pause the ritual',
                                description:
                                    'Create space\nbetween urge\nand action.',
                                accent: const Color(0xFF48AAB5),
                                onTap: () => context.go('/practice'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _TargetCard(
                                icon: Icons.eco_outlined,
                                title: 'Practice uncertainty',
                                description: 'Build tolerance,\nnot certainty.',
                                accent: const Color(0xFF56AFC4),
                                onTap: () => context.go('/practice'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _TargetCard(
                                icon: Icons.bar_chart_rounded,
                                title: 'Continue planned practice',
                                description:
                                    'Return to planned\npractice at your\npace.',
                                accent: const Color(0xFF4F9FC4),
                                onTap: () => context.go('/practice'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        key: DashboardV3Screen.valuesGridKey,
                        left: 19,
                        right: 19,
                        top: 478,
                        height: 119,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const Expanded(
                              child: _WideCard(
                                icon: Icons.explore_outlined,
                                title: 'Return to what matters',
                                description:
                                    'Work • Family • Rest\nFaith • Friends',
                                accent: Color(0xFF6AAFA5),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _WideCard(
                                icon: Icons.groups_2_outlined,
                                title: 'Need a person, not an answer?',
                                description: 'Therapist or trusted\nperson.',
                                accent: const Color(0xFF77A7C1),
                                onTap: () => context.go('/support'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Positioned(
                        left: 19,
                        right: 19,
                        top: 629,
                        height: 61,
                        child: _ReviewCard(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AccessibleDashboard extends StatelessWidget {
  const _AccessibleDashboard();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: DashboardV3Screen.screenKey,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _BrandHeader(),
          const SizedBox(height: 16),
          const Text(
            'Good evening',
            style: TextStyle(color: TrueGroundColors.inkMuted),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose your next move.',
            style: TextStyle(
              fontSize: 28,
              height: 1.05,
              fontWeight: FontWeight.w700,
              color: TrueGroundColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Make room for uncertainty.\nChoose what matters.',
            style: TextStyle(
              fontSize: 16,
              height: 1.3,
              color: TrueGroundColors.inkMuted,
            ),
          ),
          const SizedBox(height: 16),
          _HeroCard(onTap: () => context.go('/loop')),
          const SizedBox(height: 10),
          Column(
            key: DashboardV3Screen.practiceGridKey,
            children: <Widget>[
              _AccessibleCard(
                icon: Icons.pause_rounded,
                title: 'Pause the ritual',
                description: 'Create space between the urge and the action.',
                onTap: () => context.go('/practice'),
              ),
              const SizedBox(height: 8),
              _AccessibleCard(
                icon: Icons.eco_outlined,
                title: 'Practice uncertainty',
                description:
                    'Guided exercises to build tolerance, not certainty.',
                onTap: () => context.go('/practice'),
              ),
              const SizedBox(height: 8),
              _AccessibleCard(
                icon: Icons.bar_chart_rounded,
                title: 'Continue planned practice',
                description: 'Return to your planned practice at your pace.',
                onTap: () => context.go('/practice'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            key: DashboardV3Screen.valuesGridKey,
            children: <Widget>[
              const _AccessibleCard(
                icon: Icons.explore_outlined,
                title: 'Return to what matters',
                description: 'Work • Family • Rest • Faith • Friends',
              ),
              const SizedBox(height: 8),
              _AccessibleCard(
                icon: Icons.groups_2_outlined,
                title: 'Need a person, not an answer?',
                description:
                    'Find support from a therapist or a trusted person.',
                onTap: () => context.go('/support'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const _ReviewCard(),
        ],
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
        height: 38,
        child: Stack(
          alignment: Alignment.center,
          children: const <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CustomPaint(painter: _LeafMarkPainter()),
                ),
                SizedBox(width: 7),
                Text(
                  'TrueGround',
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    fontSize: 25.5,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: TrueGroundColors.primary,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ExcludeSemantics(
                child: Icon(
                  Icons.dark_mode_rounded,
                  size: 21,
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

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: "I'm stuck in a loop. Notice the urge. Pause before the ritual.",
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF159DCD).withValues(alpha: 0.30),
              blurRadius: 26,
              spreadRadius: -5,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: const Color(0xFF0A3F79).withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(19),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(19),
                border: Border.all(
                  color: const Color(0xFF86E0FF).withValues(alpha: 0.95),
                  width: 1.25,
                ),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[
                    Color(0xFF073F79),
                    Color(0xFF12639C),
                    Color(0xFF2EA4D7),
                  ],
                  stops: <double>[0, 0.52, 1],
                ),
              ),
              child: Stack(
                children: <Widget>[
                  const Positioned.fill(
                    child: CustomPaint(painter: _HeroBackdropPainter()),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: <Color>[
                            Colors.white.withValues(alpha: 0.24),
                            Colors.white.withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                          stops: const <double>[0, 0.30, 0.70],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -42,
                    right: -8,
                    child: IgnorePointer(
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(
                              0xFFA6ECFF,
                            ).withValues(alpha: 0.16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                Color(0xFF36ACE8),
                                Color(0xFF1687D2),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.14),
                                blurRadius: 11,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.keyboard_double_arrow_down_rounded,
                            color: Colors.white,
                            size: 27,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "I'm stuck in a loop",
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 19,
                                  height: 1,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.25,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Notice the urge. Pause before the ritual.',
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: 11.3,
                                  height: 1.2,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
                          size: 24,
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
    );
  }
}

class _TargetCard extends StatelessWidget {
  const _TargetCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label:
          '${title.replaceAll('\n', ' ')}. ${description.replaceAll('\n', ' ')}',
      excludeSemantics: true,
      child: _GlassPanel(
        accent: accent,
        onTap: onTap,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 12,
              top: 10,
              child: _RoundIcon(icon: icon, size: 36, accent: accent),
            ),
            Positioned(
              left: 12,
              right: 10,
              top: 55,
              height: 43,
              child: Text(
                title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.8,
                  height: 1.04,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.22,
                  color: TrueGroundColors.primary,
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 8,
              top: 102,
              height: 40,
              child: Text(
                description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.6,
                  height: 1.18,
                  fontWeight: FontWeight.w500,
                  color: TrueGroundColors.inkMuted,
                ),
              ),
            ),
            const Positioned(
              left: 10,
              bottom: 8,
              child: Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: TrueGroundColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WideCard extends StatelessWidget {
  const _WideCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label:
          '${title.replaceAll('\n', ' ')}. ${description.replaceAll('\n', ' ')}',
      excludeSemantics: true,
      child: _GlassPanel(
        accent: accent,
        onTap: onTap,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 12,
              top: 10,
              child: _RoundIcon(icon: icon, size: 35, accent: accent),
            ),
            const Positioned(
              right: 10,
              top: 15,
              child: Icon(
                Icons.chevron_right_rounded,
                size: 19,
                color: TrueGroundColors.inkMuted,
              ),
            ),
            Positioned(
              left: 12,
              right: 10,
              top: 52,
              height: 30,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.4,
                  height: 1.04,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.18,
                  color: TrueGroundColors.primary,
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 10,
              top: 84,
              height: 28,
              child: Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.2,
                  height: 1.16,
                  fontWeight: FontWeight.w500,
                  color: TrueGroundColors.inkMuted,
                ),
              ),
            ),
          ],
        ),
      ),
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
        accent: const Color(0xFF62A8B8),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: <Widget>[
              _RoundIcon(
                icon: Icons.bar_chart_rounded,
                size: 36,
                accent: Color(0xFF62A8B8),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Review patterns when useful',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 13.7,
                        height: 1,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: TrueGroundColors.primary,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Look at recurring themes, without judgment.',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 10.8,
                        height: 1.1,
                        fontWeight: FontWeight.w500,
                        color: TrueGroundColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 19,
                color: TrueGroundColors.inkMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccessibleCard extends StatelessWidget {
  const _AccessibleCard({
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
    return _GlassPanel(
      accent: const Color(0xFF65AEB7),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _RoundIcon(icon: icon, size: 46, accent: const Color(0xFF65AEB7)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: TrueGroundColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.3,
                      color: TrueGroundColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: TrueGroundColors.inkMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child, required this.accent, this.onTap});

  final Widget child;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    final content = Material(
      type: MaterialType.transparency,
      child: onTap == null ? child : InkWell(onTap: onTap, child: child),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF163E5D).withValues(alpha: 0.13),
            blurRadius: 22,
            spreadRadius: -5,
            offset: const Offset(0, 9),
          ),
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.72),
            blurRadius: 7,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Stack(
            fit: StackFit.passthrough,
            children: <Widget>[
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.88),
                      width: 1.25,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        Colors.white.withValues(alpha: 0.62),
                        accent.withValues(alpha: 0.10),
                        Colors.white.withValues(alpha: 0.34),
                      ],
                      stops: const <double>[0, 0.58, 1],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -34,
                right: -28,
                child: IgnorePointer(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(alpha: 0.11),
                      ),
                    ),
                  ),
                ),
              ),
              content,
              Positioned(
                top: 1,
                left: 14,
                right: 14,
                child: IgnorePointer(
                  child: Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.90),
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
  const _RoundIcon({
    required this.icon,
    required this.size,
    required this.accent,
  });

  final IconData icon;
  final double size;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Colors.white.withValues(alpha: 0.80),
            accent.withValues(alpha: 0.18),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.90),
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accent.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, size: size * 0.49, color: const Color(0xFF238A9A)),
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
    final fill = Paint()..color = Colors.white.withValues(alpha: 0.10);
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final ridge = Path()
      ..moveTo(0, size.height * 0.88)
      ..lineTo(size.width * 0.18, size.height * 0.73)
      ..lineTo(size.width * 0.29, size.height * 0.82)
      ..lineTo(size.width * 0.45, size.height * 0.64)
      ..lineTo(size.width * 0.59, size.height * 0.80)
      ..lineTo(size.width * 0.73, size.height * 0.71)
      ..lineTo(size.width, size.height * 0.84)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(ridge, fill);

    final ridgeLine = Path()
      ..moveTo(0, size.height * 0.88)
      ..lineTo(size.width * 0.18, size.height * 0.73)
      ..lineTo(size.width * 0.29, size.height * 0.82)
      ..lineTo(size.width * 0.45, size.height * 0.64)
      ..lineTo(size.width * 0.59, size.height * 0.80)
      ..lineTo(size.width * 0.73, size.height * 0.71)
      ..lineTo(size.width, size.height * 0.84);
    canvas.drawPath(ridgeLine, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
