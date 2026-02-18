import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../constants/app_theme.dart';
import '../constants/tamil_data.dart';
import '../providers/enhanced_progress_provider.dart';

class SentenceBuilderGame extends StatefulWidget {
  const SentenceBuilderGame({super.key});

  @override
  State<SentenceBuilderGame> createState() => _SentenceBuilderGameState();
}

class _SentenceBuilderGameState extends State<SentenceBuilderGame> {
  int _currentSentenceIndex = 0;
  List<String> _scrambledWords = [];
  List<String> _userAnswer = [];
  int _score = 0;
  int _totalAttempted = 0;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _loadSentence();
  }

  void _loadSentence() {
    final sentence = TamilData.sentences[_currentSentenceIndex];
    final words = List<String>.from(sentence['tamil'] as List);
    _scrambledWords = List.from(words)..shuffle(Random());
    _userAnswer = [];
    _showHint = false;
    setState(() {});
  }

  void _addWord(String word, int index) {
    setState(() {
      _userAnswer.add(word);
      _scrambledWords.removeAt(index);
    });

    if (_scrambledWords.isEmpty) {
      _checkAnswer();
    }
  }

  void _removeWord(int index) {
    setState(() {
      _scrambledWords.add(_userAnswer[index]);
      _userAnswer.removeAt(index);
    });
  }

  void _checkAnswer() {
    final sentence = TamilData.sentences[_currentSentenceIndex];
    final correctOrder = List<String>.from(sentence['tamil'] as List);
    _totalAttempted++;

    if (_userAnswer.join(' ') == correctOrder.join(' ')) {
      _score += 25;
      Provider.of<EnhancedProgressProvider>(context, listen: false).addQuizScore(25);
      _showSuccessDialog();
    } else {
      _showErrorDialog();
    }
  }

  void _showSuccessDialog() {
    final sentence = TamilData.sentences[_currentSentenceIndex];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            const Text(
              'Correct!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.success,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              sentence['english'] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: AppTheme.textGray),
            ),
            const SizedBox(height: 8),
            Text(
              '+25 Points!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.gold,
              ),
            ),
          ],
        ),
        actions: [
          if (_currentSentenceIndex < TamilData.sentences.length - 1)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _currentSentenceIndex++;
                  _loadSentence();
                });
              },
              child: const Text('Next Sentence'),
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

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('❌', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            const Text(
              'Try Again!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The order is not correct. Try rearranging the words.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textGray),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadSentence();
            },
            child: const Text('Retry'),
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
              'All Done!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryRed,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Score: $_score',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentSentenceIndex = 0;
                _score = 0;
                _totalAttempted = 0;
                _loadSentence();
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final sentence = TamilData.sentences[_currentSentenceIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentence Builder'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.star, color: AppTheme.gold),
                const SizedBox(width: 4),
                Text(' $_score', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (_currentSentenceIndex + 1) / TamilData.sentences.length,
                backgroundColor: Colors.grey.shade300,
                color: AppTheme.primaryRed,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sentence ${_currentSentenceIndex + 1}/${TamilData.sentences.length}',
              style: const TextStyle(fontSize: 14, color: AppTheme.textGray),
            ),
            const SizedBox(height: 24),

            // English hint
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.premiumCard(),
              child: Column(
                children: [
                  const Text(
                    'Translate to Tamil:',
                    style: TextStyle(fontSize: 14, color: AppTheme.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sentence['english'] as String,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Hint button
            if (_showHint)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('💡 ', style: TextStyle(fontSize: 18)),
                    Expanded(
                      child: Text(
                        sentence['hint'] as String,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              )
            else
              TextButton.icon(
                onPressed: () => setState(() => _showHint = true),
                icon: const Icon(Icons.lightbulb_outline, color: AppTheme.gold),
                label: const Text('Show Hint', style: TextStyle(color: AppTheme.gold)),
              ),
            const SizedBox(height: 20),

            // Answer slots
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 80),
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.glassCard(),
              child: _userAnswer.isEmpty
                  ? const Center(
                      child: Text(
                        'Tap words below to build your sentence',
                        style: TextStyle(color: AppTheme.textGray),
                      ),
                    )
                  : Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _userAnswer.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () => _removeWord(entry.key),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryRed,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryRed.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              entry.value,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.white,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const Spacer(),

            // Scrambled words
            const Text(
              'Tap words in correct order:',
              style: TextStyle(fontSize: 15, color: AppTheme.textGray),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: _scrambledWords.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _addWord(entry.value, entry.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: AppTheme.gameCard(),
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
