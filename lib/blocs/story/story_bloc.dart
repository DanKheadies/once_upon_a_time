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
    on<UpdateNewStory>(_onUpdateNewStory);
  }

  Future<void> _onCreateStory(
    CreateStory event,
    Emitter<StoryState> emit,
  ) async {
    if (state.status == StoryStateStatus.updating) return;
    emit(state.copyWith(status: StoryStateStatus.updating));

    List<Story> storiesList = [];
    Story activeStory = Story.emptyStory;

    // TODO: create / add story to Firebase
    try {
      storiesList = await databaseRepository.getStories();
      storiesList.sort((a, b) => a.title.compareTo(b.title));
      // Remove "deleted" stories.
      storiesList.removeWhere((area) => area.isDeleted == true);
      int index = Random().nextInt(storiesList.length);
      if (index >= 0) {
        activeStory = storiesList[index];
      }
      emit(
        state.copyWith(
          currentStory: activeStory,
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

    // TODO: get stories from firebase
  }

  void _onUpdateNewStory(UpdateNewStory event, Emitter<StoryState> emit) async {
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
