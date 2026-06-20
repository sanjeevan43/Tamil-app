import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';
import '../services/game_logic.dart';

class WordScrambleGame extends StatefulWidget {
  final String difficulty;
  const WordScrambleGame({super.key, this.difficulty = 'Easy'});

  @override
  State<WordScrambleGame> createState() => _WordScrambleGameState();
}

class _WordScrambleGameState extends State<WordScrambleGame> {
  String _targetWord = '';
  String _hint = '';
  String _emoji = '';
  List<String> _scrambledLetters = [];
  List<String> _selectedLetters = [];
  bool _isCorrect = false;
  int _score = 0;
  int _round = 1;
  final int _maxRounds = 8;

  @override
  void initState() {
    super.initState();
    _loadLevel();
  }

  void _loadLevel() {
    final wordData = GameLogic.generateWordScrambleRound(difficulty: widget.difficulty);
    setState(() {
      _targetWord = wordData['word']!;
      _hint = wordData['english']!;
      _emoji = wordData['emoji'] ?? '🧩';
      _scrambledLetters = List<String>.from(wordData['scrambled'] as List);
      _selectedLetters = [];
      _isCorrect = false;
    });
  }

  void _onLetterTap(int index) {
    if (_isCorrect) return;

    setState(() {
      _selectedLetters.add(_scrambledLetters[index]);
      _scrambledLetters.removeAt(index);

      String currentWord = _selectedLetters.join('');
      if (currentWord == _targetWord) {
        _isCorrect = true;
        _score += 15;
        _showSuccessDialog();
      } else if (_scrambledLetters.isEmpty) {
        // Wrong answer
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Try again! Spelling not correct.'),
            backgroundColor: AppTheme.error,
            duration: const Duration(milliseconds: 800),
          ),
        );
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            _resetLevel();
          }
        });
      }
    });
  }

  void _resetLevel() {
    setState(() {
      _scrambledLetters = _targetWord.characters.toList()..shuffle();
      _selectedLetters = [];
      _isCorrect = false;
    });
  }

  void _showSuccessDialog() {
    final progress = Provider.of<EnhancedProgressProvider>(context, listen: false);
    progress.addRewards(coins: 15, stars: 2, missionId: 'game_hero');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Center(child: Text('🎊 Excellent! 🎊', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('You spelled it correctly!', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text(_emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(_targetWord, style: GoogleFonts.notoSansTamil(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primary)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _rewardIcon('💰', '+15'),
                const SizedBox(width: 20),
                _rewardIcon('⭐', '+2'),
              ],
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (_round < _maxRounds) {
                  setState(() {
                    _round++;
                  });
                  _loadLevel();
                } else {
                  _showFinalResults();
                }
              },
              child: Text(_round < _maxRounds ? 'NEXT WORD' : 'SEE RESULTS', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.primary)),
            ),
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
              'Score: $_score/${_maxRounds * 15}',
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
                      _loadLevel();
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

  Widget _rewardIcon(String emoji, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        Text(text, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textSlate)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Word Scramble', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: AppTheme.pillBadge(),
                child: Text('Score: $_score', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.primary, fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
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
              // Hint Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: AppTheme.whiteCard(radius: 28),
                child: Column(
                  children: [
                    Text('HINT', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textSlate.withOpacity(0.4), letterSpacing: 2)),
                    const SizedBox(height: 8),
                    Text(_hint, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  ],
                ),
              ),
              const Spacer(),
              // Selected Letters Area
              Container(
                constraints: const BoxConstraints(minHeight: 80),
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.1), width: 2),
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedLetters.map((l) => _letterTile(l, true)).toList(),
                ),
              ),
              const SizedBox(height: 48),
              // Scrambled Letters Area
              Text('TAP LETTERS TO SPELL', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textSlate.withOpacity(0.4), letterSpacing: 2)),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: List.generate(_scrambledLetters.length, (index) {
                  return GestureDetector(
                    onTap: () => _onLetterTap(index),
                    child: _letterTile(_scrambledLetters[index], false),
                  );
                }),
              ),
              const Spacer(),
              // Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(
                    onPressed: _resetLevel,
                    icon: const Icon(Icons.refresh_rounded),
                    style: IconButton.styleFrom(backgroundColor: AppTheme.textSlate.withOpacity(0.1), foregroundColor: AppTheme.textSlate),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _letterTile(String letter, bool isSelected) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primary : AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isSelected ? AppTheme.primary.withOpacity(0.3) : AppTheme.textDark.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isSelected ? Colors.transparent : AppTheme.borderLight,
        ),
      ),
      child: Center(
        child: Text(
          letter,
          style: GoogleFonts.notoSansTamil(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppTheme.white : AppTheme.textDark,
          ),
        ),
      ),
    );
  }
}
