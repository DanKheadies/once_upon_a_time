import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:once_upon_a_time/barrel.dart';

class StoryWriterScreen extends StatelessWidget {
  const StoryWriterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double tabsHeight = 50;
    return Scaffold(
      appBar: CustomAppBar(isPortrait: true),
      endDrawer: CustomDrawer(isStorybook: false),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double height = constraints.maxHeight;
            double width = constraints.maxWidth;

            return BlocBuilder<StoryBloc, StoryState>(
              builder: (context, state) {
                return Column(
                  children: [
                    WriterTabs(
                      activeTab: state.tabType,
                      tabs: [
                        {'Create': WriterTabType.create},
                        {'Read': WriterTabType.read},
                        {'Update': WriterTabType.update},
                      ],
                      updateTab: (tab) {
                        context.read<StoryBloc>().add(CacheTab(tab: tab));
                      },
                      height: tabsHeight,
                    ),
                    if (state.tabType == WriterTabType.create) ...[
                      CreateStoryPane(
                        height: height - tabsHeight,
                        width: width,
                      ),
                    ],
                    if (state.tabType == WriterTabType.read) ...[
                      ReadStoriesPane(
                        height: height - tabsHeight,
                        width: width,
                      ),
                    ],
                    if (state.tabType == WriterTabType.update) ...[
                      UpdateStoryPane(
                        height: height - tabsHeight,
                        width: width,
                      ),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
