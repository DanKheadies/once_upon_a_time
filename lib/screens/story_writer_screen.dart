import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:once_upon_a_time/barrel.dart';

class StoryWriterScreen extends StatefulWidget {
  const StoryWriterScreen({super.key});

  @override
  State<StoryWriterScreen> createState() => _StoryWriterScreenState();
}

class _StoryWriterScreenState extends State<StoryWriterScreen> {
  WriterTabType activeTab = WriterTabType.create;

  @override
  void initState() {
    super.initState();

    // context.read<StoryBloc>().add(UpdateNewStory(newStory: Story.emptyStory));
  }

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
                ),
                if (activeTab == WriterTabType.create) ...[
                  CreateStoryPane(height: height - 75, width: width),
                ],
                if (activeTab == WriterTabType.read) ...[
                  Texxt('read', useDark: false),
                ],
                if (activeTab == WriterTabType.update) ...[
                  Texxt('update', useDark: false),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class CreateStoryPane extends StatefulWidget {
  final double height;
  final double width;

  const CreateStoryPane({super.key, required this.height, required this.width});

  @override
  State<CreateStoryPane> createState() => _CreateStoryPaneState();
}

class _CreateStoryPaneState extends State<CreateStoryPane> {
  TextEditingController chaptersCont = TextEditingController();
  TextEditingController povCont = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryBloc, StoryState>(
      builder: (context, state) {
        return SizedBox(
          height: widget.height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 25, width: widget.width),
                Container(
                  padding: const EdgeInsets.only(
                    bottom: 25,
                    left: 25,
                    right: 25,
                  ),
                  width: widget.width < 850 ? widget.width : 500,
                  child: CustomInput(
                    labelText: 'Title',
                    initialValue: state.newStory.title,
                    onChanged: (value) {
                      context.read<StoryBloc>().add(
                        UpdateNewStory(
                          newStory: state.newStory.copyWith(title: value),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(
                    bottom: 25,
                    left: 25,
                    right: 25,
                  ),
                  width: widget.width < 850 ? widget.width : 500,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: CustomInput(
                              labelText: 'Point of View',
                              cont: povCont,
                              onEnter: (_) => addPOV(context, state.newStory),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => addPOV(context, state.newStory),
                          ),
                        ],
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: state.newStory.pov.length,
                        itemBuilder: (context, index) => ListTile(
                          title: Text(state.newStory.pov[index]),
                          trailing: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                List<String> povList = state.newStory.pov
                                    .toList();
                                povList.remove(state.newStory.pov[index]);

                                context.read<StoryBloc>().add(
                                  UpdateNewStory(
                                    newStory: state.newStory.copyWith(
                                      pov: povList,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(
                    bottom: 25,
                    left: 25,
                    right: 25,
                  ),
                  width: widget.width < 850 ? widget.width : 500,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: CustomInput(
                              labelText: 'Chapters',
                              cont: chaptersCont,
                              onEnter: (_) =>
                                  addChapter(context, state.newStory),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () =>
                                addChapter(context, state.newStory),
                          ),
                        ],
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: state.newStory.chapters.length,
                        itemBuilder: (context, index) => ListTile(
                          title: Text(state.newStory.chapters[index]),
                          trailing: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                List<String> chaptersList = state
                                    .newStory
                                    .chapters
                                    .toList();
                                chaptersList.remove(
                                  state.newStory.chapters[index],
                                );

                                context.read<StoryBloc>().add(
                                  UpdateNewStory(
                                    newStory: state.newStory.copyWith(
                                      pov: chaptersList,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          onLongPress: () {
                            print('show dialog to edit');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                CustomInput(labelText: 'Title Hints'),
                CustomInput(labelText: 'POV Hints'),
                SizedBox(height: 25, width: widget.width),
                ElevatedButton(onPressed: () {}, child: Text('Save')),
                SizedBox(height: 25, width: widget.width),
              ],
            ),
          ),
        );
      },
    );
  }

  void addChapter(BuildContext context, Story newStory) {
    List<String> chaptersList = newStory.chapters.toList();
    chaptersList.add(chaptersCont.text);

    context.read<StoryBloc>().add(
      UpdateNewStory(newStory: newStory.copyWith(chapters: chaptersList)),
    );

    setState(() {
      chaptersCont.clear();
    });
  }

  void addPOV(BuildContext context, Story newStory) {
    List<String> povList = newStory.pov.toList();
    povList.add(povCont.text);

    context.read<StoryBloc>().add(
      UpdateNewStory(newStory: newStory.copyWith(pov: povList)),
    );

    setState(() {
      povCont.clear();
    });
  }
}
