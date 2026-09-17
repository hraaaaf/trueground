import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design/app_theme.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  static const captureKey = ValueKey('trueground-shell-capture');

  final StatefulNavigationShell navigationShell;

  void _selectDestination(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaledLabelSize = MediaQuery.textScalerOf(context).scale(12);
    final usesLargeTextLayout = scaledLabelSize > 18;
    final labelBehavior = usesLargeTextLayout
        ? NavigationDestinationLabelBehavior.onlyShowSelected
        : NavigationDestinationLabelBehavior.alwaysShow;
    final onHome = navigationShell.currentIndex == 0;

    return RepaintBoundary(
      key: captureKey,
      child: Scaffold(
        backgroundColor: onHome ? Colors.transparent : TrueGroundColors.background,
        body: SafeArea(
          child: onHome
              ? Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    const _HomeGlassBackdrop(),
                    navigationShell,
                  ],
                )
              : navigationShell,
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Semantics(
            container: true,
            label: 'TrueGround primary navigation',
            child: SizedBox(
              height: usesLargeTextLayout ? 100 : 84,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          Colors.white.withValues(alpha: 0.76),
                          const Color(0xFFEAF7FA).withValues(alpha: 0.58),
                          Colors.white.withValues(alpha: 0.66),
                        ],
                      ),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.96),
                          width: 1.3,
                        ),
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: const Color(0xFF0A456C).withValues(alpha: 0.12),
                          blurRadius: 28,
                          offset: const Offset(0, -7),
                        ),
                        BoxShadow(
                          color: const Color(0xFF57B9C7).withValues(alpha: 0.08),
                          blurRadius: 22,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: NavigationBar(
                      height: usesLargeTextLayout ? 100 : 84,
                      backgroundColor: Colors.transparent,
                      selectedIndex: navigationShell.currentIndex,
                      labelBehavior: labelBehavior,
                      onDestinationSelected: _selectDestination,
                      destinations: const <NavigationDestination>[
                        NavigationDestination(
                          icon: Icon(TrueGroundIcons.home),
                          selectedIcon: Icon(TrueGroundIcons.homeSelected),
                          label: 'Home',
                        ),
                        NavigationDestination(
                          icon: Icon(TrueGroundIcons.loop),
                          selectedIcon: Icon(TrueGroundIcons.loop),
                          label: 'Loop',
                        ),
                        NavigationDestination(
                          icon: Icon(TrueGroundIcons.practice),
                          selectedIcon: Icon(TrueGroundIcons.practiceSelected),
                          label: 'Practice',
                        ),
                        NavigationDestination(
                          icon: Icon(TrueGroundIcons.support),
                          selectedIcon: Icon(TrueGroundIcons.supportSelected),
                          label: 'Support',
                        ),
                        NavigationDestination(
                          icon: Icon(TrueGroundIcons.profile),
                          selectedIcon: Icon(TrueGroundIcons.profileSelected),
                          label: 'Profile',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeGlassBackdrop extends StatelessWidget {
  const _HomeGlassBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color(0xFFFAF7F3),
                  Color(0xFFF0F7F6),
                  Color(0xFFF7F3EF),
                ],
                stops: <double>[0, 0.50, 1],
              ),
            ),
          ),
          Positioned(
            top: -70,
            right: -55,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: _GlowOrb(
                size: 245,
                colors: <Color>[
                  const Color(0xFF58B7D6).withValues(alpha: 0.30),
                  const Color(0xFF8ED5E4).withValues(alpha: 0.10),
                  const Color(0xFF74B8CE).withValues(alpha: 0.01),
                ],
              ),
            ),
          ),
          Positioned(
            top: 205,
            left: -105,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: _GlowOrb(
                size: 270,
                colors: <Color>[
                  const Color(0xFF73C9B7).withValues(alpha: 0.24),
                  const Color(0xFFA5DCD1).withValues(alpha: 0.08),
                  const Color(0xFF9CCDBD).withValues(alpha: 0.01),
                ],
              ),
            ),
          ),
          Positioned(
            top: 390,
            right: -95,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: _GlowOrb(
                size: 255,
                colors: <Color>[
                  const Color(0xFFE4B79B).withValues(alpha: 0.24),
                  const Color(0xFFF0D1BE).withValues(alpha: 0.08),
                  const Color(0xFFE7C8B2).withValues(alpha: 0.01),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -110,
            left: 35,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 34, sigmaY: 34),
              child: _GlowOrb(
                size: 250,
                colors: <Color>[
                  const Color(0xFF6EAFD0).withValues(alpha: 0.13),
                  const Color(0xFF6EAFD0).withValues(alpha: 0.01),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: colors,
          stops: colors.length == 3
              ? const <double>[0, 0.48, 1]
              : const <double>[0, 1],
        ),
      ),
    );
  }
}
