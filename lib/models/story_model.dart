import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Story extends Equatable {
  final bool? isArchived;
  final DateTime? createdOn;
  final DateTime? updatedOn;
  final List<String> chapters;
  final List<String> pov;
  final List<String>? povHints;
  final List<String>? titleHints;
  final String createdBy;
  final String id;
  final String title;
  // final String? updatedBy; // TODO

  const Story({
    required this.chapters,
    required this.createdBy,
    required this.id,
    required this.pov,
    required this.title,
    this.createdOn,
    this.isArchived = false,
    this.povHints = const [],
    this.titleHints = const [],
    this.updatedOn,
  });

  @override
  List<Object?> get props => [
    chapters,
    createdBy,
    createdOn,
    id,
    isArchived,
    pov,
    povHints,
    title,
    titleHints,
    updatedOn,
  ];

  Story copyWith({
    bool? isArchived,
    DateTime? createdOn,
    DateTime? updatedOn,
    List<String>? chapters,
    List<String>? pov,
    List<String>? povHints,
    List<String>? titleHints,
    String? createdBy,
    String? id,
    String? title,
  }) {
    return Story(
      chapters: chapters ?? this.chapters,
      createdBy: createdBy ?? this.createdBy,
      createdOn: createdOn ?? this.createdOn,
      id: id ?? this.id,
      isArchived: isArchived ?? this.isArchived,
      pov: pov ?? this.pov,
      povHints: povHints ?? this.povHints,
      title: title ?? this.title,
      titleHints: titleHints ?? this.titleHints,
      updatedOn: updatedOn ?? this.updatedOn,
    );
  }

  factory Story.fromSnapshot(DocumentSnapshot snap) {
    dynamic data = snap.data();

    return Story.fromJson(data).copyWith(id: snap.id);
  }

  factory Story.fromJson(Map<String, dynamic> json) {
    DateTime? createdOnDT = json['createdOn'] != null
        ? DateTime.tryParse(json['createdOn'])
        : null;
    DateTime? updatedOnDT = json['updatedOn'] != null
        ? DateTime.tryParse(json['updatedOn'])
        : null;

    return Story(
      chapters: (json['chapters'] as List)
          .map((chapter) => chapter as String)
          .toList(),
      createdBy: json['createdBy'],
      createdOn: createdOnDT,
      id: json['id'],
      isArchived: json['isArchived'],
      pov: (json['pov'] as List).map((view) => view as String).toList(),
      povHints: json['povHints'] != null
          ? (json['povHints'] as List).map((hint) => hint as String).toList()
          : null,
      title: json['title'],
      titleHints: json['titleHints'] != null
          ? (json['titleHints'] as List).map((hint) => hint as String).toList()
          : null,
      updatedOn: updatedOnDT,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapters': chapters,
      'createdBy': createdBy,
      'createdOn': createdOn?.toUtc().toString(),
      'id': id,
      'isArchived': isArchived,
      'pov': pov,
      'povHints': povHints,
      'title': title,
      'titleHints': titleHints,
      'updatedOn': updatedOn?.toUtc().toString(),
    };
  }

  static const Story emptyStory = Story(
    chapters: [],
    createdBy: '',
    // createdOn: DateTime.now(),
    id: '',
    pov: [],
    title: '',
    // updatedOn: DateTime.now(),
  );

  static final Story storyExample1 = Story(
    id: '12345678900',
    title: 'Shrek',
    titleHints: ['ogre', 'green ogre', 'shrekt'],
    pov: ['farquaad', 'lord farquaad'],
    povHints: ['lord', 'king', 'little guy'],
    createdBy: 'user12345',
    createdOn: DateTime.now(),
    updatedOn: DateTime.now(),
    chapters: [
      'There was a prince, fairest in the land. He was good to his people, and they loved him for it.',
      'He was an amazing prince, and he was ready to be an amazing KING. So he set out to find the fairest princess in the land with the help of a magic mirror.',
      'He found her! Sitting in her castle so high, surrounded by lava and what.',
      'It would be dangerous. It would could claim his life. And deprive his people..',
      'He would find him a champion to go save the princess. With her at his side, he would be King!',
      'So by royal decree, he called for all the knights in the land to compete. One winner to rescue a princess for the kingdom. Low and behold, one emerged..',
      'A hideous, barbaric monster that wanted to make a deal with the prince. The monster wanted all the "outcasts" off his property, and so the prince agreed. If the monster rescued the princess, the prince would purge its swamp of the undesirables.',
      'And so the creature went with his trusty ass...',
    ],
  );
}
