import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../models/app_models.dart';
import '../data/tamil_data.dart';

class LessonProvider with ChangeNotifier {
  List<LessonQuestion> _questions = [];
  int _currentIndex = 0;
  int _xpEarned = 0;
  int _heartsCount = 5;
  bool _isLoading = false;
  bool _isLessonFinished = false;
  String _feedbackMessage = '';
  bool? _isCorrect; // null: not answered, true: correct, false: wrong

  // Getters
  List<LessonQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  int get xpEarned => _xpEarned;
  int get heartsCount => _heartsCount;
  bool get isLoading => _isLoading;
  bool get isLessonFinished => _isLessonFinished;
  String get feedbackMessage => _feedbackMessage;
  bool? get isCorrect => _isCorrect;
  double get progress => _questions.isEmpty ? 0 : (_currentIndex + 1) / _questions.length;

  Future<void> fetchQuestions(String lessonId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final allWords = TamilData.masterWords;
      if (allWords.isEmpty) {
        await TamilData.loadData();
      }

      final List<LessonQuestion> generated = [];

      final pool = TamilData.masterWords;
      if (pool.isNotEmpty) {
        final shuffledPool = List<Map<String, dynamic>>.from(pool)..shuffle();
        
        for (int i = 0; i < shuffledPool.length; i++) {
          final wordData = shuffledPool[i];
          final String englishWord = wordData['english'] as String;
          final String correctTamil = wordData['tamil'] as String;

          final wrongOptions = pool
              .where((w) => w['tamil'] != correctTamil)
              .map((w) => w['tamil'] as String)
              .toList()
            ..shuffle();

          final options = [correctTamil];
          for (int k = 0; k < 3 && k < wrongOptions.length; k++) {
            options.add(wrongOptions[k]);
          }
          options.shuffle();

          generated.add(
            LessonQuestion(
              id: wordData['id'] ?? 'lesson_q_$i',
              lessonId: lessonId,
              type: QuestionType.mcq,
              englishText: englishWord,
              options: options,
              correctAnswer: correctTamil,
            ),
          );
        }
      }

      if (generated.isEmpty) {
        generated.addAll([
          LessonQuestion(
            id: 'q1',
            lessonId: lessonId,
            type: QuestionType.mcq,
            englishText: 'Dog',
            options: ['நாய்', 'பூனை', 'ஆடு'],
            correctAnswer: 'நாய்',
          ),
          LessonQuestion(
            id: 'q2',
            lessonId: lessonId,
            type: QuestionType.mcq,
            englishText: 'Cat',
            options: ['பூனை', 'நாய்', 'மாடு'],
            correctAnswer: 'பூனை',
          ),
        ]);
      } else {
        generated.shuffle();
      }

      // Limit to 15 questions per lesson run, drawing from the 1000+ unique questions
      _questions = generated.take(15).toList();

    } catch (e) {
      debugPrint('Error generating dynamic questions: $e');
      _questions = [
        LessonQuestion(
          id: 'q1',
          lessonId: lessonId,
          type: QuestionType.mcq,
          englishText: 'Dog',
          options: ['நாய்', 'பூனை', 'ஆடு'],
          correctAnswer: 'நாய்',
        ),
      ];
    }

    _isLoading = false;
    _currentIndex = 0;
    _isLessonFinished = false;
    _isCorrect = null;
    notifyListeners();
  }

  void checkAnswer(String selectedAnswer) {
    if (_isCorrect != null) return; // Prevent double answering

    final currentQuestion = _questions[_currentIndex];
    
    if (selectedAnswer.trim().toLowerCase() == currentQuestion.correctAnswer.trim().toLowerCase()) {
      _isCorrect = true;
      _xpEarned += 10;
      _feedbackMessage = 'அற்புதம்! (Excellent!)';
    } else {
      _isCorrect = false;
      _heartsCount--;
      _feedbackMessage = 'தவறு. (Wrong.) சரியான விடை: ${currentQuestion.correctAnswer}';
    }
    notifyListeners();
  }

  void nextQuestion() {
    _isCorrect = null;
    _feedbackMessage = '';
    
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
    } else {
      _isLessonFinished = true;
    }
    notifyListeners();
  }
  
  void resetLesson() {
    _currentIndex = 0;
    _xpEarned = 0;
    _heartsCount = 5;
    _isLessonFinished = false;
    _isCorrect = null;
    notifyListeners();
  }
}
