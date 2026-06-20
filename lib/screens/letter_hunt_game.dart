import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../services/audio_service.dart';
import '../services/game_logic.dart';
import '../providers/enhanced_progress_provider.dart';

class LetterHuntGame extends StatefulWidget {
  final String difficulty;
  const LetterHuntGame({super.key, this.difficulty = 'Easy'});

  @override
  State<LetterHuntGame> createState() => _LetterHuntGameState();
}

class _LetterHuntGameState extends State<LetterHuntGame> {
  late Map<String, dynamic> _currentRound;
  int _score = 0;
  int _round = 1;
  final int _maxRounds = 10;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _generateRound();
  }

  void _generateRound() {
    _currentRound = GameLogic.generateLetterHuntRoundWithDifficulty(widget.difficulty);
    AudioService.playLetter(_currentRound['targetLetter']);
    _isAnswered = false;
  }

  void _checkAnswer(int selectedIndex) {
    if (_isAnswered) return;
    setState(() => _isAnswered = true);
    
    final correct = selectedIndex == _currentRound['correctIndex'];
    if (correct) {
      setState(() => _score += 10);
      Provider.of<EnhancedProgressProvider>(context, listen: false).addQuizScore(10);
    }
    _showFeedback(correct);
  }

  void _showFeedback(bool correct) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(correct ? '✅' : '❌', style: const TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              Text(
                correct ? 'Correct!' : 'Wrong Answer!',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: correct ? AppTheme.success : AppTheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                correct 
                    ? 'Great job! You found the correct letter.' 
                    : 'The letter you selected is not correct. Try again!',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textGray),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (correct) {
                          if (_round < _maxRounds) {
                            setState(() {
                              _round++;
                              _generateRound();
                            });
                          } else {
                            _showResults();
                          }
                        } else {
                          setState(() => _isAnswered = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: correct ? AppTheme.primary : AppTheme.textGray,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        correct ? 'Next' : 'Try Again',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
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
            const Text('🎉', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            const Text('Game Complete!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryRed)),
            const SizedBox(height: 16),
            Text('Score: $_score/${_maxRounds * 10}', style: const TextStyle(fontSize: 20)),
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
                      _generateRound();
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
        title: const Text('Letter Hunt'),
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
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.premiumCard(),
              child: Column(
                children: [
                  Text('Round $_round/$_maxRounds', style: const TextStyle(fontSize: 18, color: AppTheme.white)),
                  const SizedBox(height: 12),
                  const Text('Find this letter:', style: TextStyle(fontSize: 20, color: AppTheme.white)),
                  const SizedBox(height: 12),
                  Center(
                    child: InkWell(
                      onTap: () => AudioService.playLetter(_currentRound['targetLetter']),
                      borderRadius: BorderRadius.circular(40),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.volume_up_rounded,
                          color: AppTheme.white,
                          size: 64,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: (_currentRound['options'] as List).length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: _isAnswered ? null : () => _checkAnswer(index),
                    child: Container(
                      decoration: AppTheme.gameCard(),
                      child: Center(
                        child: Text((_currentRound['options'] as List)[index], style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.primaryRed)),
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
