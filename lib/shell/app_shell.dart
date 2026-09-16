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

    return RepaintBoundary(
      key: captureKey,
      child: Scaffold(
        body: SafeArea(child: navigationShell),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Semantics(
            container: true,
            label: 'TrueGround primary navigation',
            child: NavigationBar(
              height: usesLargeTextLayout ? 82 : null,
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
    );
  }
}
