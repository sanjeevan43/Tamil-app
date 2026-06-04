import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';

class WordScrambleGame extends StatefulWidget {
  const WordScrambleGame({super.key});

  @override
  State<WordScrambleGame> createState() => _WordScrambleGameState();
}

class _WordScrambleGameState extends State<WordScrambleGame> {
  final List<Map<String, String>> _words = [
    {'word': 'அம்மா', 'hint': 'Mother'},
    {'word': 'அப்பா', 'hint': 'Father'},
    {'word': 'ஆப்பிள்', 'hint': 'Apple'},
    {'word': 'பந்து', 'hint': 'Ball'},
    {'word': 'மலர்', 'hint': 'Flower'},
    {'word': 'தமி்ழ்', 'hint': 'Tamil'},
    {'word': 'பள்ளி', 'hint': 'School'},
    {'word': 'புத்தகம்', 'hint': 'Book'},
    {'word': 'யானை', 'hint': 'Elephant'},
    {'word': 'மயில்', 'hint': 'Peacock'},
  ];

  int _currentIndex = 0;
  List<String> _scrambledLetters = [];
  List<String> _selectedLetters = [];
  bool _isCorrect = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _loadLevel();
  }

  void _loadLevel() {
    setState(() {
      String word = _words[_currentIndex]['word']!;
      // Simple splitting for Tamil letters (considering combinations)
      _scrambledLetters = _splitTamilWord(word);
      _scrambledLetters.shuffle();
      _selectedLetters = [];
      _isCorrect = false;
    });
  }

  List<String> _splitTamilWord(String word) {
    // Basic Tamil letter splitting logic
    // In a real app, this should handle complex characters better
    List<String> letters = [];
    for (int i = 0; i < word.length; i++) {
      letters.add(word[i]);
    }
    return letters;
  }

  void _onLetterTap(int index) {
    if (_isCorrect) return;

    setState(() {
      _selectedLetters.add(_scrambledLetters[index]);
      _scrambledLetters.removeAt(index);

      String currentWord = _selectedLetters.join('');
      if (currentWord == _words[_currentIndex]['word']) {
        _isCorrect = true;
        _score += 10;
        _showSuccessDialog();
      } else if (_scrambledLetters.isEmpty) {
        // Wrong answer
        Future.delayed(const Duration(milliseconds: 500), () {
          _loadLevel();
        });
      }
    });
  }

  void _resetLevel() {
    _loadLevel();
  }

  void _showSuccessDialog() {
    final progress = Provider.of<EnhancedProgressProvider>(context, listen: false);
    progress.addRewards(coins: 10, stars: 2, missionId: 'game_hero');

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
            Text(_words[_currentIndex]['word']!, style: GoogleFonts.notoSansTamil(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primary)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _rewardIcon('💰', '+10'),
                const SizedBox(width: 20),
                _rewardIcon('⭐', '+2'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = (_currentIndex + 1) % _words.length;
                _loadLevel();
              });
            },
            child: Text('NEXT WORD', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.primary)),
          ),
        ],
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
              // Hint Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: AppTheme.whiteCard(radius: 28),
                child: Column(
                  children: [
                    Text('HINT', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textSlate.withOpacity(0.4), letterSpacing: 2)),
                    const SizedBox(height: 8),
                    Text(_words[_currentIndex]['hint']!, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
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
