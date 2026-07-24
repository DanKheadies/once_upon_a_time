import 'dart:math' as math;
import 'package:flutter/material.dart';
// import 'package:flutter/gestures.dart';

/// ============================================================================
/// THE CORE TRICK, explained once so it isn't repeated three times below
/// ----------------------------------------------------------------------------
/// Flutter's `Transform` widget takes a 4x4 matrix. For a flat rotateY, the
/// GPU still renders it geometrically correctly, but it *looks* fake — no
/// foreshortening, like a card rotating with zero depth. `setEntry(3, 2, p)`
/// injects a tiny value into the matrix's perspective row, which tells the
/// GPU "the further a point is in Z, the more it should converge toward a
/// vanishing point." That's what makes a rotating rectangle look like it's
/// tilting away from you in 3D instead of just squashing flat.
///
/// Typical values: 0.0008-0.0025. Smaller = subtler/flatter depth, bigger =
/// more dramatic/fisheye. There's no "correct" formula for it (every article
/// on this topic admits as much) — it's tuned by eye. I've used 0.0015 as a
/// good middle ground for a book-sized widget; tweak per your dimensions.
///
/// The second trick: a flat surface rotated past 90° (the "back" of it)
/// would render as a mirror-image of the front if you kept painting the
/// same widget. So whenever rotation passes the halfway point, we SWAP which
/// widget is being drawn, and pre-flip the replacement by π so it lands
/// right-reading instead of mirrored. You'll see this "swap at 0.5" pattern
/// in both BookOpener and PageFlipper below.
/// ============================================================================

const double _kPerspective = 0.0015;

Matrix4 _perspectiveMatrix() =>
    Matrix4.identity()..setEntry(3, 2, _kPerspective);

/// ============================================================================
/// 1) BookCover — the closed book. Nothing fancy: just a parchment/leather-
///    style rectangle you slide in from off-screen using your existing
///    entrance animation, then hand off to BookOpener via a GestureDetector
///    or an autoplay Timer.
/// ============================================================================
class BookCover extends StatelessWidget {
  final double width;
  final double height;
  final Widget child; // title art, embossed text, etc.
  final Color coverColor;

  const BookCover({
    super.key,
    required this.width,
    required this.height,
    required this.child,
    this.coverColor = const Color(0xFF5C3A21),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: coverColor,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        // Spine shadow: a dark gradient hugging the left edge, since that's
        // where the cover will hinge open from.
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.black.withValues(alpha: 0.45), coverColor],
          stops: const [0.0, 0.08],
        ),
      ),
      child: Center(child: child),
    );
  }
}

/// ============================================================================
/// 2) BookOpener — animates the front cover rotating open around the LEFT
///    edge (the spine), like a door swinging on a hinge, revealing whatever
///    you pass as `pageSpread` (typically your first PageFlipper spread)
///    underneath. This is the effect from the short you linked.
/// ----------------------------------------------------------------------------
/// Mechanics:
/// - alignment: Alignment.centerLeft pins the rotation pivot to the spine
///   instead of the widget's center — that's what makes it hinge rather
///   than spin in place.
/// - rotateY goes from 0 -> -pi/2 roughly (cover swings back to ~90°,
///   "resting open" against nothing, like a real book held upright) — not
///   all the way to -pi, which would flip it face-down over the back.
/// - A soft AnimatedOpacity fades the cover out near the end of the swing,
///   since a cover rotated to 90° is edge-on and effectively invisible
///   anyway — fading avoids it "popping" out if perspective rounding makes
///   it flicker at extreme angles.
/// ============================================================================
class BookOpener extends StatefulWidget {
  final double width;
  final double height;
  final Widget frontCover;
  final Widget pageSpread;
  final Duration duration;

  /// Called once the cover has finished opening — good place to trigger
  /// autoplay of anything else (e.g. a page-turn hint animation).
  final VoidCallback? onOpened;

  const BookOpener({
    super.key,
    required this.width,
    required this.height,
    required this.frontCover,
    required this.pageSpread,
    this.duration = const Duration(milliseconds: 900),
    this.onOpened,
  });

  @override
  State<BookOpener> createState() => BookOpenerState();
}

class BookOpenerState extends State<BookOpener>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _swing;

  bool _opened = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _swing = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _opened = true);
        widget.onOpened?.call();
      }
    });
  }

  /// Public so a parent (or a Timer, or a "tap to open" GestureDetector) can
  /// trigger the open animation.
  void open() {
    if (_controller.isAnimating || _opened) return;
    _controller.forward();
  }

  void toggle() {
    setState(() {
      _opened = !_opened;
    });
  }

  void reset() {
    print('reset');
    _controller.reset();
    setState(() {
      _opened = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              // width: widget.width,
              // height: widget.height,
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(left: 95, right: 25),
              // color: Colors.red,
              child: Image.asset(
                'assets/images/storybook-open-half-less.png',
                scale: 0.1,
              ),
            ),
          ),

          if (_opened)
            Positioned.fill(
              child: GestureDetector(
                onLongPress: reset,
                child: Container(
                  // width: widget.width,
                  // height: widget.height,
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(right: 25),
                  // color: Colors.green,
                  child: Image.asset(
                    'assets/images/storybook-open-partial-2.png',
                    // fit: BoxFit.fitHeight,
                    scale: 0.1,
                  ),
                ),
              ),
            ),

          // Pages; the page spread sits underneath, always present, revealed as
          // the cover swings away.
          // Positioned.fill(child: widget.pageSpread),

          // The front cover, hinged at the spine (left edge).
          if (!_opened)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _swing,
                builder: (context, child) {
                  // final angle = -(math.pi / 2.05) * _swing.value; // opens inward
                  final angle = (math.pi / 2.05) * _swing.value;
                  final fade =
                      1.0 -
                      Curves.easeIn.transform(
                        (_swing.value - 0.7).clamp(0.0, 0.3) / 0.3,
                      );
                  return Opacity(
                    opacity: fade,
                    child: Transform(
                      alignment: Alignment.centerLeft,
                      transform: _perspectiveMatrix()..rotateY(angle),
                      child: child,
                    ),
                  );
                },
                child: GestureDetector(onTap: open, child: widget.frontCover),
              ),
            ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// 3) PageFlipper — the interactive turn-a-page mechanic. This is the part
///    your linked packages (page_flip, flip_page, turnable_page) all
///    implement slightly differently; this version is deliberately simple
///    and hackable rather than trying to match any one of them.
/// ----------------------------------------------------------------------------
/// Design:
/// - `pages` is a list of widget builders — each one is the FRONT-of-page
///   content. Page N's back side is rendered as page N+1's front by default
///   (i.e. a single sheet has two pages' worth of content, front and back,
///   same as a real book) — but you can also pass `pageBackBuilder` if you
///   want fully independent front/back art (e.g. different parchment seeds
///   per side, which looks great since real paper isn't symmetric).
/// - Drag horizontally anywhere on the current page to turn it. Released
///   past a threshold -> animate to completion; released short -> springs
///   back. This mirrors the "flick to turn" feel of the packages you found.
/// - A gradient "shading" overlay is painted on top of the turning page,
///   darkening the trailing edge as it lifts and lightening near the fold —
///   this single trick does more for perceived realism than the geometry
///   itself; a flat-shaded rotateY page reads as "a card," a shaded one
///   reads as "paper."
/// ============================================================================
class PageFlipper extends StatefulWidget {
  final double width;
  final double height;
  final int pageCount;
  final Widget Function(BuildContext context, int index) pageBuilder;
  final Widget Function(BuildContext context, int index)? pageBackBuilder;

  /// Exposes the current page index if you want a "Page 3 of 20" label etc.
  final ValueChanged<int>? onPageChanged;

  const PageFlipper({
    super.key,
    required this.width,
    required this.height,
    required this.pageCount,
    required this.pageBuilder,
    this.pageBackBuilder,
    this.onPageChanged,
  });

  @override
  State<PageFlipper> createState() => _PageFlipperState();
}

class _PageFlipperState extends State<PageFlipper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  int _currentPage = 0;
  bool _forward = true; // true = turning next-ward, false = turning back

  @override
  void initState() {
    super.initState();
    // value: 0.0 = page flat/unturned, 1.0 = page fully turned.
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

  bool get _hasNext => _currentPage < widget.pageCount - 1;
  bool get _hasPrev => _currentPage > 0;

  void _onDragStart(DragStartDetails details, bool fromRightEdge) {
    if (_controller.isAnimating) return;
    _forward = fromRightEdge; // dragging from the right edge turns forward
    if (_forward && !_hasNext) return;
    if (!_forward && !_hasPrev) return;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_controller.isAnimating) return;
    final delta = -details.primaryDelta! / widget.width;
    final next = (_controller.value + (_forward ? delta : -delta)).clamp(
      0.0,
      1.0,
    );
    _controller.value = next;
  }

  void _onDragEnd(DragEndDetails details) {
    if (_controller.isAnimating) return;
    final velocity = details.primaryVelocity ?? 0;
    final completing =
        _controller.value > 0.5 ||
        velocity.abs() > 600 && _shouldCompleteFromVelocity(velocity);

    if (completing) {
      _controller
          .animateTo(1.0, curve: Curves.easeOut)
          .then((_) => _commitTurn());
    } else {
      _controller.animateTo(0.0, curve: Curves.easeOut);
    }
  }

  bool _shouldCompleteFromVelocity(double velocity) {
    // Negative primaryVelocity means swiping leftward (forward turn intent).
    return _forward ? velocity < 0 : velocity > 0;
  }

  void _commitTurn() {
    setState(() {
      _currentPage += _forward ? 1 : -1;
      _controller.value = 0.0;
    });
    widget.onPageChanged?.call(_currentPage);
  }

  /// Programmatic turn — wire a button to this if you want tap-to-turn
  /// controls in addition to (or instead of) drag.
  void nextPage() {
    if (_controller.isAnimating || !_hasNext) return;
    _forward = true;
    _controller
        .animateTo(1.0, curve: Curves.easeInOut)
        .then((_) => _commitTurn());
  }

  void prevPage() {
    if (_controller.isAnimating || !_hasPrev) return;
    _forward = false;
    _controller
        .animateTo(1.0, curve: Curves.easeInOut)
        .then((_) => _commitTurn());
  }

  Widget _buildFace(BuildContext context, int index, {required bool front}) {
    if (index < 0 || index >= widget.pageCount) return const SizedBox.shrink();
    if (front) return widget.pageBuilder(context, index);
    return (widget.pageBackBuilder ?? widget.pageBuilder)(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          // Static "under" page — whatever page will be revealed once the
          // turn completes. Always sits at the bottom of the stack.
          Positioned.fill(
            child: _buildFace(
              context,
              _forward ? _currentPage + 1 : _currentPage - 1,
              front: true,
            ),
          ),

          // The turning page itself.
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = _controller.value; // 0 -> 1
              final angle = -(_forward ? -1 : 1) * math.pi * t;
              final showingBack = t > 0.5;

              // Shading overlay: darkens as the page lifts off the surface,
              // strongest right at the fold, fading toward the outer edge.
              final liftShade = (math.sin(t * math.pi)).clamp(0.0, 1.0);

              return Transform(
                alignment: _forward
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                transform: _perspectiveMatrix()..rotateY(angle),
                child: Stack(
                  children: [
                    if (!showingBack)
                      _buildFace(context, _currentPage, front: true)
                    else
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(math.pi),
                        child: _buildFace(context, _currentPage, front: false),
                      ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: _forward
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              end: _forward
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
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

          // Two invisible drag zones (right edge = turn forward, left edge
          // = turn backward), so the gesture doesn't fight page content
          // like buttons or scrollables you might put in the middle.
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: widget.width * 0.35,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragStart: (d) => _onDragStart(d, true),
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: _onDragEnd,
              onTap: nextPage,
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: widget.width * 0.35,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragStart: (d) => _onDragStart(d, false),
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: _onDragEnd,
              onTap: prevPage,
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// Wiring example — slide-down entrance (yours) -> BookOpener -> PageFlipper.
/// Swap ParchmentPagePlaceholder for your actual ParchmentContainer /
/// shader-backed page widget from earlier.
/// ============================================================================
class BookDemoPage extends StatefulWidget {
  const BookDemoPage({super.key});

  @override
  State<BookDemoPage> createState() => _BookDemoPageState();
}

class _BookDemoPageState extends State<BookDemoPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  final GlobalKey<BookOpenerState> _openerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bookWidth = 420.0; // 360.0;
    const bookHeight = 500.0; // 480.0;

    return Scaffold(
      backgroundColor: const Color(0xFF1B140D),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: AnimatedBuilder(
              animation: _entrance,
              builder: (context, child) {
                final slide = Curves.easeOutBack.transform(_entrance.value);
                return Transform.translate(
                  offset: Offset(0, (1 - slide) * -300),
                  child: child,
                );
              },
              child: BookOpener(
                key: _openerKey,
                width: constraints.maxWidth, // bookWidth,
                height: constraints.maxHeight, // bookHeight,
                duration: const Duration(milliseconds: 900),
                frontCover: Container(
                  height: bookHeight,
                  width: bookWidth,
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(left: 50, right: 25),
                  color: Colors.teal,
                  child: Image.asset(
                    'assets/images/storybook-cover-no-bookmark.png',
                    scale: 0.1,
                  ),
                ),
                // frontCover: BookCover(
                //   width: bookWidth,
                //   height: bookHeight,
                //   child: const Text(
                //     'The Fellowship\nof the Apps',
                //     textAlign: TextAlign.center,
                //     style: TextStyle(
                //       color: Color(0xFFE8D9B5),
                //       fontFamily: 'Georgia',
                //       fontSize: 22,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
                onOpened:
                    () {}, // hook autoplay hints, sound effects, etc. here
                pageSpread: PageFlipper(
                  width: bookWidth,
                  height: bookHeight,
                  pageCount: 10,
                  pageBuilder: (context, index) => ParchmentPagePlaceholder(
                    height: bookHeight,
                    seed: index,
                    text: 'Page ${index + 1}',
                    width: bookWidth,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // onPressed: () => _openerKey.currentState?.open(),
        onPressed: () => _openerKey.currentState?.toggle(),
        child: const Icon(Icons.menu_book),
      ),
    );
  }
}

/// Stand-in for your real ParchmentContainer / shader page. Replace this
/// with the widget from earlier in our conversation.
class ParchmentPagePlaceholder extends StatelessWidget {
  final double height;
  final double width;
  final int seed;
  final String text;

  const ParchmentPagePlaceholder({
    super.key,
    required this.height,
    required this.seed,
    required this.text,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    // return Container(
    return Container(
      width: width,
      height: height,
      // color: Color.lerp(
      //   const Color(0xFFF3E3C3),
      //   const Color(0xFFE9D5A6),
      //   (seed % 5) / 5,
      // )!,
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        border: BoxBorder.all(),
      ),
      padding: const EdgeInsets.all(24),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.inverseSurface,
          fontFamily: 'Georgia',
          fontSize: 18,
        ),
      ),
    );
  }
}
