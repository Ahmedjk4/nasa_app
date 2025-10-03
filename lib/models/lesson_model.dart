import 'package:nasa_app/generated/l10n.dart';

class LessonData {
  final String title;
  final String thumbnail;
  final String videoId;
  bool isUnlocked;
  bool isCompleted;

  LessonData({
    required this.videoId,
    required this.title,
    required this.thumbnail,
    required this.isUnlocked,
    required this.isCompleted,
  });
}

class Lessons {
  static List<LessonData> getLessons(context) {
    return [
      LessonData(
        title: S.of(context).lessonOne,
        thumbnail: "assets/images/lesson1thumbnail.jpg",
        isUnlocked: true,
        isCompleted: false,
        videoId: "libKVRa01L8",
      ),
      LessonData(
        title: S.of(context).lessonTwo,
        thumbnail: "assets/images/lesson2thumbnail.jpg",
        isUnlocked: false,
        isCompleted: false,
        videoId: "XHkYf9nOK3A",
      ),
      LessonData(
        title: S.of(context).lessonThree,
        thumbnail: "assets/images/lesson3thumbnail.jpeg",
        isUnlocked: false,
        isCompleted: false,
        videoId: "3fY1bXkN6LU",
      ),
      LessonData(
        title: S.of(context).lessonFour,
        thumbnail: "assets/images/lesson1thumbnail.jpg",
        isUnlocked: false,
        isCompleted: false,
        videoId: "Z3d9q1mX5aA",
      ),
    ];
  }
}
