import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:once_upon_a_time/barrel.dart';

// final shader = (await FragmentProgram.fromAsset(
//   'shaders/instanced_shape_morph.frag',
// )).fragmentShader();

enum GridType { bouncing, chaotic, grid }

class StageScreen extends StatefulWidget {
  const StageScreen({super.key});

  @override
  State<StageScreen> createState() => _StageScreenState();
}

class _StageScreenState extends State<StageScreen> {
  bool hasShader = false;
  // bool isGrid = true;
  GridType gridType = GridType.grid;

  late ui.Image logo;
  late ShapeInstanceLayout? gridLayout;
  late ui.FragmentProgram logoProgram;
  late ui.FragmentProgram shapeProgram;
  late ui.FragmentShader logoShader;
  late ui.FragmentShader shapeShader;

  late final ElapsedSecondsClock clock;

  @override
  void initState() {
    super.initState();

    loadShaders();

    clock = ElapsedSecondsClock();
    // gridLayout = ShapeInstanceLayout.grid(columns: 0, rows: 0);
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
      // appBar: CustomAppBar(isPortrait: isPortrait),
      appBar: AppBar(
        title: Texxt(
          'Pineapple Cabaret (${clock.value})',
          isOlde: true,
          useDark: false,
        ),
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            context.goNamed('home');
          },
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double height = constraints.maxHeight;
            double width = constraints.maxWidth;

            // print('($width, $height)');

            return Stack(
              children: [
                // TODO: anime fire shader
                // https://godotshaders.com/shader/anime-style-fire-2d/
                BackgroundVeil(
                  // color: Colors.green.shade100,
                  color: Theme.of(
                    context,
                  ).colorScheme.inverseSurface.withAlpha(100),
                  height: height,
                  isReady: hasShader,
                  width: width,
                ),
                // TODO: shader grid
                if (hasShader) ...[
                  ShapeGridEffect(
                    // shader: shapeShader,
                    // layout: ShapeInstanceLayout.grid(
                    //   program: program,
                    //   columns: 10,
                    //   rows: 10,
                    //   instanceScale: 12,
                    // ),
                    layout: gridLayout!,
                    time: clock,
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: FloatingActionButton(
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

  Future<void> loadShaders() async {
    final logoFragProgram = await ui.FragmentProgram.fromAsset(
      'assets/shaders/logo_tint.frag',
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
      shapeProgram = shapeFragProgram;
      shapeShader = shapeFragProgram.fragmentShader();
      hasShader = true;
    });
  }

  void toggleGridLayout(
    ui.FragmentProgram generalProgram,
    ui.FragmentProgram logoProgram,
  ) {
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
