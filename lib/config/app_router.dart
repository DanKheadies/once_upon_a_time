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
        redirect: (context, state) => _authGuard(context, state),
        routes: [
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
        ],
      );
}

String? _authGuard(BuildContext context, GoRouterState state) {
  print('authGuard triggered');
  final authState = context.read<AuthCubit>().state;
  final path = state.matchedLocation;

  const publicPaths = {'/', '/auth', '/contact', '/error', '/home'};
  final isPublic = publicPaths.contains(path);

  // Still resolving, don't bounce yet
  if (authState.status == AuthStatus.unknown) return null;

  // print('not unknown');
  if (authState.status == AuthStatus.unauthenticated && !isPublic) {
    // print('unauth && not public');
    return '/auth';
  }
  if (authState.status == AuthStatus.authenticated && path == '/auth') {
    // print('auth\'d & trying to auth');
    return '/story-writer';
  }
  // print('do nothing');
  return null;
}
