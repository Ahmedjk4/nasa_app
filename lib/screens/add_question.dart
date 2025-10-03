import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> uploadQuestions() async {
  // اقرأ ملف JSON
  String raw = await rootBundle.loadString("assets/tests.json");
  List<dynamic> lessons = jsonDecode(raw);

  for (var lesson in lessons) {
    // lesson هنا عبارة عن List
    // أول عنصر فيه هو اللي فيه lessonId
    int lessonId = lesson[0]["lessonId"];

    // باقي العناصر هي الأسئلة
    List<Map<String, dynamic>> questions = [];
    for (int i = 1; i < lesson.length; i++) {
      questions.add(Map<String, dynamic>.from(lesson[i]));
    }

    // خزنهم في Firestore
    await FirebaseFirestore.instance
        .collection("tests")
        .doc("lesson_$lessonId")
        .set({"lessonId": lessonId, "questions": questions});

    debugPrint(
      "✅ Uploaded lesson $lessonId with ${questions.length} questions",
    );
  }
}
