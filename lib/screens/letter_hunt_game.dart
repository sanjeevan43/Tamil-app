import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../constants/app_theme.dart';
import '../constants/tamil_data.dart';
import '../services/audio_service.dart';
import '../providers/enhanced_progress_provider.dart';

class LetterHuntGame extends StatefulWidget {
  const LetterHuntGame({super.key});

  @override
  State<LetterHuntGame> createState() => _LetterHuntGameState();
}

class _LetterHuntGameState extends State<LetterHuntGame> {
  String _targetLetter = '';
  List<String> _options = [];
  int _score = 0;
  int _round = 1;
  final int _maxRounds = 10;

  @override
  void initState() {
    super.initState();
    _generateRound();
  }

  void _generateRound() {
    final random = Random();
    _targetLetter = TamilData.uyirEzhuthukkal[random.nextInt(TamilData.uyirEzhuthukkal.length)];
    
    _options = [_targetLetter];
    while (_options.length < 6) {
      final letter = TamilData.uyirEzhuthukkal[random.nextInt(TamilData.uyirEzhuthukkal.length)];
      if (!_options.contains(letter)) {
        _options.add(letter);
      }
    }
    _options.shuffle();
    
    AudioService.playLetter(_targetLetter);
  }

  void _checkAnswer(String selected) {
    if (selected == _targetLetter) {
      setState(() {
        _score += 10;
        if (_round < _maxRounds) {
          _round++;
          _generateRound();
        } else {
          _showResults();
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Try again!'),
          duration: Duration(seconds: 1),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  void _showResults() {
    Provider.of<EnhancedProgressProvider>(context, listen: false).addQuizScore(_score);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            const Text(
              'Game Complete!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryRed),
            ),
            const SizedBox(height: 16),
            Text('Score: $_score/${_maxRounds * 10}', style: const TextStyle(fontSize: 20)),
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
                      _generateRound();
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Letter Hunt'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.star, color: AppTheme.gold),
                Text(' $_score', style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.premiumCard(),
              child: Column(
                children: [
                  Text(
                    'Round $_round/$_maxRounds',
                    style: const TextStyle(fontSize: 18, color: AppTheme.white),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Find this letter:',
                    style: TextStyle(fontSize: 20, color: AppTheme.white),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _targetLetter,
                        style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: AppTheme.white),
                      ),
                      IconButton(
                        onPressed: () => AudioService.playLetter(_targetLetter),
                        icon: const Icon(Icons.volume_up, color: AppTheme.white, size: 32),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _options.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _checkAnswer(_options[index]),
                    child: Container(
                      decoration: AppTheme.gameCard(),
                      child: Center(
                        child: Text(
                          _options[index],
                          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.primaryRed),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
