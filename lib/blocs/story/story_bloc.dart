import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:logger/web.dart';
import 'package:once_upon_a_time/barrel.dart';

part 'story_event.dart';
part 'story_state.dart';

class StoryBloc extends HydratedBloc<StoryEvent, StoryState> {
  final DatabaseRepository databaseRepository;
  final Logger log;

  StoryBloc({required this.databaseRepository})
    : log = Logger(),
      super(StoryState()) {
    on<CreateStory>(_onCreateStory);
    on<GetStories>(_onGetStories);
    on<NewStory>(_onNewStory);
    on<UpdateNewStory>(_onUpdateNewStory);

    print('StoryBloc online');
    add(GetStories());
  }

  Future<void> _onCreateStory(
    CreateStory event,
    Emitter<StoryState> emit,
  ) async {
    if (state.status == StoryStateStatus.updating) return;
    emit(state.copyWith(errorMessage: '', status: StoryStateStatus.updating));

    if (event.newStory.chapters.isEmpty ||
        state.newStory.pov.isEmpty ||
        state.newStory.title == '') {
      emit(
        state.copyWith(
          errorMessage: event.newStory.title == ''
              ? 'Add a title..'
              : event.newStory.pov.isEmpty
              ? 'Add a POV..'
              : event.newStory.chapters.isEmpty
              ? 'Add chapters..'
              : 'Something went wrong.',
          status: StoryStateStatus.error,
        ),
      );
      return;
    }

    DateTime now = DateTime.now();
    List<Story> storiesList = state.stories.toList();
    Story newStory = Story.emptyStory;

    try {
      newStory = await databaseRepository.createStory(
        newStory: event.newStory.copyWith(
          createdOn: event.newStory.createdOn ?? now,
          updatedOn: now,
        ),
      );
      storiesList.add(newStory);
      storiesList.sort((a, b) => a.title.compareTo(b.title));

      emit(
        state.copyWith(
          // currentStory: activeStory,
          newStory: Story.emptyStory,
          status: StoryStateStatus.updated,
          stories: storiesList,
        ),
      );
    } catch (err) {
      log.e('CreateStory error', error: err);
      emit(state.copyWith(status: StoryStateStatus.error));
    }
  }

  Future<void> _onGetStories(GetStories event, Emitter<StoryState> emit) async {
    if (state.status == StoryStateStatus.loading) return;
    emit(state.copyWith(status: StoryStateStatus.loading));

    List<Story> storiesList = [];
    Story activeStory = Story.emptyStory;

    try {
      storiesList = await databaseRepository.getStories(event.showArchived);
      storiesList.sort((a, b) => a.title.compareTo(b.title));

      int index = Random().nextInt(storiesList.length);
      if (index >= 0) {
        activeStory = storiesList[index];
      }

      emit(
        state.copyWith(
          currentStory: activeStory,
          status: StoryStateStatus.loaded,
          stories: storiesList,
        ),
      );
    } catch (err) {
      log.e('GetStories error', error: err);
      emit(state.copyWith(status: StoryStateStatus.error));
    }
  }

  void _onNewStory(NewStory event, Emitter<StoryState> emit) {
    List<Story> storiesList = state.stories.toList();
    int index = storiesList.indexWhere((story) => story.id == event.storyId);
    Story newStory = Story.emptyStory;

    if (index >= 0) {
      storiesList.removeAt(index);
      int randoIndex = Random().nextInt(storiesList.length);
      newStory = storiesList[randoIndex];
      print('new current: ${newStory.title}');
    }

    emit(state.copyWith(currentStory: newStory));
  }

  void _onUpdateNewStory(UpdateNewStory event, Emitter<StoryState> emit) {
    emit(state.copyWith(newStory: event.newStory));
  }

  @override
  StoryState? fromJson(Map<String, dynamic> json) {
    return StoryState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(StoryState state) {
    return state.toJson();
  }
}
