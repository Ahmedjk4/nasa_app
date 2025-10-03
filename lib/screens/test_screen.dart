import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nasa_app/utils/firestore_functions.dart';
import 'package:nasa_app/utils/auth_firebase.dart';
import 'package:nasa_app/utils/unlock_lesson.dart';

class TestScreen extends StatefulWidget {
  final int lessonIndex;

  const TestScreen({super.key, required this.lessonIndex});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  bool _testStarted = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  final Map<dynamic, dynamic> _userAnswers = {};
  Timer? _timer;
  int _timeRemaining = 0; // Will be set from Firestore
  bool _testCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _loadSavedTestState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _saveTestState(); // Save state when leaving the screen
    super.dispose();
  }

  // Normalize correct answer into 'A','B','C','D' (uppercase letter) if possible
  String _normalizeCorrect(dynamic correctRaw, List<String> answers) {
    if (correctRaw == null) return '';

    // If it's an int index
    if (correctRaw is int) {
      if (correctRaw >= 0 && correctRaw < 26) {
        return String.fromCharCode(65 + correctRaw);
      }
    }

    final s = correctRaw.toString().trim();

    // single letter like 'a' or 'A'
    if (s.length == 1) {
      final up = s.toUpperCase();
      if (RegExp(r'^[A-Z]$').hasMatch(up)) return up;
      final idx = int.tryParse(s);
      if (idx != null && idx >= 0 && idx < 26) {
        return String.fromCharCode(65 + idx);
      }
    }

    // maybe "0","1","2"
    final idxFromNum = int.tryParse(s);
    if (idxFromNum != null && idxFromNum >= 0 && idxFromNum < 26) {
      return String.fromCharCode(65 + idxFromNum);
    }

    // maybe the string equals the exact answer text -> find its index
    final matchIndex = answers.indexWhere(
      (ans) => ans.toString().trim().toLowerCase() == s.toLowerCase(),
    );
    if (matchIndex != -1) return String.fromCharCode(65 + matchIndex);

    // fallback empty
    return '';
  }

  Future<void> _loadQuestions() async {
    try {
      final testDocs = await FirestoreFunctions.queryCollection(
        collection: 'tests',
        field: 'lessonId',
        isEqualTo: widget.lessonIndex,
      );

      if (testDocs.isNotEmpty) {
        final testDoc = testDocs[0];

        // Parse the questions map structure with locale-awareness
        List<Map<String, dynamic>> parsedQuestions = [];
        // get app locale to select Arabic or English
        if (!mounted) return;
        final localeCode = Localizations.localeOf(context).languageCode;
        final useArabic = localeCode.startsWith('ar');

        if (testDoc['questions'] is Map) {
          // Convert map to list (preserve order by numeric keys)
          final questionsMap = testDoc['questions'] as Map<dynamic, dynamic>;

          final sortedKeys = questionsMap.keys.toList()
            ..sort((a, b) {
              final aInt = int.tryParse(a.toString()) ?? 0;
              final bInt = int.tryParse(b.toString()) ?? 0;
              return aInt.compareTo(bInt);
            });

          for (var key in sortedKeys) {
            final questionData = questionsMap[key] as Map<dynamic, dynamic>;
            // Support both keyed fields and localized fields
            final qText =
                (questionData['question'] ??
                        (useArabic
                            ? questionData['questionAr']
                            : questionData['questionEn']) ??
                        questionData['questionAr'] ??
                        questionData['questionEn'] ??
                        '')
                    .toString();

            final answers = <String>[];
            if (questionData['answers'] != null) {
              answers.addAll(List<String>.from(questionData['answers'] ?? []));
            } else if (questionData['choices'] != null) {
              answers.addAll(List<String>.from(questionData['choices'] ?? []));
            } else {
              // try localized choices
              final keyChoices = useArabic ? 'choicesAr' : 'choicesEn';
              if (questionData[keyChoices] != null) {
                answers.addAll(
                  List<String>.from(questionData[keyChoices] ?? []),
                );
              } else {
                answers.addAll(
                  List<String>.from(
                    questionData['choicesAr'] ??
                        questionData['choicesEn'] ??
                        [],
                  ),
                );
              }
            }

            final rawCorrect =
                questionData['correctAnswer'] ??
                questionData['correct'] ??
                questionData['answer'];
            final normalized = _normalizeCorrect(rawCorrect, answers);

            parsedQuestions.add({
              'question': qText,
              'answers': answers,
              'correctAnswer': normalized,
            });
          }
        } else if (testDoc['questions'] is List) {
          // Already in list format (your uploaded format)
          final rawList = List<dynamic>.from(testDoc['questions']);
          for (var item in rawList) {
            if (item == null) continue;
            if (item is! Map) continue;

            final mapItem = Map<String, dynamic>.from(item);

            // In your file you may have items like {"lessonId": 0} present inside the list.
            // Skip pure lessonId-only objects
            if (mapItem.keys.length == 1 && mapItem.containsKey('lessonId')) {
              continue;
            }
            // pick localized question text
            final qText =
                (mapItem['question'] ??
                        (useArabic
                            ? mapItem['questionAr']
                            : mapItem['questionEn']) ??
                        mapItem['questionAr'] ??
                        mapItem['questionEn'] ??
                        '')
                    .toString();

            // pick localized choices/answers
            List<String> answers = [];
            if (mapItem['answers'] != null) {
              answers = List<String>.from(mapItem['answers']);
            } else if (mapItem['choices'] != null) {
              answers = List<String>.from(mapItem['choices']);
            } else {
              final keyChoices = useArabic ? 'choicesAr' : 'choicesEn';
              if (mapItem[keyChoices] != null) {
                answers = List<String>.from(mapItem[keyChoices]);
              } else {
                // fallback to any available choicesAr/choicesEn
                answers = List<String>.from(
                  mapItem['choicesAr'] ?? mapItem['choicesEn'] ?? [],
                );
              }
            }

            final rawCorrect =
                mapItem['correctAnswer'] ??
                mapItem['correct'] ??
                mapItem['answer'];
            final normalized = _normalizeCorrect(rawCorrect, answers);

            parsedQuestions.add({
              'question': qText,
              'answers': answers,
              'correctAnswer': normalized,
            });
          }
        }

        if (!mounted) return;
        setState(() {
          _questions = parsedQuestions;
          if (!_testStarted) {
            _timeRemaining =
                testDoc['maxTime'] ??
                testDoc['timeLimit'] ??
                300; // default 5 minutes
          }
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _questions = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading questions: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadSavedTestState() async {
    final userId = AuthFirebase.currentUser?.uid;
    if (userId == null) return;

    try {
      final docId = '${userId}_${widget.lessonIndex}';
      final savedState = await FirestoreFunctions.getDocument(
        collection: 'ongoingTests',
        documentId: docId,
      );

      if (savedState != null) {
        setState(() {
          _testStarted = true;
          _timeRemaining = savedState['timeRemaining'] ?? _timeRemaining;
          _currentQuestionIndex = savedState['currentQuestionIndex'] ?? 0;

          // Restore answers with proper type conversion
          final savedAnswers =
              savedState['userAnswers'] as Map<String, dynamic>? ?? {};
          savedAnswers.forEach((key, value) {
            // Convert string key back to integer
            final intKey = int.tryParse(key);
            if (intKey != null) {
              _userAnswers[intKey] = value.toString();
            }
          });
        });

        // Start timer if test was already started
        if (_testStarted) {
          _startTimer();
        }
      }
    } catch (e) {
      debugPrint('Error loading saved test state: $e');
    }
  }

  void _startTest() {
    if (!_testStarted) {
      setState(() {
        _testStarted = true;
      });
      _saveTestState(); // Initial save for new test
    }
    _startTimer();
  }

  Future<void> _saveTestState() async {
    if (!_testStarted || _testCompleted) return;

    final userId = AuthFirebase.currentUser?.uid;
    if (userId == null) return;

    try {
      final docId = '${userId}_${widget.lessonIndex}';
      final exists = await FirestoreFunctions.getDocument(
        collection: 'ongoingTests',
        documentId: docId,
      );

      // Convert the userAnswers map keys to strings for Firestore
      final userAnswersForFirestore = _userAnswers.map(
        (key, value) => MapEntry(key.toString(), value),
      );

      final stateData = {
        'userId': userId,
        'lessonId': widget.lessonIndex,
        'timeRemaining': _timeRemaining,
        'userAnswers': userAnswersForFirestore,
        'currentQuestionIndex': _currentQuestionIndex,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      if (exists == null) {
        await FirestoreFunctions.createDocument(
          collection: 'ongoingTests',
          documentId: docId,
          data: stateData,
        );
      } else {
        await FirestoreFunctions.updateDocument(
          collection: 'ongoingTests',
          documentId: docId,
          data: stateData,
        );
      }
    } catch (e) {
      debugPrint('Error saving test state: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
          // Save state every 30 seconds
          if (_timeRemaining % 30 == 0) {
            _saveTestState();
          }
        } else {
          _submitTest();
        }
      });
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _selectAnswer(String answer) {
    if (_testCompleted) return;

    setState(() {
      _userAnswers[_currentQuestionIndex] = answer;
    });

    // Save state when answer is selected
    _saveTestState();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  Future<void> _submitTest() async {
    _timer?.cancel();

    // Clear ongoing test
    final userId = AuthFirebase.currentUser?.uid;
    if (userId != null) {
      try {
        await FirestoreFunctions.deleteDocument(
          collection: 'ongoingTests',
          documentId: '${userId}_${widget.lessonIndex}',
        );
      } catch (e) {
        debugPrint('Error clearing test state: $e');
      }
    }
    int score = 0;

    for (int i = 0; i < _questions.length; i++) {
      if (_userAnswers[i] == _questions[i]['correctAnswer']) {
        // correctAnswer should be 'A', 'B', 'C', or 'D'
        score++;
      }
    }

    setState(() {
      _testCompleted = true;
      _score = score;
    });

    try {
      final userId = AuthFirebase.currentUser?.uid;
      if (userId == null) return;

      await FirestoreFunctions.createDocument(
        documentId: '${userId}_lesson_${widget.lessonIndex}',
        collection: 'testResults',
        data: {
          'userId': userId,
          'lessonId': widget.lessonIndex,
          'score': score,
          'totalQuestions': _questions.length,
          'timeSpent': 300 - _timeRemaining,
          'completedAt': DateTime.now().toIso8601String(),
          'answers': _userAnswers.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        },
      );

      // If passed (e.g., score > 70%)
      if (score / _questions.length >= 0.7 && mounted) {
        Navigator.pop(context, true); // Return true to mark lesson as completed
        await unlockLesson(widget.lessonIndex, true, context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving results: $e'),
            backgroundColor: Colors.red,
          ),
        );
        debugPrint('Error saving results: $e');
      }
    }
  }

  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer, size: 64, color: Colors.blue),
          SizedBox(height: 24),
          Text(
            'Test Information',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _testStarted
                      ? Colors.orange.withValues(alpha: 0.2)
                      : Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _testStarted ? Icons.timer_off : Icons.timer,
                      color: _testStarted ? Colors.orange : Colors.blue,
                    ),
                    SizedBox(width: 8),
                    Text(
                      _testStarted
                          ? 'Remaining Time: ${_formatTime(_timeRemaining)}'
                          : 'Time Limit: ${_formatTime(_timeRemaining)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _testStarted ? Colors.orange : Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Questions: ${_questions.length}\nPassing Score: 70%',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: _startTest,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              backgroundColor: Colors.blue,
            ),
            child: Text(
              'Start Test',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionScreen() {
    final question = _questions[_currentQuestionIndex];
    final userAnswer = _userAnswers[_currentQuestionIndex];
    final answers = List<String>.from(question['answers']);

    return Column(
      children: [
        // Timer and Progress
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.blue.withValues(alpha: 0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _timeRemaining <= 60 ? Colors.red : Colors.blue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _formatTime(_timeRemaining),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Question
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question['question'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 24),
                ...answers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final answer = entry.value;
                  final letter = String.fromCharCode(65 + index); // A, B, C, D
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _selectAnswer(letter),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: userAnswer == letter
                                ? Colors.blue
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: userAnswer == letter
                              ? Colors.blue.withValues(alpha: 0.1)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              margin: EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: userAnswer == letter
                                      ? Colors.blue
                                      : Colors.grey.shade400,
                                ),
                                color: userAnswer == letter
                                    ? Colors.blue.withValues(alpha: 0.1)
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  letter,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: userAnswer == letter
                                        ? Colors.blue
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                answer,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: userAnswer == letter
                                      ? Colors.blue
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // Navigation Buttons
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentQuestionIndex > 0)
                ElevatedButton(
                  onPressed: _previousQuestion,
                  child: Text('Previous'),
                )
              else
                SizedBox(width: 85),
              Text(
                '${_userAnswers.length}/${_questions.length}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _currentQuestionIndex < _questions.length - 1
                  ? ElevatedButton(
                      onPressed: _nextQuestion,
                      child: Text('Next'),
                    )
                  : ElevatedButton(
                      onPressed: _submitTest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text('Submit'),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultScreen() {
    final percentage = (_score / _questions.length * 100).round();
    final passed = percentage >= 70;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.cancel,
            size: 80,
            color: passed ? Colors.green : Colors.red,
          ),
          SizedBox(height: 24),
          Text(
            passed ? 'Congratulations!' : 'Test Failed',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: passed ? Colors.green : Colors.red,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Score: $percentage%\n($_score/${_questions.length} correct)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              context
                ..pop()
                ..pop();
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              backgroundColor: passed ? Colors.green : Colors.blue,
            ),
            child: Text(
              passed ? 'Continue to Next Lesson' : 'Try Again',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (_, __) {
        _saveTestState(); // Save state when navigating back
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Lesson ${widget.lessonIndex + 1} Test',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _testCompleted
            ? _buildResultScreen()
            : !_testStarted
            ? _buildStartScreen()
            : _buildQuestionScreen(),
      ),
    );
  }
}
