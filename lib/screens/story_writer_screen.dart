import 'package:flutter/material.dart';
import 'package:once_upon_a_time/barrel.dart';

class StoryWriterScreen extends StatefulWidget {
  const StoryWriterScreen({super.key});

  @override
  State<StoryWriterScreen> createState() => _StoryWriterScreenState();
}

class _StoryWriterScreenState extends State<StoryWriterScreen> {
  double tabsHeight = 50;
  // Story editingStory = Story.emptyStory;
  WriterTabType activeTab = WriterTabType.create;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(isPortrait: true),
      endDrawer: CustomDrawer(isStorybook: false),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double height = constraints.maxHeight;
            double width = constraints.maxWidth;

            // return Center(child: Texxt('Suh', useDark: false));
            return Column(
              children: [
                WriterTabs(
                  activeTab: activeTab,
                  tabs: [
                    {'Create': WriterTabType.create},
                    {'Read': WriterTabType.read},
                    {'Update': WriterTabType.update},
                  ],
                  // updateTab: (tab) => updateTab(context, tab),
                  updateTab: (tab) => setState(() {
                    activeTab = tab;
                  }),
                  height: tabsHeight,
                ),
                if (activeTab == WriterTabType.create) ...[
                  CreateStoryPane(height: height - tabsHeight, width: width),
                ],
                if (activeTab == WriterTabType.read) ...[
                  ReadStoriesPane(
                    height: height - tabsHeight,
                    updateStory: updateStory,
                    width: width,
                  ),
                ],
                if (activeTab == WriterTabType.update) ...[
                  UpdateStoryPane(
                    height: height - tabsHeight,
                    // editingStory: editingStory,
                    width: width,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  void updateStory(Story editingStory) {
    setState(() {
      activeTab = WriterTabType.update;
      editingStory = editingStory;
    });
  }
}
