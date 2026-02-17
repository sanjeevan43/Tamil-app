import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../constants/app_theme.dart';
import '../constants/tamil_data.dart';
import '../providers/enhanced_progress_provider.dart';

class FillBlanksGame extends StatefulWidget {
  const FillBlanksGame({super.key});

  @override
  State<FillBlanksGame> createState() => _FillBlanksGameState();
}

class _FillBlanksGameState extends State<FillBlanksGame> {
  String _word = '';
  int _blankIndex = 0;
  List<String> _options = [];
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    final words = TamilData.wordCategories['Animals']!;
    final wordData = words[Random().nextInt(words.length)];
    _word = wordData['tamil']!;
    _blankIndex = Random().nextInt(_word.length);
    
    final correctLetter = _word[_blankIndex];
    _options = [correctLetter];
    
    while (_options.length < 4) {
      final letter = TamilData.uyirEzhuthukkal[Random().nextInt(TamilData.uyirEzhuthukkal.length)];
      if (!_options.contains(letter)) {
        _options.add(letter);
      }
    }
    _options.shuffle();
    setState(() {});
  }

  void _checkAnswer(String selected) {
    if (selected == _word[_blankIndex]) {
      setState(() => _score += 15);
      Provider.of<EnhancedProgressProvider>(context, listen: false).addQuizScore(15);
      _showFeedback(true);
    } else {
      _showFeedback(false);
    }
  }

  void _showFeedback(bool correct) {
    showDialog(
      context: context,
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
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (correct) _generateQuestion();
              },
              child: Text(correct ? 'Next' : 'OK'),
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
                children: List.generate(_word.length, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 50,
                    height: 60,
                    decoration: BoxDecoration(
                      color: index == _blankIndex ? AppTheme.warning : AppTheme.primaryRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        index == _blankIndex ? '?' : _word[index],
                        style: const TextStyle(fontSize: 32, color: AppTheme.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 60),
            const Text('Choose the missing letter:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _options.map((option) {
                return GestureDetector(
                  onTap: () => _checkAnswer(option),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: AppTheme.gameCard(),
                    child: Center(
                      child: Text(
                        option,
                        style: const TextStyle(fontSize: 36, color: AppTheme.primaryRed, fontWeight: FontWeight.bold),
                      ),
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
