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
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.72),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.98),
                          width: 1.4,
                        ),
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: TrueGroundColors.primary.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, -7),
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
                  Color(0xFFF8F6F3),
                  Color(0xFFF1F5F4),
                  Color(0xFFF8F4F0),
                ],
                stops: <double>[0, 0.52, 1],
              ),
            ),
          ),
          Positioned(
            top: -55,
            right: -65,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
              child: _GlowOrb(
                size: 220,
                colors: <Color>[
                  const Color(0xFF74B8CE).withValues(alpha: 0.19),
                  const Color(0xFF74B8CE).withValues(alpha: 0.01),
                ],
              ),
            ),
          ),
          Positioned(
            top: 250,
            left: -90,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 34, sigmaY: 34),
              child: _GlowOrb(
                size: 230,
                colors: <Color>[
                  const Color(0xFF9CCDBD).withValues(alpha: 0.16),
                  const Color(0xFF9CCDBD).withValues(alpha: 0.01),
                ],
              ),
            ),
          ),
          Positioned(
            top: 430,
            right: -82,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 34, sigmaY: 34),
              child: _GlowOrb(
                size: 220,
                colors: <Color>[
                  const Color(0xFFE7C8B2).withValues(alpha: 0.15),
                  const Color(0xFFE7C8B2).withValues(alpha: 0.01),
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
