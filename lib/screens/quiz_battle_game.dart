import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../constants/app_theme.dart';
import '../services/game_logic.dart';
import '../providers/enhanced_progress_provider.dart';

class QuizBattleGame extends StatefulWidget {
  const QuizBattleGame({super.key});

  @override
  State<QuizBattleGame> createState() => _QuizBattleGameState();
}

class _QuizBattleGameState extends State<QuizBattleGame> {
  late List<Map<String, dynamic>> _questions;
  int _currentQuestion = 0;
  int _score = 0;
  int _timeLeft = 30;
  late Timer _timer;
  int? _selectedAnswer;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _questions = GameLogic.getQuizQuestions();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _nextQuestion();
        }
      });
    });
  }

  void _checkAnswer(int selected) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = selected;
      _answered = true;
    });

    if (selected == _questions[_currentQuestion]['correct']) {
      setState(() => _score += 10);
    }

    Future.delayed(const Duration(seconds: 1), _nextQuestion);
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
        _answered = false;
        _timeLeft = 30;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    _timer.cancel();
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
            const Text('Quiz Battle Complete!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryRed)),
            const SizedBox(height: 16),
            Text('Score: $_score/${_questions.length * 10}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
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
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Battle'),
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _timeLeft > 10 ? AppTheme.success : AppTheme.warning,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Time: $_timeLeft s',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: (_currentQuestion + 1) / _questions.length,
              backgroundColor: Colors.grey.shade300,
              color: AppTheme.primaryRed,
              minHeight: 8,
            ),
            const SizedBox(height: 20),
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
            ...List.generate((question['options'] as List).length, (index) {
              final option = (question['options'] as List)[index];
              Color buttonColor = AppTheme.white;
              Color borderColor = AppTheme.primaryRed;
              Color textColor = AppTheme.primaryRed;

              if (_answered && index == question['correct']) {
                buttonColor = AppTheme.success;
                textColor = AppTheme.white;
                borderColor = AppTheme.success;
              } else if (_answered && index == _selectedAnswer && index != question['correct']) {
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
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: borderColor, width: 2)),
                  ),
                  child: Text(option, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
