class Question {
  final String questionId;
  final String questionText;
  final List<String> choices;
  final int correctAnswerIndex;

  Question({
    required this.questionId,
    required this.questionText,
    required this.choices,
    required this.correctAnswerIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionId: json['questionId'],
      questionText: json['questionText'],
      choices: List<String>.from(json['choices']),
      correctAnswerIndex: json['correctAnswerIndex'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'choices': choices,
      'correctAnswerIndex': correctAnswerIndex,
    };
  }
}

class Exam {
  final String examId;
  final String title;
  final String subject;
  final DateTime examDate;
  final int duration; // in minutes
  final int totalMarks;
  final bool isCompleted;
  final List<Question> questions;

  Exam({
    required this.examId,
    required this.title,
    required this.subject,
    required this.examDate,
    required this.duration,
    required this.totalMarks,
    required this.questions,
    this.isCompleted = false,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      examId: json['examId'],
      title: json['title'],
      subject: json['subject'],
      examDate: DateTime.parse(json['examDate']),
      duration: json['duration'],
      totalMarks: json['totalMarks'],
      isCompleted: json['isCompleted'] ?? false,
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'examId': examId,
      'title': title,
      'subject': subject,
      'examDate': examDate.toIso8601String(),
      'duration': duration,
      'totalMarks': totalMarks,
      'isCompleted': isCompleted,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }

  Exam copyWith({
    String? examId,
    String? title,
    String? subject,
    DateTime? examDate,
    int? duration,
    int? totalMarks,
    bool? isCompleted,
    List<Question>? questions,
  }) {
    return Exam(
      examId: examId ?? this.examId,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      examDate: examDate ?? this.examDate,
      duration: duration ?? this.duration,
      totalMarks: totalMarks ?? this.totalMarks,
      isCompleted: isCompleted ?? this.isCompleted,
      questions: questions ?? this.questions,
    );
  }
}
