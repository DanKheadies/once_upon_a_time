import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:once_upon_a_time/barrel.dart';

class CreateStoryPane extends StatefulWidget {
  final double height;
  final double width;

  const CreateStoryPane({super.key, required this.height, required this.width});

  @override
  State<CreateStoryPane> createState() => _CreateStoryPaneState();
}

class _CreateStoryPaneState extends State<CreateStoryPane> {
  bool setDate = false;
  late TextEditingController chaptersCont;
  late TextEditingController povCont;
  late TextEditingController povHintsCont;
  late TextEditingController titleCont;
  late TextEditingController titleHintsCont;

  @override
  void initState() {
    super.initState();

    initializeControllers();
  }

  void initializeControllers() {
    setState(() {
      chaptersCont = TextEditingController();
      povCont = TextEditingController();
      povHintsCont = TextEditingController();
      titleCont = TextEditingController();
      titleHintsCont = TextEditingController();
      setDate = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StoryBloc, StoryState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          (previous.status == StoryStateStatus.updating &&
              current.status == StoryStateStatus.updated),
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage != '') {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Something went wrong.'),
              ),
            );
        }
        if (state.status == StoryStateStatus.updated) {
          // print('successful update; clear out');
          initializeControllers();
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(content: Text('Your story was created. Huzzah.')),
            );
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
                        Container(
                          padding: rowPadding,
                          width: widget.width < 850 ? widget.width : 500,
                          child: CustomInput(
                            labelText: 'Title',
                            initialValue: state.newStory.title,
                            // cont: titleCont,
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
                                    child: CustomInput(
                                      labelText: 'Point of View',
                                      cont: povCont,
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
                                    child: CustomInput(
                                      labelText: 'Chapters',
                                      cont: chaptersCont,
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
                                    child: CustomInput(
                                      labelText: 'Title Hints',
                                      cont: titleHintsCont,
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
                                            isMulti: true,
                                            newStory: state.newStory,
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
                                    child: CustomInput(
                                      labelText: 'POV Hints',
                                      cont: povHintsCont,
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
                                            isMulti: true,
                                            newStory: state.newStory,
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
                        if (!setDate) ...[
                          Tooltip(
                            message: 'Currently set to today.',
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  setDate = !setDate;
                                });
                              },
                              child: Text('Add Creation Date'),
                            ),
                          ),
                        ],
                        if (setDate) ...[
                          Container(
                            padding: rowPadding,
                            width: widget.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: DatePicker(
                                    label: 'Date Created',
                                    onSave: (date) {
                                      context.read<StoryBloc>().add(
                                        UpdateNewStory(
                                          newStory: state.newStory.copyWith(
                                            createdOn: date,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () {
                                    context.read<StoryBloc>().add(
                                      UpdateNewStory(
                                        newStory: state.newStory.copyWith(
                                          createdOn: DateTime.now(),
                                        ),
                                      ),
                                    );
                                    setState(() {
                                      setDate = !setDate;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                        SizedBox(height: 35, width: widget.width),
                        ElevatedButton(
                          onPressed: () {
                            context.read<StoryBloc>().add(
                              CreateStory(
                                newStory: state.newStory.copyWith(
                                  createdBy:
                                      context.read<AuthCubit>().state.uid ??
                                      context.read<AuthCubit>().state.email,
                                ),
                              ),
                            );
                          },
                          child: Text('Save'),
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

  // void addDateCreated(BuildContext context, DateTime date, Story newStory) {
  //   context.read<StoryBloc>().add(
  //     UpdateNewStory(newStory: newStory.copyWith(chapters: chaptersList)),
  //   );

  //   // setState(() {
  //   //   chaptersCont.clear();
  //   // });
  // }

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
