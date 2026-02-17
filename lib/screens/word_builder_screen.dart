import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/tamil_data.dart';
import '../services/audio_service.dart';
import '../providers/progress_provider.dart';

class WordBuilderScreen extends StatefulWidget {
  const WordBuilderScreen({super.key});

  @override
  State<WordBuilderScreen> createState() => _WordBuilderScreenState();
}

class _WordBuilderScreenState extends State<WordBuilderScreen> {
  late Map<String, String> _currentWordData;
  List<String> _jumbledLetters = [];
  List<String?> _slots = [];
  int _currentIndex = 0;
  final List<Map<String, String>> _allWords = [
    {'tamil': 'ஆமை', 'english': 'Tortoise', 'image': 'tortoise_hare_1'},
    {'tamil': 'முயல்', 'english': 'Hare', 'image': 'tortoise_hare_2'},
    {'tamil': 'சிங்கம்', 'english': 'Lion', 'image': 'lion_mouse_1'},
    {'tamil': 'எலி', 'english': 'Mouse', 'image': 'lion_mouse_2'},
  ];

  @override
  void initState() {
    super.initState();
    _loadWord();
  }

  void _loadWord() {
    _currentWordData = _allWords[_currentIndex];
    String word = _currentWordData['tamil']!;
    
    // In Tamil, characters are complex (UirMei). 
    // For simplicity in this demo, we'll treat the string as a list of characters.
    // Note: Real Tamil character splitting is more complex.
    List<String> chars = word.split('');
    _jumbledLetters = List.from(chars)..shuffle();
    _slots = List.filled(chars.length, null);
    setState(() {});
  }

  void _onLetterDrop(int slotIndex, String letter) {
    setState(() {
      _slots[slotIndex] = letter;
      _jumbledLetters.remove(letter);
    });

    if (!_slots.contains(null)) {
      _checkResult();
    }
  }

  void _checkResult() {
    String builtWord = _slots.join('');
    if (builtWord == _currentWordData['tamil']) {
      _showSuccess();
    } else {
      _showFailure();
    }
  }

  void _showSuccess() {
    AudioService.playWord(_currentWordData['tamil']!);
    Provider.of<ProgressProvider>(context, listen: false).addXP(50);
    Provider.of<ProgressProvider>(context, listen: false).addCoins(20);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('சரியானது! (Correct)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/${_currentWordData['image']}.png', height: 100, errorBuilder: (_, __, ___) => const Icon(Icons.star, size: 50)),
            const SizedBox(height: 10),
            Text(_currentWordData['tamil']!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (_currentIndex < _allWords.length - 1) {
                _currentIndex++;
                _loadWord();
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('Next Word'),
          ),
        ],
      ),
    );
  }

  void _showFailure() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Try again!'), backgroundColor: Colors.red),
    );
    _loadWord();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Word Builder')),
      body: Column(
        children: [
          const SizedBox(height: 40),
          // Image / Hint
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Image.asset('assets/images/${_currentWordData['image']}.png', height: 150, errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 100, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Text(_currentWordData['english']!, style: const TextStyle(fontSize: 20, color: Colors.grey)),
                ],
              ),
            ),
          ),
          const Spacer(),
          
          // Result Slots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_slots.length, (index) {
              return DragTarget<String>(
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primaryRed, width: 2),
                    ),
                    child: Center(
                      child: Text(_slots[index] ?? '', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
                onAccept: (data) => _onLetterDrop(index, data),
              );
            }),
          ),
          const SizedBox(height: 40),

          // Jumbled Letters
          Wrap(
            spacing: 15,
            children: _jumbledLetters.map((letter) {
              return Draggable<String>(
                data: letter,
                feedback: _buildLetterCard(letter, isDragging: true),
                childWhenDragging: Opacity(opacity: 0.5, child: _buildLetterCard(letter)),
                child: _buildLetterCard(letter),
              );
            }).toList(),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildLetterCard(String letter, {bool isDragging = false}) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primaryRed,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isDragging ? [BoxShadow(color: Colors.black26, blurRadius: 10)] : null,
        ),
        child: Center(
          child: Text(
            letter,
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
