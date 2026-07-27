// import 'dart:math' as math;
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'curling_page.dart';

// const double _kPerspective = 0.0015;
// Matrix4 _perspectiveMatrix() =>
//     Matrix4.identity()..setEntry(3, 2, _kPerspective);

// /// ============================================================================
// /// SpinePageFlipper
// /// ----------------------------------------------------------------------------
// /// Same page-turn mechanic as PageFlipper, but built for an open-book
// /// background image where the spine (binding) isn't centered - the right
// /// page fills most of the widget, and only a sliver of the left page peeks
// /// out to the left of the spine.
// ///
// /// `width` / `height`   -> total widget size (matches your background image)
// /// `spineOffset`         -> x-distance from the LEFT edge of the widget to
// ///                          the spine. In your numbers: width=555,
// ///                          spineOffset=70 (so the right page area is
// ///                          555-70=485 wide, matching what you described).
// ///
// /// Geometry key insight: both the forward-turning page and the
// /// backward-turning page, when fully flat, occupy the SAME rectangle - from
// /// the spine to the right edge (spineOffset .. width). What differs is only
// /// which page is drawn there and which edge it rotates in from. So the
// /// "flip area" is a single sub-box positioned at `left: spineOffset`, and
// /// Alignment.centerLeft (that sub-box's left edge) always equals the spine,
// /// automatically, because Alignment is relative to the widget it's applied
// /// to - not to the outer screen.
// ///
// /// The 70px sliver to the left of the spine is NOT rendered as an animated
// /// page at all here - it's just your static background image showing
// /// through (the edge of the page stack), which is almost always all that's
// /// visible of it anyway. It's used purely as a gesture hit zone.
// /// ============================================================================
// class SpinePageFlipper extends StatefulWidget {
//   final double width;
//   final double height;
//   final double spineOffset;
//   final int pageCount;
//   final Widget Function(BuildContext context, int index) pageBuilder;
//   final Widget Function(BuildContext context, int index)? pageBackBuilder;
//   final ValueChanged<int>? onPageChanged;

//   /// Pre-captured page textures (see PageTextureCapture / PageImageCache
//   /// in curling_page.dart) and the loaded curl shader. Both are handed in
//   /// from above since they're async to produce and shouldn't be recreated
//   /// every time this widget rebuilds.
//   final PageImageCache pageImageCache;
//   final ui.FragmentShader curlShader;

//   const SpinePageFlipper({
//     super.key,
//     required this.width,
//     required this.height,
//     required this.spineOffset,
//     required this.pageCount,
//     required this.pageBuilder,
//     required this.pageImageCache,
//     required this.curlShader,
//     this.pageBackBuilder,
//     this.onPageChanged,
//   });

//   @override
//   State<SpinePageFlipper> createState() => SpinePageFlipperState();
// }

// class SpinePageFlipperState extends State<SpinePageFlipper>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;

//   int _currentPage = 0;
//   bool _forward = true;

//   double get _flipAreaWidth => widget.width - widget.spineOffset;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 380),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   bool get _hasNext => _currentPage < widget.pageCount - 1;
//   bool get _hasPrev => _currentPage > 0;

//   // --- Forward zone (the 485px main area): drag = next page only. ---
//   void _onForwardDragUpdate(DragUpdateDetails details) {
//     if (_controller.isAnimating || !_hasNext) return;
//     _forward = true;
//     final delta = -details.primaryDelta! / _flipAreaWidth;
//     _controller.value = (_controller.value + delta).clamp(0.0, 1.0);
//   }

//   void _onForwardDragEnd(DragEndDetails details) => _resolveDrag();

//   // --- Backward zone (the 70px sliver): drag = previous page only. ---
//   void _onBackwardDragUpdate(DragUpdateDetails details) {
//     if (_controller.isAnimating || !_hasPrev) return;
//     _forward = false;
//     // Dragging rightward (positive delta) should increase turn progress
//     // here, since we're pulling the previous page back into view.
//     final delta = details.primaryDelta! / _flipAreaWidth;
//     _controller.value = (_controller.value + delta).clamp(0.0, 1.0);
//   }

//   void _onBackwardDragEnd(DragEndDetails details) => _resolveDrag();

//   void _resolveDrag({double velocityThreshold = 600}) {
//     if (_controller.value >= 0.5) {
//       _controller.animateTo(1.0, curve: Curves.easeOut).then((_) => _commit());
//     } else {
//       _controller.animateTo(0.0, curve: Curves.easeOut);
//     }
//   }

//   void _commit() {
//     setState(() {
//       _currentPage += _forward ? 1 : -1;
//       _controller.value = 0.0;
//     });
//     widget.onPageChanged?.call(_currentPage);
//   }

//   void nextPage() {
//     if (_controller.isAnimating || !_hasNext) return;
//     _forward = true;
//     _controller.animateTo(1.0, curve: Curves.easeInOut).then((_) => _commit());
//   }

//   void prevPage() {
//     if (_controller.isAnimating || !_hasPrev) return;
//     _forward = false;
//     _controller.animateTo(1.0, curve: Curves.easeInOut).then((_) => _commit());
//   }

//   Widget _buildFace(BuildContext context, int index, {required bool front}) {
//     if (index < 0 || index >= widget.pageCount) return const SizedBox.shrink();
//     if (front) return widget.pageBuilder(context, index);
//     return (widget.pageBackBuilder ?? widget.pageBuilder)(context, index);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: widget.width,
//       height: widget.height,
//       child: Stack(
//         children: [
//           // The flip area: everything from the spine to the right edge.
//           // Positioning it here is the whole trick - Alignment.centerLeft
//           // inside this sub-tree now IS the spine, with zero extra math.
//           Positioned(
//             left: widget.spineOffset,
//             top: 0,
//             bottom: 0,
//             width: _flipAreaWidth,
//             child: Stack(
//               children: [
//                 Positioned.fill(
//                   child: _buildFace(
//                     context,
//                     _forward ? _currentPage + 1 : _currentPage - 1,
//                     front: true,
//                   ),
//                 ),
//                 AnimatedBuilder(
//                   animation: _controller,
//                   builder: (context, child) {
//                     final t = _controller.value;

//                     // Same sheet-index logic as before: which page's
//                     // captured texture is the one currently curling.
//                     final sheetIndex = _forward
//                         ? _currentPage
//                         : _currentPage - 1;
//                     final pageImage = widget.pageImageCache[sheetIndex];

//                     if (pageImage == null) {
//                       // Texture not captured yet (still loading) - fall
//                       // back to the flat, undistorted page rather than
//                       // showing nothing.
//                       return _buildFace(context, sheetIndex, front: true);
//                     }

//                     return CurlingPage(
//                       pageImage: pageImage,
//                       width: _flipAreaWidth,
//                       height: widget.height,
//                       progress: t,
//                       forward: _forward,
//                       shader: widget.curlShader,
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),

//           // Forward hit zone - the full 485px flip area. Forward only.
//           Positioned(
//             left: widget.spineOffset,
//             top: 0,
//             bottom: 0,
//             right: 0,
//             child: GestureDetector(
//               behavior: HitTestBehavior.translucent,
//               onHorizontalDragUpdate: _onForwardDragUpdate,
//               onHorizontalDragEnd: _onForwardDragEnd,
//               onTap: nextPage,
//             ),
//           ),

//           // Backward hit zone - the 70px sliver left of the spine. Backward only.
//           Positioned(
//             left: 0,
//             top: 0,
//             bottom: 0,
//             width: widget.spineOffset,
//             child: GestureDetector(
//               behavior: HitTestBehavior.translucent,
//               onHorizontalDragUpdate: _onBackwardDragUpdate,
//               onHorizontalDragEnd: _onBackwardDragEnd,
//               onTap: prevPage,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// ============================================================================
// /// Usage against your numbers:
// ///
// ///   Stack(
// ///     children: [
// ///       Image.asset('assets/open_book_bg.png', width: 555, height: 480,
// ///           fit: BoxFit.cover),
// ///       SpinePageFlipper(
// ///         width: 555,
// ///         height: 480,
// ///         spineOffset: 70,
// ///         pageCount: pages.length,
// ///         pageBuilder: (context, i) => YourParchmentPage(seed: i),
// ///       ),
// ///     ],
// ///   )
// /// ============================================================================
