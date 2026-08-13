import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:once_upon_a_time/barrel.dart';

class PageFlipper extends StatefulWidget {
  final BookLayout layout;
  final bool canFlip;
  final double height;
  final double spineOffset;
  final double width;
  final Function solve;
  final Function onPromptToSolve;
  final Function? onPageTap;
  final int pageCount;
  final ValueChanged<int>? onPageChanged;
  final Widget Function(
    BuildContext context,
    int index,
    bool isVisible,
    bool prevPage,
    bool showText,
  )
  pageBuilder;

  // final PageImageCache pageImageCache;
  // final ui.FragmentShader curlShader;

  const PageFlipper({
    super.key,
    required this.canFlip,
    // required this.curlShader,
    required this.height,
    required this.layout,
    required this.pageBuilder,
    required this.pageCount,
    // required this.pageImageCache,
    required this.onPromptToSolve,
    required this.solve,
    required this.spineOffset,
    required this.width,
    this.onPageChanged,
    this.onPageTap,
  });

  @override
  State<PageFlipper> createState() => PageFlipperState();
}

class PageFlipperState extends State<PageFlipper>
    with SingleTickerProviderStateMixin {
  int currentPage = 0;
  bool forward = true;
  bool isFlipping = false;

  final double kPerspective = 0.001;

  late final AnimationController controller;

  bool get hasNext => currentPage < widget.pageCount - 1;
  bool get hasPrev => currentPage > 0;
  double get flipAreaWidth => widget.width - widget.spineOffset;

  Matrix4 perspectiveMatrix() =>
      Matrix4.identity()..setEntry(3, 2, kPerspective);

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          Positioned(
            left: widget.spineOffset,
            top: 0,
            bottom: 0,
            width: flipAreaWidth,
            child: Stack(
              children: [
                // Static, right page; seen 95% of the time
                Positioned.fill(
                  child: Container(
                    height: widget.height,
                    width: flipAreaWidth,
                    // color: Colors.blue.withAlpha(128),
                    alignment: AlignmentGeometry.centerLeft,
                    child: buildFace(
                      context,
                      currentPage,
                      front: true,
                      isVisible: !isFlipping,
                      showText: !forward,
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    final t = controller.value;

                    // Forward: the sheet starts flat (angle 0) and rotates
                    // AWAY, ending fully turned (angle -pi).
                    // Backward: the sheet we're animating is the PREVIOUS
                    // one - it starts already fully turned (angle -pi, which
                    // is why its back face matches what's currently flat on
                    // screen - no visual jump at drag start) and rotates
                    // back TO flat (angle 0) as the drag completes.
                    final angle = forward ? math.pi * t : math.pi * (1 - t);

                    // Which physical sheet is animating, and which of its
                    // two faces is pointed at the viewer right now. Using
                    // the angle itself (not raw t) keeps this correct for
                    // both directions without a separate branch.
                    final sheetIndex = forward ? currentPage : currentPage - 1;
                    final showingBack = angle.abs() > (math.pi / 2);

                    final liftShade = math.sin(t * math.pi).clamp(0.0, 1.0);

                    return Transform(
                      // The spine never moves - both directions pivot here.
                      alignment: Alignment.centerLeft,
                      origin: Offset(widget.layout.flipperOffset, 0),
                      transform: perspectiveMatrix()..rotateY(angle),
                      child: Stack(
                        children: [
                          if (!showingBack)
                            Container(
                              alignment: AlignmentGeometry.centerLeft,
                              // color: Colors.red.withAlpha(128),
                              child: buildFace(
                                context,
                                sheetIndex,
                                front: false,
                                isVisible: !isFlipping,
                                showText: true,
                              ),
                            )
                          else
                            Center(
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(math.pi),
                                child: buildFace(
                                  context,
                                  sheetIndex,
                                  front: false,
                                  isVisible: false,
                                  showText: false,
                                ),
                              ),
                            ),
                          Positioned.fill(
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  // The pivot is always on the left now, so
                                  // the lifting/lit edge is always the far
                                  // (right) edge of the flip area, for both
                                  // directions.
                                  gradient: LinearGradient(
                                    begin: Alignment.centerRight,
                                    end: Alignment.centerLeft,
                                    colors: [
                                      Colors.black.withValues(alpha: 0),
                                      Colors.black.withValues(
                                        alpha: 0.22 * liftShade,
                                      ),
                                    ],
                                    stops: const [0.6, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Static left page; shows when not on the first page
          if (currentPage > 0) ...[
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: widget.layout.prevWidth,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Center(
                      child: Transform(
                        alignment: Alignment.centerLeft,
                        transform: Matrix4.identity()..rotateY(math.pi),
                        child: AnimatedOpacity(
                          opacity: controller.isAnimating ? 0 : 1,
                          duration: Duration(milliseconds: 300),
                          child: buildFace(
                            context,
                            currentPage - 1,
                            front: true,
                            isVisible: false,
                            showText: false,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Right hit zone; moves forward only.
          Positioned(
            left: widget.spineOffset,
            top: 0,
            bottom: 0,
            right: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: onForwardDragUpdate,
              onHorizontalDragEnd: onForwardDragEnd,
              onLongPress: () => widget.solve(),
              onTap: nextPage,
            ),
          ),

          // Left hit zone; moves backward only.
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: widget.spineOffset,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: onBackwardDragUpdate,
              onHorizontalDragEnd: onBackwardDragEnd,
              onTap: prevPage,
            ),
          ),
        ],
      ),
    );
  }

  void onBackwardDragUpdate(DragUpdateDetails details) {
    if (!widget.canFlip || controller.isAnimating || !hasPrev) return;
    // Dragging rightward (positive delta) should increase turn progress
    // here, since we're pulling the previous page back into view.
    final delta = details.primaryDelta! / flipAreaWidth;
    setState(() {
      forward = false;
      isFlipping = true;
      controller.value = (controller.value + delta).clamp(0.0, 1.0);
    });
  }

  void onBackwardDragEnd(DragEndDetails details) => resolveDrag();

  void onForwardDragUpdate(DragUpdateDetails details) {
    if (!widget.canFlip || controller.isAnimating || !hasNext) return;
    final delta = -details.primaryDelta! / flipAreaWidth;
    setState(() {
      forward = true;
      isFlipping = true;
      controller.value = (controller.value + delta).clamp(0.0, 1.0);
    });
  }

  void onForwardDragEnd(DragEndDetails details) => resolveDrag();

  void resolveDrag() {
    if (controller.value >= 0.5) {
      setState(() {
        currentPage += forward ? 1 : -1;
        isFlipping = false;
        controller.animateTo(1.0, curve: Curves.easeOut).then((_) => commit());
      });
    } else {
      setState(() {
        isFlipping = false;
        controller.animateTo(0.0, curve: Curves.easeOut);
      });
    }
  }

  void commit() {
    setState(() {
      controller.value = 0.0;
      isFlipping = false;
    });
    widget.onPageChanged?.call(currentPage);
  }

  void nextPage() {
    widget.onPageTap?.call();

    if (!hasNext) widget.onPromptToSolve.call();
    if (!widget.canFlip || controller.isAnimating || !hasNext) return;

    setState(() {
      forward = true;
      isFlipping = true;
      currentPage += 1;
      controller.animateTo(1.0, curve: Curves.easeInOut).then((_) => commit());
    });
  }

  void prevPage() {
    widget.onPageTap?.call();

    if (!widget.canFlip || controller.isAnimating || !hasPrev) return;

    setState(() {
      forward = false;
      isFlipping = true;
      currentPage -= 1;
      controller.animateTo(1.0, curve: Curves.easeInOut).then((_) => commit());
    });
  }

  void resetStory() {
    setState(() {
      forward = false;
      isFlipping = true;
      currentPage = 0;
      controller
          .animateTo(
            1.0,
            curve: Curves.easeInOut,
            duration: Duration(milliseconds: 1000),
          )
          .then((_) => commit());
    });
  }

  void showNewStory() {
    setState(() {
      forward = true;
      isFlipping = true;
      currentPage = 0;
      controller.animateTo(1.0, curve: Curves.easeInOut).then((_) => commit());
    });
  }

  Widget buildFace(
    BuildContext context,
    int index, {
    required bool front,
    required bool isVisible,
    required bool showText,
  }) {
    if (index < 0 || index >= widget.pageCount) return const SizedBox.shrink();
    return widget.pageBuilder(context, index, isVisible, !front, showText);
  }
}
