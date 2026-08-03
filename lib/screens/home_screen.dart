import 'dart:async';
import 'dart:ui' as ui;

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
import 'package:once_upon_a_time/barrel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// TODO:
// 1) Add a menu button that contains:
// - Give new story
// - Stumped, give answer
// - Help / Contact
// - Secret Admin login
// - Restart story (?)
// 2) On a correct solve, the rest of the story should be told with some victory
// fanfare in the background. Player can keep reading or go on to the next story.
// 3) At the end of the chapters, give the Player one last chance to solve or
// give them the answer.

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool canProceed = false;
  bool hasPrev = false;
  bool hasShader = false;
  bool isOpened = false;
  bool isVideoInitialized = false;
  bool showFloatingMenu = true;
  int chapterIndex = 0;
  int checkpointIndex = 0;
  int parchmentSeed = 0;
  List<String> story = [];

  final GlobalKey<PageFlipperState> storybookKey = GlobalKey();

  late final AnimationController entrance;
  late final AnimatedTextController textController;
  late ScrollController scrollController;
  late Timer scrollTimer;
  late ui.FragmentShader pageShader;

  @override
  void initState() {
    super.initState();

    loadShader();

    entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    scrollController = ScrollController();
    textController = AnimatedTextController();

    scrollTimer = Timer(Duration.zero, () {});

    story = Story.storyExample1.chapters;
  }

  @override
  void dispose() {
    entrance.dispose();
    pageShader.dispose();
    scrollController.dispose();
    scrollTimer.cancel();
    textController.pause();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isPortrait = size.height > size.width; // TODO: a better way for this

    return Scaffold(
      appBar: CustomAppBar(isPortrait: isPortrait),
      endDrawer: CustomDrawer(resetStory: resetStory),
      floatingActionButton: AnimatedOpacity(
        opacity: isOpened ? 1 : 0,
        duration: Duration(milliseconds: 500),
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return state.showActionButtons
                ? buildStorybookActions()
                : const SizedBox();
          },
        ),
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
                Transform.flip(
                  flipX: true,
                  child: BackgroundVideo(
                    isInitialized: () {
                      setState(() {
                        isVideoInitialized = true;
                      });
                    },
                  ),
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
                        initializeScrollTimer();
                      },
                    ),
                  ),
                ),
                if (isOpened && hasShader) ...[
                  PageFlipper(
                    key: storybookKey,
                    canFlip: canProceed,
                    width: width,
                    height: height,
                    layout: layout,
                    spineOffset: layout.spineOffset,
                    pageCount: story.length,
                    pageBuilder:
                        (context, index, isVisible, goingBack, showText) =>
                            ParchmentPage(
                              width: layout.pageWidth,
                              height: layout.pageHeight,
                              seed: index,
                              shader: pageShader,
                              fadeStart: 0.0,
                              fadeEnd: layout.fadeEnd,
                              layout: layout,
                              child: isVisible && showText
                                  ? buildChapterText(layout, showText, index)
                                  : const SizedBox(),
                            ),
                    onPageChanged: (value) {
                      // print('onPageChanged: Page ${value + 1}');
                      setState(() {
                        // scrollController.jumpTo(0);
                        scrollController.dispose();
                        scrollController = ScrollController();

                        canProceed = value < checkpointIndex;
                        chapterIndex = value;
                        checkpointIndex = value > checkpointIndex
                            ? value
                            : checkpointIndex;

                        textController.play();
                      });

                      initializeScrollTimer();
                    },
                    onPageTap: () {
                      // print('onPageTap!');
                      setState(() {
                        textController.pause();
                        canProceed = true;
                      });
                    },
                  ),
                ],
                !isPortrait
                    ? Positioned(
                        right: 10,
                        top: 10,
                        child: FloatingActionButton(
                          heroTag: 'prevChp',
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(100),
                          ),
                          onPressed: () {
                            Scaffold.of(context).openEndDrawer();
                          },
                          child: Transform.flip(
                            flipX: true,
                            child: Icon(
                              Icons.menu_book,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> loadShader() async {
    final program = await ui.FragmentProgram.fromAsset(
      'assets/shaders/parchment_page.frag',
    );
    setState(() {
      // curlShader = program.fragmentShader();
      pageShader = program.fragmentShader();
      hasShader = true;
      // showShader = true;
    });
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

  void initializeScrollTimer() {
    // print('initializeScrollTimer');
    setState(() {
      scrollTimer = Timer.periodic(Duration(milliseconds: 300), (tick) {
        // print('tick: ${tick.tick}');
        if (scrollController.hasClients) {
          // print('hasClients');
          final maxScroll = scrollController.position.maxScrollExtent;
          // print('animating to: $maxScroll');
          if (chapterIndex == checkpointIndex) {
            // print("SCROLL");
            scrollController.animateTo(
              maxScroll,
              duration: Duration(milliseconds: 300),
              curve: Curves.linear,
            );
          }
        }
        if (canProceed) {
          // print('can proceed, so cancel');
          scrollTimer.cancel();
        }
        // TODO: remove this after debugging
        // if (tick.tick > 30) {
        //   print('30 ticks: cancel for safety');
        //   scrollTimer.cancel();
        // }
      });
    });
  }

  void resetStory() {
    // print('reset story');
    setState(() {
      textController.pause();
      scrollController.dispose();
      scrollController = ScrollController();
      canProceed = false;
      hasPrev = false;
      chapterIndex = 0;
      checkpointIndex = 0;
      textController.reset();
      textController.play();
    });
    initializeScrollTimer();
  }

  Widget buildChapterText(BookLayout layout, bool showText, int index) {
    String chapterText = story[index]
        .replaceAll('. ', '.\n\n')
        .replaceAll('! ', '!\n\n')
        .replaceAll('? ', '?\n\n');

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (index == 0) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Texxt('O', size: layout.fontSize * 3, height: 1),
                Expanded(
                  child: Texxt(
                    'nce upon a time..',
                    size: layout.fontSize,
                    height: 1.333,
                    useDark: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: layout.fontSize),
          ],
          index < checkpointIndex
              ? Texxt(chapterText, size: layout.fontSize, useDark: true)
              : BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, state) {
                    return AnimatedTextKit(
                      controller: textController,
                      isRepeatingAnimation: false,
                      // onNext: (index, last) {}, // (RIP) overridden
                      // onNextBeforePause: (index, last) {}, // (RIP) overridden
                      // displayFullTextOnTap: true, // (RIP) overridden
                      // stopPauseOnTap: true, // (RIP) overridden
                      pause: const Duration(milliseconds: 1000),
                      onTap: () {}, // (RIP) overridden
                      onFinished: () {
                        setState(() {
                          canProceed = true;
                        });
                      },
                      animatedTexts: [
                        TyperAnimatedText(
                          chapterText,
                          textStyle: TextStyle(
                            color: Theme.of(context).colorScheme.inverseSurface,
                            fontSize: layout.fontSize,
                            fontFamily: state.fontFamily,
                          ),
                          speed: const Duration(milliseconds: 30),
                        ),
                      ],
                    );
                  },
                ),
        ],
      ),
    );
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
                  onPressed: chapterIndex < 1 || !canProceed
                      ? null
                      : () {
                          // print('prev chp');
                          setState(() {
                            chapterIndex -= 1;
                          });
                          storybookKey.currentState?.prevPage();
                        },
                  child: Transform.flip(
                    flipX: true,
                    child: Icon(
                      Icons.auto_stories,
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withAlpha(canProceed ? 255 : 100),
                    ),
                  ),
                ),
          // TODO: delay showing solve until chapter 2 (?)
          FloatingActionButton(
            heroTag: 'solve',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(100),
            ),
            onPressed: !canProceed
                ? null
                : () {
                    print('TODO: solve');
                  },
            child: Icon(
              Icons.auto_awesome,
              color: Theme.of(
                context,
              ).colorScheme.onPrimary.withAlpha(canProceed ? 255 : 100),
            ),
          ),
          chapterIndex + 1 >= story.length
              ? emptyFlaction()
              : FloatingActionButton(
                  heroTag: 'goOn',
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(100),
                  ),
                  onPressed: !canProceed
                      ? null
                      : () {
                          // print('go on');
                          if (chapterIndex + 1 < story.length) {
                            setState(() {
                              scrollController.jumpTo(0);
                              chapterIndex += 1;
                            });
                            storybookKey.currentState?.nextPage();
                          }
                        },
                  child: Icon(
                    Icons.auto_stories,
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimary.withAlpha(canProceed ? 255 : 100),
                  ),
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
