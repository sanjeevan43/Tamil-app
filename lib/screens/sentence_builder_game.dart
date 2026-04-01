import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../services/game_logic.dart';
import '../providers/enhanced_progress_provider.dart';

class SentenceBuilderGame extends StatefulWidget {
  const SentenceBuilderGame({super.key});

  @override
  State<SentenceBuilderGame> createState() => _SentenceBuilderGameState();
}

class _SentenceBuilderGameState extends State<SentenceBuilderGame> {
  late Map<String, dynamic> _currentRound;
  List<String> _userSentence = [];
  int _score = 0;
  int _round = 1;
  final int _maxRounds = 8;

  @override
  void initState() {
    super.initState();
    _generateSentence();
  }

  void _generateSentence() {
    _currentRound = GameLogic.generateSentenceBuilderRound();
    _userSentence = [];
    setState(() {});
  }

  void _addWord(String word, int index) {
    if (_userSentence.length >= (_currentRound['correctOrder'] as List).length) return;
    
    setState(() {
      _userSentence.add(word);
      (_currentRound['words'] as List).removeAt(index);
    });
    _checkSentence();
  }

  void _removeWord(int index) {
    setState(() {
      (_currentRound['words'] as List).add(_userSentence[index]);
      _userSentence.removeAt(index);
    });
  }

  void _checkSentence() {
    if (_userSentence.length == (_currentRound['correctOrder'] as List).length) {
      if (_userSentence.join(' ') == (_currentRound['correctSentence'] as String)) {
        _score += 25;
        Provider.of<EnhancedProgressProvider>(context, listen: false).addRewards(coins: 20, stars: 2, missionId: 'game_hero');
        _showSuccess();
      }
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✅', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            const Text('Perfect!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.success)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (_round < _maxRounds) {
                  setState(() => _round++);
                  _generateSentence();
                } else {
                  _showResults();
                }
              },
              child: const Text('Next Sentence'),
            ),
          ],
        ),
      ),
    );
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
            Text('Score: $_score/${_maxRounds * 25}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                      _generateSentence();
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
        title: const Text('Sentence Builder'),
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
            const Text('Build the sentence:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              height: 100,
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.glassCard(),
              child: Center(
                child: Wrap(
                  spacing: 8,
                  children: _userSentence.asMap().entries.map((entry) {
                    return GestureDetector(
                      onTap: () => _removeWord(entry.key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(entry.value, style: const TextStyle(fontSize: 18, color: AppTheme.white, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text('Tap words to build:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: (_currentRound['words'] as List).asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _addWord(entry.value as String, entry.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: AppTheme.gameCard(),
                    child: Text(entry.value as String, style: const TextStyle(fontSize: 18, color: AppTheme.primaryRed, fontWeight: FontWeight.bold)),
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
