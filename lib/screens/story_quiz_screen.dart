import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';

class StoryQuizScreen extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final String storyTitle;

  const StoryQuizScreen({
    super.key,
    required this.questions,
    required this.storyTitle,
  });

  @override
  State<StoryQuizScreen> createState() => _StoryQuizScreenState();
}

class _StoryQuizScreenState extends State<StoryQuizScreen> {
  int _currentQuestion = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;

  void _checkAnswer(int selected) {
    setState(() {
      _selectedAnswer = selected;
      _answered = true;
      if (selected == widget.questions[_currentQuestion]['correct']) {
        _score++;
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (_currentQuestion < widget.questions.length - 1) {
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
    final progress = Provider.of<EnhancedProgressProvider>(context, listen: false);
    progress.addStoryScore(widget.storyTitle, _score);
    
    // Award rewards based on performance
    final coinsEarned = _score * 25;
    final starsEarned = _score * 5;
    progress.addRewards(coins: coinsEarned, stars: starsEarned, missionId: 'quiz_master');
        
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars, color: AppTheme.warning, size: 80),
            const SizedBox(height: 20),
            Text(
              'அற்புதம்!',
              style: GoogleFonts.notoSansTamil(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryRed,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your Score: $_score / ${widget.questions.length}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Exit quiz
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
              ),
              child: const Text('Finish'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.storyTitle} - Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (_currentQuestion + 1) / widget.questions.length,
                minHeight: 12,
                backgroundColor: AppTheme.primaryRed.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation(AppTheme.primaryRed),
              ),
            ),
            const SizedBox(height: 40),
            
            // Question Card
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
                ],
              ),
              child: Text(
                question['question'],
                style: GoogleFonts.notoSansTamil(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                  color: AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Options
            Expanded(
              child: ListView.builder(
                itemCount: (question['options'] as List).length,
                itemBuilder: (context, index) {
                  final option = question['options'][index];
                  bool isCorrect = index == question['correct'];
                  bool isSelected = index == _selectedAnswer;

                  Color bgColor = AppTheme.white;
                  Color borderColor = AppTheme.primaryRed.withOpacity(0.2);
                  
                  if (_answered) {
                    if (isCorrect) {
                      bgColor = AppTheme.success.withOpacity(0.1);
                      borderColor = AppTheme.success;
                    } else if (isSelected) {
                      bgColor = AppTheme.error.withOpacity(0.1);
                      borderColor = AppTheme.error;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: _answered ? null : () => _checkAnswer(index),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: borderColor, width: 2),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${index + 1}.',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textGray),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                option,
                                style: GoogleFonts.notoSansTamil(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (_answered && isCorrect)
                              const Icon(Icons.check_circle, color: AppTheme.success),
                            if (_answered && isSelected && !isCorrect)
                              const Icon(Icons.cancel, color: AppTheme.error),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
