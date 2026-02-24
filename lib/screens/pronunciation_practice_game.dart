import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../constants/app_theme.dart';
import '../services/game_logic.dart';
import '../services/audio_service.dart';
import '../providers/enhanced_progress_provider.dart';

class PronunciationPracticeGame extends StatefulWidget {
  const PronunciationPracticeGame({super.key});

  @override
  State<PronunciationPracticeGame> createState() => _PronunciationPracticeGameState();
}

class _PronunciationPracticeGameState extends State<PronunciationPracticeGame> {
  final SpeechToText _speechToText = SpeechToText();
  late Map<String, dynamic> _currentRound;
  bool _isListening = false;
  String _recognizedText = '';
  int _score = 0;
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _generateRound();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _generateRound() {
    _currentRound = GameLogic.generatePronunciationRound();
    _recognizedText = '';
    AudioService.playWord(_currentRound['word']);
  }

  void _startListening() async {
    if (!_speechEnabled) return;
    await _speechToText.listen(
      onResult: (result) {
        setState(() => _recognizedText = result.recognizedWords);
        if (_recognizedText.contains(_currentRound['word'])) {
          _score += 20;
          Provider.of<EnhancedProgressProvider>(context, listen: false).addRewards(coins: 15, stars: 2, missionId: 'game_hero');
          _showFeedback(true);
        }
      },
      localeId: 'ta_IN',
    );
    setState(() => _isListening = true);
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
  }

  void _showFeedback(bool correct) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(correct ? Icons.check_circle : Icons.cancel, color: correct ? AppTheme.success : AppTheme.error, size: 80),
              const SizedBox(height: 16),
              Text(
                correct ? 'சரியானது!' : 'மீண்டும் முயற்சிக்கவும்',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: correct ? AppTheme.success : AppTheme.error),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (correct) _generateRound();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pronunciation Practice'),
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryRed.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Text(
                  _currentRound['emoji'] ?? '🎤',
                  style: const TextStyle(fontSize: 80),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                _currentRound['word'],
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.primaryRed),
              ),
              const SizedBox(height: 20),
              Text(
                _currentRound['english'],
                style: const TextStyle(fontSize: 18, color: AppTheme.textGray),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => AudioService.playWord(_currentRound['word']),
                icon: const Icon(Icons.volume_up, size: 32),
                label: const Text('Listen', style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _isListening ? _stopListening : _startListening,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: _isListening ? AppTheme.error : AppTheme.primaryRed,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryRed.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    size: 50,
                    color: AppTheme.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _isListening ? 'Listening...' : 'Tap to speak',
                style: const TextStyle(fontSize: 18, color: AppTheme.textGray),
              ),
              if (_recognizedText.isNotEmpty) ...[
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryRed, width: 2),
                  ),
                  child: Text(
                    'You said: $_recognizedText',
                    style: const TextStyle(fontSize: 18, color: AppTheme.primaryRed),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
