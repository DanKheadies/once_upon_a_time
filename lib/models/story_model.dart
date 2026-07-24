import 'package:equatable/equatable.dart';

class Story extends Equatable {
  final DateTime createdOn;
  final DateTime updatedOn;
  final List<String> chapters;
  final List<String> pov;
  final List<String>? povHints;
  final List<String>? titleHints;
  final String createdBy;
  final String id;
  final String title;

  const Story({
    required this.chapters,
    required this.createdBy,
    required this.createdOn,
    required this.id,
    required this.pov,
    required this.title,
    required this.updatedOn,
    this.povHints = const [],
    this.titleHints = const [],
  });

  @override
  List<Object?> get props => [chapters, id, pov, povHints, title, titleHints];

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
