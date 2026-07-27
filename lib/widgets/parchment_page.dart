import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Loads the parchment page shader once. Call this near app/book startup,
/// same as you're already doing for the curl shader, and hold the result
/// in state - don't reload it per page or per rebuild.
Future<ui.FragmentShader> loadParchmentPageShader() async {
  final program = await ui.FragmentProgram.fromAsset(
    'shaders/parchment_page.frag',
  );
  return program.fragmentShader();
}

/// A single parchment page background, rendered via the shader, with your
/// page content laid on top. One shader INSTANCE can be reused across all
/// pages - each page just gets a different `seed` so the mesh-gradient
/// blob positions and grain differ per page without needing to reload or
/// recompile anything.
class ParchmentPage extends StatelessWidget {
  final double width;
  final double height;
  final int seed;
  final Widget child;
  final ui.FragmentShader shader;

  final Color colorA;
  final Color colorB;
  final Color colorC;
  final Color colorD;

  /// Grid resolution for the pixel-art mode - defaults match your 15x19
  /// reference art. Set pixelate to false to fall back to a smooth blend
  /// (useful for comparing the two side by side while you decide).
  final double gridCols;
  final double gridRows;
  final double levels;
  final bool pixelate;

  /// Hue-lock: measured from your parchment.png reference, which sits at
  /// roughly hue 42 (warm tan/khaki), ~15-20% saturation. You can now pick
  /// any 4 blob colors you like for interesting light/shadow variation -
  /// these three params guarantee the OUTPUT stays a single consistent
  /// hue family regardless.
  final double targetHue;
  final double hueLock;
  final double maxSaturation;

  /// How strongly each grid cell's brightness is randomly jittered.
  /// 0.2-0.35 is a good starting range - high enough to kill the "big
  /// light spot / big dark spot" look, not so high it looks like noise.
  final double cellVariation;

  /// Left-edge transparency fade, in uv space (0.0 = left edge of THIS
  /// widget, 1.0 = right edge). fadeStart is where alpha hits 0,
  /// fadeEnd is where it reaches full opacity. If this ParchmentPage is
  /// positioned starting right at the spine (as in SpinePageFlipper),
  /// these can stay small fractions - e.g. fadeEnd: 0.15 fades out over
  /// the leftmost ~15% of the page.
  final double fadeStart;
  final double fadeEnd;

  const ParchmentPage({
    super.key,
    required this.width,
    required this.height,
    required this.seed,
    required this.child,
    required this.shader,
    // OG
    this.colorA = const Color(0xFFF3E3C3),
    this.colorB = const Color(0xFFE9D5A6),
    this.colorC = const Color(0xFFD9BE8C),
    this.colorD = const Color(0xFFB89B6B),
    // Custom
    // this.colorA = const Color(0xFFcfc9b3), //F3E3C3),
    // this.colorB = const Color(0xFFE9D5A6),
    // this.colorC = const Color(0xFFc5bfa3), //D9BE8C),
    // this.colorD = const Color(0xFFbfba9c), //B89B6B),
    this.gridCols = 15,
    this.gridRows = 19,
    this.levels = 20,
    this.pixelate = true,
    this.targetHue = 48.0, // 42.0,
    this.hueLock = 1.0,
    this.maxSaturation = 0.25, // 0.20
    this.cellVariation = 0.05, // 0.125, // 0.25,
    this.fadeStart = 0.0,
    this.fadeEnd = 0.2, // 0.15,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _ParchmentPagePainter(
              shader: shader,
              seed: seed,
              colorA: colorA,
              colorB: colorB,
              colorC: colorC,
              colorD: colorD,
              gridCols: gridCols,
              gridRows: gridRows,
              levels: levels,
              pixelate: pixelate,
              targetHue: targetHue,
              hueLock: hueLock,
              maxSaturation: maxSaturation,
              cellVariation: cellVariation,
              fadeStart: fadeStart,
              fadeEnd: fadeEnd,
            ),
          ),
          // Soften the overall look and feel
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorA.withAlpha(0), colorA.withAlpha(42)],
              ),
            ),
            width: width,
            height: height,
          ),
          Padding(padding: const EdgeInsets.all(24), child: child),
        ],
      ),
    );
  }
}

class _ParchmentPagePainter extends CustomPainter {
  final ui.FragmentShader shader;
  final int seed;
  final Color colorA, colorB, colorC, colorD;
  final double gridCols, gridRows, levels;
  final bool pixelate;
  final double targetHue, hueLock, maxSaturation;
  final double cellVariation, fadeStart, fadeEnd;

  _ParchmentPagePainter({
    required this.shader,
    required this.seed,
    required this.colorA,
    required this.colorB,
    required this.colorC,
    required this.colorD,
    required this.gridCols,
    required this.gridRows,
    required this.levels,
    required this.pixelate,
    required this.targetHue,
    required this.hueLock,
    required this.maxSaturation,
    required this.cellVariation,
    required this.fadeStart,
    required this.fadeEnd,
  });

  void _setColor(int startIndex, Color c) {
    shader.setFloat(startIndex, c.r);
    shader.setFloat(startIndex + 1, c.g);
    shader.setFloat(startIndex + 2, c.b);
    shader.setFloat(startIndex + 3, c.a);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Index bookkeeping - must match the .frag file's uniform DECLARATION
    // order exactly, counting each vec4 as 4 float slots:
    //   0-1   uSize (vec2)          -> 2 floats
    //   2-5   uColorA (vec4)        -> 4 floats
    //   6-9   uColorB (vec4)        -> 4 floats
    //   10-13 uColorC (vec4)        -> 4 floats
    //   14-17 uColorD (vec4)        -> 4 floats
    //   18    uSeed (float)         -> 1 float
    //   19    uCols (float)
    //   20    uRows (float)
    //   21    uLevels (float)
    //   22    uPixelate (float)
    //   23    uTargetHue (float)
    //   24    uHueLock (float)
    //   25    uMaxSaturation (float)
    //   26    uCellVariation (float)
    //   27    uFadeStart (float)
    //   28    uFadeEnd (float)
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    _setColor(2, colorA);
    _setColor(6, colorB);
    _setColor(10, colorC);
    _setColor(14, colorD);
    shader.setFloat(18, seed.toDouble());
    shader.setFloat(19, gridCols);
    shader.setFloat(20, gridRows);
    shader.setFloat(21, levels);
    shader.setFloat(22, pixelate ? 1.0 : 0.0);
    shader.setFloat(23, targetHue);
    shader.setFloat(24, hueLock);
    shader.setFloat(25, maxSaturation);
    shader.setFloat(26, cellVariation);
    shader.setFloat(27, fadeStart);
    shader.setFloat(28, fadeEnd);

    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _ParchmentPagePainter oldDelegate) =>
      oldDelegate.seed != seed ||
      oldDelegate.pixelate != pixelate ||
      oldDelegate.gridCols != gridCols ||
      oldDelegate.gridRows != gridRows ||
      oldDelegate.levels != levels ||
      oldDelegate.cellVariation != cellVariation ||
      oldDelegate.fadeStart != fadeStart ||
      oldDelegate.fadeEnd != fadeEnd;
}

/// ============================================================================
/// Wiring into SpinePageFlipper - swap this in for your placeholder
/// pageBuilder / pageBackBuilder:
///
///   SpinePageFlipper(
///     ...
///     pageBuilder: (context, index) => ParchmentPage(
///       width: 485,
///       height: 480,
///       seed: index,
///       shader: myLoadedParchmentShader, // load once, hold in state
///       child: Text('Page ${index + 1} content...'),
///     ),
///   )
/// ============================================================================

// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';

// /// Loads the parchment page shader once. Call this near app/book startup,
// /// same as you're already doing for the curl shader, and hold the result
// /// in state - don't reload it per page or per rebuild.
// Future<ui.FragmentShader> loadParchmentPageShader() async {
//   final program = await ui.FragmentProgram.fromAsset(
//     'shaders/parchment_page.frag',
//   );
//   return program.fragmentShader();
// }

// /// A single parchment page background, rendered via the shader, with your
// /// page content laid on top. One shader INSTANCE can be reused across all
// /// pages - each page just gets a different `seed` so the mesh-gradient
// /// blob positions and grain differ per page without needing to reload or
// /// recompile anything.
// class ParchmentPage extends StatelessWidget {
//   final double width;
//   final double height;
//   final int seed;
//   final Widget child;
//   final ui.FragmentShader shader;

//   final Color colorA;
//   final Color colorB;
//   final Color colorC;
//   final Color colorD;

//   /// Grid resolution for the pixel-art mode - defaults match your 15x19
//   /// reference art. Set pixelate to false to fall back to a smooth blend
//   /// (useful for comparing the two side by side while you decide).
//   final double gridCols;
//   final double gridRows;
//   final double levels;
//   final bool pixelate;

//   /// Hue-lock: measured from your parchment.png reference, which sits at
//   /// roughly hue 42 (warm tan/khaki), ~15-20% saturation. You can now pick
//   /// any 4 blob colors you like for interesting light/shadow variation -
//   /// these three params guarantee the OUTPUT stays a single consistent
//   /// hue family regardless.
//   final double targetHue;
//   final double hueLock;
//   final double maxSaturation;

//   const ParchmentPage({
//     super.key,
//     required this.width,
//     required this.height,
//     required this.seed,
//     required this.child,
//     required this.shader,
//     this.colorA = const Color(0xFFcfc9b3), //F3E3C3),
//     this.colorB = const Color(0xFFE9D5A6),
//     this.colorC = const Color(0xFFD9BE8C),
//     this.colorD = const Color(0xFFB89B6B),
//     // Custom pick
//     // this.colorA = const Color(0xFFcfc9b3), //F3E3C3),
//     // this.colorB = const Color(0xFFc9c7ae), //E9D5A6),
//     // this.colorC = const Color(0xFFc5bfa3), //D9BE8C),
//     // this.colorD = const Color(0xFFbfba9c), //B89B6B),
//     // OG
//     // this.colorA = const Color(0xFFF3E3C3),
//     // this.colorB = const Color(0xFFE9D5A6),
//     // this.colorC = const Color(0xFFD9BE8C),
//     // this.colorD = const Color(0xFFB89B6B),
//     this.gridCols = 15,
//     this.gridRows = 19,
//     this.levels = 30,
//     this.pixelate = true,
//     this.targetHue = 42.0,
//     this.hueLock = 1.0,
//     this.maxSaturation = 0.20,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       width: width,
//       height: height,
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           CustomPaint(
//             painter: _ParchmentPagePainter(
//               shader: shader,
//               seed: seed,
//               colorA: colorA,
//               colorB: colorB,
//               colorC: colorC,
//               colorD: colorD,
//               gridCols: gridCols,
//               gridRows: gridRows,
//               levels: levels,
//               pixelate: pixelate,
//               targetHue: targetHue,
//               hueLock: hueLock,
//               maxSaturation: maxSaturation,
//             ),
//           ),
//           Padding(padding: const EdgeInsets.all(24), child: child),
//         ],
//       ),
//     );
//   }
// }

// class _ParchmentPagePainter extends CustomPainter {
//   final ui.FragmentShader shader;
//   final int seed;
//   final Color colorA, colorB, colorC, colorD;
//   final double gridCols, gridRows, levels;
//   final bool pixelate;
//   final double targetHue, hueLock, maxSaturation;

//   _ParchmentPagePainter({
//     required this.shader,
//     required this.seed,
//     required this.colorA,
//     required this.colorB,
//     required this.colorC,
//     required this.colorD,
//     required this.gridCols,
//     required this.gridRows,
//     required this.levels,
//     required this.pixelate,
//     required this.targetHue,
//     required this.hueLock,
//     required this.maxSaturation,
//   });

//   void _setColor(int startIndex, Color c) {
//     shader.setFloat(startIndex, c.r);
//     shader.setFloat(startIndex + 1, c.g);
//     shader.setFloat(startIndex + 2, c.b);
//     shader.setFloat(startIndex + 3, c.a);
//   }

//   @override
//   void paint(Canvas canvas, Size size) {
//     // Index bookkeeping - must match the .frag file's uniform DECLARATION
//     // order exactly, counting each vec4 as 4 float slots:
//     //   0-1   uSize (vec2)          -> 2 floats
//     //   2-5   uColorA (vec4)        -> 4 floats
//     //   6-9   uColorB (vec4)        -> 4 floats
//     //   10-13 uColorC (vec4)        -> 4 floats
//     //   14-17 uColorD (vec4)        -> 4 floats
//     //   18    uSeed (float)         -> 1 float
//     //   19    uCols (float)
//     //   20    uRows (float)
//     //   21    uLevels (float)
//     //   22    uPixelate (float)
//     //   23    uTargetHue (float)
//     //   24    uHueLock (float)
//     //   25    uMaxSaturation (float)
//     shader.setFloat(0, size.width);
//     shader.setFloat(1, size.height);
//     _setColor(2, colorA);
//     _setColor(6, colorB);
//     _setColor(10, colorC);
//     _setColor(14, colorD);
//     shader.setFloat(18, seed.toDouble());
//     shader.setFloat(19, gridCols);
//     shader.setFloat(20, gridRows);
//     shader.setFloat(21, levels);
//     shader.setFloat(22, pixelate ? 1.0 : 0.0);
//     shader.setFloat(23, targetHue);
//     shader.setFloat(24, hueLock);
//     shader.setFloat(25, maxSaturation);

//     canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
//   }

//   @override
//   bool shouldRepaint(covariant _ParchmentPagePainter oldDelegate) =>
//       oldDelegate.seed != seed ||
//       oldDelegate.pixelate != pixelate ||
//       oldDelegate.gridCols != gridCols ||
//       oldDelegate.gridRows != gridRows ||
//       oldDelegate.levels != levels;
// }

// /// ============================================================================
// /// Wiring into SpinePageFlipper - swap this in for your placeholder
// /// pageBuilder / pageBackBuilder:
// ///
// ///   SpinePageFlipper(
// ///     ...
// ///     pageBuilder: (context, index) => ParchmentPage(
// ///       width: 485,
// ///       height: 480,
// ///       seed: index,
// ///       shader: myLoadedParchmentShader, // load once, hold in state
// ///       child: Text('Page ${index + 1} content...'),
// ///     ),
// ///   )
// /// ============================================================================
