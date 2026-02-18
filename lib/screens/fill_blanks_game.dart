import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:characters/characters.dart';
import 'dart:math';
import '../constants/app_theme.dart';
import '../constants/tamil_data.dart';
import '../services/audio_service.dart';
import '../providers/enhanced_progress_provider.dart';

class FillBlanksGame extends StatefulWidget {
  const FillBlanksGame({super.key});

  @override
  State<FillBlanksGame> createState() => _FillBlanksGameState();
}

class _FillBlanksGameState extends State<FillBlanksGame>
    with SingleTickerProviderStateMixin {
  String _word = '';
  String _english = '';
  String _emoji = '';
  List<String> _wordChars = [];
  int _blankIndex = 0;
  List<String> _options = [];
  int _score = 0;
  int _round = 1;
  final int _maxRounds = 10;
  bool _answered = false;
  String _selectedOption = '';
  late AnimationController _animController;
  late Animation<double> _bounceAnimation;

  // Aggregate all words from all categories
  late List<Map<String, String>> _allWords;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );

    // Build a flat list of all words from all categories
    _allWords = [];
    for (final category in TamilData.wordCategories.entries) {
      for (final word in category.value) {
        _allWords.add(word);
      }
    }

    _generateQuestion();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _generateQuestion() {
    final random = Random();
    final wordData = _allWords[random.nextInt(_allWords.length)];
    _word = wordData['tamil']!;
    _english = wordData['english']!;
    _emoji = wordData['emoji']!;

    // Use characters package for proper Tamil character splitting
    _wordChars = _word.characters.toList();

    if (_wordChars.length < 2) {
      // Skip single-character words
      _generateQuestion();
      return;
    }

    _blankIndex = random.nextInt(_wordChars.length);
    final correctChar = _wordChars[_blankIndex];

    _options = [correctChar];

    // Add distractors from Tamil vowels and consonants
    final allLetters = [
      ...TamilData.uyirEzhuthukkal,
      ...TamilData.meiEzhuthukkal,
    ];

    while (_options.length < 4) {
      final letter = allLetters[random.nextInt(allLetters.length)];
      if (!_options.contains(letter)) {
        _options.add(letter);
      }
    }
    _options.shuffle();

    _answered = false;
    _selectedOption = '';
    setState(() {});
  }

  String _getDisplayWord() {
    return _wordChars.asMap().entries.map((entry) {
      if (entry.key == _blankIndex) return '___';
      return entry.value;
    }).join(' ');
  }

  void _checkAnswer(String selected) {
    if (_answered) return;

    setState(() {
      _answered = true;
      _selectedOption = selected;
    });

    final correctChar = _wordChars[_blankIndex];

    if (selected == correctChar) {
      _score += 15;
      Provider.of<EnhancedProgressProvider>(context, listen: false)
          .addQuizScore(15);
      _animController.forward(from: 0.0);
      AudioService.playWord(_word);
    }

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (_round < _maxRounds) {
        setState(() => _round++);
        _generateQuestion();
      } else {
        _showResults();
      }
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
              'Score: $_score/${_maxRounds * 15}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _score >= _maxRounds * 10
                  ? '🌟 Excellent!'
                  : _score >= _maxRounds * 5
                      ? '👍 Good Job!'
                      : '💪 Keep Practicing!',
              style: TextStyle(
                fontSize: 18,
                color: _score >= _maxRounds * 10
                    ? AppTheme.success
                    : AppTheme.textGray,
              ),
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

  @override
  Widget build(BuildContext context) {
    final correctChar = _wordChars.isNotEmpty ? _wordChars[_blankIndex] : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fill the Blanks'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.star, color: AppTheme.gold),
                const SizedBox(width: 4),
                Text(
                  '$_score',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Progress
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _round / _maxRounds,
                backgroundColor: Colors.grey.shade300,
                color: AppTheme.primaryRed,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Round $_round/$_maxRounds',
              style: const TextStyle(fontSize: 14, color: AppTheme.textGray),
            ),
            const SizedBox(height: 24),

            // Word display card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.premiumCard(),
              child: Column(
                children: [
                  Text(
                    _emoji,
                    style: const TextStyle(fontSize: 50),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _english,
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppTheme.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ScaleTransition(
                    scale: _bounceAnimation,
                    child: Text(
                      _getDisplayWord(),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Feedback area
            if (_answered)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _selectedOption == correctChar
                      ? AppTheme.success.withOpacity(0.1)
                      : AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _selectedOption == correctChar
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: _selectedOption == correctChar
                          ? AppTheme.success
                          : AppTheme.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedOption == correctChar
                          ? 'Correct! +15 points'
                          : 'Wrong! Answer: $correctChar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _selectedOption == correctChar
                            ? AppTheme.success
                            : AppTheme.error,
                      ),
                    ),
                  ],
                ),
              ),

            const Spacer(),

            // Options
            const Text(
              'Choose the missing letter:',
              style: TextStyle(fontSize: 16, color: AppTheme.textGray),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.0,
              children: _options.map((option) {
                Color bgColor = AppTheme.white;
                Color borderColor = AppTheme.primaryRed;
                Color textColor = AppTheme.primaryRed;

                if (_answered) {
                  if (option == correctChar) {
                    bgColor = AppTheme.success;
                    borderColor = AppTheme.success;
                    textColor = AppTheme.white;
                  } else if (option == _selectedOption &&
                      option != correctChar) {
                    bgColor = AppTheme.error;
                    borderColor = AppTheme.error;
                    textColor = AppTheme.white;
                  } else {
                    bgColor = Colors.grey.shade200;
                    borderColor = Colors.grey;
                    textColor = Colors.grey;
                  }
                }

                return GestureDetector(
                  onTap: () => _checkAnswer(option),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: borderColor.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
