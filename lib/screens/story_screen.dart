import 'dart:async';
import 'dart:ui' as ui;

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:once_upon_a_time/barrel.dart';

class StoryScreen extends StatefulWidget {
  final String? storyId;

  const StoryScreen({super.key, this.storyId});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

// TODO: SOLVE
// 1) Add a menu button that contains:
// - Stumped, give answer
// 2) On a correct solve, the rest of the story should be told with some victory
// fanfare in the background. Player can keep reading or go on to the next story.
// 3) At the end of the chapters, give the Player one last chance to solve or
// give them the answer.

class _StoryScreenState extends State<StoryScreen>
    with TickerProviderStateMixin {
  bool canProceed = false;
  bool hasPrev = false;
  bool hasShader = false;
  bool isCyclingStory = false;
  bool isOpened = false;
  bool isVideoInitialized = false;
  bool showFloatingMenu = true;
  int chapterIndex = 0;
  int checkpointIndex = 0;
  int parchmentSeed = 0;
  String? urlStoryId = '';

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

    // Note: need an init check with the widget.storyId for when we have stories
    // and StoryBloc isn't triggering a update via listener, i.e. bloc listener
    // triggers AFTER GetStories has done its thing (or we handle errors).
    // If storyId is null, cool do nothing.
    // If it isn't null / '', then we should check for the story by id;
    // however, we may still be GettingStories. So if we are getting stories,
    // we should let bloc lisenter help and GetById (see listener). If we have
    // stories, i.e. not loading or initial, we should try to GetById. If the
    // story doesn't exist, bloc listener should be able to handle the error.
    StoryStateStatus status = context.read<StoryBloc>().state.status;
    urlStoryId = widget.storyId;
    // print('init status: $status');
    // print('init storyId: $urlStoryId');
    // Gets the story via urlId if we have stories; see listener for more
    if (urlStoryId != null &&
        urlStoryId != '' &&
        (status != StoryStateStatus.initial &&
            status != StoryStateStatus.loading)) {
      // print('get that init id; already have stories on deck');
      context.read<StoryBloc>().add(GetStoryById(storyId: urlStoryId!));
    } else if (status == StoryStateStatus.error) {
      // If we have an error upon loading the page, clear it out and get a story
      // print('error so get a new story');
      context.read<StoryBloc>().add(NewStory(storyId: ''));
    }
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

    return BlocListener<StoryBloc, StoryState>(
      listenWhen: (previous, current) =>
          previous.currentStory.id != current.currentStory.id ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        // print('trigger story bloc');
        // print('urlStoryId: $urlStoryId');
        // print('state.currentStory.id: ${state.currentStory.id}');
        // print('state.errorMessage: ${state.errorMessage}');

        // Handle showing a new story when the storybook is open
        if (isOpened) {
          storybookKey.currentState?.showNewStory();
          setState(() {
            scrollController.dispose();
            scrollController = ScrollController();

            canProceed = true;
            chapterIndex = 0;
            checkpointIndex = 0;

            textController.play();
          });
        }

        // Show errors if present
        if (state.errorMessage != '') {
          snackError(context);
        } else if (urlStoryId != null &&
            urlStoryId != '' &&
            urlStoryId != state.currentStory.id) {
          // Gets story by urlId after StoryBloc is done w/ GetStories & no errors
          // print('gotta go GET ETTT');
          context.read<StoryBloc>().add(GetStoryById(storyId: urlStoryId!));
        }
      },
      child: BlocBuilder<StoryBloc, StoryState>(
        builder: (context, state) {
          return Scaffold(
            appBar: CustomAppBar(isPortrait: isPortrait),
            endDrawer: CustomDrawer(
              isStorybookOpen: isOpened,
              resetStory: resetStory,
              resetUrlId: (urlId) {
                setState(() {
                  urlStoryId = '';
                });
                context.read<StoryBloc>().add(NewStory(storyId: urlId));
              },
              solveStory: () =>
                  solve(context, state.currentStory, viaDrawer: true),
              urlId: urlStoryId,
            ),
            floatingActionButton: AnimatedOpacity(
              opacity: isOpened ? 1 : 0,
              duration: Duration(milliseconds: 500),
              child: BlocBuilder<SettingsCubit, SettingsState>(
                builder: (_, settingsState) {
                  return state.status == StoryStateStatus.loading ||
                          !settingsState.showActionButtons
                      ? const SizedBox()
                      : buildStorybookActions(
                          state.currentStory.chapters,
                          state.currentStory,
                        );
                },
              ),
            ),
            body: Stack(
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
                  size.height,
                  size.width,
                ),
                SafeArea(
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
                                canOpen:
                                    state.status != StoryStateStatus.loading,
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
                              solve: () => solve(context, state.currentStory),
                              pageCount: state.currentStory.chapters.length,
                              pageBuilder:
                                  (
                                    context,
                                    index,
                                    isVisible,
                                    goingBack,
                                    showText,
                                  ) => ParchmentPage(
                                    width: layout.pageWidth,
                                    height: layout.pageHeight,
                                    seed: index,
                                    shader: pageShader,
                                    fadeStart: 0.0,
                                    fadeEnd: layout.fadeEnd,
                                    layout: layout,
                                    child: isVisible && showText
                                        ? buildChapterText(
                                            layout,
                                            showText,
                                            index,
                                            state.currentStory.chapters,
                                          )
                                        : const SizedBox(),
                                  ),
                              onPageChanged: (value) {
                                setState(() {
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
                                setState(() {
                                  textController.pause();
                                  canProceed = true;
                                });
                              },
                              onPromptToSolve: () =>
                                  promptToSolve(context, state),
                            ),
                          ],
                          !isPortrait
                              ? Positioned(
                                  right: 10,
                                  top: 10,
                                  child: FloatingActionButton(
                                    heroTag: 'prevChp',
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadiusGeometry.circular(100),
                                    ),
                                    onPressed: () {
                                      Scaffold.of(context).openEndDrawer();
                                    },
                                    child: Transform.flip(
                                      flipX: true,
                                      child: Icon(
                                        Icons.menu_book,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.inverseSurface,
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
              ],
            ),
          );
        },
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

  void promptToSolve(BuildContext context, StoryState state) {
    if (state.currentStory != Story.emptyStory) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text('That\'s the last page.'),
            action: SnackBarAction(
              label: 'Care to solve?',
              textColor: Theme.of(context).colorScheme.primary,
              onPressed: () => solve(context, state.currentStory),
            ),
          ),
        );
    } else {
      snackError(context);
    }
  }

  void resetStory() {
    storybookKey.currentState?.resetStory();

    setState(() {
      scrollController.dispose();
      scrollController = ScrollController();

      canProceed = true;
      chapterIndex = 0;
      checkpointIndex = 0;

      textController.play();
    });
  }

  void snackError(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('This story is a URL fairytale..'),
          action: SnackBarAction(
            label: 'Notify support?',
            textColor: Theme.of(context).colorScheme.primary,
            onPressed: () => context.go('/contact/story-$urlStoryId'),
          ),
        ),
      );
  }

  void solve(BuildContext context, Story story, {bool? viaDrawer = false}) {
    if (viaDrawer!) {
      Navigator.of(context).pop();
    }
    showDialog(
      context: context,
      builder: (context) {
        return SolveModal(story: story);
      },
    );
  }

  Widget buildChapterText(
    BookLayout layout,
    bool showText,
    int index,
    List<String> chapters,
  ) {
    // TODO: how does user input handle?
    String chapterText = chapters[index]
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

  Widget buildStorybookActions(List<String> chapters, Story currentStory) {
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
                          setState(() {
                            chapterIndex -= 1;
                          });
                          storybookKey.currentState?.prevPage();
                        },
                  child: Transform.flip(
                    flipX: true,
                    child: Icon(
                      Icons.auto_stories,
                      color: Theme.of(context).colorScheme.inverseSurface
                          .withAlpha(canProceed ? 255 : 100),
                    ),
                  ),
                ),
          FloatingActionButton(
            heroTag: 'solve',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(100),
            ),
            onPressed: !canProceed ? null : () => solve(context, currentStory),
            child: Icon(
              Icons.auto_awesome,
              color: Theme.of(
                context,
              ).colorScheme.inverseSurface.withAlpha(canProceed ? 255 : 100),
            ),
          ),
          chapterIndex + 1 >= chapters.length
              ? emptyFlaction()
              : FloatingActionButton(
                  heroTag: 'goOn',
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(100),
                  ),
                  onPressed: !canProceed
                      ? null
                      : () {
                          if (chapterIndex + 1 < chapters.length) {
                            setState(() {
                              scrollController.jumpTo(0);
                              chapterIndex += 1;
                            });
                            storybookKey.currentState?.nextPage();
                          }
                        },
                  child: Icon(
                    Icons.auto_stories,
                    color: Theme.of(context).colorScheme.inverseSurface
                        .withAlpha(canProceed ? 255 : 100),
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
