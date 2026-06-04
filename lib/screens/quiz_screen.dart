import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../data/tamil_data.dart';
import '../providers/enhanced_progress_provider.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestion = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;
  late List<Map<String, dynamic>> _questions;

  @override
  void initState() {
    super.initState();
    _questions = TamilData.getQuizQuestions()..shuffle();
  }

  void _checkAnswer(int selected) {
    if (_answered) return;
    if (_selectedAnswer != null) return; // Double-check to prevent multiple selections

    setState(() {
      _selectedAnswer = selected;
      _answered = true;
      if (selected == _questions[_currentQuestion]['correct']) {
        _score += 10;
      }
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (_currentQuestion < _questions.length - 1) {
        setState(() {
          _currentQuestion++;
          _selectedAnswer = null;
          _answered = false;
        });
      } else {
        _showResults();
      }
    });
  }

  void _showResults() {
    Provider.of<EnhancedProgressProvider>(context, listen: false)
        .addQuizScore(_score);

    int stars = _score >= _questions.length * 8
        ? 3
        : _score >= _questions.length * 5
            ? 2
            : 1;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: AppTheme.warning, size: 80),
            const SizedBox(height: 16),
            const Text(
              'Quiz Complete!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryRed,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Score: $_score/${_questions.length * 10}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => Icon(
                  i < stars ? Icons.star : Icons.star_border,
                  color: AppTheme.gold,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentQuestion = 0;
                      _score = 0;
                      _selectedAnswer = null;
                      _answered = false;
                      _questions = TamilData.getQuizQuestions()..shuffle();
                    });
                  },
                  child: const Text('Retry'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.darkRed,
                  ),
                  child: const Text('Exit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tamil Quiz'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.star, color: AppTheme.gold),
                const SizedBox(width: 4),
                Text(
                  '$_score',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (_currentQuestion + 1) / _questions.length,
                backgroundColor: AppTheme.textGray.withOpacity(0.3),
                color: AppTheme.primaryRed,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Question ${_currentQuestion + 1}/${_questions.length}',
              style: const TextStyle(fontSize: 14, color: AppTheme.textGray),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.premiumCard(),
              child: Column(
                children: [
                  Text(
                    question['question'] as String,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    question['letter'] as String,
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ...List.generate(
              (question['options'] as List).length,
              (index) => _buildOptionButton(
                (question['options'] as List)[index] as String,
                index,
                question['correct'] as int,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(String option, int index, int correctIndex) {
    Color buttonColor = AppTheme.white;
    Color borderColor = AppTheme.primaryRed;
    Color textColor = AppTheme.primaryRed;

    if (_answered && index == correctIndex) {
      buttonColor = AppTheme.success;
      textColor = AppTheme.white;
      borderColor = AppTheme.success;
    } else if (_answered &&
        index == _selectedAnswer &&
        index != correctIndex) {
      buttonColor = AppTheme.error;
      textColor = AppTheme.white;
      borderColor = AppTheme.error;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: _answered ? null : () => _checkAnswer(index),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          padding: const EdgeInsets.all(18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: borderColor, width: 2),
          ),
          elevation: _answered ? 0 : 4,
        ),
        child: Text(
          option,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _answered ? textColor : AppTheme.primaryRed,
          ),
        ),
      ),
    );
  }
}
