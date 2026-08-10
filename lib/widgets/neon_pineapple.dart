import 'package:flutter/material.dart';

class NeonPineapple extends StatelessWidget {
  final Size size;

  const NeonPineapple({super.key, this.size = const Size(220, 260)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: size, painter: _NeonPineapplePainter());
  }
}

class _NeonPineapplePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bodyPath = _buildBodyPath(size);
    final crownPath = _buildCrownPath(size);
    final outlinePath = Path()
      ..addPath(bodyPath, Offset.zero)
      ..addPath(crownPath, Offset.zero);

    // Outer outline glow (unchanged from before)
    final outlineLayers = [
      (color: Colors.deepPurple, sigma: 20.0, width: 10.0),
      (color: Colors.pink, sigma: 10.0, width: 7.0),
      (color: Colors.pinkAccent, sigma: 5.0, width: 4.0),
      (color: Colors.white, sigma: 0.0, width: 2.0),
    ];
    for (final layer in outlineLayers) {
      canvas.drawPath(
        outlinePath,
        _glowPaint(layer.color, layer.sigma, layer.width),
      );
    }

    // Cross-hatch skin texture, clipped to the body only
    canvas.save();
    canvas.clipPath(bodyPath);

    final hatchPath = _buildHatchPath(size);
    final hatchLayers = [
      (color: Colors.pink, sigma: 6.0, width: 3.0),
      (color: Colors.pinkAccent, sigma: 2.5, width: 1.5),
      (color: Colors.white, sigma: 0.0, width: 0.8),
    ];
    for (final layer in hatchLayers) {
      canvas.drawPath(
        hatchPath,
        _glowPaint(layer.color, layer.sigma, layer.width),
      );
    }

    canvas.restore();
  }

  Paint _glowPaint(Color color, double sigma, double width) {
    return Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..maskFilter = sigma > 0
          ? MaskFilter.blur(BlurStyle.normal, sigma)
          : null;
  }

  Path _buildBodyPath(Size size) {
    final w = size.width;
    final h = size.height;
    final bodyTop = h * 0.42;
    final bodyBottom = h * 0.95;
    final bodyRect = Rect.fromLTRB(w * 0.22, bodyTop, w * 0.78, bodyBottom);

    return Path()
      ..moveTo(bodyRect.center.dx, bodyTop)
      ..cubicTo(
        bodyRect.left,
        bodyTop,
        bodyRect.left,
        bodyBottom,
        bodyRect.center.dx,
        bodyBottom,
      )
      ..cubicTo(
        bodyRect.right,
        bodyBottom,
        bodyRect.right,
        bodyTop,
        bodyRect.center.dx,
        bodyTop,
      )
      ..close();
  }

  Path _buildCrownPath(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();
    final crownBaseY = h * 0.42 + h * 0.02;
    final crownCenterX = w * 0.5;
    const leafCount = 5;
    final leafSpread = w * 0.34;
    final leafHeight = h * 0.42;

    for (var i = 0; i < leafCount; i++) {
      final t = i / (leafCount - 1);
      final tipX = crownCenterX + (t - 0.5) * leafSpread;
      final heightFactor = 1.0 - (0.5 - t).abs() * 0.9;
      final tip = Offset(tipX, crownBaseY - leafHeight * heightFactor);
      final baseLeft = Offset(
        crownCenterX - w * 0.03 + (t - 0.5) * w * 0.06,
        crownBaseY,
      );
      final baseRight = Offset(
        crownCenterX + w * 0.03 + (t - 0.5) * w * 0.06,
        crownBaseY,
      );

      path
        ..moveTo(baseLeft.dx, baseLeft.dy)
        ..quadraticBezierTo(
          (baseLeft.dx + tip.dx) / 2 - w * 0.02,
          (baseLeft.dy + tip.dy) / 2,
          tip.dx,
          tip.dy,
        )
        ..quadraticBezierTo(
          (baseRight.dx + tip.dx) / 2 + w * 0.02,
          (baseRight.dy + tip.dy) / 2,
          baseRight.dx,
          baseRight.dy,
        )
        ..close();
    }
    return path;
  }

  // Diagonal cross-hatch covering the body's bounding box.
  // Gets clipped to the body shape by the caller.
  Path _buildHatchPath(Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Rect.fromLTRB(w * 0.15, h * 0.38, w * 0.85, h * 1.0);
    final path = Path();

    const spacing = 16.0; // distance between hatch lines — tweak for density
    final diag =
        rect.width + rect.height; // enough length to cover the rect at 45°

    // Lines going "/" direction
    for (double offset = -diag; offset < diag; offset += spacing) {
      path.moveTo(rect.left + offset, rect.bottom);
      path.lineTo(rect.left + offset + rect.height, rect.top);
    }
    // Lines going "\" direction
    for (double offset = -diag; offset < diag; offset += spacing) {
      path.moveTo(rect.left + offset, rect.top);
      path.lineTo(rect.left + offset + rect.height, rect.bottom);
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant _NeonPineapplePainter oldDelegate) => false;
}
