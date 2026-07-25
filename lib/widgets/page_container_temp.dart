import 'package:flutter/material.dart';

class PageContainerTemp extends StatelessWidget {
  final double height;
  final double width;
  final int seed;
  final String text;

  const PageContainerTemp({
    super.key,
    required this.height,
    required this.seed,
    required this.text,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    // print('build PageContainerTemp: $text');
    // return Container(
    return Container(
      width: width, // bookSize atm
      height: height, // bookSize atm
      // color: Color.lerp(
      //   const Color(0xFFF3E3C3),
      //   const Color(0xFFE9D5A6),
      //   (seed % 5) / 5,
      // )!,
      decoration: BoxDecoration(
        color: Colors.red.shade100.withAlpha(200),
        border: BoxBorder.all(),
      ),
      // DACO
      margin: const EdgeInsets.only(bottom: 0, left: 0),
      // margin: const EdgeInsets.only(bottom: 60, left: 10),
      padding: const EdgeInsets.all(24),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.inverseSurface,
          fontFamily: 'Georgia',
          fontSize: 18,
        ),
      ),
    );
  }
}
