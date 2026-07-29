/// Computed layout values for a given screen-safe area.
class BookLayout {
  final double bookWidth;
  final double bookHeight;
  final double pageWidth;
  final double pageHeight;
  final double spineOffset;
  final double flipperOffset;
  final double fadeEnd;
  final double prevWidth;
  final double fontSize;

  const BookLayout({
    required this.bookWidth,
    required this.bookHeight,
    required this.pageWidth,
    required this.pageHeight,
    required this.spineOffset,
    required this.flipperOffset,
    required this.fadeEnd,
    required this.prevWidth,
    required this.fontSize,
  });

  @override
  String toString() =>
      'BookLayout(book: ${bookWidth.toStringAsFixed(1)}x${bookHeight.toStringAsFixed(1)}, '
      'page: ${pageWidth.toStringAsFixed(1)}x${pageHeight.toStringAsFixed(1)}, '
      'spine: ${spineOffset.toStringAsFixed(1)}, '
      'flipper: ${flipperOffset.toStringAsFixed(1)}, '
      'fadeEnd: ${fadeEnd.toStringAsFixed(3)}, '
      'prevWidth: ${prevWidth.toStringAsFixed(1)})';
}

/// Target book-frame aspect ratio (width:height). This is the crossover
/// point you measured at 560x669 - screenSafeWidth/screenSafeHeight equal
/// to this value is exactly where the layout switches from width-locked
/// to height-locked.
const double kBookAspectRatio = 0.8371;

// --- Width-locked regime (screenSafeWidth is the limiting dimension) ---
// Tune these to affect ONLY the case where the screen is relatively tall
// / narrow. Fit from your original measured data.
const double kPageWidthScaleNarrow = 0.7087;
const double kPageWidthOffsetNarrow = -26.4;
const double kPageHeightScaleNarrow = 0.7876;
const double kPageHeightOffsetNarrow = -22.0;

// --- Height-locked regime (screenSafeHeight is the limiting dimension,
// extra width goes unused) ---
// These start as copies of the narrow-regime constants. Adjust THESE,
// and only these, to fix "pages look too small once extra width shows
// up" without touching the narrow/tall case at all.
const double kPageWidthScaleWide = 0.675;
const double kPageWidthOffsetWide = 0.01;
const double kPageHeightScaleWide = 0.75;
const double kPageHeightOffsetWide = 0.1;

BookLayout computeBookLayout({
  required double screenSafeWidth,
  required double screenSafeHeight,
}) {
  // Step 1: fit the book-frame box to the available area, preserving
  // aspect ratio (same math as BoxFit.contain).
  double bookWidth;
  double bookHeight;
  final bool isHeightLocked =
      screenSafeWidth / screenSafeHeight >= kBookAspectRatio;

  if (isHeightLocked) {
    // Box is relatively wide - height is the limiting dimension.
    bookHeight = screenSafeHeight;
    bookWidth = screenSafeHeight * kBookAspectRatio;
  } else {
    // Box is relatively tall/narrow - width is the limiting dimension.
    bookWidth = screenSafeWidth;
    bookHeight = screenSafeWidth / kBookAspectRatio;
  }

  // Step 2: derived dimensions. pageWidth/pageHeight now branch on regime,
  // each using its own independently-tunable constants - this is the
  // piece that was missing before. Everything else (spineOffset,
  // flipperOffset, fadeEnd, prevWidth) stays a single shared formula,
  // since your data didn't show a need to split those.
  final double pageWidth;
  final double pageHeight;
  if (isHeightLocked) {
    pageWidth = kPageWidthScaleWide * bookWidth + kPageWidthOffsetWide;
    pageHeight = kPageHeightScaleWide * bookHeight + kPageHeightOffsetWide;
  } else {
    pageWidth = kPageWidthScaleNarrow * bookWidth + kPageWidthOffsetNarrow;
    pageHeight = kPageHeightScaleNarrow * bookHeight + kPageHeightOffsetNarrow;
  }

  final spineOffset = 0.1598 * bookWidth - 4.3;

  // Approximate - your data showed ~10% scatter here. Treat this
  // multiplier as a starting point to nudge, not a locked constant.
  final flipperOffset = -0.22 * spineOffset;

  // Near-exact fit across all measured rows in both regimes.
  final fadeEnd = 0.0793 + 63.4 / pageWidth;

  // Fits much better against pageWidth + spineOffset than against
  // bookWidth directly - within ~2px on almost every measured row.
  final prevWidth = pageWidth + 1.12 * spineOffset;

  final fontSize = spineOffset / 3;

  return BookLayout(
    bookWidth: bookWidth,
    bookHeight: bookHeight,
    pageWidth: pageWidth,
    pageHeight: pageHeight,
    spineOffset: spineOffset,
    flipperOffset: flipperOffset,
    fadeEnd: fadeEnd,
    prevWidth: prevWidth,
    fontSize: fontSize,
  );
}

/// ============================================================================
/// Usage inside a LayoutBuilder:
///
///   LayoutBuilder(
///     builder: (context, constraints) {
///       final layout = computeBookLayout(
///         screenSafeWidth: constraints.maxWidth,
///         screenSafeHeight: constraints.maxHeight,
///       );
///       return SpinePageFlipper(
///         width: layout.bookWidth,
///         height: layout.bookHeight,
///         spineOffset: layout.spineOffset,
///         ...
///       );
///     },
///   )
///
/// Quick self-check against your own measured rows - drop this in a test
/// or just print it once to sanity-check the fit before wiring it in:
///
///   for (final row in [
///     (390.0, 788.0), (500.0, 941.0), (670.0, 941.0), (778.0, 941.0),
///     (560.0, 941.0), (560.0, 800.0), (560.0, 674.0),
///     (560.0, 550.0), (560.0, 424.0), (560.0, 244.0),
///   ]) {
///     print(computeBookLayout(screenSafeWidth: row.$1, screenSafeHeight: row.$2));
///   }
/// ============================================================================

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
// prevWidth

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
