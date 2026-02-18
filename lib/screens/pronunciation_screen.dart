import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../services/audio_service.dart';
import '../providers/enhanced_progress_provider.dart';

class PronunciationScreen extends StatefulWidget {
  const PronunciationScreen({super.key});

  @override
  State<PronunciationScreen> createState() => _PronunciationScreenState();
}

class _PronunciationScreenState extends State<PronunciationScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  
  int _currentIndex = 0;
  final List<Map<String, String>> _words = [
    {'tamil': 'அம்மா', 'english': 'Mother'},
    {'tamil': 'அப்பா', 'english': 'Father'},
    {'tamil': 'பள்ளி', 'english': 'School'},
    {'tamil': 'புத்தகம்', 'english': 'Book'},
    {'tamil': 'தமிழ்', 'english': 'Tamil'},
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {},
        onError: (val) {},
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            _checkPronunciation();
          }),
          localeId: 'ta-IN', // Tamil locale
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _checkPronunciation() {
    String target = _words[_currentIndex]['tamil']!;
    // Clean strings for comparison
    String spoken = _text.replaceAll(' ', '').trim();
    
    if (spoken.contains(target)) {
      _showResult(true);
      Provider.of<EnhancedProgressProvider>(context, listen: false).addXP(10);
    }
  }

  void _showResult(bool correct) {
    if (!correct) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('அற்புதம்! Correct Pronunciation!'),
        backgroundColor: AppTheme.success,
        duration: const Duration(seconds: 2),
      ),
    );
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _words.length;
          _text = 'Press the button and start speaking';
          _isListening = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final word = _words[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('உச்சரிப்பு (Pronunciation)'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            'சரியாகச் சொல்லுங்கள் (Say it correctly):',
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(40),
            decoration: AppTheme.premiumCard(),
            child: Column(
              children: [
                Text(
                  word['tamil']!,
                  style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  word['english']!,
                  style: const TextStyle(fontSize: 24, color: Colors.white70),
                ),
                const SizedBox(height: 20),
                IconButton(
                  onPressed: () => AudioService.playWord(word['tamil']!),
                  icon: const Icon(Icons.volume_up, color: Colors.white, size: 40),
                ),
              ],
            ),
          ),
          const Expanded(child: SizedBox()),
          Container(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Text(
                  _text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    color: _isListening ? AppTheme.primaryRed : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: _listen,
                  child: Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      color: _isListening ? Colors.redAccent : AppTheme.primaryRed,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening ? Colors.red : AppTheme.primaryRed).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 45,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _isListening ? 'Listening...' : 'Tap to speak',
                  style: TextStyle(color: _isListening ? Colors.red : Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
