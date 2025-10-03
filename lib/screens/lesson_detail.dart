import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nasa_app/generated/l10n.dart';
import 'package:nasa_app/models/lesson_model.dart';
import 'package:nasa_app/utils/app_router.dart';
import 'package:nasa_app/utils/auth_firebase.dart';
import 'package:nasa_app/utils/firestore_functions.dart';

class LessonDetailPage extends StatefulWidget {
  final LessonData lesson;
  final int lessonIndex;

  const LessonDetailPage({
    super.key,
    required this.lesson,
    required this.lessonIndex,
  });

  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  Map<String, dynamic>? _testResults;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTestResults();
  }

  String get _lessonTitle => widget.lesson.title;

  String get _lessonDescription {
    switch (widget.lessonIndex) {
      case 0:
        return S.of(context).lessonOneDesc;
      case 1:
        return S.of(context).lessonTwoDesc;
      case 2:
        return S.of(context).lessonThreeDesc;
      case 3:
        return S.of(context).lessonFourDesc;
      default:
        return S.of(context).noLessonDescription;
    }
  }

  Future<void> _loadTestResults() async {
    try {
      final userId = AuthFirebase.currentUser?.uid;
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final results = await FirestoreFunctions.getDocument(
        collection: 'testResults',
        documentId: '${userId}_lesson_${widget.lessonIndex}',
      );

      setState(() {
        _testResults = results;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading test results: $e');
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTestResultsBadge() {
    if (_isLoading) return const SizedBox.shrink();

    if (_testResults == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          S.of(context).notAttempt,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final score = _testResults!['score'] ?? 0;
    final total = _testResults!['totalQuestions'] ?? 1;
    final percentage = (score / total * 100).round();
    final passed = percentage >= 70;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: passed
            ? Colors.green.withValues(alpha: 0.2)
            : Colors.red.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: passed ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            '${S.of(context).score}: $percentage%',
            style: TextStyle(
              color: passed ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton() {
    final bool testPassed =
        _testResults != null &&
        (_testResults!['score'] / _testResults!['totalQuestions'] * 100) >= 70;

    return ElevatedButton(
      onPressed: () async {
        final result = await context.push(
          AppRouter.testScreen,
          extra: widget.lessonIndex,
        );
        if (result == true) {
          // Refresh test results if test was completed
          _loadTestResults();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: testPassed ? Colors.green : null,
      ),
      child: Text(
        testPassed ? S.of(context).retakeTest : S.of(context).takeTest,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(_lessonTitle, style: const TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                widget.lesson.thumbnail,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      _lessonTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildTestResultsBadge(),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _lessonDescription,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.push(
                          AppRouter.videoPlayer,
                          extra: [widget.lesson],
                        );
                      },
                      child: Text(S.of(context).goToLesson),
                    ),
                    const SizedBox(height: 16),
                    _buildTestButton(),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
