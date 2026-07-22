import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flip_page/flip_page.dart';
import 'package:flutter/material.dart';
// import 'package:marquee/marquee.dart';
import 'package:once_upon_a_time/widgets/_widgets.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// TODO:
// 1) Auto-scroll should be on a timer, i.e. after X seconds, start scrolling,
// and the distance is should cover is related to the number of characters in
// the prompt, e.g. string contains 120 characters, which in general is 500.
// - Not full-proof; should consider a better way to know "how much is left to
//   show" rather than guessing
// 2) On text complete, we show two buttons: Guess || Go On..
// 3) On a tap, we load all of the text, stop the timer(s) (e.g. scroll), and
// present the buttons.
// 4) Continue to keep old text and guesses "in-view," i.e. if we have a 120
// character prompt with no guesses, then both the text and "no guess" are shown
// while the prompt continues to load more (and scroll down while it loads).
// - Players should be able to scroll back up to review context (with a "jump to
//   the bottom" button).
// - Alternative: there could be arrows to denote old text and guesses, which
//   could have a "page flip" to the other prompts
// 5) ...
class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool showAll = false;
  double raggedness = 0;
  int parchmentSeed = 0;
  ScrollController scrollController = ScrollController();

  late final AnimatedTextController textController;
  late final VideoPlayerController videoController;

  @override
  void initState() {
    super.initState();

    Random random = Random();
    parchmentSeed = random.nextInt(420);
    raggedness = random.nextDouble() * 0.2 + 0.4;

    textController = AnimatedTextController();
    videoController =
        VideoPlayerController.asset(
            'assets/vids/once-upon-a-time-castles-contrast.mp4',
          )
          ..initialize().then((_) {
            setState(() {
              videoController.setVolume(0);
              videoController.setLooping(true);
              videoController.play();
            });
          });

    // scrollController.animateTo(
    //   500,
    //   duration: const Duration(seconds: 3),
    //   curve: Curves.linear,
    // );
  }

  Future<void> delayBackground() async {
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {
      videoController.play();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    textController.pause();
    textController.dispose();
    videoController.pause();
    videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Texxt('Once Upon a Time', isOlde: true),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.info_outline),
          //   onPressed: () {
          //     ScaffoldMessenger.of(context)
          //       ..clearSnackBars()
          //       ..showSnackBar(SnackBar(content: Text('TODO')));
          //   },
          // ),
          IconButton(
            icon: Icon(Icons.restore),
            onPressed: () {
              print('reset');
              scrollController.jumpTo(0);
              // textController.pause();
              textController.reset();
              // textController.play();
            },
          ),
          // videoController.value.isInitialized
          //     ? IconButton(
          //         icon: Icon(Icons.pause),
          //         onPressed: () {
          //           setState(() {
          //             videoController.pause();
          //           });
          //         },
          //       )
          //     : IconButton(
          //         icon: Icon(Icons.play_arrow),
          //         onPressed: () {
          //           setState(() {
          //             videoController.play();
          //           });
          //         },
          //       ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    height: videoController.value.size.height,
                    width: videoController.value.size.width,
                    child: videoController.value.isInitialized
                        ? VideoPlayer(videoController)
                        : const SizedBox(),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: Duration(seconds: 1),
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                color: Theme.of(context).scaffoldBackgroundColor.withAlpha(
                  videoController.value.isInitialized ? 155 : 255,
                ),
              ),
              ...buildBorder(
                context,
                Theme.of(context).colorScheme.inverseSurface.withAlpha(128),
                constraints.maxHeight,
                constraints.maxWidth,
              ),
              Container(
                margin: const EdgeInsets.only(left: 50, right: 50, top: 25),
                child: ParchmentContainer(
                  // baseColor: Theme.of(context).colorScheme.onSurface,
                  // baseColor: Color(0xFF90824F),
                  raggedness: raggedness,
                  seed: parchmentSeed,
                  height: constraints.maxHeight,
                  width: constraints.maxWidth,
                  child: const SizedBox(),
                ),
              ),
              // Container(
              //   height: constraints.maxHeight,
              //   width: constraints.maxWidth,
              //   margin: const EdgeInsets.only(
              //     bottom: 10,
              //     left: 75,
              //     right: 75,
              //     top: 50,
              //   ),
              //   child: GestureDetector(
              //     onTap: () {
              //       print('showAll');
              //       setState(() {
              //         showAll = true;
              //       });
              //     },
              //     // child: Marquee(
              //     //   text:
              //     //       'There once was a boy who told this story about a boy: That way you don\'t need to manually thread constraints through — both stack layers just match the outer SizedBox automatically. Either approach gets you the same result, so keep whichever feels cleaner in your version. And yeah — the random seed/raggedness generator is a nice touch, gives you a fresh "torn" look each load instead of the same shape every time. Have fun tweaking it! Oh but also, I just need a little more from you...',
              //     //   scrollAxis: Axis.vertical,
              //     // ),
              //     child: SingleChildScrollView(
              //       controller: scrollController,
              //       child: AnimatedTextKit(
              //         controller: textController,
              //         onNext: (index, last) {
              //           print('onNext index: $index');
              //           print('onNext last: $last');
              //         },
              //         onNextBeforePause: (index, last) {
              //           print('onNextBeforePause index: $index');
              //           print('onNextBeforePause last: $last');
              //         },
              //         isRepeatingAnimation: false,
              //         // totalRepeatCount: 1,
              //         displayFullTextOnTap: true,
              //         pause: const Duration(milliseconds: 1000),
              //         stopPauseOnTap: true,
              //         // repeatForever: true,
              //         onTap: () {
              //           print('animated text kit tap');
              //         },
              //         onFinished: () {
              //           print('onFinished');
              //           scrollController.animateTo(
              //             500,
              //             duration: const Duration(seconds: 3),
              //             curve: Curves.linear,
              //           );
              //         },
              //         animatedTexts: [
              //           // TyperAnimatedText(
              //           //   'That way you don\'t need to manually thread constraints through — both stack layers just match the outer SizedBox automatically.',
              //           //   textStyle: TextStyle(
              //           //     color: Theme.of(context).primaryColor,
              //           //     // fontFamily: "HoldMoney",
              //           //     fontSize: 32.0,
              //           //   ),
              //           //   speed: const Duration(milliseconds: 30),
              //           // ),
              //           TyperAnimatedText(
              //             'That way you don\'t need to manually thread constraints through — both stack layers just match the outer SizedBox automatically. Either approach gets you the same result, so keep whichever feels cleaner in your version. And yeah — the random seed/raggedness generator is a nice touch, gives you a fresh "torn" look each load instead of the same shape every time. Have fun tweaking it! Oh but also, I just need a little more from you...',
              //             textStyle: TextStyle(
              //               color: Theme.of(context).primaryColor,
              //               // fontFamily: "HoldMoney",
              //               fontSize: 32.0,
              //             ),
              //             speed: const Duration(milliseconds: 30),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              //   // child: const Text(
              //   //   'That way you don\'t need to manually thread constraints through — both stack layers just match the outer SizedBox automatically. Either approach gets you the same result, so keep whichever feels cleaner in your version. And yeah — the random seed/raggedness generator is a nice touch, gives you a fresh "torn" look each load instead of the same shape every time. Have fun tweaking it!',
              //   //   style: TextStyle(fontFamily: 'Georgia', fontSize: 16),
              //   // ),
              // ),
              // ScrollBanner(
              //   width: constraints.maxWidth,
              //   height: constraints.maxHeight,
              //   child: Texxt('test'),
              // ),
              Container(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                margin: const EdgeInsets.only(
                  bottom: 10,
                  left: 75,
                  right: 75,
                  top: 50,
                ),
                child: FlipPage(
                  pages: [
                    Container(
                      color: Colors.amber,
                      child: Center(child: Text('1')),
                    ),
                    Container(
                      color: Colors.teal,
                      child: Center(child: Text('2')),
                    ),
                    // AnimatedTextKit(
                    //   controller: textController,
                    //   onNext: (index, last) {
                    //     print('onNext index: $index');
                    //     print('onNext last: $last');
                    //   },
                    //   onNextBeforePause: (index, last) {
                    //     print('onNextBeforePause index: $index');
                    //     print('onNextBeforePause last: $last');
                    //   },
                    //   isRepeatingAnimation: false,
                    //   // totalRepeatCount: 1,
                    //   displayFullTextOnTap: true,
                    //   pause: const Duration(milliseconds: 1000),
                    //   stopPauseOnTap: true,
                    //   // repeatForever: true,
                    //   onTap: () {
                    //     print('animated text kit tap');
                    //   },
                    //   onFinished: () {
                    //     print('onFinished');
                    //     // scrollController.animateTo(
                    //     //   500,
                    //     //   duration: const Duration(seconds: 3),
                    //     //   curve: Curves.linear,
                    //     // );
                    //   },
                    //   animatedTexts: [
                    //     // TyperAnimatedText(
                    //     //   'That way you don\'t need to manually thread constraints through — both stack layers just match the outer SizedBox automatically.',
                    //     //   textStyle: TextStyle(
                    //     //     color: Theme.of(context).primaryColor,
                    //     //     // fontFamily: "HoldMoney",
                    //     //     fontSize: 32.0,
                    //     //   ),
                    //     //   speed: const Duration(milliseconds: 30),
                    //     // ),
                    //     TyperAnimatedText(
                    //       'That way you don\'t need to manually thread constraints through — both stack layers just match the outer SizedBox automatically. Either approach gets you the same result, so keep whichever feels cleaner in your version. And yeah — the random seed/raggedness generator is a nice touch, gives you a fresh "torn" look each load instead of the same shape every time. Have fun tweaking it! Oh but also, I just need a little more from you...',
                    //       textStyle: TextStyle(
                    //         color: Theme.of(context).primaryColor,
                    //         // fontFamily: "HoldMoney",
                    //         fontSize: 32.0,
                    //       ),
                    //       speed: const Duration(milliseconds: 30),
                    //     ),
                    //   ],
                    // ),
                    Container(
                      color: Colors.indigo,
                      child: Center(child: Text('3')),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> buildBorder(
    BuildContext context,
    Color color,
    double height,
    double width,
  ) {
    double borderHeight = 200;

    return [
      // Left
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: borderHeight,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, Colors.transparent]),
          ),
        ),
      ),
      // Top
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: width,
          height: borderHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, Colors.transparent],
              begin: AlignmentGeometry.topCenter,
              end: AlignmentGeometry.bottomCenter,
            ),
          ),
        ),
      ),
      // Right
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: borderHeight,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.transparent, color]),
          ),
        ),
      ),
      // Bottom
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: width,
          height: borderHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, color],
              begin: AlignmentGeometry.topCenter,
              end: AlignmentGeometry.bottomCenter,
            ),
          ),
        ),
      ),
    ];
  }
}

// class TornPaperClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     var path = Path();
//     path.lineTo(0.0, size.height);

//     // Example: Create a ragged torn edge on the bottom
//     path.lineTo(size.width * 0.3, size.height);
//     path.lineTo(size.width * 0.35, size.height - 15);
//     path.lineTo(size.width * 0.4, size.height);
//     path.lineTo(size.width, size.height);

//     path.lineTo(size.width, 0.0);
//     path.close();

//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }

// class FBSPainter extends CustomPainter {
//   final Color color;
//   final FragmentShader shader;

//   FBSPainter({required this.color, required this.shader});

//   @override
//   void paint(Canvas canvas, Size size) {
//     // 10x10 square
//     // final path = Path()
//     //   ..lineTo(0, 10)
//     //   ..lineTo(10, 10)
//     //   ..lineTo(10, 0)
//     //   ..lineTo(0, 0);
//     // canvas.drawPath(path, Paint()..color = Colors.red);

//     // Variable square defined by the provided size and custom shader
//     shader.setFloat(0, size.width);
//     shader.setFloat(1, size.height);
//     shader.setFloat(2, color.r.toDouble());
//     shader.setFloat(3, color.g.toDouble());
//     shader.setFloat(4, color.b.toDouble());
//     shader.setFloat(5, color.a.toDouble());
//     canvas.drawRect(
//       Rect.fromLTWH(0, 0, size.width, size.height),
//       Paint()..shader = shader,
//     );
//   }

//   @override
//   // bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
//   bool shouldRepaint(FBSPainter oldDelegate) => color != oldDelegate.color;
// }
