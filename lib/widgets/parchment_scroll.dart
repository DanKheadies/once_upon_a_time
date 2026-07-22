import 'dart:math';

import 'package:flutter/material.dart';

/// ============================================================================
/// ScrollBanner
/// ----------------------------------------------------------------------------
/// A variant styled as an unfurled scroll: flat torn top/bottom edges (no
/// side tears, since the sides are "rolled") plus painted wooden dowel caps
/// on the left and right with a highlight/shadow gradient to sell the
/// cylindrical roll. Good for banners, quest logs, "ye olde" UI, etc.
/// ============================================================================
class ScrollBanner extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final EdgeInsets padding;
  final int seed;
  final Color paperColor;
  final Color woodColor;

  const ScrollBanner({
    super.key,
    required this.child,
    required this.width,
    required this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
    this.seed = 7,
    this.paperColor = const Color(0xFFF3E3C3),
    this.woodColor = const Color(0xFF6B4A2E),
  });

  @override
  Widget build(BuildContext context) {
    final dowelWidth = height * 0.16;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Paper body with ragged top/bottom only.
          Positioned(
            left: dowelWidth * 0.55,
            right: dowelWidth * 0.55,
            top: 0,
            bottom: 0,
            child: ClipPath(
              clipper: _HorizontalTornClipper(seed: seed),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.lerp(paperColor, woodColor, 0.10)!,
                      paperColor,
                      Color.lerp(paperColor, woodColor, 0.10)!,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      // color: Colors.black.withOpacity(0.2),
                      color: Colors.black.withAlpha(51),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(padding: padding, child: child),
              ),
            ),
          ),
          // Left dowel cap.
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: dowelWidth,
            child: _Dowel(color: woodColor),
          ),
          // Right dowel cap.
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: dowelWidth,
            child: _Dowel(color: woodColor),
          ),
        ],
      ),
    );
  }
}

/// A single rolled wooden dowel cap with a radial highlight to read as
/// cylindrical, plus small knob caps top and bottom.
class _Dowel extends StatelessWidget {
  final Color color;
  const _Dowel({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color.lerp(color, Colors.black, 0.35)!,
            Color.lerp(color, Colors.white, 0.25)!,
            color,
            Color.lerp(color, Colors.black, 0.35)!,
          ],
          stops: const [0.0, 0.35, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            // color: Colors.black.withOpacity(0.35),
            color: Colors.black.withAlpha(89),
            blurRadius: 6,
            offset: const Offset(2, 3),
          ),
        ],
      ),
    );
  }
}

/// Clips only the top and bottom edges into a torn shape; left/right stay
/// straight since they tuck behind the dowel caps in [ScrollBanner].
class _HorizontalTornClipper extends CustomClipper<Path> {
  final int seed;
  const _HorizontalTornClipper({required this.seed});

  @override
  Path getClip(Size size) {
    final rand = Random(seed);
    final w = size.width;
    final h = size.height;
    const segLen = 16.0;
    const depth = 8.0;

    Offset jag(Offset base, Offset inward) {
      final r = rand.nextDouble();
      final mag = r < 0.15
          ? depth * (0.6 + rand.nextDouble() * 0.4)
          : depth * rand.nextDouble() * 0.4;
      return base + inward * mag;
    }

    final path = Path()..moveTo(0, 0);
    final nTop = max(3, (w / segLen).round());
    for (int i = 0; i <= nTop; i++) {
      final t = i / nTop;
      final base = Offset(w * t, 0);
      final p = (i == 0 || i == nTop) ? base : jag(base, const Offset(0, 1));
      path.lineTo(p.dx, p.dy);
    }
    path.lineTo(w, h);
    final nBottom = max(3, (w / segLen).round());
    for (int i = 1; i <= nBottom; i++) {
      final t = i / nBottom;
      final base = Offset(w - w * t, h);
      final p = (i == nBottom) ? base : jag(base, const Offset(0, -1));
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _HorizontalTornClipper oldClipper) =>
      oldClipper.seed != seed;
}
