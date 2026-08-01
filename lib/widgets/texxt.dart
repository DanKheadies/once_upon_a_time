import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:once_upon_a_time/barrel.dart';

class Texxt extends StatelessWidget {
  final bool? isOlde;
  final bool? useDark;
  final double? height;
  final double? size;
  final String text;

  const Texxt(
    this.text, {
    super.key,
    this.height,
    this.isOlde = false,
    this.size = 24,
    this.useDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Text(
          text,
          style: TextStyle(
            color: useDark!
                ? Theme.of(context).colorScheme.inverseSurface
                : Theme.of(context).colorScheme.surface,
            fontFamily: isOlde! ? 'HoldMoney' : state.fontFamily,
            fontSize: size,
            height: height,
          ),
        );
      },
    );
  }
}
