import 'package:nasa_app/generated/l10n.dart';

class LessonData {
  final String title;
  final String thumbnail;
  final int lessonId;
  bool isUnlocked;
  bool isCompleted;

  LessonData({
    required this.title,
    required this.lessonId,
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
        lessonId: 0,
      ),
      LessonData(
        title: S.of(context).lessonTwo,
        thumbnail: "assets/images/lesson2thumbnail.jpg",
        isUnlocked: false,
        isCompleted: false,
        lessonId: 1,
      ),
      LessonData(
        title: S.of(context).lessonThree,
        thumbnail: "assets/images/lesson3thumbnail.jpeg",
        isUnlocked: false,
        isCompleted: false,
        lessonId: 2,
      ),
      LessonData(
        title: S.of(context).lessonFour,
        thumbnail: "assets/images/lesson4thumbnail.jpg",
        isUnlocked: false,
        isCompleted: false,
        lessonId: 3,
      ),
    ];
  }
}
