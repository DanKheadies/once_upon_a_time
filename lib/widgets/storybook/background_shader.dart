import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class BackgroundShader extends StatefulWidget {
  final double height;
  final double width;
  final Function isInitialized;

  const BackgroundShader({
    super.key,
    required this.height,
    required this.isInitialized,
    required this.width,
  });

  @override
  State<BackgroundShader> createState() => _BackgroundShaderState();
}

class _BackgroundShaderState extends State<BackgroundShader> {
  bool hasShader = false;

  late ui.FragmentShader pageShader;

  @override
  void initState() {
    super.initState();

    loadShader();
  }

  @override
  void dispose() {
    pageShader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _ShaderPainter(shader: pageShader),
    );
    // return SizedBox.expand(
    //   child: FittedBox(
    //     fit: BoxFit.cover,
    //     child: hasShader ? SizedBox() : const SizedBox(),
    //     // child: SizedBox(
    //     //   height: videoController.value.size.height,
    //     //   width: videoController.value.size.width,
    //     //   child: videoController.value.isInitialized
    //     //       ? VideoPlayer(videoController)
    //     //       : const SizedBox(),
    //     // ),
    //   ),
    // );
    // return SizedBox.expand(
    //   child: Stack(
    //     fit: StackFit.expand,
    //     children: [
    //       // CustomPaint(
    //       //   painter: _ShaderPainter(
    //       //     shader: shader,
    //       //     seed: seed,
    //       //     colorA: colorA,
    //       //     colorB: colorB,
    //       //     colorC: colorC,
    //       //     colorD: colorD,
    //       //     gridCols: gridCols,
    //       //     gridRows: gridRows,
    //       //     levels: levels,
    //       //     pixelate: pixelate,
    //       //     targetHue: targetHue,
    //       //     hueLock: hueLock,
    //       //     maxSaturation: maxSaturation,
    //       //     cellVariation: cellVariation,
    //       //     fadeStart: fadeStart,
    //       //     fadeEnd: fadeEnd,
    //       //   ),
    //       // ),
    //     ],
    //   ),
    // );
  }

  Future<void> loadShader() async {
    final program = await ui.FragmentProgram.fromAsset(
      'assets/shaders/anime_fire.frag',
    );
    setState(() {
      hasShader = true;
      pageShader = program.fragmentShader();
    });
    widget.isInitialized();
  }
}

class _ShaderPainter extends CustomPainter {
  final ui.FragmentShader shader;
  // final int seed;
  // final Color colorA, colorB, colorC, colorD;
  // final double gridCols, gridRows, levels;
  // final bool pixelate;
  // final double targetHue, hueLock, maxSaturation;
  // final double cellVariation, fadeStart, fadeEnd;

  _ShaderPainter({
    required this.shader,
    // required this.seed,
    // required this.colorA,
    // required this.colorB,
    // required this.colorC,
    // required this.colorD,
    // required this.gridCols,
    // required this.gridRows,
    // required this.levels,
    // required this.pixelate,
    // required this.targetHue,
    // required this.hueLock,
    // required this.maxSaturation,
    // required this.cellVariation,
    // required this.fadeStart,
    // required this.fadeEnd,
  });

  // void _setColor(int startIndex, Color c) {
  //   shader.setFloat(startIndex, c.r);
  //   shader.setFloat(startIndex + 1, c.g);
  //   shader.setFloat(startIndex + 2, c.b);
  //   shader.setFloat(startIndex + 3, c.a);
  // }

  @override
  void paint(Canvas canvas, Size size) {
    // // Index bookkeeping - must match the .frag file's uniform DECLARATION
    // // order exactly, counting each vec4 as 4 float slots:
    // //   0-1   uSize (vec2)          -> 2 floats
    // //   2-5   uColorA (vec4)        -> 4 floats
    // //   6-9   uColorB (vec4)        -> 4 floats
    // //   10-13 uColorC (vec4)        -> 4 floats
    // //   14-17 uColorD (vec4)        -> 4 floats
    // //   18    uSeed (float)         -> 1 float
    // //   19    uCols (float)
    // //   20    uRows (float)
    // //   21    uLevels (float)
    // //   22    uPixelate (float)
    // //   23    uTargetHue (float)
    // //   24    uHueLock (float)
    // //   25    uMaxSaturation (float)
    // //   26    uCellVariation (float)
    // //   27    uFadeStart (float)
    // //   28    uFadeEnd (float)
    // shader.setFloat(0, size.width);
    // shader.setFloat(1, size.height);
    // _setColor(2, colorA);
    // _setColor(6, colorB);
    // _setColor(10, colorC);
    // _setColor(14, colorD);
    // shader.setFloat(18, seed.toDouble());
    // shader.setFloat(19, gridCols);
    // shader.setFloat(20, gridRows);
    // shader.setFloat(21, levels);
    // shader.setFloat(22, pixelate ? 1.0 : 0.0);
    // shader.setFloat(23, targetHue);
    // shader.setFloat(24, hueLock);
    // shader.setFloat(25, maxSaturation);
    // shader.setFloat(26, cellVariation);
    // shader.setFloat(27, fadeStart);
    // shader.setFloat(28, fadeEnd);

    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _ShaderPainter oldDelegate) => false;
  // oldDelegate.seed != seed ||
  // oldDelegate.pixelate != pixelate ||
  // oldDelegate.gridCols != gridCols ||
  // oldDelegate.gridRows != gridRows ||
  // oldDelegate.levels != levels ||
  // oldDelegate.cellVariation != cellVariation ||
  // oldDelegate.fadeStart != fadeStart ||
  // oldDelegate.fadeEnd != fadeEnd;
}
