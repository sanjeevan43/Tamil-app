import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../constants/tamil_data.dart';
import '../services/audio_service.dart';
import '../services/game_logic.dart';
import '../providers/enhanced_progress_provider.dart';

class LetterHuntGame extends StatefulWidget {
  const LetterHuntGame({super.key});

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
    _currentRound = GameLogic.generateLetterHuntRound();
    AudioService.playLetter(_currentRound['targetLetter']);
    _isAnswered = false;
  }

  void _checkAnswer(int selectedIndex) {
    if (_isAnswered) return;
    setState(() => _isAnswered = true);
    
    if (selectedIndex == _currentRound['correctIndex']) {
      setState(() => _score += 10);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        if (_round < _maxRounds) {
          setState(() {
            _round++;
            _generateRound();
          });
        } else {
          _showResults();
        }
      });
    } else {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _isAnswered = false);
      });
    }
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_currentRound['targetLetter'], style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: AppTheme.white)),
                      IconButton(
                        onPressed: () => AudioService.playLetter(_currentRound['targetLetter']),
                        icon: const Icon(Icons.volume_up, color: AppTheme.white, size: 32),
                      ),
                    ],
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
