import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:once_upon_a_time/barrel.dart';

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
    final program = await ui.FragmentProgram.fromAsset(
      'assets/shaders/parchment_page.frag',
    );
    setState(() {
      // curlShader = program.fragmentShader();
      pageShader = program.fragmentShader();
      hasShader = true;
    });
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {
      showShader = true;
    });
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
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Texxt(
          'Once Upon a Time (${size.width}, ${size.height})',
          isOlde: true,
          useDark: false,
        ),
        actions: [
          // IconButton(icon: Icon(Icons.info), onPressed: () {}),
        ],
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: isOpened ? 1 : 0,
        duration: Duration(milliseconds: 500),
        child: buildStorybookActions(),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double height = constraints.maxHeight;
            double width = constraints.maxWidth;
            BookLayout layout = computeBookLayout(
              screenSafeWidth: width,
              screenSafeHeight: height,
            );

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
                      final slide = Curves.easeOutBack.transform(
                        entrance.value,
                      );
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
                // if (isOpened && hasShader && height > 400) ...[
                if (isOpened && hasShader) ...[
                  GestureDetector(
                    onLongPress: () {
                      print('($width, $height)');
                      print('(${layout.bookWidth}, ${layout.bookWidth})');
                      print('(${layout.pageWidth}, ${layout.pageHeight})');

                      // Preface: we want to look at "screenSafe" sizes to work
                      // around nav bars, status bars, etc. We CAN use screen
                      // sizes, e.g. MediaQuery.of(context).size.height, but we
                      // are getting LayBuilder box constraints to determine the
                      // screenSafeHeight and screenSafeWidth.
                      // Aspect Ratio of to maintain is ~5:6 or 0.8371:1, e.g.
                      // 560ssw x 669ssh (560sw x 725sh). This is the point
                      // where it shrinks from width changes to height changes
                      // and vice versa.

                      // Goal: find a formula (or two) that handles dealing with
                      // the specific aspect ratio above while supplying values
                      // for the following variables:
                      // screenSafeWidth
                      // screenSafeHeight
                      // pageWidth
                      // pageHeight,
                      // spineOffset
                      // flipperOffset
                      // fadeEnd

                      // For when screenSafeHeight == 941 (sh == 997)
                      // screenSafeWidth x screenSafeHeight => pageWidth x pageHeight (spineOffset) [flipperOffset] {fadeEnd} "prevWidth"
                      // 390ssw x 788ssh => 250pw x 345ph (58so) [-12.5off] {0.333fe} "315"
                      // 500ssw x 941ssh => 330pw x 447.5ph (76so) [-15off] {0.275fe} "415"
                      // 670ssw x 941ssh => 445pw x 610ph (103so) [-25off] {0.225fe} "570"
                      // 778ssw x 941ssh => 525pw x 710ph (120so) [-26.5off] {0.2fe} "660"
                      // > maintains above, i.e. triggers the aspect ratio to
                      // hold after this point, and we maintain. BUT if screen
                      // height goes down, we need below to recalculate and
                      // change our variables based on the new height & width.

                      // For when screenSafeWidth == 560 (sw == 560)
                      // screenSafeWidth => pageWidth x pageHeight (spineOffset) [flipperOffset] {fadeEnd} "prevWidth"
                      // 500ssw x 941ssh => 330pw x 447.5ph (76so) [-15off] {0.275fe} "415"
                      // 560ssw x 941ssh => 375pw x 500ph (86so) [-17.5off] {0.275fe} "470"
                      // 560ssw x 800ssh => 375pw x 500ph (86so) [-17.5off] {0.275fe} "470"
                      // 560ssw x 674ssh => 375pw x 500ph (85so) [-17.5off] {0.275fe} "470"
                      // This is no longer holding those values because the aspect
                      // ratio.
                      // 560ssw x 550ssh => 310pw x 410ph (70so) [-15.5off] [0.225fe] "387.5"
                      // 560ssw x 424ssh => 237.5pw x 315ph (53so) [-10off] [0.2fe] "297.5"
                      // 560ssw x 244ssh => 137.5pw x 185ph (31so) [-6.5off] [0.333fe] "170"

                      // Consideration: when the aspect ratio is triggered and
                      // more width is added, the calculations stay the same;
                      // however, if the height changes, we need to recalculate.

                      // Does it look like this?
                      // screenSafeWidth / screenSafeHeight > 0.83 ?
                      //    heightForumula(height, width) :
                      //    widthForumula(height, width),
                    },
                    child: PageFlipper(
                      // widget.width > 778
                      //     ? 778 - widget.spineOffset
                      //     : widget.width - widget.spineOffset,
                      // widget.height < 674
                      //     ? 674 - widget.spineOffset (70)
                      //     : widget.width (560) - widget.spineOffset (70)
                      // 5:6 || 0.8371:1 * w/h
                      // 0.8371/1 == 560/674
                      // 460.405
                      key: storybookKey,
                      width: width,
                      height: height,
                      layout: layout,
                      spineOffset: layout.spineOffset,
                      pageCount: story.length,
                      pageBuilder: (context, index, isVisible, showBack) =>
                          ParchmentPage(
                            width: layout.pageWidth,
                            height: layout.pageHeight,
                            arwidth: width,
                            arheight: height,
                            seed: index,
                            shader: pageShader,
                            fadeStart: 0.0,
                            // DACO
                            // TODO: smaller screen size, i.e. mobile @ 390,
                            // are better with bigger values, e.g. 0.333.
                            fadeEnd: layout.fadeEnd,
                            layout: layout,
                            child: isVisible
                                ? Text(
                                    '${index + 1} $exampleText',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.inverseSurface,
                                      fontSize: layout.fontSize,
                                    ),
                                  )
                                : const SizedBox(),
                          ),
                      onPageChanged: (value) {
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
          // TODO: delay showing solve until chapter 2 (?)
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
          // TODO: delay next page until all text is shown (?)
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
