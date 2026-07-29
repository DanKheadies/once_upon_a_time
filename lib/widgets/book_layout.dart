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
      'fadeEnd: ${fadeEnd.toStringAsFixed(3)})';
}

/// Target book-frame aspect ratio (width:height). This is the crossover
/// point you measured at 560x669 - screenSafeWidth/screenSafeHeight equal
/// to this value is exactly where the layout switches from width-locked
/// to height-locked.
const double kBookAspectRatio = 0.8371;

/// Computes all responsive book layout values from the available
/// screen-safe area. Derived from fitting your measured data points -
/// see the accompanying notes for fit-quality caveats, particularly
/// around very small screenSafeHeight values.
BookLayout computeBookLayout({
  required double screenSafeWidth,
  required double screenSafeHeight,
}) {
  // Step 1: fit the book-frame box to the available area, preserving
  // aspect ratio (same math as BoxFit.contain).
  double bookWidth;
  double bookHeight;

  if (screenSafeWidth / screenSafeHeight >= kBookAspectRatio) {
    // Box is relatively wide - height is the limiting dimension.
    bookHeight = screenSafeHeight;
    bookWidth = screenSafeHeight * kBookAspectRatio;
  } else {
    // Box is relatively tall/narrow - width is the limiting dimension.
    bookWidth = screenSafeWidth;
    bookHeight = screenSafeWidth / kBookAspectRatio;
  }

  // Step 2: derived dimensions, fit as affine functions of the book box.
  final pageWidth = 0.7087 * bookWidth - 26.4;
  final pageHeight = 0.7876 * bookHeight - 22.0;
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
