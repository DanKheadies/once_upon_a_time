// import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:once_upon_a_time/barrel.dart';

/// ============================================================================
/// PageFlipper
/// ----------------------------------------------------------------------------
/// Same page-turn mechanic as PageFlipper, but built for an open-book
/// background image where the spine (binding) isn't centered - the right
/// page fills most of the widget, and only a sliver of the left page peeks
/// out to the left of the spine.
///
/// `width` / `height`   -> total widget size (matches your background image)
/// `spineOffset`         -> x-distance from the LEFT edge of the widget to
///                          the spine. In your numbers: width=555,
///                          spineOffset=70 (so the right page area is
///                          555-70=485 wide, matching what you described).
///
/// Geometry key insight: both the forward-turning page and the
/// backward-turning page, when fully flat, occupy the SAME rectangle - from
/// the spine to the right edge (spineOffset .. width). What differs is only
/// which page is drawn there and which edge it rotates in from. So the
/// "flip area" is a single sub-box positioned at `left: spineOffset`, and
/// Alignment.centerLeft (that sub-box's left edge) always equals the spine,
/// automatically, because Alignment is relative to the widget it's applied
/// to - not to the outer screen.
///
/// The 70px sliver to the left of the spine is NOT rendered as an animated
/// page at all here - it's just your static background image showing
/// through (the edge of the page stack), which is almost always all that's
/// visible of it anyway. It's used purely as a gesture hit zone.
/// ============================================================================
class PageFlipper extends StatefulWidget {
  final double height;
  final double spineOffset;
  final double width;
  final int pageCount;
  final ValueChanged<int>? onPageChanged;
  final Widget Function(BuildContext context, int index, bool isVisible)
  pageBuilder;
  final Widget Function(BuildContext context, int index, bool isVisible)?
  pageBackBuilder;

  /// Pre-captured page textures (see PageTextureCapture / PageImageCache
  /// in curling_page.dart) and the loaded curl shader. Both are handed in
  /// from above since they're async to produce and shouldn't be recreated
  /// every time this widget rebuilds.
  final PageImageCache pageImageCache;
  final ui.FragmentShader curlShader;

  const PageFlipper({
    super.key,
    required this.curlShader,
    required this.height,
    required this.pageBuilder,
    required this.pageCount,
    required this.pageImageCache,
    required this.spineOffset,
    required this.width,
    this.pageBackBuilder,
    this.onPageChanged,
  });

  @override
  State<PageFlipper> createState() => PageFlipperState();
}

class PageFlipperState extends State<PageFlipper>
    with SingleTickerProviderStateMixin {
  int currentPage = 0;
  bool forward = true;
  bool isFlipping = false;

  final double kPerspective = 0.001; // 0.0015;

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
      // color: Colors.green.shade100.withAlpha(128),
      padding: EdgeInsets.zero,
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          // The flip area: everything from the spine to the right edge.
          // Positioning it here is the whole trick - Alignment.centerLeft
          // inside this sub-tree now IS the spine, with zero extra math.
          Positioned(
            left: widget.spineOffset,
            top: 0,
            bottom: 0,
            width: flipAreaWidth,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    height: widget.height,
                    // width: widget.width,
                    width: flipAreaWidth,
                    // color: Colors.black,
                    alignment: AlignmentGeometry.centerLeft,
                    // margin: const EdgeInsets.only(left: 10),
                    child: buildFace(
                      context,
                      // forward ? currentPage + 1 : currentPage - 1,
                      currentPage,
                      front: true,
                      isVisible: !isFlipping,
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    final t = controller.value;

                    // Same sheet-index logic as before: which page's
                    // captured texture is the one currently curling.
                    final sheetIndex = forward ? currentPage : currentPage - 1;
                    final pageImage = widget.pageImageCache[sheetIndex];

                    if (pageImage == null) {
                      print('DERP');
                      // Texture not captured yet (still loading) - fall
                      // back to the flat, undistorted page rather than
                      // showing nothing.
                      return buildFace(
                        context,
                        sheetIndex,
                        front: true,
                        isVisible: true, // !isFlipping,
                      );
                    }

                    return CurlingPage(
                      pageImage: pageImage,
                      width: flipAreaWidth,
                      height: widget.height,
                      progress: t,
                      forward: forward,
                      shader: widget.curlShader,
                    );
                    // final t = controller.value;

                    // // Forward: the sheet starts flat (angle 0) and rotates
                    // // AWAY, ending fully turned (angle -pi).
                    // // Backward: the sheet we're animating is the PREVIOUS
                    // // one - it starts already fully turned (angle -pi, which
                    // // is why its back face matches what's currently flat on
                    // // screen - no visual jump at drag start) and rotates
                    // // back TO flat (angle 0) as the drag completes.
                    // final angle = forward ? math.pi * t : math.pi * (1 - t);

                    // // Which physical sheet is animating, and which of its
                    // // two faces is pointed at the viewer right now. Using
                    // // the angle itself (not raw t) keeps this correct for
                    // // both directions without a separate branch.
                    // final sheetIndex = forward ? currentPage : currentPage - 1;
                    // final showingBack = angle.abs() > (math.pi / 2);

                    // final liftShade = math.sin(t * math.pi).clamp(0.0, 1.0);

                    // return Transform(
                    //   // The spine never moves - both directions pivot here.
                    //   alignment: Alignment.centerLeft,
                    //   transform: perspectiveMatrix()..rotateY(angle),
                    //   child: Stack(
                    //     children: [
                    //       if (!showingBack)
                    //         Container(
                    //           height: widget.height,
                    //           width: widget.width,
                    //           alignment: AlignmentGeometry.centerLeft,
                    //           // margin: const EdgeInsets.only(left: 10),
                    //           child: buildFace(
                    //             context,
                    //             sheetIndex,
                    //             front: true,
                    //             isVisible: !isFlipping,
                    //           ),
                    //         )
                    //       else
                    //         // Note: this is where the "left page" is showing;
                    //         // it also aids in the animation, i.e. looks better
                    //         // with it in. So I should remove once the animation
                    //         // is done.
                    //         Center(
                    //           child: Transform(
                    //             alignment: Alignment.center,
                    //             origin: Offset(-40, 0),
                    //             transform: Matrix4.identity()
                    //               // ..rotateY(math.pi)
                    //               ..rotateY(math.pi),
                    //             child: Container(
                    //               // margin: const EdgeInsets.only(right: 20),
                    //               child: buildFace(
                    //                 context,
                    //                 sheetIndex,
                    //                 front: false,
                    //                 isVisible: false, // isFlipping,
                    //               ),
                    //             ),
                    //             // Page 2 to 1 on prev dont work right
                    //             // child:
                    //             //     // 1 + 1 == 2
                    //             //     isFlipping || currentPage == 0
                    //             //     ? Container(
                    //             //         margin: const EdgeInsets.only(left: 50),
                    //             //         child: buildFace(
                    //             //           context,
                    //             //           sheetIndex,
                    //             //           front: false,
                    //             //           isVisible: !isFlipping,
                    //             //         ),
                    //             //       )
                    //             //     : const SizedBox(),
                    //             // child: const SizedBox(),
                    //           ),
                    //         ),
                    //       Positioned.fill(
                    //         child: IgnorePointer(
                    //           child: DecoratedBox(
                    //             decoration: BoxDecoration(
                    //               // The pivot is always on the left now, so
                    //               // the lifting/lit edge is always the far
                    //               // (right) edge of the flip area, for both
                    //               // directions.
                    //               gradient: LinearGradient(
                    //                 begin: Alignment.centerRight,
                    //                 end: Alignment.centerLeft,
                    //                 colors: [
                    //                   Colors.black.withValues(alpha: 0.0),
                    //                   Colors.black.withValues(
                    //                     alpha: 0.22 * liftShade,
                    //                   ),
                    //                 ],
                    //                 stops: const [0.6, 1.0],
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // );
                  },
                ),
              ],
            ),
          ),

          // Forward hit zone - the full 485px flip area. Forward only.
          Positioned(
            left: widget.spineOffset,
            top: 0,
            bottom: 0,
            right: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: onForwardDragUpdate,
              onHorizontalDragEnd: onForwardDragEnd,
              onTap: nextPage,
            ),
          ),

          // Backward hit zone - the 70px sliver left of the spine. Backward only.
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

  // --- Backward zone (the 70px sliver): drag = previous page only. ---
  void onBackwardDragUpdate(DragUpdateDetails details) {
    if (controller.isAnimating || !hasPrev) return;
    // Dragging rightward (positive delta) should increase turn progress
    // here, since we're pulling the previous page back into view.
    final delta = details.primaryDelta! / flipAreaWidth;
    setState(() {
      forward = false;
      // isFlipping = delta < 0 ? true : false;
      isFlipping = true;
      controller.value = (controller.value + delta).clamp(0.0, 1.0);
    });
  }

  void onBackwardDragEnd(DragEndDetails details) => resolveDrag();

  // --- Forward zone (the 485px main area): drag = next page only. ---
  void onForwardDragUpdate(DragUpdateDetails details) {
    if (controller.isAnimating || !hasNext) return;
    final delta = -details.primaryDelta! / flipAreaWidth;
    setState(() {
      forward = true;
      // isFlipping = delta > 0 ? true : false;
      isFlipping = true;
      controller.value = (controller.value + delta).clamp(0.0, 1.0);
    });
  }

  void onForwardDragEnd(DragEndDetails details) => resolveDrag();

  void resolveDrag(
    // {double velocityThreshold = 600}
  ) {
    // print('resolveDrag forward: $forward');
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
    // print('commit');
    // print('forward: $forward');
    setState(() {
      // currentPage += forward ? 1 : -1;
      controller.value = 0.0;
      isFlipping = false;
    });
    widget.onPageChanged?.call(currentPage);
  }

  void nextPage() {
    // print('hasNext: $hasNext');
    // print('currentPage: Page ${currentPage + 1}');
    // print('widget.pageCount: ${widget.pageCount}');
    if (controller.isAnimating || !hasNext) return;
    setState(() {
      forward = true;
      isFlipping = true;
      currentPage += 1;
      controller.animateTo(1.0, curve: Curves.easeInOut).then((_) => commit());
    });
  }

  void prevPage() {
    // print('hasPrev: $hasPrev');
    // print('currentPage: Page ${currentPage + 1}');
    // print('widget.pageCount: ${widget.pageCount}');
    if (controller.isAnimating || !hasPrev) return;
    setState(() {
      forward = false;
      isFlipping = true;
      currentPage -= 1;
      controller.animateTo(1.0, curve: Curves.easeInOut).then((_) => commit());
    });
  }

  Widget buildFace(
    BuildContext context,
    int index, {
    required bool front,
    required bool isVisible,
  }) {
    if (index < 0 || index >= widget.pageCount) return const SizedBox.shrink();
    if (front) return widget.pageBuilder(context, index, isVisible);
    return (widget.pageBackBuilder ?? widget.pageBuilder)(
      context,
      index,
      isVisible,
    );
  }
}
