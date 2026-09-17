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
    final homeBody = Stack(
      fit: StackFit.expand,
      children: <Widget>[const _HomeGlassBackdrop(), navigationShell],
    );

    return RepaintBoundary(
      key: captureKey,
      child: Scaffold(
        backgroundColor: onHome
            ? Colors.transparent
            : TrueGroundColors.background,
        body: SafeArea(child: onHome ? homeBody : navigationShell),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Semantics(
            container: true,
            label: 'TrueGround primary navigation',
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.48),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.96),
                        width: 1.2,
                      ),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: TrueGroundColors.primary.withValues(alpha: 0.12),
                        blurRadius: 28,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: NavigationBar(
                    height: usesLargeTextLayout ? 96 : null,
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
                  Color(0xFFF8F5F2),
                  Color(0xFFE4F0F4),
                  Color(0xFFF7EFE9),
                ],
                stops: <double>[0, 0.48, 1],
              ),
            ),
          ),
          Positioned(
            top: -34,
            right: -42,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: _GlowOrb(
                size: 220,
                colors: <Color>[
                  const Color(0xFF68B6D0).withValues(alpha: 0.46),
                  const Color(0xFF68B6D0).withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
          Positioned(
            top: 250,
            left: -70,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: _GlowOrb(
                size: 210,
                colors: <Color>[
                  const Color(0xFF9CCDBD).withValues(alpha: 0.40),
                  const Color(0xFF9CCDBD).withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
          Positioned(
            top: 390,
            right: -58,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 17, sigmaY: 17),
              child: _GlowOrb(
                size: 205,
                colors: <Color>[
                  const Color(0xFFE4C5AE).withValues(alpha: 0.36),
                  const Color(0xFFE4C5AE).withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 96,
            left: -24,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: _GlowOrb(
                size: 190,
                colors: <Color>[
                  const Color(0xFF87BFD6).withValues(alpha: 0.28),
                  const Color(0xFF87BFD6).withValues(alpha: 0.01),
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
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}
