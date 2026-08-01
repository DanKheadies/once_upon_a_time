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

  late ShapeInstanceLayout? gridLayout;
  late ui.FragmentProgram program;
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

            print('($width, $height)');

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
                      onPressed: () => toggleGridLayout(program),
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
    final uiProgram = await ui.FragmentProgram.fromAsset(
      'assets/shaders/instanced_shape_morph.frag',
    );

    setState(() {
      gridLayout = ShapeInstanceLayout.grid(
        program: uiProgram,
        columns: 10,
        rows: 10,
        instanceScale: 12,
      );
      // gridLayout = ShapeInstanceLayout.chaotic(
      //   program: uiProgram,
      //   count: 69,
      //   instanceScale: 12,
      // );
      shapeShader = uiProgram.fragmentShader();
      hasShader = true;
      program = uiProgram;
    });
  }

  void toggleGridLayout(ui.FragmentProgram program) {
    if (gridType == GridType.bouncing) {
      setState(() {
        gridLayout = ShapeInstanceLayout.chaotic(
          program: program,
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
          program: program,
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
          program: program,
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
