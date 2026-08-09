import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:once_upon_a_time/barrel.dart';

enum GridType { bouncing, chaotic, grid }

class StageShadersScreen extends StatefulWidget {
  const StageShadersScreen({super.key});

  @override
  State<StageShadersScreen> createState() => _StageShadersScreenState();
}

class _StageShadersScreenState extends State<StageShadersScreen> {
  bool hasPixel = false;
  bool hasShader = false;
  bool isPixel = true;
  bool isShader = false;
  double pixelFactor = 1;
  GridType gridType = GridType.grid;

  late ui.Image logo;
  late ui.Image pixelImage;
  late ShapeInstanceLayout? gridLayout;
  late ui.FragmentProgram logoProgram;
  late ui.FragmentProgram pixelProgram;
  late ui.FragmentProgram shapeProgram;
  late ui.FragmentShader logoShader;
  late ui.FragmentShader pixelShader;
  late ui.FragmentShader shapeShader;

  late final ElapsedSecondsClock clock;

  @override
  void initState() {
    super.initState();

    loadPixelAssets();
    loadShaders();

    clock = ElapsedSecondsClock();
  }

  @override
  void dispose() {
    clock.dispose();
    gridLayout?.dispose();
    logoShader.dispose();
    shapeShader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Texxt('Pineapple Cabaret', isOlde: true, useDark: false),
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            context.goNamed('home');
          },
        ),
        actions: [
          IconButton(
            icon: Icon(isPixel ? Icons.grid_on : Icons.roller_shades_sharp),
            onPressed: () {
              setState(() {
                isPixel = !isPixel;
                isShader = !isShader;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double height = constraints.maxHeight;
            double width = constraints.maxWidth;

            // print('($width, $height)');

            return Stack(
              children: [
                BackgroundVeil(
                  color: Theme.of(
                    context,
                  ).colorScheme.inverseSurface.withAlpha(100),
                  height: height,
                  isReady: hasShader,
                  width: width,
                ),
                if (hasPixel && hasShader && isPixel) ...[
                  PixelateEffect(
                    shader: pixelShader,
                    image: pixelImage,
                    blocksX: width / pixelFactor,
                    blocksY: height / pixelFactor,
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Row(
                      children: [
                        FloatingActionButton(
                          heroTag: 'pixelUp',
                          onPressed: pixelFactor > 1
                              ? () => setState(() {
                                  pixelFactor -= 1;
                                })
                              : null,
                          child: Icon(Icons.remove),
                        ),
                        const SizedBox(width: 10),
                        FloatingActionButton(
                          heroTag: 'pixelDown',
                          onPressed: pixelFactor <= 100
                              ? () => setState(() {
                                  pixelFactor += 1;
                                })
                              : null,
                          child: Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                ],
                if (hasShader && isShader) ...[
                  ShapeGridEffect(layout: gridLayout!, time: clock),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: FloatingActionButton(
                      heroTag: 'changeShader',
                      onPressed: () =>
                          toggleGridLayout(shapeProgram, logoProgram),
                      child: Icon(Icons.gas_meter),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> loadPixelAssets() async {
    final data = await rootBundle.load('assets/images/castle-colors.jpg');
    // final image = await decodeUiImage(data.buffer.asUint8List());
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    final image = frame.image;
    setState(() {
      pixelImage = image;
      hasPixel = true;
    });
  }

  // /// Decodes raw image bytes into a ui.Image. Keep the returned Image alive
  // /// for as long as anything is sampling it — same lesson as logoImage.
  // Future<ui.Image> decodeUiImage(Uint8List bytes) async {
  //   final codec = await ui.instantiateImageCodec(bytes);
  //   final frame = await codec.getNextFrame();
  //   return frame.image;
  // }

  // /// Convenience loader for a bundled asset.
  // Future<ui.Image> loadUiImageFromAsset(String assetPath) async {
  //   final data = await rootBundle.load(assetPath);
  //   return decodeUiImage(data.buffer.asUint8List());
  // }

  Future<void> loadShaders() async {
    final logoFragProgram = await ui.FragmentProgram.fromAsset(
      'assets/shaders/logo_tint.frag',
    );
    final pixelFragProgram = await ui.FragmentProgram.fromAsset(
      'assets/shaders/pixelate.frag',
    );
    final shapeFragProgram = await ui.FragmentProgram.fromAsset(
      'assets/shaders/instanced_shape_morph.frag',
    );

    final logoImage = await ShapeInstanceLayout.rasterizeTextLogo('DVD');

    setState(() {
      gridLayout = ShapeInstanceLayout.bouncing(
        program: logoFragProgram,
        logoImage: logoImage,
        count: 13,
      );
      // gridLayout = ShapeInstanceLayout.grid(
      //   program: shapeFragProgram,
      //   columns: 10,
      //   rows: 10,
      //   instanceScale: 12,
      // );
      // gridLayout = ShapeInstanceLayout.chaotic(
      //   program: shapeFragProgram,
      //   count: 69,
      //   instanceScale: 12,
      // );
      logo = logoImage;
      logoProgram = logoFragProgram;
      logoShader = logoFragProgram.fragmentShader();
      pixelProgram = pixelFragProgram;
      pixelShader = pixelFragProgram.fragmentShader();
      shapeProgram = shapeFragProgram;
      shapeShader = shapeFragProgram.fragmentShader();
      hasShader = true;
    });
  }

  Future<void> toggleGridLayout(
    ui.FragmentProgram generalProgram,
    ui.FragmentProgram logoProgram,
  ) async {
    if (gridType == GridType.bouncing) {
      setState(() {
        gridLayout = ShapeInstanceLayout.chaotic(
          program: generalProgram,
          count: 69,
          // shapeColor: Colors.black,
          // backgroundColor: Colors.white,
          shapeColor: Colors.white,
        );
        gridType = GridType.chaotic;
      });
    } else if (gridType == GridType.chaotic) {
      setState(() {
        gridLayout = ShapeInstanceLayout.grid(
          program: generalProgram,
          columns: 10,
          rows: 10,
          shapeColor: const Color(0xFF3AA6FF),
          // backgroundColor defaults to transparent
        );
        gridType = GridType.grid;
      });
    } else if (gridType == GridType.grid) {
      // Note: the DVD example (95% of the time) shows for a split second and
      // then disappears. Something is destroying the image (most likely), but
      // it's not worth nailing. This was for fun, not results.
      setState(() {
        gridLayout = ShapeInstanceLayout.bouncing(
          program: logoProgram,
          logoImage: logo,
          count: 20,
          instanceScale: 16,
          minSpeed: 0.08,
          maxSpeed: 0.22,
          shapeColor: Colors.cyan,
        );
        gridType = GridType.bouncing;
      });
    }

    // ShapeInstanceLayout.grid(
    //   program: program,
    //   columns: 10,
    //   rows: 10,
    //   shapeColor: const Color(0xFF3AA6FF),
    //   // backgroundColor defaults to transparent
    // );
    // ShapeInstanceLayout.bouncing(
    //   program: program,
    //   count: 20,
    //   instanceScale: 16,
    //   minSpeed: 0.08,
    //   maxSpeed: 0.22,
    //   shapeColor: Colors.cyan,
    // );
  }
}
