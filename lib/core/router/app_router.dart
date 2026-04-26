import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/api_constants.dart';
import '../presentation/screens/app_shell.dart';
import '../../features/discovery/presentation/screens/discover_screen.dart';
import '../../features/library/presentation/screens/library_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorLibraryKey = GlobalKey<NavigatorState>(
  debugLabel: 'libraryShell',
);
final shellNavigatorDiscoverKey = GlobalKey<NavigatorState>(
  debugLabel: 'discoverShell',
);
final shellNavigatorSettingsKey = GlobalKey<NavigatorState>(
  debugLabel: 'settingsShell',
);

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/discover',
    onException: (context, state, router) {
      // Supabase auth callbacks arrive as io.supabase.serapeum://login-callback/[?...]
      // login-callback is the URI host, not a path, so GoRouter can't match it.
      // Supabase's own app_links listener handles the token; redirect to Settings.
      if (state.uri.scheme == ApiConstants.supabaseDeepLinkScheme) {
        router.go('/settings');
      } else {
        router.go('/discover');
      }
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: shellNavigatorLibraryKey,
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorDiscoverKey,
            routes: [
              GoRoute(
                path: '/discover',
                builder: (context, state) => const DiscoverScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorSettingsKey,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
