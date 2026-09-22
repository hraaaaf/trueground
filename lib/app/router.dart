import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../dashboard/dashboard_v3_screen.dart';
import '../loop/loop_flow_screen.dart';
import '../patterns/pattern_memory_store.dart';
import '../patterns/pattern_review_screen.dart';
import '../practice/practice_completion_store.dart';
import '../practice/practice_screen.dart';
import '../safety/urgent_support_screen.dart';
import '../shell/app_shell.dart';
import '../shell/shell_placeholder_screen.dart';
import '../support/support_screen.dart';
import '../values/values_screen.dart';

GoRouter createTrueGroundRouter({
  PracticeCompletionStore? practiceCompletionStore,
  DateTime Function()? practiceNow,
  PatternMemoryStore? patternMemoryStore,
  DateTime Function()? patternNow,
}) {
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/urgent-support',
        name: 'urgent-support',
        builder: (context, state) => const UrgentSupportScreen(),
      ),
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
                routes: <RouteBase>[
                  GoRoute(
                    path: 'values',
                    name: 'values',
                    builder: (context, state) => ValuesScreen(
                      memoryStore: patternMemoryStore,
                      now: patternNow,
                    ),
                  ),
                  GoRoute(
                    path: 'patterns',
                    name: 'patterns',
                    builder: (context, state) => PatternReviewScreen(
                      memoryStore: patternMemoryStore,
                      now: patternNow,
                    ),
                  ),
                ],
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
                builder: (context, state) => PracticeScreen(
                  completionStore: practiceCompletionStore,
                  now: practiceNow,
                  patternMemoryStore: patternMemoryStore,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/support',
                name: 'support',
                builder: (context, state) => const SupportScreen(),
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
