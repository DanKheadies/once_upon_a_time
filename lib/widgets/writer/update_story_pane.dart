import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:once_upon_a_time/barrel.dart';

class UpdateStoryPane extends StatefulWidget {
  final double height;
  final double width;

  const UpdateStoryPane({super.key, required this.height, required this.width});

  @override
  State<UpdateStoryPane> createState() => _UpdateStoryPaneState();
}

class _UpdateStoryPaneState extends State<UpdateStoryPane> {
  TextEditingController chaptersCont = TextEditingController();
  TextEditingController povCont = TextEditingController();
  TextEditingController povHintsCont = TextEditingController();
  TextEditingController titleApproxCont = TextEditingController();
  TextEditingController titleCont = TextEditingController();
  TextEditingController titleHintsCont = TextEditingController();

  @override
  void initState() {
    super.initState();

    titleCont.text = context.read<StoryBloc>().state.newStory.title;
  }

  @override
  void dispose() {
    chaptersCont.dispose();
    povCont.dispose();
    povHintsCont.dispose();
    titleApproxCont.dispose();
    titleCont.dispose();
    titleHintsCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StoryBloc, StoryState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          (previous.status == StoryStateStatus.updating &&
              current.status == StoryStateStatus.updated),
      listener: (context, state) {
        if (state.errorMessage != '') {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage)));
        }
        if (state.status == StoryStateStatus.updated) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(SnackBar(content: Text('Your story was updated.')));
        }
      },
      child: BlocBuilder<StoryBloc, StoryState>(
        builder: (context, state) {
          return SizedBox(
            height: widget.height,
            child: state.status == StoryStateStatus.updating
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 25, width: widget.width),
                        Text('TODO: search / filter'),
                        SizedBox(height: 25, width: widget.width),
                        Container(
                          padding: rowPadding,
                          width: widget.width < 850 ? widget.width : 500,
                          child: SimpleInput(
                            controller: titleCont,
                            labelText: 'Title',
                            onChanged: (value) {
                              context.read<StoryBloc>().add(
                                UpdateNewStory(
                                  newStory: state.newStory.copyWith(
                                    title: value,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // TODO: refactor Title Hints as a link & subsection here
                        Container(
                          padding: rowPadding,
                          width: widget.width < 850 ? widget.width : 500,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: SimpleInput(
                                      controller: povCont,
                                      labelText: 'Point of View',
                                      onEnter: (_) =>
                                          addPOV(context, state.newStory),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () =>
                                        addPOV(context, state.newStory),
                                  ),
                                ],
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: state.newStory.pov.length,
                                itemBuilder: (context, index) => ListTile(
                                  title: Text(state.newStory.pov[index]),
                                  trailing: IconButton(
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
                                  contentPadding: const EdgeInsets.only(
                                    left: 16,
                                  ),
                                  onLongPress: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return EditModal(
                                          content: state.newStory.pov[index],
                                          index: index,
                                          // isMulti: true,
                                          newStory: state.newStory,
                                          onUpdate: (newValue) {
                                            List<String> updatedPOV = state
                                                .newStory
                                                .pov
                                                .toList();
                                            updatedPOV[index] = newValue;
                                            context.read<StoryBloc>().add(
                                              UpdateNewStory(
                                                newStory: state.newStory
                                                    .copyWith(pov: updatedPOV),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        // TODO: refactor POV Hints as a link & subsection here
                        Container(
                          padding: rowPadding,
                          width: widget.width < 850 ? widget.width : 500,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: SimpleInput(
                                      controller: chaptersCont,
                                      labelText: 'Chapters',
                                      isMulti: true,
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
                                  trailing: IconButton(
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
                                            chapters: chaptersList,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  contentPadding: const EdgeInsets.only(
                                    left: 16,
                                  ),
                                  onLongPress: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return EditModal(
                                          content:
                                              state.newStory.chapters[index],
                                          index: index,
                                          isMulti: true,
                                          newStory: state.newStory,
                                          onUpdate: (newValue) {
                                            List<String> updatedChapters = state
                                                .newStory
                                                .chapters
                                                .toList();
                                            updatedChapters[index] = newValue;
                                            context.read<StoryBloc>().add(
                                              UpdateNewStory(
                                                newStory: state.newStory
                                                    .copyWith(
                                                      chapters: updatedChapters,
                                                    ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: rowPadding,
                          width: widget.width < 850 ? widget.width : 500,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: SimpleInput(
                                      controller: titleApproxCont,
                                      labelText: 'Title Approximates',
                                      onEnter: (_) => addTitleApprox(
                                        context,
                                        state.newStory,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () =>
                                        addTitleApprox(context, state.newStory),
                                  ),
                                ],
                              ),
                              if (state.newStory.titleApproximates != null) ...[
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount:
                                      state.newStory.titleApproximates!.length,
                                  itemBuilder: (context, index) => ListTile(
                                    title: Text(
                                      state.newStory.titleApproximates![index],
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: () {
                                        List<String> titleApproxList = state
                                            .newStory
                                            .titleApproximates!
                                            .toList();
                                        titleApproxList.remove(
                                          state
                                              .newStory
                                              .titleApproximates![index],
                                        );

                                        context.read<StoryBloc>().add(
                                          UpdateNewStory(
                                            newStory: state.newStory.copyWith(
                                              titleApproximates:
                                                  titleApproxList,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    contentPadding: const EdgeInsets.only(
                                      left: 16,
                                    ),
                                    onLongPress: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return EditModal(
                                            content: state
                                                .newStory
                                                .titleApproximates![index],
                                            index: index,
                                            newStory: state.newStory,
                                            onUpdate: (newValue) {
                                              List<String> updatedTitleApprox =
                                                  state.newStory.chapters
                                                      .toList();
                                              updatedTitleApprox[index] =
                                                  newValue;
                                              context.read<StoryBloc>().add(
                                                UpdateNewStory(
                                                  newStory: state.newStory
                                                      .copyWith(
                                                        titleApproximates:
                                                            updatedTitleApprox,
                                                      ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: rowPadding,
                          width: widget.width < 850 ? widget.width : 500,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: SimpleInput(
                                      controller: titleHintsCont,
                                      labelText: 'Title Hints',
                                      onEnter: (_) => addTitleHints(
                                        context,
                                        state.newStory,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () =>
                                        addTitleHints(context, state.newStory),
                                  ),
                                ],
                              ),
                              if (state.newStory.titleHints != null) ...[
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: state.newStory.titleHints!.length,
                                  itemBuilder: (context, index) => ListTile(
                                    title: Text(
                                      state.newStory.titleHints![index],
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: () {
                                        List<String> titleHintsList = state
                                            .newStory
                                            .titleHints!
                                            .toList();
                                        titleHintsList.remove(
                                          state.newStory.titleHints![index],
                                        );

                                        context.read<StoryBloc>().add(
                                          UpdateNewStory(
                                            newStory: state.newStory.copyWith(
                                              titleHints: titleHintsList,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    contentPadding: const EdgeInsets.only(
                                      left: 16,
                                    ),
                                    onLongPress: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return EditModal(
                                            content: state
                                                .newStory
                                                .titleHints![index],
                                            index: index,
                                            // isMulti: true,
                                            newStory: state.newStory,
                                            onUpdate: (newValue) {
                                              List<String> updatedChapters =
                                                  state.newStory.chapters
                                                      .toList();
                                              updatedChapters[index] = newValue;
                                              context.read<StoryBloc>().add(
                                                UpdateNewStory(
                                                  newStory: state.newStory
                                                      .copyWith(
                                                        chapters:
                                                            updatedChapters,
                                                      ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: rowPadding,
                          width: widget.width < 850 ? widget.width : 500,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: SimpleInput(
                                      controller: povHintsCont,
                                      labelText: 'POV Hints',
                                      onEnter: (_) =>
                                          addPOVHints(context, state.newStory),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () =>
                                        addPOVHints(context, state.newStory),
                                  ),
                                ],
                              ),
                              if (state.newStory.povHints != null) ...[
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: state.newStory.povHints!.length,
                                  itemBuilder: (context, index) => ListTile(
                                    title: Text(
                                      state.newStory.povHints![index],
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: () {
                                        List<String> povHintsList = state
                                            .newStory
                                            .povHints!
                                            .toList();
                                        povHintsList.remove(
                                          state.newStory.povHints![index],
                                        );

                                        context.read<StoryBloc>().add(
                                          UpdateNewStory(
                                            newStory: state.newStory.copyWith(
                                              povHints: povHintsList,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    contentPadding: const EdgeInsets.only(
                                      left: 16,
                                    ),
                                    onLongPress: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return EditModal(
                                            content:
                                                state.newStory.povHints![index],
                                            index: index,
                                            // isMulti: true,
                                            newStory: state.newStory,
                                            onUpdate: (newValue) {
                                              List<String> updatedPOVHints =
                                                  (state.newStory.povHints ??
                                                          [])
                                                      .toList();
                                              updatedPOVHints[index] = newValue;
                                              context.read<StoryBloc>().add(
                                                UpdateNewStory(
                                                  newStory: state.newStory
                                                      .copyWith(
                                                        povHints:
                                                            updatedPOVHints,
                                                      ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (state.stories.contains((state.newStory))) ...[
                          SizedBox(height: 25, width: widget.width),
                          HyperlinkText(
                            text: 'Delete',
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return DeleteModal(
                                    title: titleCont.text,
                                    onDelete: () =>
                                        deleteStory(context, state.newStory.id),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                        SizedBox(height: 35, width: widget.width),
                        ElevatedButton(
                          onPressed: () {
                            context.read<StoryBloc>().add(
                              UpdateStory(
                                editedStory: state.newStory.copyWith(
                                  createdBy:
                                      context.read<AuthCubit>().state.uid ??
                                      context.read<AuthCubit>().state.email,
                                ),
                              ),
                            );
                          },
                          child: Text('Update'),
                        ),
                        SizedBox(height: 25, width: widget.width),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  EdgeInsetsGeometry rowPadding = const EdgeInsets.only(
    bottom: 25,
    left: 25,
    right: 25,
  );

  Future<bool> deleteStory(BuildContext context, String storyId) async {
    context.read<StoryBloc>().add(DeleteStory(storyId: storyId));

    final hasUpdated = await context.read<StoryBloc>().stream.firstWhere(
      (state) =>
          state.status == StoryStateStatus.updated ||
          state.status == StoryStateStatus.error,
    );

    return hasUpdated.status == StoryStateStatus.updated;
  }

  void addChapter(BuildContext context, Story newStory) {
    if (chaptersCont.text != '') {
      List<String> chaptersList = newStory.chapters.toList();
      chaptersList.add(chaptersCont.text);

      context.read<StoryBloc>().add(
        UpdateNewStory(newStory: newStory.copyWith(chapters: chaptersList)),
      );

      setState(() {
        chaptersCont.clear();
      });
    }
  }

  void addPOV(BuildContext context, Story newStory) {
    if (povCont.text != '') {
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

  void addPOVHints(BuildContext context, Story newStory) {
    if (povHintsCont.text != '') {
      List<String> povHintsList = (newStory.povHints ?? []).toList();
      povHintsList.add(povHintsCont.text);

      context.read<StoryBloc>().add(
        UpdateNewStory(newStory: newStory.copyWith(povHints: povHintsList)),
      );

      setState(() {
        povHintsCont.clear();
      });
    }
  }

  void addTitleApprox(BuildContext context, Story newStory) {
    if (titleApproxCont.text != '') {
      List<String> titleApproxList = (newStory.titleApproximates ?? [])
          .toList();
      titleApproxList.add(titleApproxCont.text);

      context.read<StoryBloc>().add(
        UpdateNewStory(
          newStory: newStory.copyWith(titleApproximates: titleApproxList),
        ),
      );

      setState(() {
        titleApproxCont.clear();
      });
    }
  }

  void addTitleHints(BuildContext context, Story newStory) {
    if (titleHintsCont.text != '') {
      List<String> titleHintsList = (newStory.titleHints ?? []).toList();
      titleHintsList.add(titleHintsCont.text);

      context.read<StoryBloc>().add(
        UpdateNewStory(newStory: newStory.copyWith(titleHints: titleHintsList)),
      );

      setState(() {
        titleHintsCont.clear();
      });
    }
  }
}
