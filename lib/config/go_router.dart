// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:once_upon_a_time/barrel.dart';

// class GoRouterRefreshStream extends ChangeNotifier {
//   GoRouterRefreshStream(Stream<dynamic> stream) {
//     notifyListeners();
//     _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
//   }

//   late final StreamSubscription<dynamic> _subscription;

//   @override
//   void dispose() {
//     _subscription.cancel();
//     super.dispose();
//   }
// }

// final GoRouter goRouter = GoRouter(
//   // refreshListenable: GoRouterRefreshStream(stream),
//   routes: [
//     GoRoute(
//       path: '/',
//       name: 'splash',
//       pageBuilder: (context, state) => CustomTransitionPage(
//         key: state.pageKey,
//         child: const SplashScreen(),
//         transitionsBuilder: (context, animation, secondaryAnimation, child) =>
//             FadeTransition(opacity: animation, child: child),
//       ),
//     ),
//     GoRoute(
//       path: '/home',
//       name: 'home',
//       pageBuilder: (context, state) => CustomTransitionPage(
//         key: state.pageKey,
//         child: const HomeScreen(),
//         transitionsBuilder: (context, animation, secondaryAnimation, child) =>
//             FadeTransition(opacity: animation, child: child),
//       ),
//     ),
//     GoRoute(
//       path: '/stage',
//       name: 'stage',
//       pageBuilder: (context, state) => CustomTransitionPage(
//         key: state.pageKey,
//         child: const StageScreen(),
//         transitionsBuilder: (context, animation, secondaryAnimation, child) =>
//             FadeTransition(opacity: animation, child: child),
//       ),
//     ),
//   ],
//   errorPageBuilder: (context, state) => CustomTransitionPage(
//     key: state.pageKey,
//     name: 'error',
//     child: const ErrorScreen(),
//     transitionsBuilder: (context, animation, secondaryAnimation, child) =>
//         FadeTransition(opacity: animation, child: child),
//   ),
// );
