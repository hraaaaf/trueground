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
    final homeBody = Stack(
      fit: StackFit.expand,
      children: <Widget>[const _HomeGlassBackdrop(), navigationShell],
    );

    return RepaintBoundary(
      key: captureKey,
      child: Scaffold(
        body: SafeArea(
          child: navigationShell.currentIndex == 0 ? homeBody : navigationShell,
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Semantics(
            container: true,
            label: 'TrueGround primary navigation',
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.82),
                    width: 0.8,
                  ),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: TrueGroundColors.primary.withValues(alpha: 0.07),
                    blurRadius: 18,
                    offset: const Offset(0, -4),
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
    );
  }
}

class _HomeGlassBackdrop extends StatelessWidget {
  const _HomeGlassBackdrop();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFFF5F2F0),
              Color(0xFFEAF2F4),
              Color(0xFFF7F3F0),
            ],
            stops: <double>[0, 0.52, 1],
          ),
        ),
      ),
    );
  }
}
