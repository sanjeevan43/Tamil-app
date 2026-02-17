import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/tamil_data.dart';
import '../services/audio_service.dart';
import '../providers/progress_provider.dart';

class LetterHuntScreen extends StatefulWidget {
  const LetterHuntScreen({super.key});

  @override
  State<LetterHuntScreen> createState() => _LetterHuntScreenState();
}

class _LetterHuntScreenState extends State<LetterHuntScreen> with SingleTickerProviderStateMixin {
  late String _targetLetter;
  List<_FallingLetter> _fallingLetters = [];
  int _score = 0;
  int _lives = 3;
  bool _isPlaying = false;
  Timer? _gameTimer;
  Timer? _spawnTimer;
  Random _random = Random();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _controller.repeat();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      _score = 0;
      _lives = 3;
      _isPlaying = true;
      _fallingLetters = [];
    });
    _setNewTarget();
    _startGameTimers();
  }

  void _setNewTarget() {
    _targetLetter = TamilData.uyirEzhuthukkal[_random.nextInt(TamilData.uyirEzhuthukkal.length)];
    AudioService.playLetter(_targetLetter);
  }

  void _startGameTimers() {
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (_isPlaying) {
        _spawnLetter();
      }
    });

    _gameTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_isPlaying) {
        _updatePhysics();
      }
    });
  }

  void _spawnLetter() {
    final isTarget = _random.nextDouble() < 0.3;
    String letter;
    if (isTarget) {
      letter = _targetLetter;
    } else {
      letter = TamilData.uyirEzhuthukkal[_random.nextInt(TamilData.uyirEzhuthukkal.length)];
    }

    setState(() {
      _fallingLetters.add(_FallingLetter(
        letter: letter,
        x: _random.nextDouble() * 0.8 + 0.1,
        y: -0.1,
        speed: _random.nextDouble() * 0.01 + 0.005,
      ));
    });
  }

  void _updatePhysics() {
    setState(() {
      for (var letter in _fallingLetters) {
        letter.y += letter.speed;
      }

      // Check if target letter fell off screen
      final missedTarget = _fallingLetters.any((l) => l.y > 1.1 && l.letter == _targetLetter);
      if (missedTarget) {
        _lives--;
        if (_lives <= 0) _gameOver();
      }

      _fallingLetters.removeWhere((l) => l.y > 1.1);
    });
  }

  void _onLetterTap(_FallingLetter letter) {
    if (!_isPlaying) return;

    if (letter.letter == _targetLetter) {
      setState(() {
        _score += 10;
        _fallingLetters.remove(letter);
        _setNewTarget();
      });
    } else {
      setState(() {
        _lives--;
        _fallingLetters.remove(letter);
        if (_lives <= 0) _gameOver();
      });
    }
  }

  void _gameOver() {
    setState(() {
      _isPlaying = false;
    });
    _spawnTimer?.cancel();
    _gameTimer?.cancel();

    Provider.of<ProgressProvider>(context, listen: false).addXP(_score);
    Provider.of<ProgressProvider>(context, listen: false).addCoins(_score ~/ 5);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over!'),
        content: Text('Score: $_score\nXP Earned: $_score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startNewGame();
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    _gameTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryRed, AppColors.darkRed],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Stats Header
              Positioned(
                top: 20,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatChip(Icons.stars, '$_score', Colors.amber),
                    _buildTargetDisplay(),
                    _buildStatChip(Icons.favorite, '$_lives', Colors.redAccent),
                  ],
                ),
              ),

              // Falling Letters
              ..._fallingLetters.map((letter) => Positioned(
                    left: MediaQuery.of(context).size.width * letter.x - 30,
                    top: MediaQuery.of(context).size.height * letter.y,
                    child: GestureDetector(
                      onTap: () => _onLetterTap(letter),
                      child: _buildLetterBubble(letter.letter),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildTargetDisplay() {
    return Column(
      children: [
        const Text('FIND', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        Text(
          _targetLetter,
          style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildLetterBubble(String letter) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _FallingLetter {
  String letter;
  double x;
  double y;
  double speed;

  _FallingLetter({required this.letter, required this.x, required this.y, required this.speed});
}
