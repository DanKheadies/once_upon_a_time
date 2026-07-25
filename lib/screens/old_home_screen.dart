// import 'dart:math';

// import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:once_upon_a_time/barrel.dart';

class OldHomeScreen extends StatefulWidget {
  const OldHomeScreen({super.key});

  @override
  State<OldHomeScreen> createState() => _OldHomeScreenState();
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
// 5) Add a menu button that contains:
// - Give new story
// - Stumped, give answer
// - Help / Contact
// - Secret Admin login
// - Restart story (?)
// 6) Have the first page show the "Once upon a time..." tagline with a fancy "O"
// 7) On a correct solve, the rest of the story should be told with some victory
// fanfare in the background. Player can keep reading or go on to the next story.
// 8) At the end of the chapters, give the Player one last chance to solve or
// give them the answer.

// Thoughts:
// It feels like the book visual is the play. I should have a book "appear" and
// open up. Then the story starts flowing. Having
class _OldHomeScreenState extends State<OldHomeScreen>
    with TickerProviderStateMixin {
  bool hasPrev = false;
  bool isInitialized = false;
  bool showAll = false;
  double raggedness = 0;
  int chapterIndex = 0;
  int parchmentSeed = 0;
  List<String> story = [];
  // ScrollController scrollController = ScrollController();
  // String currentChapter = '';

  // late final AnimatedTextController textController;
  // late final VideoPlayerController videoController;

  @override
  void initState() {
    super.initState();

    // currentChapter = Story.storyExample1.chapters[chapterIndex];
    story = Story.storyExample1.chapters;

    // Random random = Random();
    // parchmentSeed = random.nextInt(420);
    // raggedness = random.nextDouble() * 0.2 + 0.4;

    // textController = AnimatedTextController();
    // videoController =
    //     VideoPlayerController.asset(
    //         'assets/vids/once-upon-a-time-castles-contrast.mp4',
    //       )
    //       ..initialize().then((_) {
    //         setState(() {
    //           videoController.setVolume(0);
    //           videoController.setLooping(true);
    //           videoController.play();
    //         });
    //       });

    // scrollController.animateTo(
    //   500,
    //   duration: const Duration(seconds: 3),
    //   curve: Curves.linear,
    // );
  }

  // Future<void> delayBackground() async {
  //   await Future.delayed(Duration(milliseconds: 1000));
  //   setState(() {
  //     videoController.play();
  //   });
  // }

  @override
  void dispose() {
    // scrollController.dispose();
    // textController.pause();
    // textController.dispose();
    // videoController.pause();
    // videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Texxt('Once Upon a Time', isOlde: true, useDark: false),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.info_outline),
          //   onPressed: () {
          //     ScaffoldMessenger.of(context)
          //       ..clearSnackBars()
          //       ..showSnackBar(SnackBar(content: Text('TODO')));
          //   },
          // ),
          // IconButton(
          //   icon: Icon(Icons.restore),
          //   onPressed: () {
          //     print('reset');
          //     scrollController.jumpTo(0);
          //     // textController.pause();
          //     textController.reset();
          //     // textController.play();
          //   },
          // ),
          IconButton(
            icon: Icon(Icons.navigate_next),
            onPressed: () {
              print('book');
              context.goNamed('book');
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
      floatingActionButton: Container(
        // color: Colors.red.shade100,
        padding: const EdgeInsets.only(left: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            chapterIndex < 1
                // ? const SizedBox(width: 56)
                ? emptyFlaction()
                : FloatingActionButton(
                    heroTag: 'prevChp',
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(100),
                    ),
                    onPressed: chapterIndex < 1
                        ? null
                        : () {
                            print('prev chp');
                            setState(() {
                              chapterIndex -= 1;
                            });
                          },
                    child: Icon(Icons.arrow_back),
                  ),
            FloatingActionButton(
              heroTag: 'solve',
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(100),
              ),
              onPressed: () {
                print('solve');
              },
              child: Icon(Icons.auto_fix_high),
            ),
            chapterIndex + 1 >= story.length
                // ? const SizedBox(width: 56)
                ? emptyFlaction()
                : FloatingActionButton(
                    heroTag: 'goOn',
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(100),
                    ),
                    onPressed: () {
                      print('go on');
                      if (chapterIndex + 1 < story.length) {
                        setState(() {
                          chapterIndex += 1;
                        });
                      }
                    },
                    // child: Icon(Icons.arrow_forward),
                    child: Icon(Icons.auto_stories),
                  ),
          ],
          // children: [
          //   // const SizedBox(width: 50),
          //   FloatingActionButton(
          //     backgroundColor: Theme.of(
          //       context,
          //     ).colorScheme.primary.withAlpha(hasPrev ? 255 : 128),
          //     enableFeedback: hasPrev,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadiusGeometry.circular(100),
          //     ),
          //     onPressed: hasPrev
          //         ? null
          //         : () {
          //             print('prev chp');
          //           },
          //     child: Icon(Icons.arrow_back),
          //   ),
          //   // Spacer(),
          //   FloatingActionButton(
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadiusGeometry.circular(100),
          //     ),
          //     onPressed: () {
          //       print('next chp');
          //     },
          //     child: Icon(Icons.album_outlined),
          //   ),
          //   FloatingActionButton(
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadiusGeometry.circular(100),
          //     ),
          //     onPressed: () {
          //       print('next chp');
          //     },
          //     // child: Icon(Icons.arrow_forward),
          //     child: Icon(Icons.auto_stories),
          //   ),
          //   // const SizedBox(width: 50),
          // ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double height = constraints.maxHeight;
          double width = constraints.maxWidth;

          return Stack(
            children: [
              BackgroundVideo(
                isInitialized: () {
                  print('isInitialized');
                  setState(() {
                    isInitialized = true;
                  });
                },
              ),
              ...buildBackgroundVeil(
                context,
                Theme.of(context).colorScheme.inverseSurface.withAlpha(100),
                height,
                width,
              ),
              // TODO: come back to this and see how best to handle
              height <= 400
                  ? const SizedBox()
                  : Align(
                      alignment: AlignmentGeometry.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight: 300,
                          // maxHeight: height > width ? width - 100 : height - 100,
                          // Note: height isn't perfect; there's some relationship
                          // that's missing based on the current width
                          maxHeight: height > width
                              ? width - 100
                              // : height - (height / 200 < 100 ? 100 : height / 200),
                              : height - 100,
                          minWidth: 300,
                          maxWidth: width > height ? height - 100 : width - 100,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          color: Colors.deepPurple.shade100,
                        ),
                        margin: EdgeInsets.only(
                          left: constraints.maxHeight / 10 > 50
                              ? 50
                              : constraints.maxHeight / 10,
                        ),
                        padding: const EdgeInsets.all(20),
                        height: constraints.maxHeight,
                        width: constraints.maxWidth,
                        // child: Texxt(currentChapter),
                        // child: Texxt(story[chapterIndex]),
                        child: GestureDetector(
                          onTap: () {
                            print('($width, $height)');
                          },
                          child: SingleChildScrollView(
                            child: Texxt(
                              story[chapterIndex]
                                  .replaceAll('. ', '.\n\n')
                                  .replaceAll('! ', '!\n\n')
                                  .replaceAll('? ', '?\n\n'),
                              size:
                                  12 +
                                  (width > height ? height / 20 : width / 20),
                            ),
                          ),
                        ),
                        // child: ListView.builder(
                        //   // physics: NeverScrollableScrollPhysics(),
                        //   shrinkWrap: true,
                        //   itemCount: Story.storyExample1.chapters.length,
                        //   itemBuilder: (context, index) {
                        //     return Texxt(Story.storyExample1.chapters[index]);
                        //   },
                        // ),
                      ),
                    ),
              // Container(
              //   margin: const EdgeInsets.symmetric(horizontal: 10),
              //   child: BookFlip.builder(
              //     // fit: BookFit.contain,
              //     pageCount: 6,
              //     pageSize: const Size(360, 500),
              //     pageBuilder: (context, index) => ColoredBox(
              //       // color: Colors.primaries[index % Colors.primaries.length],
              //       color: Theme.of(context).primaryColor,
              //       child: Center(
              //         child: Text(
              //           // 'Page ${index + 1}',
              //           Story.storyExample1.chapters[index],
              //           style: const TextStyle(
              //             fontSize: 12,
              //             color: Colors.white,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              // BookFlip.builder(
              //   material: BookFlipMaterial.magazine,
              //   pageCount: 6,
              //   pageSize: const Size(360, 500),
              //   pageBuilder: (context, index) => Center(
              //     child: Text(
              //       'Page ${index + 1}',
              //       style: const TextStyle(fontSize: 48, color: Colors.white),
              //     ),
              //   ),
              // ),
              // BookFlip.builder(
              //   material: BookFlipMaterial.paper,
              //   pageCount: 6,
              //   pageSize: const Size(360, 500),
              //   pageBuilder: (context, i) =>
              //       Center(child: Text('Page ${i + 1}')),
              // ),
              // Positioned(
              //   child: BookFlip.widgets(
              //     // fit: BookFit.fill,
              //     pageSize: const Size(360, 500),
              //     pages: const [
              //       Center(child: Text('Once upon a time...')),
              //       ColoredBox(color: Color(0xFFFFF3E0)),
              //       ColoredBox(color: Color(0xFFE3F2FD)),
              //       Center(child: Text('...the end.')),
              //     ],
              //   ),
              // ),
              // Container(
              //   margin: const EdgeInsets.only(left: 50, right: 50, top: 25),
              //   child: ParchmentContainer(
              //     raggedness: raggedness,
              //     seed: parchmentSeed,
              //     height: constraints.maxHeight,
              //     width: constraints.maxWidth,
              //     child: const SizedBox(),
              //   ),
              // ),
              // // Container(
              // //   height: constraints.maxHeight,
              // //   width: constraints.maxWidth,
              // //   margin: const EdgeInsets.only(
              // //     bottom: 10,
              // //     left: 75,
              // //     right: 75,
              // //     top: 50,
              // //   ),
              // //   child: GestureDetector(
              // //     onTap: () {
              // //       print('showAll');
              // //       setState(() {
              // //         showAll = true;
              // //       });
              // //     },
              // //     // child: Marquee(
              // //     //   text:
              // //     //       'There once was a boy who told this story about a boy: That way you don\'t need to manually thread constraints through — both stack layers just match the outer SizedBox automatically. Either approach gets you the same result, so keep whichever feels cleaner in your version. And yeah — the random seed/raggedness generator is a nice touch, gives you a fresh "torn" look each load instead of the same shape every time. Have fun tweaking it! Oh but also, I just need a little more from you...',
              // //     //   scrollAxis: Axis.vertical,
              // //     // ),
              // //     child: SingleChildScrollView(
              // //       controller: scrollController,
              // //       child: AnimatedTextKit(
              // //         controller: textController,
              // //         onNext: (index, last) {
              // //           print('onNext index: $index');
              // //           print('onNext last: $last');
              // //         },
              // //         onNextBeforePause: (index, last) {
              // //           print('onNextBeforePause index: $index');
              // //           print('onNextBeforePause last: $last');
              // //         },
              // //         isRepeatingAnimation: false,
              // //         // totalRepeatCount: 1,
              // //         displayFullTextOnTap: true,
              // //         pause: const Duration(milliseconds: 1000),
              // //         stopPauseOnTap: true,
              // //         // repeatForever: true,
              // //         onTap: () {
              // //           print('animated text kit tap');
              // //         },
              // //         onFinished: () {
              // //           print('onFinished');
              // //           scrollController.animateTo(
              // //             500,
              // //             duration: const Duration(seconds: 3),
              // //             curve: Curves.linear,
              // //           );
              // //         },
              // //         animatedTexts: [
              // //           // TyperAnimatedText(
              // //           //   'That way you don\'t need to manually thread constraints through — both stack layers just match the outer SizedBox automatically.',
              // //           //   textStyle: TextStyle(
              // //           //     color: Theme.of(context).primaryColor,
              // //           //     // fontFamily: "HoldMoney",
              // //           //     fontSize: 32.0,
              // //           //   ),
              // //           //   speed: const Duration(milliseconds: 30),
              // //           // ),
              // //           TyperAnimatedText(
              // //             'That way you don\'t need to manually thread constraints through — both stack layers just match the outer SizedBox automatically. Either approach gets you the same result, so keep whichever feels cleaner in your version. And yeah — the random seed/raggedness generator is a nice touch, gives you a fresh "torn" look each load instead of the same shape every time. Have fun tweaking it! Oh but also, I just need a little more from you...',
              // //             textStyle: TextStyle(
              // //               color: Theme.of(context).primaryColor,
              // //               // fontFamily: "HoldMoney",
              // //               fontSize: 32.0,
              // //             ),
              // //             speed: const Duration(milliseconds: 30),
              // //           ),
              // //         ],
              // //       ),
              // //     ),
              // //   ),
              // //   // child: const Text(
              // //   //   'That way you don\'t need to manually thread constraints through — both stack layers just match the outer SizedBox automatically. Either approach gets you the same result, so keep whichever feels cleaner in your version. And yeah — the random seed/raggedness generator is a nice touch, gives you a fresh "torn" look each load instead of the same shape every time. Have fun tweaking it!',
              // //   //   style: TextStyle(fontFamily: 'Georgia', fontSize: 16),
              // //   // ),
              // // ),
              // // ScrollBanner(
              // //   width: constraints.maxWidth,
              // //   height: constraints.maxHeight,
              // //   child: Texxt('test'),
              // // ),
              // Container(
              //   height: constraints.maxHeight,
              //   width: constraints.maxWidth,
              //   margin: const EdgeInsets.only(
              //     bottom: 10,
              //     left: 75,
              //     right: 75,
              //     top: 50,
              //   ),
              //   child: FlipPage(
              //     pages: [
              //       Container(
              //         color: Colors.amber,
              //         child: Center(child: Text('1')),
              //       ),
              //       Container(
              //         color: Colors.teal,
              //         child: Center(child: Text('2')),
              //       ),
              //       // AnimatedTextKit(
              //       //   controller: textController,
              //       //   onNext: (index, last) {
              //       //     print('onNext index: $index');
              //       //     print('onNext last: $last');
              //       //   },
              //       //   onNextBeforePause: (index, last) {
              //       //     print('onNextBeforePause index: $index');
              //       //     print('onNextBeforePause last: $last');
              //       //   },
              //       //   isRepeatingAnimation: false,
              //       //   // totalRepeatCount: 1,
              //       //   displayFullTextOnTap: true,
              //       //   pause: const Duration(milliseconds: 1000),
              //       //   stopPauseOnTap: true,
              //       //   // repeatForever: true,
              //       //   onTap: () {
              //       //     print('animated text kit tap');
              //       //   },
              //       //   onFinished: () {
              //       //     print('onFinished');
              //       //     // scrollController.animateTo(
              //       //     //   500,
              //       //     //   duration: const Duration(seconds: 3),
              //       //     //   curve: Curves.linear,
              //       //     // );
              //       //   },
              //       //   animatedTexts: [
              //       //     // TyperAnimatedText(
              //       //     //   'That way you don\'t need to manually thread constraints through — both stack layers just match the outer SizedBox automatically.',
              //       //     //   textStyle: TextStyle(
              //       //     //     color: Theme.of(context).primaryColor,
              //       //     //     // fontFamily: "HoldMoney",
              //       //     //     fontSize: 32.0,
              //       //     //   ),
              //       //     //   speed: const Duration(milliseconds: 30),
              //       //     // ),
              //       //     TyperAnimatedText(
              //       //       'That way you don\'t need to manually thread constraints through — both stack layers just match the outer SizedBox automatically. Either approach gets you the same result, so keep whichever feels cleaner in your version. And yeah — the random seed/raggedness generator is a nice touch, gives you a fresh "torn" look each load instead of the same shape every time. Have fun tweaking it! Oh but also, I just need a little more from you...',
              //       //       textStyle: TextStyle(
              //       //         color: Theme.of(context).primaryColor,
              //       //         // fontFamily: "HoldMoney",
              //       //         fontSize: 32.0,
              //       //       ),
              //       //       speed: const Duration(milliseconds: 30),
              //       //     ),
              //       //   ],
              //       // ),
              //       Container(
              //         color: Colors.indigo,
              //         child: Center(child: Text('3')),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> buildBackgroundVeil(
    BuildContext context,
    Color color,
    double height,
    double width,
  ) {
    double borderHeight = 200;

    return [
      // Full
      AnimatedContainer(
        duration: Duration(seconds: 1),
        height: height,
        width: width,
        color: Theme.of(
          context,
        ).scaffoldBackgroundColor.withAlpha(isInitialized ? 100 : 255),
      ),
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

  Widget emptyFlaction() {
    return FloatingActionButton(
      backgroundColor: Colors.transparent,
      elevation: 0,
      onPressed: null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(100),
      ),
    );
  }
}
