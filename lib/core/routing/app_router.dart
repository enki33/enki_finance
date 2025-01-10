import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/auth.dart';

part 'app_router.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;

      if (state.matchedLocation == '/') {
        return isLoggedIn ? '/home' : '/login';
      }

      if (!isLoggedIn &&
          !state.matchedLocation.startsWith('/login') &&
          !state.matchedLocation.startsWith('/signup') &&
          !state.matchedLocation.startsWith('/forgot-password')) {
        return '/login';
      }

      if (isLoggedIn &&
          (state.matchedLocation.startsWith('/login') ||
              state.matchedLocation.startsWith('/signup') ||
              state.matchedLocation.startsWith('/forgot-password'))) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Home Screen')),
        ),
      ),
      GoRoute(
        path: '/jars',
        name: 'jars',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Jars Screen')),
        ),
      ),
      GoRoute(
        path: '/transactions',
        name: 'transactions',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Transactions Screen')),
        ),
      ),
      GoRoute(
        path: '/reports',
        name: 'reports',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Reports Screen')),
        ),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Settings Screen')),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Error: ${state.error}',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    ),
  );
}
