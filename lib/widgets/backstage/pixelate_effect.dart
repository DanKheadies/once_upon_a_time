import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Renders `image` through pixelate.frag. `blocksX`/`blocksY` control how
/// many "pixels" the effect divides the image into — smaller numbers mean
/// chunkier pixelation.
///
/// TODO: maintain centered, aspect ratio on smallest dimension and "cut off"
/// excess, i.e. show the image without distorting its height / width
class PixelateEffect extends StatelessWidget {
  const PixelateEffect({
    super.key,
    required this.shader,
    required this.image,
    this.blocksX = 60,
    this.blocksY = 60,
  });

  final ui.FragmentShader shader;
  final ui.Image image;
  final double blocksX;
  final double blocksY;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _PixelatePainter(
        shader: shader,
        image: image,
        blocksX: blocksX,
        blocksY: blocksY,
      ),
    );
  }
}

class _PixelatePainter extends CustomPainter {
  _PixelatePainter({
    required this.shader,
    required this.image,
    required this.blocksX,
    required this.blocksY,
  });

  final ui.FragmentShader shader;
  final ui.Image image;
  final double blocksX;
  final double blocksY;

  @override
  void paint(Canvas canvas, Size size) {
    // This is a single full-canvas draw (not 100 tiny ones like the shape
    // grid), so there's no shared-buffer aliasing risk here — one shader,
    // one draw, every frame. Setting uSize here (rather than once) means
    // resizes are handled automatically for free.
    shader
      ..setFloat(0, blocksX)
      ..setFloat(1, blocksY)
      ..setFloat(2, size.width)
      ..setFloat(3, size.height)
      ..setImageSampler(0, image);

    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _PixelatePainter oldDelegate) =>
      oldDelegate.image != image ||
      oldDelegate.blocksX != blocksX ||
      oldDelegate.blocksY != blocksY;
}
