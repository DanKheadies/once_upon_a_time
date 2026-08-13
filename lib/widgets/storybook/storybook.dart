import 'dart:math' as math;

import 'package:flutter/material.dart';

class Storybook extends StatefulWidget {
  final bool? canOpen;
  final double height;
  final double width;
  final Duration duration;
  final VoidCallback? onOpened;
  final Widget frontCover;
  final Widget pages;

  const Storybook({
    super.key,
    required this.width,
    required this.height,
    required this.frontCover,
    required this.pages,
    this.canOpen = false,
    this.duration = const Duration(milliseconds: 900),
    this.onOpened,
  });

  @override
  State<Storybook> createState() => StorybookState();
}

class StorybookState extends State<Storybook>
    with SingleTickerProviderStateMixin {
  bool opened = false;
  bool opening = false;
  List<String> loadingPrompts = [
    'Are you sure you want to do that?',
    'Magic is collecting..',
    'Try again with INTENT!',
    'A picture is worth a thousand words.',
    'Once upon a bind..',
    'Say "please" first.',
  ];

  final double kPerspective = 0.0015;

  late final AnimationController controller;
  late final Animation<double> swing;

  Matrix4 _perspectiveMatrix() =>
      Matrix4.identity()..setEntry(3, 2, kPerspective);

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: widget.duration);
    swing = CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic);

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => opened = true);
        widget.onOpened?.call();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.canOpen!
          ? open
          : () {
              int index = math.Random().nextInt(loadingPrompts.length);
              // TODO: random responses
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(SnackBar(content: Text(loadingPrompts[index])));
            },
      child: Container(
        color: Colors.transparent,
        width: widget.width,
        height: widget.height,
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: !opening ? 1 : 0,
                duration: Duration(milliseconds: 2000),
                child: Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(right: 25),
                  child: Image.asset(
                    'assets/images/storybook-open-pages.png',
                    scale: 0.1,
                  ),
                ),
              ),
            ),

            Positioned.fill(
              child: AnimatedOpacity(
                opacity: opening ? 1 : 0,
                duration: Duration(milliseconds: 300),
                child: Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(right: 25),
                  child: Image.asset(
                    'assets/images/storybook-open-full.png',
                    scale: 0.1,
                  ),
                ),
              ),
            ),

            Positioned.fill(
              child: AnimatedOpacity(
                opacity: opened ? 1 : 0,
                duration: Duration(milliseconds: 300),
                child: Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(right: 25),
                  child: widget.pages,
                ),
              ),
            ),

            // The front cover, hinged at the spine (left edge).
            if (!opened)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: swing,
                  builder: (context, child) {
                    final angle = (math.pi / 2.05) * swing.value;
                    final fade =
                        1.0 -
                        Curves.easeIn.transform(
                          (swing.value - 0.7).clamp(0.0, 0.3) / 0.3,
                        );

                    return Opacity(
                      opacity: fade,
                      child: Transform(
                        alignment: Alignment.centerLeft,
                        transform: _perspectiveMatrix()..rotateY(angle),
                        child: child,
                      ),
                    );
                  },
                  // child: GestureDetector(onTap: open, child: widget.frontCover),
                  child: widget.frontCover,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> open() async {
    if (controller.isAnimating || opened) return;
    controller.forward();

    await Future.delayed(Duration(milliseconds: 500));

    setState(() {
      opening = true;
    });
  }

  void toggle() {
    setState(() {
      opened = !opened;
    });
  }
}
