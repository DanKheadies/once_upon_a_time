import 'package:flutter/material.dart';

class Texxt extends StatelessWidget {
  final bool? isOlde;
  final double? size;
  final String text;

  const Texxt(this.text, {super.key, this.isOlde = false, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.surface,
        fontFamily: isOlde! ? 'HoldMoney' : null,
        fontSize: size,
      ),
    );
  }
}
