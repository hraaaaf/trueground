import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../dashboard/dashboard_v3_screen.dart';
import '../shell/app_shell.dart';
import '../shell/shell_placeholder_screen.dart';

GoRouter createTrueGroundRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/',
                name: 'home',
                builder: (context, state) => const DashboardV3Screen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/loop',
                name: 'loop',
                builder: (context, state) => const LoopFlowScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/practice',
                name: 'practice',
                builder: (context, state) => const ShellPlaceholderScreen(
                  key: ValueKey('screen-practice'),
                  title: 'Practice',
                  description:
                      'Practice behavior is intentionally not implemented in this lot.',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/support',
                name: 'support',
                builder: (context, state) => const ShellPlaceholderScreen(
                  key: ValueKey('screen-support'),
                  title: 'Support',
                  description:
                      'Support behavior is intentionally not implemented in this lot.',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ShellPlaceholderScreen(
                  key: ValueKey('screen-profile'),
                  title: 'Profile',
                  description:
                      'Profile behavior is intentionally not implemented in this lot.',
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
