part of 'story_bloc.dart';

sealed class StoryEvent extends Equatable {
  const StoryEvent();

  @override
  List<Object?> get props => [];
}

class CreateStory extends StoryEvent {
  final Story newStory;

  const CreateStory({required this.newStory});

  @override
  List<Object> get props => [newStory];
}

class GetStories extends StoryEvent {
  final bool? showArchived;

  const GetStories({this.showArchived = false});

  @override
  List<Object?> get props => [showArchived];
}

class NewStory extends StoryEvent {
  final String storyId;

  const NewStory({required this.storyId});

  @override
  List<Object?> get props => [storyId];
}

class UpdateNewStory extends StoryEvent {
  final Story newStory;

  const UpdateNewStory({required this.newStory});

  @override
  List<Object> get props => [newStory];
}
