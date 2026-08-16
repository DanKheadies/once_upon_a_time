part of 'story_bloc.dart';

enum StoryStateStatus { error, initial, loaded, loading, updated, updating }

class StoryState extends Equatable {
  final List<Story> stories;
  final Story currentStory;
  final Story newStory;
  final StoryStateStatus status;
  final String errorMessage;
  final WriterTabType tabType;

  const StoryState({
    this.currentStory = Story.emptyStory,
    this.errorMessage = '',
    this.newStory = Story.emptyStory,
    this.status = StoryStateStatus.initial,
    this.stories = const [],
    this.tabType = WriterTabType.create,
  });

  @override
  List<Object> get props => [
    currentStory,
    errorMessage,
    newStory,
    status,
    stories,
    tabType,
  ];

  StoryState copyWith({
    List<Story>? stories,
    Story? currentStory,
    Story? newStory,
    StoryStateStatus? status,
    String? errorMessage,
    WriterTabType? tabType,
  }) {
    return StoryState(
      currentStory: currentStory ?? this.currentStory,
      errorMessage: errorMessage ?? this.errorMessage,
      newStory: newStory ?? this.newStory,
      status: status ?? this.status,
      stories: stories ?? this.stories,
      tabType: tabType ?? this.tabType,
    );
  }

  factory StoryState.fromJson(Map<String, dynamic> json) {
    List<Story> storiesList = (json['stories'] as List)
        .map((story) => Story.fromJson(story))
        .toList();

    return StoryState(
      currentStory: Story.fromJson(json['currentStory']),
      errorMessage: json['errorMessage'],
      newStory: Story.fromJson(json['newStory']),
      status: StoryStateStatus.values.firstWhere(
        (status) => status.name == json['status'],
      ),
      stories: storiesList,
      tabType: WriterTabType.values.firstWhere(
        (tab) => tab.name == json['tabType'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> storiesList = [];
    if (stories.isNotEmpty) {
      for (var story in stories) {
        storiesList.add(story.toJson());
      }
    }

    return {
      'currentStory': currentStory.toJson(),
      'errorMessage': errorMessage,
      'newStory': newStory.toJson(),
      'status': status.name,
      'stories': storiesList,
      'tabType': tabType.name,
    };
  }
}
