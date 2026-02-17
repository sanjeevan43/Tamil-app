import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../constants/app_theme.dart';
import '../constants/tamil_data.dart';
import '../providers/enhanced_progress_provider.dart';

class WordBuilderGame extends StatefulWidget {
  const WordBuilderGame({super.key});

  @override
  State<WordBuilderGame> createState() => _WordBuilderGameState();
}

class _WordBuilderGameState extends State<WordBuilderGame> {
  String _targetWord = '';
  List<String> _scrambledLetters = [];
  List<String> _userAnswer = [];
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _generateWord();
  }

  void _generateWord() {
    final words = TamilData.wordCategories['Animals']!;
    final word = words[Random().nextInt(words.length)]['tamil']!;
    _targetWord = word;
    _scrambledLetters = word.split('')..shuffle();
    _userAnswer = [];
    setState(() {});
  }

  void _addLetter(String letter, int index) {
    setState(() {
      _userAnswer.add(letter);
      _scrambledLetters.removeAt(index);
    });
    _checkAnswer();
  }

  void _removeLetter(int index) {
    setState(() {
      _scrambledLetters.add(_userAnswer[index]);
      _userAnswer.removeAt(index);
    });
  }

  void _checkAnswer() {
    if (_userAnswer.length == _targetWord.length) {
      if (_userAnswer.join() == _targetWord) {
        _score += 20;
        Provider.of<EnhancedProgressProvider>(context, listen: false).addQuizScore(20);
        _showSuccess();
      }
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✅', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            const Text('Correct!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.success)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _generateWord();
              },
              child: const Text('Next Word'),
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
        title: const Text('Word Builder'),
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
            const Text('Build the word:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              height: 100,
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.glassCard(),
              child: Center(
                child: Wrap(
                  spacing: 8,
                  children: _userAnswer.asMap().entries.map((entry) {
                    return GestureDetector(
                      onTap: () => _removeLetter(entry.key),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            entry.value,
                            style: const TextStyle(fontSize: 32, color: AppTheme.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text('Tap letters to build:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _scrambledLetters.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _addLetter(entry.value, entry.key),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: AppTheme.gameCard(),
                    child: Center(
                      child: Text(
                        entry.value,
                        style: const TextStyle(fontSize: 32, color: AppTheme.primaryRed, fontWeight: FontWeight.bold),
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
