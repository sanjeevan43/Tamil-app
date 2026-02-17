import 'package:flutter/material.dart';
import 'dart:math';
import '../constants/app_theme.dart';
import '../constants/tamil_data.dart';
import '../services/audio_service.dart';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  List<String> _cards = [];
  List<bool> _revealed = [];
  List<int> _selectedIndices = [];
  int _matches = 0;
  int _moves = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    final letters = TamilData.uyirEzhuthukkal.take(6).toList();
    _cards = [...letters, ...letters];
    _cards.shuffle(Random());
    _revealed = List.filled(_cards.length, false);
    _selectedIndices = [];
    _matches = 0;
    _moves = 0;
  }

  void _onCardTap(int index) {
    if (_revealed[index] || _selectedIndices.length >= 2) return;

    setState(() {
      _revealed[index] = true;
      _selectedIndices.add(index);
    });

    AudioService.playLetter(_cards[index]);

    if (_selectedIndices.length == 2) {
      _moves++;
      if (_cards[_selectedIndices[0]] == _cards[_selectedIndices[1]]) {
        _matches++;
        _selectedIndices.clear();
        if (_matches == _cards.length ~/ 2) {
          _showWinDialog();
        }
      } else {
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            _revealed[_selectedIndices[0]] = false;
            _revealed[_selectedIndices[1]] = false;
            _selectedIndices.clear();
          });
        });
      }
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: AppTheme.warning, size: 80),
            const SizedBox(height: 16),
            const Text('வெற்றி!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryRed)),
            const SizedBox(height: 16),
            Text('Moves: $_moves', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _initializeGame());
              },
              child: const Text('Play Again'),
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
            padding: const EdgeInsets.all(16),
            child: Text('Moves: $_moves', style: const TextStyle(fontSize: 18)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _cards.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _onCardTap(index),
              child: Container(
                decoration: BoxDecoration(
                  color: _revealed[index] ? AppTheme.white : AppTheme.primaryRed,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryRed, width: 3),
                ),
                child: Center(
                  child: Text(
                    _revealed[index] ? _cards[index] : '?',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _revealed[index] ? AppTheme.primaryRed : AppTheme.white,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
