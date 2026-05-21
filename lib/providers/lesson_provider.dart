import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_models.dart';

class LessonProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
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
      final snapshot = await _db
          .collection('questions')
          .where('lessonId', isEqualTo: lessonId)
          .get();

      _questions = snapshot.docs.map((doc) => LessonQuestion.fromFirestore(doc)).toList();
      
      // MOCK DATA for testing if Firestore is empty
      if (_questions.isEmpty) {
        _loadMockData();
      }
    } catch (e) {
      print('Error fetching questions: $e');
      _loadMockData();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _loadMockData() {
    _questions = [
      LessonQuestion(
        id: 'q1',
        lessonId: 'animals_1',
        type: QuestionType.mcq,
        tamilText: 'நாய்',
        options: ['Dog', 'Cat', 'Car'],
        correctAnswer: 'Dog',
      ),
      LessonQuestion(
        id: 'q2',
        lessonId: 'animals_1',
        type: QuestionType.mcq,
        englishText: 'Cat',
        options: ['பூனை', 'நாய்', 'மாடு'],
        correctAnswer: 'பூனை',
      ),
      LessonQuestion(
        id: 'q3',
        lessonId: 'animals_1',
        type: QuestionType.speaking,
        englishText: 'This is a dog',
        correctAnswer: 'This is a dog',
      ),
    ];
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
