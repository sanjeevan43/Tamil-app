import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../data/tamil_data.dart';
import '../services/audio_service.dart';
import '../providers/enhanced_progress_provider.dart';
import '../widgets/premium_animations.dart';

class OddOneOutGame extends StatefulWidget {
  const OddOneOutGame({super.key});

  @override
  State<OddOneOutGame> createState() => _OddOneOutGameState();
}

class _OddOneOutGameState extends State<OddOneOutGame> {
  final Random _random = Random();
  final int _maxRounds = 8;
  
  int _round = 1;
  int _score = 0;
  bool _answered = false;
  
  late String _correctAnswerTamil;
  late String _correctAnswerEnglish;
  late String _oddCategory;
  late String _mainCategory;
  late List<Map<String, String>> _options;

  @override
  void initState() {
    super.initState();
    _generateRound();
  }

  void _generateRound() {
    _answered = false;
    
    // Get all available categories
    final categories = TamilData.wordCategories.keys.toList();
    
    // Pick a main category and an odd category
    _mainCategory = categories[_random.nextInt(categories.length)];
    categories.remove(_mainCategory);
    _oddCategory = categories[_random.nextInt(categories.length)];

    final mainWords = List<Map<String, String>>.from(TamilData.wordCategories[_mainCategory]!)..shuffle();
    final oddWords = List<Map<String, String>>.from(TamilData.wordCategories[_oddCategory]!)..shuffle();

    // Take 3 words from main category and 1 word from odd category
    final mainSelection = mainWords.take(3).toList();
    final oddSelection = oddWords.first;

    _correctAnswerTamil = oddSelection['tamil']!;
    _correctAnswerEnglish = oddSelection['english']!;
    _options = [...mainSelection, oddSelection]..shuffle();
    
    setState(() {});
  }

  void _checkAnswer(Map<String, String> selected) {
    if (_answered) return;
    setState(() => _answered = true);

    final isCorrect = selected['tamil'] == _correctAnswerTamil;
    if (isCorrect) {
      _score += 20;
      Provider.of<EnhancedProgressProvider>(context, listen: false).addQuizScore(20);
      AudioService.playWord(_correctAnswerTamil);
      _showFeedback(true);
    } else {
      _showFeedback(false);
    }
  }

  void _showFeedback(bool correct) {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(correct ? '🎉' : '🥺', style: const TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              Text(
                correct ? 'Correct! +20 XP' : 'Not quite right!',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: correct ? AppTheme.success : AppTheme.error,
                ),
              ),
              const SizedBox(height: 12),
              if (correct) ...[
                Text(
                  '$_correctAnswerTamil ($_correctAnswerEnglish)',
                  style: GoogleFonts.notoSansTamil(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.secondary),
                ),
                Text(
                  'belongs to $_oddCategory, others are $_mainCategory!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textGray),
                ),
              ] else ...[
                Text(
                  'Try again to find the odd one!',
                  style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textGray),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (correct) {
                          if (_round < _maxRounds) {
                            setState(() => _round++);
                            _generateRound();
                          } else {
                            _showFinalResults();
                          }
                        } else {
                          setState(() => _answered = false);
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

  void _showFinalResults() {
    final progress = Provider.of<EnhancedProgressProvider>(context, listen: false);
    progress.addRewards(coins: _score ~/ 2, stars: _score ~/ 20, missionId: 'game_hero');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_rounded, color: AppTheme.gold, size: 80),
            const SizedBox(height: 16),
            Text(
              'Game Complete!',
              style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.secondary),
            ),
            const SizedBox(height: 12),
            Text(
              'Score: $_score/${_maxRounds * 20}',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              'You earned ${_score ~/ 2} coins and ${_score ~/ 20} stars!',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textGray),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.topoSilver),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('Exit', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppTheme.textGray)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _round = 1;
                        _score = 0;
                        _generateRound();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('Play Again', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
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
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Odd One Out', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.star, color: AppTheme.gold),
                const SizedBox(width: 4),
                Text('$_score', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _round / _maxRounds,
                  backgroundColor: AppTheme.topoSilver.withOpacity(0.5),
                  color: AppTheme.primary,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Round $_round/$_maxRounds',
                style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textGray, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              
              // Question description
              Text(
                'வேறுபட்டதைக் கண்டுபிடி!',
                style: GoogleFonts.notoSansTamil(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.secondary),
              ),
              const SizedBox(height: 6),
              Text(
                'Find the odd one out!',
                style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textGray, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              
              // Options Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.05,
                ),
                itemCount: _options.length,
                itemBuilder: (context, index) {
                  final option = _options[index];
                  return FadeInSlide(
                    direction: SlideDirection.up,
                    delay: Duration(milliseconds: 100 + (index * 80)),
                    child: SpringyTap(
                      onTap: () => _checkAnswer(option),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppTheme.primary.withOpacity(0.12), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.secondary.withOpacity(0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              option['emoji'] ?? '❓',
                              style: const TextStyle(fontSize: 44),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              option['tamil'] ?? '',
                              style: GoogleFonts.notoSansTamil(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              option['english'] ?? '',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
