// import 'dart:math';

// import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:once_upon_a_time/barrel.dart';

// Future<ui.FragmentShader> loadPageShader() async {
//   try {
//     final program = await ui.FragmentProgram.fromAsset(
//       'assets/shaders/page_curl.frag',
//     );
//     print('shader OK');
//     return program.fragmentShader();
//   } catch (e) {
//     print('error: $e');
//     throw Exception();
//   }
// }
// Future<ui.FragmentShader> loadParchmentPageShader() async {
//   final program = await ui.FragmentProgram.fromAsset(
//     'assets/shaders/parchment_page.frag',
//   );
//   print('derp');
//   return program.fragmentShader();
// }

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
class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool hasPrev = false;
  bool isOpened = false;
  bool isVideoInitialized = false;
  // bool showAll = false;
  double raggedness = 0;
  int chapterIndex = 0;
  int parchmentSeed = 0;
  List<String> story = [];
  String exampleText =
      'If this never prints, the widget isn\'t in the tree at all — easy to do if it\'s built conditionally and that condition isn\'t true yet, or if it\'s nested inside something that hasn\'t been reached.';

  bool hasShader = false;
  bool showShader = false;
  late ui.FragmentShader pageShader;

  // PageImageCache? _imageCache;
  // ui.FragmentShader? curlShader;

  // final GlobalKey<BookOpenerState> openerKey = GlobalKey();
  final GlobalKey<PageFlipperState> storybookKey = GlobalKey();

  late final AnimationController entrance;

  @override
  void initState() {
    super.initState();

    entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    loadShader();
    story = Story.storyExample1.chapters;
  }

  Future<void> loadShader() async {
    // pageShader = await loadPageShader();
    print('a');
    final program = await ui.FragmentProgram.fromAsset(
      'assets/shaders/parchment_page.frag',
    );
    print('b');
    setState(() {
      // curlShader = program.fragmentShader();
      pageShader = program.fragmentShader();
      hasShader = true;
    });
    print('c');
    await Future.delayed(Duration(milliseconds: 100));
    print('d');
    setState(() {
      showShader = true;
    });
    print('e');
  }

  @override
  void dispose() {
    // curlShader?.dispose();
    entrance.dispose();
    pageShader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Texxt('Once Upon a Time', isOlde: true, useDark: false),
        actions: [
          IconButton(
            icon: Icon(Icons.navigate_next),
            onPressed: () {
              print('book');
              context.goNamed('curling');
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
      floatingActionButton: buildStorybookActions(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double height = constraints.maxHeight;
          double width = constraints.maxWidth;

          return Stack(
            children: [
              // PageTextureCapture(
              //   pageCount: story.length, // _pageCount,
              //   pageWidth: width, // _flipAreaWidth,
              //   pageHeight: height, // _pageHeight,
              //   // pageBuilder: _pageContent,
              //   pageBuilder: (context, index) => ParchmentPagePlaceholder(
              //     height: 500, // height
              //     width: width,
              //     seed: index,
              //     text: '${index + 1} $exampleText',
              //   ),
              //   onReady: (cache) {
              //     debugPrint('onReady fired, cache.isReady = ${cache.isReady}');
              //     setState(
              //       () => _imageCache = cache,
              //     ); // <- the setState was the missing piece
              //   },
              // ),
              BackgroundVideo(
                isInitialized: () {
                  // print('isVideoInitialized');
                  setState(() {
                    isVideoInitialized = true;
                  });
                },
              ),
              ...buildBackgroundVeil(
                context,
                Theme.of(context).colorScheme.inverseSurface.withAlpha(100),
                height,
                width,
              ),
              Center(
                child: AnimatedBuilder(
                  animation: entrance,
                  builder: (context, child) {
                    final slide = Curves.easeOutBack.transform(entrance.value);
                    return Transform.translate(
                      offset: Offset(0, (1 - slide) * -300),
                      child: child,
                    );
                  },
                  child: Storybook(
                    width: width,
                    height: height,
                    frontCover: Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(right: 25),
                      child: Image.asset(
                        'assets/images/storybook-cover.png',
                        scale: 0.1,
                      ),
                    ),
                    pages: const SizedBox(),
                    onOpened: () {
                      setState(() {
                        isOpened = true;
                      });
                    },
                  ),
                ),
              ),

              // TODO: come back to this and see how best to handle
              // height > 400 && isOpened
              //     ? buildStorybookContent(height, width)
              //     : const SizedBox(),
              if (isOpened && hasShader) ...[
                // if (isOpened) ...[
                GestureDetector(
                  onLongPress: () {
                    print('($width, $height)');
                    // For when screenHeight (941) > screenWidth (see below)
                    // screenWidth = pageHeight (spineOffset) | pageWidth
                    // 500sw = 320pw x 440ph (75so)
                    // 670sw = 425pw x 600ph (105so)
                    // 775sw = 500pw x 700ph (120so)
                    // > maintains above
                    // Note: screenWidth >= screenHeight after this point, and
                    // we maintain. BUT if screen height goes down, we need below
                  },
                  child: PageFlipper(
                    key: storybookKey,
                    width: width,
                    height: height,
                    // spineOffset: height / 10 > 55 ? 55 : height / 10, // 70,
                    // spineOffset: height / 20 > 70 ? 70 : height / 10, // 70,
                    spineOffset: 75,
                    pageCount: story.length,
                    pageBuilder: (context, index, isVisible, showBack) =>
                        // buildStorybookContent(isVisible, height, width, index),
                        // PagePlaceholder(
                        //   height: 440,
                        //   width: 320,
                        //   seed: index,
                        //   text: isVisible ? '${index + 1} $exampleText' : '',
                        // ),
                        ParchmentPage(
                          width: 330,
                          height: 447.5,
                          seed: index,
                          shader: pageShader,
                          // TODO
                          // fadeStart: showBack ? 1.0 : 0.0,
                          // fadeEnd: showBack ? 0.8 : 0.2,
                          // child: Text('${index + 1} $exampleText'),
                          child: isVisible
                              ? Texxt('${index + 1} $exampleText')
                              // ? const SizedBox()
                              : const SizedBox(),
                        ),
                    // pageImageCache: _imageCache!,
                    // curlShader: pageShader,
                    // curlShader: curlShader!,
                    // pageBackBuilder: (context, index, isVisible) =>
                    //     buildStorybookContent(isVisible, height, width, index),
                    // pageBackBuilder: (context, index, isVisible) =>
                    //     Container(width: 100, height: 100, color: Colors.red),
                    // pageBuilder: (context, index, isVisible) => PageContainerTemp(
                    //   // DACO
                    //   // height: bookHeight,
                    //   // height: isPortrait ? bookHeight : constraints.maxHeight,
                    //   // height: isPortrait ? width - 125 : height,
                    //   height: height,
                    //   // width: bookWidth,
                    //   // width: isPortrait
                    //   //     ? width - 230 + 0
                    //   //     // (constraints.maxHeight / 10)
                    //   //     : width,
                    //   width: width,
                    //   seed: index,
                    //   // Note: the value of index isn't correct on prev; it's
                    //   // losing an extra "1"
                    //   text: isVisible ? 'Page ${index + 1}' : '',
                    // ),
                    onPageChanged: (value) {
                      // The new index being shown, i.e. Page {$value + 1}
                      print('onPageChanged: Page ${value + 1}');
                      setState(() {
                        chapterIndex = value;
                      });
                    },
                  ),
                ),
              ],
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
        ).scaffoldBackgroundColor.withAlpha(isVideoInitialized ? 100 : 255),
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

  Widget buildStorybookActions() {
    return Container(
      padding: const EdgeInsets.only(left: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          chapterIndex < 1
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
                          storybookKey.currentState?.prevPage();
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
                      storybookKey.currentState?.nextPage();
                    }
                  },
                  child: Icon(Icons.auto_stories),
                ),
        ],
      ),
    );
  }

  Widget buildStorybookContent(
    bool isVisible,
    double height,
    double width,
    int index,
  ) {
    // bool isPortrait = height > width;

    return Align(
      alignment: AlignmentGeometry.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          minHeight: 300,
          // maxHeight: height > width ? width - 100 : height - 100,
          // Note: height isn't perfect; there's some relationship
          // that's missing based on the current width
          maxHeight: height > width
              ? width - 70
              // : height - (height / 200 < 100 ? 100 : height / 200),
              : height - 100,
          minWidth: 250,
          maxWidth: width > height + 175 ? height - 175 : width - 175,
        ),
        // constraints: BoxConstraints(
        //   minHeight: 300,
        //   // maxHeight: height > width ? width - 100 : height - 100,
        //   // Note: height isn't perfect; there's some relationship
        //   // that's missing based on the current width
        //   maxHeight: height > width
        //       ? width - 100
        //       // : height - (height / 200 < 100 ? 100 : height / 200),
        //       : height - 100,
        //   minWidth: 250,
        //   maxWidth: width > height ? height - 250 : width - 175,
        // ),
        decoration: BoxDecoration(
          border: Border.all(),
          color: Colors.deepPurple.shade100.withAlpha(255),
        ),
        // margin: EdgeInsets.only(left: height / 10 > 50 ? 50 : height / 10),
        padding: const EdgeInsets.all(20),
        height: height,
        width: width,
        child: GestureDetector(
          onLongPress: () {
            print('($width, $height)');
          },
          child: SingleChildScrollView(
            child: isVisible
                ? Texxt(
                    story[index]
                        .replaceAll('. ', '.\n\n')
                        .replaceAll('! ', '!\n\n')
                        .replaceAll('? ', '?\n\n'),
                    size: 12 + (width > height ? height / 25 : width / 25),
                  )
                : const SizedBox(),
          ),
        ),
      ),
    );
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
