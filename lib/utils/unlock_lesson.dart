import 'package:flutter/material.dart';
import 'package:nasa_app/models/lesson_model.dart';
import 'package:nasa_app/utils/auth_firebase.dart';
import 'package:nasa_app/utils/firestore_functions.dart';

Future<void> unlockLesson(
  int index,
  bool completed,
  BuildContext context,
) async {
  var lessons = Lessons.getLessons(context);
  try {
    final userId = AuthFirebase.currentUser?.uid;
    if (userId == null) return;

    final lessonKey = 'lesson${index + 1}';
    final nextLessonKey = 'lesson${index + 2}';

    final updates = {'lessons.$lessonKey.isCompleted': completed};

    if (completed && index + 1 < lessons.length) {
      updates['lessons.$nextLessonKey.isUnlocked'] = true;
    }
    if (index == 3 && completed) {
      FirestoreFunctions.createDocument(
        collection: 'certificates',
        data: {'userId': userId, 'date': DateTime.now()},
        documentId: userId,
      );
    }

    await FirestoreFunctions.updateDocument(
      collection: 'users',
      documentId: userId,
      data: updates,
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error updating progress: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
