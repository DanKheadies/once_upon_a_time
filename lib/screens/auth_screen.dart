import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:once_upon_a_time/barrel.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool obscurePassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(isPortrait: true),
      endDrawer: CustomDrawer(isStorybook: false),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // double height = constraints.maxHeight;
            double width = constraints.maxWidth;

            return BlocListener<AuthCubit, AuthState>(
              listenWhen: (previous, current) =>
                  // previous.status != current.status ||
                  previous.errorMessage != current.errorMessage,
              listener: (context, state) {
                // if (state.status == AuthStatus.authenticated) {
                //   print(
                //     'TODO (?): nav here; but should be handled via AppRouter',
                //   );
                //   // clearInputs();
                //   // avoid this?
                // }
                if (state.errorMessage != null && state.errorMessage != '') {
                  String errMsg = ErrorHelper().cleanUpMessage(
                    state.errorMessage,
                  );
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(errMsg)));
                }
              },
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state.status == AuthStatus.submitting) {
                    return GestureDetector(
                      onTap: () {
                        context.read<AuthCubit>().reset();
                      },
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      width: width < 850 ? width : 500,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 75,
                              child: AnimatedTextKit(
                                repeatForever: true,
                                animatedTexts: [
                                  FlickerAnimatedText(
                                    'Backstage',
                                    textStyle: neonStyle('Alagard'),
                                  ),
                                  FlickerAnimatedText(
                                    'Backstage',
                                    textStyle: neonStyle('HoldMoney'),
                                  ),
                                  FlickerAnimatedText(
                                    'Backstage',
                                    textStyle: neonStyle('Storybook'),
                                  ),
                                ],
                              ),
                            ),
                            NeonPineapple(),
                            const SizedBox(height: 25),
                            CustomInput(
                              labelText: 'Email',
                              initialValue: state.email,
                              onChanged: (value) => context
                                  .read<AuthCubit>()
                                  .updateLogin(email: value),
                              onEnter: (_) => context.read<AuthCubit>().login(),
                            ),
                            const SizedBox(height: 15),
                            GestureDetector(
                              onDoubleTap: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                              child: CustomInput(
                                labelText: 'Password',
                                obscureText: !obscurePassword,
                                onChanged: (value) => context
                                    .read<AuthCubit>()
                                    .updateLogin(password: value),
                                onEnter: (_) =>
                                    context.read<AuthCubit>().login(),
                              ),
                            ),
                            const SizedBox(height: 40),
                            state.status == AuthStatus.submitting
                                ? const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: SizedBox(
                                      height: 35,
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed:
                                        state.status == AuthStatus.submitting
                                        ? null
                                        : () =>
                                              context.read<AuthCubit>().login(),
                                    child: Text('Login'),
                                  ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  TextStyle neonStyle(String fontFamily) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 40,
      fontWeight: FontWeight.bold,
      color: Colors.white, // The core light tube color
      shadows: [
        // Close intense glow
        Shadow(
          blurRadius: 10.0,
          color: Colors.pinkAccent,
          offset: Offset(0, 0),
        ),
        // Medium widespread glow
        Shadow(blurRadius: 20.0, color: Colors.pink, offset: Offset(0, 0)),
        // Large environmental glow
        Shadow(
          blurRadius: 40.0,
          color: Colors.deepPurple,
          offset: Offset(0, 0),
        ),
      ],
    );
  }
}
