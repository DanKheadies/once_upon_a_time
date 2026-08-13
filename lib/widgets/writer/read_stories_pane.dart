import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:once_upon_a_time/barrel.dart';

class ReadStoriesPane extends StatefulWidget {
  final double height;
  final double width;
  final Function(Story) updateStory;

  const ReadStoriesPane({
    super.key,
    required this.height,
    required this.updateStory,
    required this.width,
  });

  @override
  State<ReadStoriesPane> createState() => _ReadStoriesPaneState();
}

class _ReadStoriesPaneState extends State<ReadStoriesPane> {
  @override
  void initState() {
    super.initState();

    context.read<StoryBloc>().add(GetStories(showArchived: true));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryBloc, StoryState>(
      builder: (context, state) {
        if (state.status == StoryStateStatus.loading) {
          return SizedBox(
            height: widget.height,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        double calcWidth = widget.width < 850 ? widget.width - 300 : 300;
        return SizedBox(
          height: widget.height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // TODO: filtering & search tools
                SizedBox(height: 25, width: widget.width),
                Container(
                  padding: rowPadding,
                  width: widget.width < 850 ? widget.width : 500,
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: state.stories.length,
                        itemBuilder: (context, index) => ExpansionTile(
                          title: Text(state.stories[index].title),
                          subtitle: Wrap(
                            children: [
                              // TODO: better distinction / seperation
                              ...state.stories[index].pov.map(
                                (pov) => Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Text(pov),
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              // TODO: queue up UpdateStory
                              // Switch tab to Update
                              print(context.read<AuthCubit>().state.authUser);
                              context.read<StoryBloc>().add(
                                UpdateNewStory(newStory: state.stories[index]),
                              );
                              widget.updateStory(state.stories[index]);
                            },
                          ),
                          childrenPadding: const EdgeInsets.only(left: 16),
                          children: [
                            // if (state.stories[index].isArchived != null &&
                            //     state.stories[index].isArchived!) ...[
                            //   StoryDetailsRow(
                            //     label: 'isArchived',
                            //     value: 'yes, its inactive',
                            //     width: calcWidth,
                            //   ),
                            // ],
                            // if (state.stories[index].isArchived != null &&
                            //     state.stories[index].isArchived!) ...[
                            //       TextButton()
                            //     ],
                            StoryDetailsRow(
                              label: 'id',
                              value: state.stories[index].id,
                              width: calcWidth,
                            ),
                            // TODO: incorporate feedback
                            StoryDetailsRow(
                              isArchived: state.stories[index].isArchived,
                              onHyperlink:
                                  state.status == StoryStateStatus.updating
                                  ? null
                                  : () {
                                      context.read<StoryBloc>().add(
                                        UpdateStory(
                                          editedStory: state.stories[index]
                                              .copyWith(
                                                isArchived:
                                                    state
                                                            .stories[index]
                                                            .isArchived ==
                                                        null
                                                    ? true
                                                    : !state
                                                          .stories[index]
                                                          .isArchived!,
                                              ),
                                        ),
                                      );
                                    },
                              label: 'isArchived',
                              value: state.status == StoryStateStatus.updating
                                  ? 'Updating..'
                                  : '',
                              width: calcWidth,
                            ),
                            StoryDetailsRow(
                              label: 'created',
                              value: state.stories[index].createdOn != null
                                  ? '${DateFormat('MM/dd/yyyy').format(state.stories[index].createdOn!)} (${state.stories[index].createdBy})'
                                  : 'by ${state.stories[index].createdBy}',
                              width: calcWidth,
                            ),
                            StoryDetailsRow(
                              label: 'updated',
                              value: state.stories[index].updatedOn != null
                                  ? DateFormat(
                                      'MM/dd/yyyy',
                                    ).format(state.stories[index].updatedOn!)
                                  : '',
                              width: calcWidth,
                            ),
                            if (state.stories[index].titleHints != null &&
                                state
                                    .stories[index]
                                    .titleHints!
                                    .isNotEmpty) ...[
                              StoryDetailsRow(
                                label: 'title hints',
                                value: '',
                                values: state.stories[index].titleHints,
                                width: calcWidth,
                              ),
                            ],
                            if (state.stories[index].povHints != null &&
                                state.stories[index].povHints!.isNotEmpty) ...[
                              StoryDetailsRow(
                                label: 'pov hints',
                                value: '',
                                values: state.stories[index].povHints,
                                width: calcWidth,
                              ),
                            ],
                            StoryDetailsRow(
                              label: 'chapters',
                              value: '',
                              values: state.stories[index].chapters,
                              width: calcWidth,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  EdgeInsetsGeometry rowPadding = const EdgeInsets.only(
    bottom: 25,
    left: 25,
    right: 25,
  );
}
