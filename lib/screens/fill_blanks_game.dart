import 'package:flutter/material.dart';
import 'package:characters/characters.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../services/game_logic.dart';
import '../providers/enhanced_progress_provider.dart';

class FillBlanksGame extends StatefulWidget {
  final String difficulty;
  const FillBlanksGame({super.key, this.difficulty = 'Easy'});

  @override
  State<FillBlanksGame> createState() => _FillBlanksGameState();
}

class _FillBlanksGameState extends State<FillBlanksGame> {
  late Map<String, dynamic> _currentRound;
  int _score = 0;
  bool _answered = false;
  int _round = 1;
  final int _maxRounds = 10;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    _currentRound = GameLogic.generateFillBlanksRound(difficulty: widget.difficulty);
    _answered = false;
  }

  void _checkAnswer(String selected) {
    if (_answered) return;
    setState(() => _answered = true);
    
    if (selected == _currentRound['correctLetter']) {
      setState(() => _score += 15);
      Provider.of<EnhancedProgressProvider>(context, listen: false).addQuizScore(15);
      _showFeedback(true);
    } else {
      _showFeedback(false);
    }
  }

  void _showFeedback(bool correct) {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(correct ? '✅' : '❌', style: const TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              Text(
                correct ? 'Correct!' : 'Try Again!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: correct ? AppTheme.success : AppTheme.error,
                ),
              ),
              const SizedBox(height: 16),
              if (correct)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (_round < _maxRounds) {
                      setState(() => _round++);
                      _generateQuestion();
                    } else {
                      _showResults();
                    }
                  },
                  child: const Text('Next'),
                )
              else
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() => _answered = false);
                  },
                  child: const Text('Try Again'),
                ),
            ],
          ),
        ),
      );
    });
  }

  void _showResults() {
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
            const Text('Game Complete!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryRed)),
            const SizedBox(height: 16),
            Text('Score: $_score/${_maxRounds * 15}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _score = 0;
                      _round = 1;
                      _generateQuestion();
                    });
                  },
                  child: const Text('Play Again'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fill the Blanks'),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.glassCard(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: () {
                  final wordChars = (_currentRound['word'] as String).characters.toList();
                  return List.generate(wordChars.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 58,
                      height: 65,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: index == _currentRound['blankIndex'] ? AppTheme.warning : AppTheme.primaryRed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            index == _currentRound['blankIndex'] ? '?' : wordChars[index],
                            style: GoogleFonts.notoSansTamil(
                              fontSize: 32,
                              color: AppTheme.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  });
                }(),
              ),
            ),
            const SizedBox(height: 60),
            const Text('Choose the missing letter:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: (_currentRound['options'] as List).map((option) {
                return GestureDetector(
                  onTap: _answered ? null : () => _checkAnswer(option as String),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: AppTheme.gameCard(),
                    child: Center(
                      child: Text(option as String, style: const TextStyle(fontSize: 36, color: AppTheme.primaryRed, fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
