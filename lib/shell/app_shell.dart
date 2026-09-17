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
                    color: Colors.white.withValues(alpha: 0.58),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.92),
                        width: 1,
                      ),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: TrueGroundColors.primary.withValues(alpha: 0.10),
                        blurRadius: 24,
                        offset: const Offset(0, -6),
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
                  Color(0xFFF7F4F2),
                  Color(0xFFE9F2F5),
                  Color(0xFFF8F3EF),
                ],
                stops: <double>[0, 0.50, 1],
              ),
            ),
          ),
          Positioned(
            top: -54,
            right: -64,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: _GlowOrb(
                size: 230,
                colors: <Color>[
                  const Color(0xFF7CBFD3).withValues(alpha: 0.36),
                  const Color(0xFF7CBFD3).withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
          Positioned(
            top: 300,
            left: -92,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
              child: _GlowOrb(
                size: 250,
                colors: <Color>[
                  const Color(0xFFBFD8C7).withValues(alpha: 0.30),
                  const Color(0xFFBFD8C7).withValues(alpha: 0.01),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: -86,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: _GlowOrb(
                size: 270,
                colors: <Color>[
                  const Color(0xFFE0C8B5).withValues(alpha: 0.28),
                  const Color(0xFFE0C8B5).withValues(alpha: 0.01),
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
