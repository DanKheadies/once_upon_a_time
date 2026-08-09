import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:once_upon_a_time/barrel.dart';

class AppRouter {
  final GoRouter router;

  AppRouter(BuildContext context)
    : router = GoRouter(
        initialLocation: '/',
        refreshListenable: GoRouterRefreshStream(
          context.read<AuthCubit>().stream,
        ),
        redirect: (context, state) {
          final authState = context.read<AuthCubit>().state;
          final path = state.matchedLocation;

          const publicPaths = {'/', '/auth', '/contact', '/error', '/home'};
          final isPublic = publicPaths.contains(path);

          // Still resolving, don't bounce yet
          if (authState.status == AuthStatus.unknown) return null;

          if (authState.status == AuthStatus.unauthenticated && !isPublic) {
            return '/auth';
          }
          if (authState.status == AuthStatus.authenticated && path == '/auth') {
            return '/home';
          }
          return null;
        },
        routes: [
          // GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
          GoRoute(
            path: '/',
            name: 'splash',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SplashScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
            ),
          ),
          // GoRoute(path: '/auth', builder: (_, _) => const AuthScreen()),
          GoRoute(
            path: '/auth',
            name: 'auth',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const AuthScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
            ),
          ),
          // GoRoute(path: '/contact', builder: (_, _) => const ContactScreen()),
          GoRoute(
            path: '/contact',
            name: 'contact',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ContactScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
            ),
          ),
          // GoRoute(path: '/error', builder: (_, _) => const ErrorScreen()),
          GoRoute(
            path: '/error',
            name: 'error',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ErrorScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
            ),
          ),
          // GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const HomeScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
            ),
          ),
          // GoRoute(
          //   path: '/story-writer',
          //   builder: (_, _) => const StoryWriterScreen(),
          // ),
          GoRoute(
            path: '/story-writer',
            name: 'story-writer',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const StoryWriterScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
            ),
          ),
          // GoRoute(path: '/settings', builder: (_, _) => const SettingsPage()),
        ],
      );
}
