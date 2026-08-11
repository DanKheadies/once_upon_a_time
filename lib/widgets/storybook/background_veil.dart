import 'package:flutter/material.dart';

class BackgroundVeil extends StatelessWidget {
  final bool isReady;
  final Color color;
  final double height;
  final double width;
  final double? borderHeight;

  const BackgroundVeil({
    super.key,
    required this.color,
    required this.height,
    required this.isReady,
    required this.width,
    this.borderHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full
        AnimatedContainer(
          duration: Duration(seconds: 1),
          height: height,
          width: width,
          color: Theme.of(
            context,
          ).scaffoldBackgroundColor.withAlpha(isReady ? 100 : 255),
        ),
        // Left
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: borderHeight,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, Colors.transparent]),
            ),
          ),
        ),
        // Top
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: width,
            height: borderHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, Colors.transparent],
                begin: AlignmentGeometry.topCenter,
                end: AlignmentGeometry.bottomCenter,
              ),
            ),
          ),
        ),
        // Right
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: borderHeight,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.transparent, color]),
            ),
          ),
        ),
        // Bottom
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            width: width,
            height: borderHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, color],
                begin: AlignmentGeometry.topCenter,
                end: AlignmentGeometry.bottomCenter,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
