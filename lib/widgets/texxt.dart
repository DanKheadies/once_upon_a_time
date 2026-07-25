import 'package:flutter/material.dart';

class Texxt extends StatelessWidget {
  final bool? isOlde;
  final bool? useDark;
  final double? size;
  final String text;

  const Texxt(
    this.text, {
    super.key,
    this.isOlde = false,
    this.size = 24,
    this.useDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: useDark!
            ? Theme.of(context).colorScheme.inverseSurface
            : Theme.of(context).colorScheme.surface,
        fontFamily: isOlde! ? 'HoldMoney' : null,
        fontSize: size,
      ),
    );
  }
}
