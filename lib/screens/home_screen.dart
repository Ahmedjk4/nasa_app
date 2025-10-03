import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nasa_app/generated/l10n.dart';
import 'package:nasa_app/models/lesson_model.dart';
import 'package:nasa_app/utils/app_router.dart';
import 'package:nasa_app/utils/firestore_functions.dart';
import 'package:nasa_app/utils/auth_firebase.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<LessonData> _lessons = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lessons = Lessons.getLessons(context);
    _loadLessonProgress();
  }

  Future<void> _loadLessonProgress() async {
    var lessons = Lessons.getLessons(context);
    try {
      final userId = AuthFirebase.currentUser?.uid;
      if (userId == null) return;

      // Listen to real-time updates
      FirestoreFunctions.listenToDocument(
        collection: 'users',
        documentId: userId,
        onData: (userProgress) {
          if (userProgress != null &&
              userProgress['lessons'] != null &&
              mounted) {
            setState(() {
              final lessonProgress = userProgress['lessons'];
              for (int i = 0; i < _lessons.length; i++) {
                final lessonKey = 'lesson${i + 1}';
                if (lessonProgress[lessonKey] != null) {
                  _lessons[i] = LessonData(
                    title: lessons[i].title, // Keep original title
                    thumbnail: lessons[i].thumbnail, // Keep original thumbnail
                    isUnlocked:
                        lessonProgress[lessonKey]['isUnlocked'] ?? false,
                    isCompleted:
                        lessonProgress[lessonKey]['isCompleted'] ?? false,
                    videoId: lessons[i].videoId,
                  );
                }
              }
            });
          }
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading progress: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading progress: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var lessons = Lessons.getLessons(context);
    void handleLessonTap(int index) {
      if (_lessons[index].isUnlocked) {
        context.push(
          AppRouter.lessonDetail,
          extra: {'lesson': lessons[index], 'lessonIndex': index},
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).completeFirstLesson)),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "AstroQuest",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.montserrat().fontFamily,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _lessons.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: LessonCard(
              lesson: _lessons[index],
              onTap: () => handleLessonTap(index),
            ),
          );
        },
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  final LessonData lesson;
  final VoidCallback onTap;

  const LessonCard({super.key, required this.lesson, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
              child: Image.asset(
                lesson.thumbnail,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      lesson.title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    lesson.isUnlocked
                        ? Icons.play_circle_fill
                        : lesson.isCompleted
                        ? Icons.check_circle
                        : Icons.lock,
                    color: lesson.isCompleted
                        ? Colors.green
                        : lesson.isUnlocked
                        ? Colors.blue
                        : Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
