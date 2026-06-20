import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../constants/app_theme.dart';
import '../services/game_logic.dart';
import '../services/audio_service.dart';
import '../services/pronunciation_evaluator.dart';
import '../providers/enhanced_progress_provider.dart';

class PronunciationPracticeGame extends StatefulWidget {
  final String difficulty;
  const PronunciationPracticeGame({super.key, this.difficulty = 'Easy'});

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
  int _round = 1;
  final int _maxRounds = 8;
  
  double _matchPercentage = 0.0;
  bool _hasEvaluated = false;
  bool _isCorrect = false;
  String _feedbackMessage = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _generateRound();
  }

  void _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (val) => debugPrint('STT Error: $val'),
        onStatus: (val) => debugPrint('STT Status: $val'),
      );
    } catch (e) {
      debugPrint('Speech initialization failed: $e');
      _speechEnabled = false;
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _generateRound() {
    _currentRound = GameLogic.generatePronunciationRound(difficulty: widget.difficulty);
    _recognizedText = '';
    _matchPercentage = 0.0;
    _hasEvaluated = false;
    _isCorrect = false;
    _feedbackMessage = '';
    setState(() {});
    AudioService.playWord(_currentRound['word']);
  }

  void _startListening() async {
    if (!_speechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition is not enabled or supported on this device.')),
      );
      return;
    }
    
    _recognizedText = '';
    _hasEvaluated = false;
    setState(() => _isListening = true);

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
        });
        if (result.finalResult) {
          _stopListeningAndEvaluate();
        }
      },
      localeId: 'ta_IN',
      listenFor: const Duration(seconds: 8),
      pauseFor: const Duration(seconds: 3),
    );
  }

  void _stopListeningAndEvaluate() async {
    await _speechToText.stop();
    if (!mounted) return;
    
    setState(() {
      _isListening = false;
      _hasEvaluated = true;
    });

    final evaluation = PronunciationEvaluator.evaluate(_currentRound['word'], _recognizedText);
    
    setState(() {
      _matchPercentage = evaluation['matchPercentage'] as double;
      _isCorrect = evaluation['isCorrect'] as bool;
      _feedbackMessage = evaluation['feedback'] as String;
    });

    if (_isCorrect) {
      _score += 25;
      Provider.of<EnhancedProgressProvider>(context, listen: false).addRewards(coins: 15, stars: 2, missionId: 'game_hero');
      _showFeedbackDialog(true);
    } else {
      _showFeedbackDialog(false);
    }
  }

  void _showFeedbackDialog(bool correct) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (correct ? AppTheme.success : AppTheme.error).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                correct ? Icons.check_circle : Icons.error,
                color: correct ? AppTheme.success : AppTheme.error,
                size: 64,
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              '${_matchPercentage.toStringAsFixed(1)}% Match',
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: correct ? AppTheme.success : AppTheme.error,
              ),
            ),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.topoLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.topoSilver),
              ),
              child: Column(
                children: [
                  Text(
                    'Expected / இலக்கு:',
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textGray),
                  ),
                  Text(
                    _currentRound['word'],
                    style: GoogleFonts.notoSansTamil(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const Divider(height: 16),
                  Text(
                    'You said / நீங்கள் கூறியது:',
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textGray),
                  ),
                  Text(
                    _recognizedText.isEmpty ? '(No speech detected)' : _recognizedText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSansTamil(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryRed),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              _feedbackMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSlate, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              if (!correct)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _generateRound();
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('Retry', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  ),
                ),
              if (!correct) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (_round < _maxRounds) {
                      setState(() => _round++);
                      _generateRound();
                    } else {
                      _showFinalResults();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: correct ? AppTheme.primary : AppTheme.textGray,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    _round < _maxRounds ? 'Next' : 'Results',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFinalResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: AppTheme.warning, size: 80),
            const SizedBox(height: 16),
            const Text(
              'Game Complete!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryRed,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Score: $_score/${_maxRounds * 25}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
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
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Pronunciation (${widget.difficulty})', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
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
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _round / _maxRounds,
                  backgroundColor: AppTheme.textGray.withOpacity(0.3),
                  color: AppTheme.primaryRed,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Round $_round/$_maxRounds',
                style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textGray, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withOpacity(0.08),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryRed.withOpacity(0.15), width: 2),
                ),
                child: Center(
                  child: Text(
                    _currentRound['emoji'] ?? '🎤',
                    style: const TextStyle(fontSize: 64),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                _currentRound['word'],
                style: GoogleFonts.notoSansTamil(fontSize: 42, fontWeight: FontWeight.bold, color: AppTheme.primaryRed),
              ),
              const SizedBox(height: 8),
              
              Text(
                _currentRound['english'],
                style: GoogleFonts.outfit(fontSize: 20, color: AppTheme.textSlate, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              
              ElevatedButton.icon(
                onPressed: () => AudioService.playWord(_currentRound['word']),
                icon: const Icon(Icons.volume_up, size: 24, color: Colors.white),
                label: Text('Listen / கேளுங்கள்', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 32),
              
              GestureDetector(
                onTap: _isListening ? _stopListeningAndEvaluate : _startListening,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: _isListening ? AppTheme.error : AppTheme.primaryRed,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isListening ? AppTheme.error : AppTheme.primaryRed).withOpacity(0.35),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    size: 56,
                    color: AppTheme.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isListening ? 'Listening... Speak now!' : 'Tap Mic to Speak / பேசவும்',
                style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textGray, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
