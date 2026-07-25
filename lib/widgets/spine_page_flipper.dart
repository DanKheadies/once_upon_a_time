import 'dart:math' as math;
import 'package:flutter/material.dart';

const double _kPerspective = 0.001; // 0.0015;
Matrix4 _perspectiveMatrix() =>
    Matrix4.identity()..setEntry(3, 2, _kPerspective);

/// ============================================================================
/// SpinePageFlipper
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
class SpinePageFlipper extends StatefulWidget {
  final double width;
  final double height;
  final double spineOffset;
  final int pageCount;
  final Widget Function(BuildContext context, int index, bool isVisible)
  pageBuilder;
  final Widget Function(BuildContext context, int index, bool isVisible)?
  pageBackBuilder;
  final ValueChanged<int>? onPageChanged;

  const SpinePageFlipper({
    super.key,
    required this.width,
    required this.height,
    required this.spineOffset,
    required this.pageCount,
    required this.pageBuilder,
    this.pageBackBuilder,
    this.onPageChanged,
  });

  @override
  State<SpinePageFlipper> createState() => SpinePageFlipperState();
}

class SpinePageFlipperState extends State<SpinePageFlipper>
    with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  bool _forward = true;
  bool _isFlipping = false;

  double get _flipAreaWidth => widget.width - widget.spineOffset;

  late final AnimationController _controller;

  bool get _hasNext => _currentPage < widget.pageCount - 1;
  bool get _hasPrev => _currentPage > 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green.shade100.withAlpha(128),
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
            width: _flipAreaWidth,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    height: widget.height,
                    width: widget.width,
                    // color: Colors.black,
                    alignment: AlignmentGeometry.centerLeft,
                    // margin: const EdgeInsets.only(left: 10),
                    child: _buildFace(
                      context,
                      // _forward ? _currentPage + 1 : _currentPage - 1,
                      _currentPage,
                      front: true,
                      isVisible: !_isFlipping,
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final t = _controller.value;

                    // Forward: the sheet starts flat (angle 0) and rotates
                    // AWAY, ending fully turned (angle -pi).
                    // Backward: the sheet we're animating is the PREVIOUS
                    // one - it starts already fully turned (angle -pi, which
                    // is why its back face matches what's currently flat on
                    // screen - no visual jump at drag start) and rotates
                    // back TO flat (angle 0) as the drag completes.
                    final angle = _forward ? math.pi * t : math.pi * (1 - t);

                    // Which physical sheet is animating, and which of its
                    // two faces is pointed at the viewer right now. Using
                    // the angle itself (not raw t) keeps this correct for
                    // both directions without a separate branch.
                    final sheetIndex = _forward
                        ? _currentPage
                        : _currentPage - 1;
                    final showingBack = angle.abs() > (math.pi / 2);

                    final liftShade = math.sin(t * math.pi).clamp(0.0, 1.0);

                    return Transform(
                      // The spine never moves - both directions pivot here.
                      alignment: Alignment.centerLeft,
                      transform: _perspectiveMatrix()..rotateY(angle),
                      child: Stack(
                        children: [
                          if (!showingBack)
                            Container(
                              height: widget.height,
                              width: widget.width,
                              alignment: AlignmentGeometry.centerLeft,
                              // margin: const EdgeInsets.only(left: 10),
                              child: _buildFace(
                                context,
                                sheetIndex,
                                front: true,
                                isVisible: !_isFlipping,
                              ),
                            )
                          else
                            // Note: this is where the "left page" is showing;
                            // it also aids in the animation, i.e. looks better
                            // with it in. So I should remove once the animation
                            // is done.
                            Center(
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(math.pi),
                                child: Container(
                                  // margin: const EdgeInsets.only(right: 20),
                                  child: _buildFace(
                                    context,
                                    sheetIndex,
                                    front: false,
                                    isVisible: !_isFlipping,
                                  ),
                                ),
                                // Page 2 to 1 on prev dont work right
                                // child:
                                //     // 1 + 1 == 2
                                //     _isFlipping || _currentPage == 0
                                //     ? Container(
                                //         margin: const EdgeInsets.only(left: 50),
                                //         child: _buildFace(
                                //           context,
                                //           sheetIndex,
                                //           front: false,
                                //           isVisible: !_isFlipping,
                                //         ),
                                //       )
                                //     : const SizedBox(),
                                // child: const SizedBox(),
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
                                      Colors.black.withValues(alpha: 0.0),
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

          // Forward hit zone - the full 485px flip area. Forward only.
          Positioned(
            left: widget.spineOffset,
            top: 0,
            bottom: 0,
            right: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: _onForwardDragUpdate,
              onHorizontalDragEnd: _onForwardDragEnd,
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
              onHorizontalDragUpdate: _onBackwardDragUpdate,
              onHorizontalDragEnd: _onBackwardDragEnd,
              onTap: prevPage,
            ),
          ),
        ],
      ),
    );
  }

  // --- Backward zone (the 70px sliver): drag = previous page only. ---
  void _onBackwardDragUpdate(DragUpdateDetails details) {
    if (_controller.isAnimating || !_hasPrev) return;
    // Dragging rightward (positive delta) should increase turn progress
    // here, since we're pulling the previous page back into view.
    final delta = details.primaryDelta! / _flipAreaWidth;
    setState(() {
      _forward = false;
      _isFlipping = delta < 0 ? true : false;
      _controller.value = (_controller.value + delta).clamp(0.0, 1.0);
    });
  }

  void _onBackwardDragEnd(DragEndDetails details) => _resolveDrag();

  // --- Forward zone (the 485px main area): drag = next page only. ---
  void _onForwardDragUpdate(DragUpdateDetails details) {
    if (_controller.isAnimating || !_hasNext) return;
    final delta = -details.primaryDelta! / _flipAreaWidth;
    setState(() {
      _forward = true;
      _isFlipping = delta > 0 ? true : false;
      _controller.value = (_controller.value + delta).clamp(0.0, 1.0);
    });
  }

  void _onForwardDragEnd(DragEndDetails details) => _resolveDrag();

  void _resolveDrag(
    // {double velocityThreshold = 600}
  ) {
    print('_resolveDrag _forward: $_forward');
    if (_controller.value >= 0.5) {
      setState(() {
        _currentPage += _forward ? 1 : -1;
        _isFlipping = false;
        _controller
            .animateTo(1.0, curve: Curves.easeOut)
            .then((_) => _commit());
      });
    } else {
      setState(() {
        _isFlipping = false;
        _controller.animateTo(0.0, curve: Curves.easeOut);
      });
    }
  }

  void _commit() {
    print('commit');
    print('_forward: $_forward');
    setState(() {
      // _currentPage += _forward ? 1 : -1;
      _controller.value = 0.0;
      _isFlipping = false;
    });
    widget.onPageChanged?.call(_currentPage);
  }

  void nextPage() {
    print('_hasNext: $_hasNext');
    print('_currentPage: Page ${_currentPage + 1}');
    print('widget.pageCount: ${widget.pageCount}');
    if (_controller.isAnimating || !_hasNext) return;
    setState(() {
      _forward = true;
      _isFlipping = true;
      _currentPage += 1;
      _controller
          .animateTo(1.0, curve: Curves.easeInOut)
          .then((_) => _commit());
    });
  }

  void prevPage() {
    print('_hasPrev: $_hasPrev');
    print('_currentPage: Page ${_currentPage + 1}');
    // print('widget.pageCount: ${widget.pageCount}');
    if (_controller.isAnimating || !_hasPrev) return;
    setState(() {
      _forward = false;
      _isFlipping = true;
      _currentPage -= 1;
      _controller
          .animateTo(1.0, curve: Curves.easeInOut)
          .then((_) => _commit());
    });
  }

  Widget _buildFace(
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

/// ============================================================================
/// Usage against your numbers:
///
///   Stack(
///     children: [
///       Image.asset('assets/open_book_bg.png', width: 555, height: 480,
///           fit: BoxFit.cover),
///       SpinePageFlipper(
///         width: 555,
///         height: 480,
///         spineOffset: 70,
///         pageCount: pages.length,
///         pageBuilder: (context, i) => YourParchmentPage(seed: i),
///       ),
///     ],
///   )
/// ============================================================================
