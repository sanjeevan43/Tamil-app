import 'dart:math';
import 'package:flutter/material.dart';
import 'package:characters/characters.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';
import '../services/game_logic.dart';

class WordSearchGame extends StatefulWidget {
  final String difficulty;
  const WordSearchGame({super.key, this.difficulty = 'Easy'});

  @override
  State<WordSearchGame> createState() => _WordSearchGameState();
}

class _WordSearchGameState extends State<WordSearchGame> {
  int gridSize = 8;
  List<String> _wordsToFind = [];
  final List<String> _fillerLetters = ['க்', 'ங்', 'ச்', 'ஞ்', 'ட்', 'ண்', 'த்', 'ந்', 'ப்', 'ம்', 'ய்', 'ர்', 'அ', 'ஆ', 'இ', 'ஈ', 'உ', 'ஊ'];
  
  late List<List<String>> _grid;
  final List<Offset> _selectedIndices = [];
  final Set<String> _foundWords = {};

  @override
  void initState() {
    super.initState();
    _generateGrid();
  }

  List<String> _splitTamil(String word) {
    return word.characters.toList();
  }

  void _generateGrid() {
    final searchRound = GameLogic.generateWordSearchRound(difficulty: widget.difficulty);
    gridSize = searchRound['gridSize'] as int;
    final wordsData = searchRound['words'] as List;
    _wordsToFind = wordsData.map((w) => w['tamil'] as String).toList();
    _foundWords.clear();
    _selectedIndices.clear();

    _grid = List.generate(gridSize, (_) => List.generate(gridSize, (_) {
      return _fillerLetters[Random().nextInt(_fillerLetters.length)];
    }));

    for (String word in _wordsToFind) {
      _placeWord(word);
    }
    setState(() {});
  }

  void _placeWord(String word) {
    Random rand = Random();
    bool placed = false;
    int attempts = 0;

    List<String> chars = _splitTamil(word);

    while (!placed && attempts < 100) {
      int row = rand.nextInt(gridSize);
      int col = rand.nextInt(gridSize);
      int direction = rand.nextInt(2); // 0: Horizontal, 1: Vertical

      if (direction == 0) { // Horizontal
        if (col + chars.length <= gridSize) {
          bool canPlace = true;
          for (int i = 0; i < chars.length; i++) {
            if (_grid[row][col + i].length > 2) {
              // already has a word character placed
            }
          }
          if (canPlace) {
            for (int i = 0; i < chars.length; i++) {
              _grid[row][col + i] = chars[i];
            }
            placed = true;
          }
        }
      } else { // Vertical
        if (row + chars.length <= gridSize) {
          bool canPlace = true;
          if (canPlace) {
            for (int i = 0; i < chars.length; i++) {
              _grid[row + i][col] = chars[i];
            }
            placed = true;
          }
        }
      }
      attempts++;
    }
  }

  void _onCellTap(int r, int c) {
    Offset pos = Offset(r.toDouble(), c.toDouble());
    setState(() {
      if (_selectedIndices.contains(pos)) {
        _selectedIndices.remove(pos);
      } else {
        _selectedIndices.add(pos);
      }
      _checkSelection();
    });
  }

  void _checkSelection() {
    String selectedWord = _selectedIndices.map((o) => _grid[o.dx.toInt()][o.dy.toInt()]).join('');
    String reversedWord = selectedWord.characters.toList().reversed.join('');

    if (_wordsToFind.contains(selectedWord) && !_foundWords.contains(selectedWord)) {
      _onWordFound(selectedWord);
    } else if (_wordsToFind.contains(reversedWord) && !_foundWords.contains(reversedWord)) {
      _onWordFound(reversedWord);
    }
  }

  void _onWordFound(String word) {
    setState(() {
      _foundWords.add(word);
      _selectedIndices.clear();
    });

    if (_foundWords.length == _wordsToFind.length) {
      _showWinDialog();
    }
  }

  void _showWinDialog() {
    final progress = Provider.of<EnhancedProgressProvider>(context, listen: false);
    progress.addRewards(coins: 50, stars: 10, missionId: 'game_hero');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Center(child: Text('🏆 Victory! 🏆', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('You found all the Tamil words!', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _rewardBadge('💰', '+50'),
                const SizedBox(width: 24),
                _rewardBadge('⭐', '+10'),
              ],
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('BACK TO HUB'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _rewardBadge(String emoji, String val) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        Text(val, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.textDark)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Word Search (${widget.difficulty})', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(onPressed: _generateGrid, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildWordList(),
            const SizedBox(height: 32),
            Expanded(
              child: Container(
                decoration: AppTheme.whiteCard(radius: 28),
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: gridSize * gridSize,
                  itemBuilder: (context, index) {
                    int r = index ~/ gridSize;
                    int c = index % gridSize;
                    bool isSelected = _selectedIndices.contains(Offset(r.toDouble(), c.toDouble()));
                    
                    return GestureDetector(
                      onTap: () => _onCellTap(r, c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primary : AppTheme.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppTheme.primary : AppTheme.borderLight,
                          ),
                          boxShadow: isSelected ? [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 8)] : [],
                        ),
                        child: Center(
                          child: Text(
                            _grid[r][c],
                            style: GoogleFonts.notoSansTamil(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppTheme.white : AppTheme.textDark,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('TAP LETTERS IN ORDER TO SELECT A WORD', 
                 style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textSlate.withOpacity(0.4), letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildWordList() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: _wordsToFind.map((word) {
        bool found = _foundWords.contains(word);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: found ? AppTheme.success.withOpacity(0.1) : AppTheme.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: found ? AppTheme.success : AppTheme.borderLight),
          ),
          child: Text(
            word,
            style: GoogleFonts.notoSansTamil(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: found ? AppTheme.success : AppTheme.textSlate,
              decoration: found ? TextDecoration.lineThrough : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
