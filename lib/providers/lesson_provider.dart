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
      if (TamilData.lessonQuestions.isEmpty) {
        await TamilData.loadDatabase();
      }

      final List<LessonQuestion> generated = [];
      final pool = TamilData.lessonQuestions;
      
      if (pool.isNotEmpty) {
        // Filter pool by category name if lessonId is a specific category (not 'all')
        final filteredPool = pool.where((item) {
          if (lessonId == 'all' || lessonId.isEmpty) return true;
          final cat = item['category']?.toString().toLowerCase();
          return cat == lessonId.toLowerCase();
        }).toList();

        final activePool = filteredPool.isNotEmpty ? filteredPool : pool;
        final shuffledPool = List<Map<String, dynamic>>.from(activePool)..shuffle();
        
        for (int i = 0; i < shuffledPool.length; i++) {
          final item = shuffledPool[i];
          final String englishWord = item['correct_answer'] as String; // e.g. "Apple"
          final String correctTamil = item['question'] as String; // e.g. "ஆப்பிள்"
          final String category = item['category'] ?? 'General';

          // Select wrong Tamil options from other items in the same category
          final wrongTamilOptions = pool
              .where((q) => q['category'] == category && q['question'] != correctTamil)
              .map((q) => q['question'] as String)
              .toList();

          if (wrongTamilOptions.length < 3) {
            wrongTamilOptions.addAll(
              pool
                  .where((q) => q['question'] != correctTamil)
                  .map((q) => q['question'] as String)
            );
          }
          
          wrongTamilOptions.shuffle();

          final options = [correctTamil];
          for (int k = 0; k < 3 && k < wrongTamilOptions.length; k++) {
            options.add(wrongTamilOptions[k]);
          }
          options.shuffle();

          generated.add(
            LessonQuestion(
              id: item['id']?.toString() ?? 'lesson_q_$i',
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
            englishText: 'Apple',
            options: ['ஆப்பிள்', 'வாழைப்பழம்', 'மாம்பழம்', 'ஆரஞ்சு'],
            correctAnswer: 'ஆப்பிள்',
          ),
        ]);
      } else {
        generated.shuffle();
      }

      // Limit to 15 questions per lesson run, drawing from the 600+ questions
      _questions = generated.take(15).toList();

    } catch (e) {
      debugPrint('Error generating lessons: $e');
      _questions = [
        LessonQuestion(
          id: 'q1',
          lessonId: lessonId,
          type: QuestionType.mcq,
          englishText: 'Apple',
          options: ['ஆப்பிள்', 'வாழைப்பழம்', 'மாம்பழம்', 'ஆரஞ்சு'],
          correctAnswer: 'ஆப்பிள்',
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
