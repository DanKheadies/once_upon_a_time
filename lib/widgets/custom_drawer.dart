import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:once_upon_a_time/barrel.dart';

class CustomDrawer extends StatelessWidget {
  final bool? isStorybook;
  final bool? isStorybookOpen;
  final VoidCallback? resetStory;
  final VoidCallback? solveStory;

  const CustomDrawer({
    super.key,
    this.isStorybook = true,
    this.isStorybookOpen = false,
    this.resetStory,
    this.solveStory,
  });

  @override
  Widget build(BuildContext context) {
    Color activeColor = isStorybookOpen!
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.surface;

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // InkWell(
          //   mouseCursor: SystemMouseCursors.click,
          //   onTap: () => context.read<BrightnessCubit>().toggleBrightness(),
          //   child: BlocBuilder<BrightnessCubit, Brightness>(
          //     builder: (context, cubit) {
          //       return Container(
          //         margin: const EdgeInsets.only(bottom: 10, top: 40),
          //         height: 225,
          //         padding: const EdgeInsets.symmetric(horizontal: 25),
          //         child: Image(
          //           image: AssetImage(
          //             'assets/images/storybook.png',
          //             // cubit == Brightness.dark
          //             //     ? 'assets/images/bollard-og-teal.png'
          //             //     : 'assets/images/ship-teal.png',
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          // ),
          GestureDetector(
            onDoubleTap: () {
              context.goNamed('auth');
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Image(
                image: AssetImage(
                  'assets/images/storybook.png',
                  // cubit == Brightness.dark
                  //     ? 'assets/images/bollard-og-teal.png'
                  //     : 'assets/images/ship-teal.png',
                ),
              ),
            ),
          ),
          Center(
            child: Texxt('Once Upon a Time', isOlde: true, useDark: false),
          ),
          const SizedBox(height: 15),
          if (isStorybook!) ...[
            ListTile(
              title: Text(
                'Solve Story',
                style: TextStyle(fontSize: 18, color: activeColor),
              ),
              leading: Icon(Icons.auto_awesome, color: activeColor),
              onTap: isStorybookOpen! ? solveStory ?? () {} : null,
              hoverColor: Theme.of(context).colorScheme.primary.withAlpha(30),
            ),
            ListTile(
              title: Text(
                'New Story',
                style: TextStyle(fontSize: 18, color: activeColor),
              ),
              leading: Icon(Icons.auto_mode, color: activeColor),
              onTap: isStorybookOpen!
                  ? () {
                      context.read<StoryBloc>().add(
                        NewStory(
                          storyId: context
                              .read<StoryBloc>()
                              .state
                              .currentStory
                              .id,
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  : null,
              hoverColor: Theme.of(context).colorScheme.primary.withAlpha(30),
            ),
            ListTile(
              title: Text(
                'Reset Story',
                style: TextStyle(fontSize: 18, color: activeColor),
              ),
              leading: Icon(Icons.autorenew, color: activeColor),
              onTap: isStorybookOpen!
                  ? () {
                      if (resetStory != null) resetStory!();
                      Navigator.of(context).pop();
                    }
                  : null,
              hoverColor: Theme.of(context).colorScheme.primary.withAlpha(30),
            ),
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) {
                return ListTile(
                  title: Text(
                    'Toggle Buttons (${state.showActionButtons ? 'On' : 'Off'})',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  leading: Icon(
                    Icons.autorenew,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () => context.read<SettingsCubit>().toggleButtons(),
                  hoverColor: Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha(30),
                );
              },
            ),
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) {
                return ListTile(
                  title: Text(
                    'Toggle Font (${state.fontFamily ?? 'System'})',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  leading: Icon(
                    Icons.next_plan_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () => context.read<SettingsCubit>().rotateFonts(),
                  hoverColor: Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha(30),
                );
              },
            ),
            ListTile(
              title: Text(
                'Support',
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              leading: Icon(
                Icons.help_outline_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () => context.goNamed('contact'),
              hoverColor: Theme.of(context).colorScheme.primary.withAlpha(30),
            ),
          ],
          if (!isStorybook!) ...[
            ListTile(
              title: Text(
                'Storybook',
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              leading: Icon(
                Icons.help_outline_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () => context.goNamed('home'),
              hoverColor: Theme.of(context).colorScheme.primary.withAlpha(30),
            ),
            ListTile(
              title: Text(
                'Stage',
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              leading: Icon(
                Icons.temple_buddhist,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () => context.goNamed('stage'),
              hoverColor: Theme.of(context).colorScheme.primary.withAlpha(30),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
