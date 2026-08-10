part of 'story_bloc.dart';

sealed class StoryEvent extends Equatable {
  const StoryEvent();

  @override
  List<Object?> get props => [];
}

class CreateStory extends StoryEvent {
  final List<String>? chapters;
  final List<String>? pov;
  final List<String>? povHints;
  final List<String>? titleHints;
  final String? title;

  const CreateStory({
    this.chapters,
    this.pov,
    this.povHints,
    this.title,
    this.titleHints,
  });

  @override
  List<Object?> get props => [chapters, pov, povHints, title, titleHints];
}

class GetStories extends StoryEvent {
  const GetStories();

  @override
  List<Object> get props => [];
}

class UpdateNewStory extends StoryEvent {
  final Story newStory;

  const UpdateNewStory({required this.newStory});

  @override
  List<Object> get props => [newStory];
}
