import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../constants/tamil_data.dart';
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

  void _checkAnswer(int selected) {
    setState(() {
      _selectedAnswer = selected;
      _answered = true;
      if (selected == TamilData.quizQuestions[_currentQuestion]['correct']) {
        _score += 10;
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (_currentQuestion < TamilData.quizQuestions.length - 1) {
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
    Provider.of<EnhancedProgressProvider>(context, listen: false).addQuizScore(_score);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: AppTheme.warning, size: 80),
            const SizedBox(height: 16),
            const Text('Quiz Complete!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryRed)),
            const SizedBox(height: 16),
            Text('Score: $_score/${TamilData.quizQuestions.length * 10}', style: const TextStyle(fontSize: 20)),
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
                    });
                  },
                  child: const Text('Retry'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkRed),
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
    final question = TamilData.quizQuestions[_currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tamil Quiz'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.star, color: AppTheme.gold),
                Text(' $_score', style: const TextStyle(fontSize: 18)),
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
            LinearProgressIndicator(
              value: (_currentQuestion + 1) / TamilData.quizQuestions.length,
              backgroundColor: Colors.grey.shade300,
              color: AppTheme.primaryRed,
              minHeight: 8,
            ),
            const SizedBox(height: 20),
            Text('Question ${_currentQuestion + 1}/${TamilData.quizQuestions.length}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.premiumCard(),
              child: Column(
                children: [
                  Text(question['question'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.white), textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  Text(question['letter'], style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: AppTheme.white)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ...List.generate((question['options'] as List).length, (index) => _buildOptionButton((question['options'] as List)[index], index, question['correct'])),
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
    } else if (_answered && index == _selectedAnswer && index != correctIndex) {
      buttonColor = AppTheme.error;
      textColor = AppTheme.white;
      borderColor = AppTheme.error;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton(
        onPressed: _answered ? null : () => _checkAnswer(index),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: borderColor, width: 2)),
        ),
        child: Text(option, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
      ),
    );
  }
}
