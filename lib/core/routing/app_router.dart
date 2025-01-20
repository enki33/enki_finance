import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../../features/auth/auth.dart';
import '../../features/main/main_feature_barrel.dart';
import '../providers/supabase_provider.dart';
import '../../features/auth/data/repositories/auth_repository_provider.dart';
import '../../features/transactions/presentation/pages/transactions_page.dart';
import '../../features/maintenance/presentation/pages/maintenance_page.dart';
import '../../features/maintenance/presentation/pages/jars_page.dart';
import '../../features/maintenance/presentation/pages/categories_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/account/presentation/pages/accounts_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) async {
      final isLoggedIn = authRepository.currentUser != null;
      final isAuthRoute = state.matchedLocation == '/login';

      debugPrint(
          'Router redirect - isLoggedIn: $isLoggedIn, isAuthRoute: $isAuthRoute, location: ${state.matchedLocation}');

      if (!isLoggedIn && !isAuthRoute) {
        debugPrint(
            'Not logged in and not on auth route - redirecting to /login');
        return '/login';
      }

      if (isLoggedIn && isAuthRoute) {
        debugPrint('Logged in and on auth route - redirecting to /');
        return '/';
      }

      debugPrint('No redirect needed');
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const Center(
              child: Text('Dashboard Content'),
            ),
          ),
          GoRoute(
            path: '/jars',
            name: 'jars',
            builder: (context, state) => const Center(
              child: Text('Jars Content'),
            ),
          ),
          GoRoute(
            path: '/transactions',
            name: 'transactions',
            builder: (context, state) => TransactionsPage(
              userId: ref.read(authRepositoryProvider).currentUser?.id ?? '',
            ),
          ),
          GoRoute(
            path: '/reports',
            name: 'reports',
            builder: (context, state) => const Center(
              child: Text('Reports Content'),
            ),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
            routes: [
              GoRoute(
                path: 'user-info',
                name: 'user-info',
                builder: (context, state) => const UserInfoPage(),
              ),
              GoRoute(
                path: 'maintenance',
                name: 'maintenance',
                builder: (context, state) => const MaintenancePage(),
              ),
              GoRoute(
                path: 'categories',
                name: 'categories',
                builder: (context, state) => const CategoriesPage(),
              ),
              GoRoute(
                path: 'jars',
                name: 'settings-jars',
                builder: (context, state) => const JarsPage(),
              ),
              GoRoute(
                path: 'accounts',
                name: 'accounts',
                builder: (context, state) => const AccountsPage(),
              ),
              GoRoute(
                path: 'notifications',
                name: 'notifications',
                builder: (context, state) => const Center(
                  child: Text('Notifications Settings'),
                ),
              ),
              GoRoute(
                path: 'theme',
                name: 'theme',
                builder: (context, state) => const Center(
                  child: Text('Theme Settings'),
                ),
              ),
              GoRoute(
                path: 'language',
                name: 'language',
                builder: (context, state) => const Center(
                  child: Text('Language Settings'),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
