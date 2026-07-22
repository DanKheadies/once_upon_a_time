import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:once_upon_a_time/barrel.dart';

Future<FragmentShader> loadParchmentShader() async {
  final program = await FragmentProgram.fromAsset(
    'assets/shaders/parchment.frag',
  );
  return program.fragmentShader();
}

class ParchmentContainer extends StatefulWidget {
  final Color baseColor;
  final Color edgeColor;
  final double height;
  final double width;

  /// 0.0 (barely torn) to 1.0 (very ragged). Values around 0.4-0.6 look best.
  final double raggedness;

  final EdgeInsets padding;

  /// Any int works as a seed. Same seed + same size => same torn shape every
  /// rebuild (so it doesn't "flicker" into a new random shape on setState).
  final int seed;

  final Widget? child;

  const ParchmentContainer({
    super.key,
    required this.width,
    required this.height,
    this.child,
    this.padding = const EdgeInsets.all(24),
    this.seed = 42,
    this.raggedness = 0.5,
    this.baseColor = const Color(0xFFF3E3C3),
    this.edgeColor = const Color(0xFF8B7748),
  });

  @override
  State<ParchmentContainer> createState() => _ParchmentContainerState();
}

class _ParchmentContainerState extends State<ParchmentContainer> {
  bool hasShader = false;
  bool showShader = false;
  late FragmentShader parchmentShader;

  @override
  void initState() {
    super.initState();

    loadShader();
  }

  Future<void> loadShader() async {
    parchmentShader = await loadParchmentShader();
    setState(() {
      hasShader = true;
    });
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {
      showShader = true;
    });
  }

  @override
  void dispose() {
    parchmentShader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clipper = _TornEdgeClipper(
      seed: widget.seed,
      raggedness: widget.raggedness,
    );

    return Opacity(
      opacity: 0.9,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          children: [
            // Placeholder when shader is loading.
            if (!hasShader) ...[
              // Shadow layer: same torn silhouette, offset + blurred, sitting
              // underneath so the shadow reads as "paper" rather than "box".
              Positioned.fill(
                child: ClipPath(
                  clipper: clipper,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      // color: Colors.black.withOpacity(0.001), // keeps clip visible
                      color: Colors.black.withAlpha(1), // keeps clip visible
                      boxShadow: [
                        BoxShadow(
                          // color: Colors.black.withOpacity(0.28),
                          color: Colors.black.withAlpha(71),
                          blurRadius: 16,
                          offset: const Offset(6, 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Main parchment layer.
              Positioned.fill(
                child: ClipPath(
                  clipper: clipper,
                  child: CustomPaint(
                    foregroundPainter: _ParchmentTexturePainter(
                      seed: widget.seed,
                      edgeColor: widget.edgeColor,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 1.15,
                          colors: [
                            // widget.baseColor,
                            parchment1,
                            Color.lerp(
                              // widget.baseColor,
                              parchment1,
                              // widget.edgeColor,
                              parchment2,
                              0.30,
                            )!,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            // Main shader; flavortown.
            if (hasShader) ...[
              Positioned.fill(
                child: AnimatedCrossFade(
                  crossFadeState: hasShader
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(seconds: 1),
                  firstChild: const SizedBox(),
                  secondChild: ClipPath(
                    clipper: clipper,
                    child: CustomPaint(
                      foregroundPainter: _ParchmentTexturePainter(
                        seed: widget.seed,
                        edgeColor: parchment3, // widget.edgeColor,
                      ),
                      child: CustomPaint(
                        painter: ParchmentShaderPainter(
                          colorA: parchment1,
                          colorB: parchment2,
                          colorC: parchment3,
                          colorD: parchment4,
                          seed: widget.seed.toDouble(),
                          shader: parchmentShader,
                        ),
                        child: SizedBox(
                          height: widget.height,
                          width: widget.width,
                        ),
                        // child: Padding(
                        //    padding: widget.padding,
                        //    child: widget.child,
                        //  ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Clips a rectangle into a torn-edge polygon. Walks all four sides and
/// perturbs each segment inward by a random amount, with an occasional
/// deeper "notch" to sell the hand-torn look.
class _TornEdgeClipper extends CustomClipper<Path> {
  final int seed;
  final double raggedness;

  const _TornEdgeClipper({required this.seed, required this.raggedness});

  @override
  Path getClip(Size size) {
    final rand = Random(seed);
    final w = size.width;
    final h = size.height;
    final depth = 5 + raggedness * 16; // max tear depth in px
    const segLen = 16.0; // approx spacing between jag points

    Offset jag(Offset base, Offset inward) {
      final r = rand.nextDouble();
      // Mostly shallow nibbles, occasionally a deeper tear-notch.
      final mag = r < 0.15
          ? depth * (0.6 + rand.nextDouble() * 0.4)
          : depth * rand.nextDouble() * 0.4;
      return base + inward * mag;
    }

    final path = Path();
    bool first = true;
    void addPoint(Offset p) {
      if (first) {
        path.moveTo(p.dx, p.dy);
        first = false;
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }

    // Top edge: left -> right, inward = down.
    final nTop = max(3, (w / segLen).round());
    for (int i = 0; i <= nTop; i++) {
      final t = i / nTop;
      final base = Offset(w * t, 0);
      addPoint(i == 0 || i == nTop ? base : jag(base, const Offset(0, 1)));
    }
    // Right edge: top -> bottom, inward = left.
    final nRight = max(3, (h / segLen).round());
    for (int i = 1; i <= nRight; i++) {
      final t = i / nRight;
      final base = Offset(w, h * t);
      addPoint(i == nRight ? base : jag(base, const Offset(-1, 0)));
    }
    // Bottom edge: right -> left, inward = up.
    final nBottom = max(3, (w / segLen).round());
    for (int i = 1; i <= nBottom; i++) {
      final t = i / nBottom;
      final base = Offset(w - w * t, h);
      // addPoint(i == nBottom ? base : jag(base, const Offset(0, -1)));
      addPoint(i == nBottom ? base : jag(base, const Offset(0, 0)));
    }
    // Left edge: bottom -> top, inward = right.
    final nLeft = max(3, (h / segLen).round());
    for (int i = 1; i <= nLeft; i++) {
      final t = i / nLeft;
      final base = Offset(0, h - h * t);
      addPoint(i == nLeft ? base : jag(base, const Offset(1, 0)));
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _TornEdgeClipper oldClipper) =>
      oldClipper.seed != seed || oldClipper.raggedness != raggedness;
}

/// Draws the "aged paper" texture on top of the base color: a darkened
/// vignette toward the edges (like a light scorch/stain), scattered faint
/// foxing spots, and a handful of short fiber-like strokes.
class _ParchmentTexturePainter extends CustomPainter {
  final int seed;
  final Color edgeColor;

  _ParchmentTexturePainter({required this.seed, required this.edgeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed ^ 0x5EED);
    // final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Edge burn / vignette.
    _drawVignette(canvas, size, edgeColor);
    // canvas.drawRect(rect, );
    // final vignette = Paint()
    //   ..shader = RadialGradient(
    //     // colors: [Colors.transparent, edgeColor.withOpacity(0.5)],
    //     colors: [Colors.transparent, edgeColor.withAlpha(128)],
    //     stops: const [0.70, 1.0],
    //   ).createShader(rect);
    // canvas.drawRect(rect, vignette);

    // final vignette = Paint()
    //   ..shader = MeshGradientPainter(shader: shader, points: points, options: options).paint(canvas, size)
    // MeshGradientPainter(
    //       points: points,
    //       // Low latency configurations (ex: level of vertex detail)
    //       options: MeshGradientOptions(
    //         blend: 3.5, // Controls how softly the colors blend into each other
    //       ).paint(canvas, size);

    // Foxing / age spots.
    final spotPaint = Paint()..style = PaintingStyle.fill;
    final spotCount = (size.width * size.height / 9000).clamp(6, 40).toInt();
    for (int i = 0; i < spotCount; i++) {
      final dx = rand.nextDouble() * size.width;
      final dy = rand.nextDouble() * size.height;
      final r = 1.2 + rand.nextDouble() * 2.5;
      // spotPaint.color = edgeColor.withOpacity(0.05 + rand.nextDouble() * 0.10);
      // spotPaint.color = edgeColor.withValues(
      //   alpha: 0.05 + rand.nextDouble() * 0.10,
      // );
      spotPaint.color = edgeColor.withValues(
        alpha: 0.1 + rand.nextDouble() * rand.nextDouble(), // * 0.50,
      );
      canvas.drawCircle(Offset(dx, dy), r, spotPaint);
    }

    // Faint fiber strokes.
    for (int i = 0; i < 25; i++) {
      final fiberPaint = Paint()
        ..color = edgeColor.withValues(alpha: rand.nextDouble() * 0.25 + 0.25)
        ..strokeWidth = rand.nextDouble() * 1.5
        ..style = PaintingStyle.stroke;
      final sx = rand.nextDouble() * size.width;
      final sy = rand.nextDouble() * size.height;
      final len = 10 + rand.nextDouble() * 64;
      final angle = rand.nextDouble() * pi;
      final end = Offset(sx + cos(angle) * len, sy + sin(angle) * len);
      canvas.drawLine(Offset(sx, sy), end, fiberPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParchmentTexturePainter oldDelegate) => false;

  void _drawVignette(Canvas canvas, Size size, Color edgeColor) {
    final w = size.width, h = size.height;
    final band = (w < h ? w : h) * 0.15; // vignette thickness, tune to taste

    void edge(Rect r, Alignment from, Alignment to) {
      canvas.drawRect(
        r,
        Paint()
          ..shader = LinearGradient(
            begin: from,
            end: to,
            colors: [edgeColor.withValues(alpha: 0.1), Colors.transparent],
          ).createShader(r),
      );
    }

    edge(
      Rect.fromLTWH(0, 0, w, band),
      Alignment.topCenter,
      Alignment.bottomCenter,
    );
    edge(
      Rect.fromLTWH(0, h - band, w, band),
      Alignment.bottomCenter,
      Alignment.topCenter,
    );
    edge(
      Rect.fromLTWH(0, 0, band, h),
      Alignment.centerLeft,
      Alignment.centerRight,
    );
    edge(
      Rect.fromLTWH(w - band, 0, band, h),
      Alignment.centerRight,
      Alignment.centerLeft,
    );
  }
}
