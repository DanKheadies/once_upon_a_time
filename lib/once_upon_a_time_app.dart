import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:once_upon_a_time/barrel.dart';

class OnceUponATimeApp extends StatefulWidget {
  const OnceUponATimeApp({super.key});

  @override
  State<OnceUponATimeApp> createState() => _OnceUponATimeAppState();
}

class _OnceUponATimeAppState extends State<OnceUponATimeApp> {
  late final GoRouter appRouter;

  @override
  void initState() {
    super.initState();
    appRouter = AppRouter(context).router;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
          // theme: state == Brightness.dark ? darkTheme() : lightTheme(),
          theme: darkTheme(),
        );
      },
    );
  }
}
