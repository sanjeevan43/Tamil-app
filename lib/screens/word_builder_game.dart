import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../constants/app_theme.dart';
import '../data/tamil_data.dart';
import '../services/audio_service.dart';
import '../providers/enhanced_progress_provider.dart';

class WordBuilderGame extends StatefulWidget {
  const WordBuilderGame({super.key});

  @override
  State<WordBuilderGame> createState() => _WordBuilderGameState();
}

class _WordBuilderGameState extends State<WordBuilderGame> {
  String _targetWord = '';
  String _english = '';
  String _emoji = '';
  List<String> _scrambledLetters = [];
  List<String> _userAnswer = [];
  int _score = 0;
  int _round = 1;
  final int _maxRounds = 8;
  bool _showingResult = false;

  // Aggregate all words from all categories
  late List<Map<String, String>> _allWords;

  @override
  void initState() {
    super.initState();
    _allWords = [];
    for (final category in TamilData.wordCategories.entries) {
      for (final word in category.value) {
        _allWords.add(word);
      }
    }
    _generateWord();
  }

  void _generateWord() {
    final random = Random();
    final wordData = _allWords[random.nextInt(_allWords.length)];
    _targetWord = wordData['tamil']!;
    _english = wordData['english']!;
    _emoji = wordData['emoji']!;

    // Use characters package for proper Tamil character handling
    _scrambledLetters = _targetWord.characters.toList()..shuffle(random);
    _userAnswer = [];
    _showingResult = false;
    setState(() {});
  }

  void _addLetter(String letter, int index) {
    if (_showingResult) return;
    if (_userAnswer.length >= _targetWord.characters.length) return; // Prevent adding more letters than needed
    
    setState(() {
      _userAnswer.add(letter);
      _scrambledLetters.removeAt(index);
    });
    _checkAnswer();
  }

  void _removeLetter(int index) {
    if (_showingResult) return;
    setState(() {
      _scrambledLetters.add(_userAnswer[index]);
      _userAnswer.removeAt(index);
    });
  }

  void _checkAnswer() {
    if (_userAnswer.length == _targetWord.characters.length) {
      final builtWord = _userAnswer.join();
      if (builtWord == _targetWord) {
        _score += 20;
        Provider.of<EnhancedProgressProvider>(context, listen: false)
            .addQuizScore(20);
        AudioService.playWord(_targetWord);
        setState(() => _showingResult = true);
        _showSuccess();
      } else {
        // Wrong answer - show briefly then reset
        setState(() => _showingResult = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Not quite right, try again!'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 1),
          ),
        );
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            // Reset the word without changing it
            setState(() {
              _scrambledLetters =
                  _targetWord.characters.toList()..shuffle(Random());
              _userAnswer = [];
              _showingResult = false;
            });
          }
        });
      }
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_emoji, style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(
              _targetWord,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryRed,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _english,
              style: const TextStyle(fontSize: 16, color: AppTheme.textGray),
            ),
            const SizedBox(height: 16),
            const Text(
              '✅ Correct! +20 Points',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.success,
              ),
            ),
          ],
        ),
        actions: [
          if (_round < _maxRounds)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _round++);
                _generateWord();
              },
              child: const Text('Next Word'),
            )
          else
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showFinalResults();
              },
              child: const Text('See Results'),
            ),
        ],
      ),
    );
  }

  void _showFinalResults() {
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
              'Game Complete!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryRed,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Score: $_score/${_maxRounds * 20}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
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
                      _generateWord();
                    });
                  },
                  child: const Text('Play Again'),
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

  void _skipWord() {
    if (_round < _maxRounds) {
      setState(() => _round++);
      _generateWord();
    } else {
      _showFinalResults();
    }
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
                const SizedBox(width: 4),
                Text(
                  '$_score',
                  style:
                      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Progress
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _round / _maxRounds,
                  backgroundColor: AppTheme.textGray.withOpacity(0.3),
                  color: AppTheme.primaryRed,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Word $_round/$_maxRounds',
                style: const TextStyle(fontSize: 14, color: AppTheme.textGray),
              ),
              const SizedBox(height: 20),

              // Clue
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.premiumCard(),
                child: Column(
                  children: [
                    Text(_emoji, style: const TextStyle(fontSize: 50)),
                    const SizedBox(height: 8),
                    Text(
                      _english,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Build the Tamil word!',
                      style: TextStyle(fontSize: 14, color: AppTheme.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Answer slots
              Container(
                constraints: const BoxConstraints(minHeight: 80),
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.glassCard(),
                child: Center(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: _userAnswer.asMap().entries.map((entry) {
                      return GestureDetector(
                        onTap: () => _removeLetter(entry.key),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryRed,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryRed.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              entry.value,
                              style: const TextStyle(
                                fontSize: 28,
                                color: AppTheme.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Scrambled letters
              const Text(
                'Tap letters to build:',
                style: TextStyle(fontSize: 14, color: AppTheme.textGray),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _scrambledLetters.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => _addLetter(entry.value, entry.key),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: AppTheme.gameCard(),
                      child: Center(
                        child: Text(
                          entry.value,
                          style: const TextStyle(
                            fontSize: 28,
                            color: AppTheme.primaryRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),

              // Skip button
              TextButton.icon(
                onPressed: _skipWord,
                icon: const Icon(Icons.skip_next, color: AppTheme.textGray),
                label:
                    const Text('Skip', style: TextStyle(color: AppTheme.textGray)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
