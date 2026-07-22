import 'dart:ui';

import 'package:flutter/material.dart';

class ParchmentShaderPainter extends CustomPainter {
  final FragmentShader shader;
  final double seed;
  final Color colorA, colorB, colorC, colorD;

  ParchmentShaderPainter({
    required this.shader,
    required this.seed,
    required this.colorA,
    required this.colorB,
    required this.colorC,
    required this.colorD,
  });

  void _setColor(int start, Color c) {
    shader.setFloat(start, c.r);
    shader.setFloat(start + 1, c.g);
    shader.setFloat(start + 2, c.b);
    shader.setFloat(start + 3, c.a);
  }

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    _setColor(2, colorA);
    _setColor(6, colorB);
    _setColor(10, colorC);
    _setColor(14, colorD);
    shader.setFloat(18, seed);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant ParchmentShaderPainter oldDelegate) => true;
}
