import 'package:flutter/material.dart';
import 'package:once_upon_a_time/barrel.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isPortrait;

  const CustomAppBar({super.key, required this.isPortrait});

  @override
  Widget build(BuildContext context) {
    return isPortrait
        ? AppBar(
            title: Texxt('Once Upon a Time', isOlde: true, useDark: false),
            actions: [
              IconButton(
                icon: Icon(Icons.menu_book),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ],
          )
        : const SizedBox();
  }

  // This getter informs the Scaffold how tall the app bar should be
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // + 20);
}
