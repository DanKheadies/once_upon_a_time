import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimatedTextController controller;
  late final Timer timer;

  @override
  void initState() {
    super.initState();

    controller = AnimatedTextController();

    timer = Timer(const Duration(seconds: 4), () => context.goNamed('story'));
  }

  @override
  void dispose() {
    controller.dispose();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: InkWell(
        onTap: () {
          timer.cancel();
          context.goNamed('story');
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'Once Upon a Time',
                  textStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontFamily: "HoldMoney",
                    fontSize: 64.0,
                  ),
                  speed: const Duration(milliseconds: 150),
                ),
              ],
              // totalRepeatCount: 1,
              isRepeatingAnimation: false,
              pause: const Duration(milliseconds: 100),
              displayFullTextOnTap: true,
              stopPauseOnTap: true,
              controller: controller,
              onTap: () {
                timer.cancel();
                context.goNamed('story');
              },
            ),
          ),
        ),
      ),
    );
  }
}
