import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../constants/app_theme.dart';
import '../constants/tamil_data.dart';
import '../services/audio_service.dart';
import '../providers/enhanced_progress_provider.dart';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen>
    with SingleTickerProviderStateMixin {
  List<String> _cards = [];
  List<bool> _revealed = [];
  List<bool> _matched = [];
  List<int> _selectedIndices = [];
  int _matches = 0;
  int _moves = 0;
  bool _isChecking = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _initializeGame();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initializeGame() {
    final letters = TamilData.uyirEzhuthukkal.toList()..shuffle(Random());
    final selected = letters.take(6).toList();
    _cards = [...selected, ...selected];
    _cards.shuffle(Random());
    _revealed = List.filled(_cards.length, false);
    _matched = List.filled(_cards.length, false);
    _selectedIndices = [];
    _matches = 0;
    _moves = 0;
    _isChecking = false;
    setState(() {});
  }

  void _onCardTap(int index) {
    if (_isChecking) return;
    if (_revealed[index]) return;
    if (_matched[index]) return;
    if (_selectedIndices.length >= 2) return;
    if (_selectedIndices.contains(index)) return; // Prevent tapping same card twice

    setState(() {
      _revealed[index] = true;
      _selectedIndices.add(index);
    });

    AudioService.playLetter(_cards[index]);

    if (_selectedIndices.length == 2) {
      _moves++;
      _isChecking = true;

      if (_cards[_selectedIndices[0]] == _cards[_selectedIndices[1]]) {
        // Match found
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            setState(() {
              _matched[_selectedIndices[0]] = true;
              _matched[_selectedIndices[1]] = true;
              _matches++;
              _selectedIndices.clear();
              _isChecking = false;
            });

            if (_matches == _cards.length ~/ 2) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) _showWinDialog();
              });
            }
          }
        });
      } else {
        // No match - flip back after delay
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) {
            setState(() {
              _revealed[_selectedIndices[0]] = false;
              _revealed[_selectedIndices[1]] = false;
              _selectedIndices.clear();
              _isChecking = false;
            });
          }
        });
      }
    }
  }

  void _showWinDialog() {
    int stars = _moves <= 8
        ? 3
        : _moves <= 12
            ? 2
            : 1;
    int xpEarned = stars * 30;
    int coinsEarned = stars * 15;

    Provider.of<EnhancedProgressProvider>(context, listen: false)
        .addXP(xpEarned);
    Provider.of<EnhancedProgressProvider>(context, listen: false)
        .addCoins(coinsEarned);

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
              'You Won!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryRed,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Completed in $_moves moves',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => Icon(
                  i < stars ? Icons.star : Icons.star_border,
                  color: AppTheme.gold,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '+$xpEarned XP  |  +$coinsEarned 🪙',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.success,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _initializeGame();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Match'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.swap_horiz, color: AppTheme.white, size: 20),
                const SizedBox(width: 4),
                Text(
                  '$_moves',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.check_circle_outline,
                    color: AppTheme.gold, size: 20),
                const SizedBox(width: 4),
                Text(
                  '$_matches/${_cards.length ~/ 2}',
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Progress
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _cards.isEmpty
                    ? 0
                    : _matches / (_cards.length ~/ 2),
                backgroundColor: AppTheme.textGray.withOpacity(0.3),
                color: AppTheme.success,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 16),

            // Cards Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final isRevealed = _revealed[index] || _matched[index];

                  return GestureDetector(
                    onTap: () => _onCardTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: _matched[index]
                            ? AppTheme.success.withOpacity(0.15)
                            : isRevealed
                                ? AppTheme.white
                                : AppTheme.primaryRed,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _matched[index]
                              ? AppTheme.success
                              : isRevealed
                                  ? AppTheme.primaryRed
                                  : AppTheme.darkRed,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_matched[index]
                                    ? AppTheme.success
                                    : AppTheme.primaryRed)
                                .withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: isRevealed
                            ? Text(
                                _cards[index],
                                style: TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                  color: _matched[index]
                                      ? AppTheme.success
                                      : AppTheme.primaryRed,
                                ),
                              )
                            : const Icon(
                                Icons.question_mark,
                                size: 36,
                                color: AppTheme.white,
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Restart button
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: TextButton.icon(
                onPressed: _initializeGame,
                icon: const Icon(Icons.refresh, color: AppTheme.primaryRed),
                label: const Text(
                  'Restart',
                  style: TextStyle(color: AppTheme.primaryRed),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
