part of 'story_bloc.dart';

sealed class StoryEvent extends Equatable {
  const StoryEvent();

  @override
  List<Object?> get props => [];
}

class CacheTab extends StoryEvent {
  final WriterTabType tab;

  const CacheTab({required this.tab});

  @override
  List<Object> get props => [tab];
}

class CreateStory extends StoryEvent {
  final Story newStory;

  const CreateStory({required this.newStory});

  @override
  List<Object> get props => [newStory];
}

class DeleteStory extends StoryEvent {
  final String storyId;

  const DeleteStory({required this.storyId});

  @override
  List<Object> get props => [storyId];
}

class GetStories extends StoryEvent {
  final bool? showArchived;

  const GetStories({this.showArchived = false});

  @override
  List<Object?> get props => [showArchived];
}

class GetStoryById extends StoryEvent {
  final String storyId;

  const GetStoryById({required this.storyId});

  @override
  List<Object> get props => [storyId];
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

class UpdateStory extends StoryEvent {
  final Story editedStory;

  const UpdateStory({required this.editedStory});

  @override
  List<Object> get props => [editedStory];
}
