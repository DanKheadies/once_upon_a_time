import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:once_upon_a_time/barrel.dart';

class StageScreen extends StatefulWidget {
  const StageScreen({super.key});

  @override
  State<StageScreen> createState() => _StageScreenState();
}

class _StageScreenState extends State<StageScreen> {
  Size gridDimensions = Size(5, 5);
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
        actions: [IconButton(icon: Icon(Icons.abc), onPressed: () {})],
      ),
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
              PointerDeviceKind.stylus,
            },
          ),
          child: RefreshIndicator(
            onRefresh: () async {
              print('refresh');
            },
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) => Container(
                width: double.infinity,
                height: 100,
                color: index.isEven
                    ? Colors.blue.shade100
                    : Colors.red.shade100,
              ),
            ),
          ),
        ),
      ),
      // body: SafeArea(
      //   child: LayoutBuilder(
      //     builder: (context, constraints) {
      //       double height = constraints.maxHeight;
      //       double width = constraints.maxWidth;

      //       bool isPortrait = height > width;
      //       double dependDimension = isPortrait ? width : height;

      //       print('($width, $height)');
      //       print('dependDimension: $dependDimension');

      //       return GestureDetector(
      //         // onTapMove: (details) {
      //         //   print('DERP');
      //         // },
      //         // onTap: () {
      //         //   print('derp');
      //         // },
      //         // onHorizontalDragUpdate: (details) {
      //         //   print('drag hori via global: ${details.globalPosition}');
      //         //   // print('drag hor via local: ${details.localPosition}');
      //         // },
      //         // onVerticalDragUpdate: (details) {
      //         //   print('drag vert via vert: ${details.globalPosition}');
      //         // },
      //         child: Container(
      //           height: height,
      //           width: width,
      //           color: isPortrait ? Colors.red.shade100 : Colors.blue.shade100,
      //           child: GridView.count(
      //             shrinkWrap: true,
      //             physics: NeverScrollableScrollPhysics(),
      //             // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      //             //   // crossAxisCount: (dependDimension / gridDimensions.width)
      //             //   //     .toInt(),
      //             //   crossAxisCount: gridDimensions.width.toInt(),
      //             //   // mainAxisExtent: gridDimensions.height.toInt()

      //             // ),
      //             crossAxisCount: gridDimensions.width.toInt(),
      //             children: [
      //               Container(
      //                 width: 100,
      //                 height: 100,
      //                 color: Colors.green.shade100,
      //               ),
      //             ],
      //             // itemBuilder: (context, index) {
      //             //   return Container(
      //             //     width: 100,
      //             //     height: 100,
      //             //     decoration: BoxDecoration(
      //             //       border: BoxBorder.all(color: Colors.black12),
      //             //       color: Colors.green.shade100,
      //             //     ),
      //             //   );
      //             // },
      //           ),
      //           // child: Column(
      //           //   children: [
      //           //     Container(
      //           //       width: dependDimension / gridDimensions.width,
      //           //       height: dependDimension / gridDimensions.height,
      //           //       color: Colors.purple.shade100,
      //           //     ),
      //           //     // Container(height: 100, color: Colors.green.shade100),
      //           //     // Row(
      //           //     //   children: [
      //           //     //     Container(
      //           //     //       width: dependDimension / gridDimensions.width,
      //           //     //       height: dependDimension / gridDimensions.height,
      //           //     //       color: Colors.green.shade200,
      //           //     //     ),
      //           //     //     Container(
      //           //     //       width: dependDimension / gridDimensions.width,
      //           //     //       height: dependDimension / gridDimensions.height,
      //           //     //       color: Colors.green.shade100,
      //           //     //     ),
      //           //     //     Container(
      //           //     //       width: dependDimension / gridDimensions.width,
      //           //     //       height: dependDimension / gridDimensions.height,
      //           //     //       color: Colors.green.shade300,
      //           //     //     ),
      //           //     //   ],
      //           //     // ),
      //           //     Row(
      //           //       children: [
      //           //         SizedBox(
      //           //           width: width,
      //           //           height: dependDimension / gridDimensions.height,
      //           //           child: ListView.builder(
      //           //             shrinkWrap: true,
      //           //             physics: NeverScrollableScrollPhysics(),
      //           //             itemCount: gridDimensions.width.toInt(),
      //           //             itemBuilder: (context, index) => Container(
      //           //               width: dependDimension / gridDimensions.width,
      //           //               height: dependDimension / gridDimensions.height,
      //           //               color: index.isEven
      //           //                   ? Colors.yellow.shade100
      //           //                   : Colors.green.shade100,
      //           //             ),
      //           //           ),
      //           //         ),
      //           //       ],
      //           //     ),
      //           //     GridUnit(
      //           //       color: Colors.amber.shade100,
      //           //       id: 'alpha',
      //           //       height: 100,
      //           //       width: 100,
      //           //     ),
      //           //     Row(
      //           //       mainAxisAlignment: MainAxisAlignment.center,
      //           //       children: [
      //           //         Container(
      //           //           width: 100,
      //           //           height: 100,
      //           //           color: Colors.pink.shade100,
      //           //         ),
      //           //         Container(
      //           //           width: 100,
      //           //           height: 100,
      //           //           color: Colors.brown.shade100,
      //           //         ),
      //           //         // Container(
      //           //         //   width: 100,
      //           //         //   height: 100,
      //           //         //   color: Colors.teal.shade100,
      //           //         // ),
      //           //         GridUnit(height: 100, id: 'beta', width: 100),
      //           //         Container(
      //           //           width: 100,
      //           //           height: 100,
      //           //           color: Colors.orange.shade100,
      //           //         ),
      //           //         Container(
      //           //           width: 100,
      //           //           height: 100,
      //           //           color: Colors.blueGrey.shade100,
      //           //         ),
      //           //       ],
      //           //     ),
      //           //     Container(
      //           //       width: 100,
      //           //       height: 100,
      //           //       color: Colors.lime.shade100,
      //           //     ),
      //           //   ],
      //           // ),
      //         ),
      //       );
      //     },
      //   ),
      // ),
    );
  }
}

class GridUnit extends StatelessWidget {
  final Color? color;
  final double height;
  final double width;
  final String id;

  const GridUnit({
    super.key,
    required this.height,
    required this.id,
    required this.width,
    this.color = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: visual (light up, depress, etc), track by id, timers, et al.
        print(
          'id: $id${color != Colors.transparent ? ' (color: ${color.toString()})' : ''}',
        );
      },
      // onHorizontalDragUpdate: (details) {
      //   print('drag @ $id');
      // },
      child: Container(height: height, width: width, color: color),
    );
  }
}
