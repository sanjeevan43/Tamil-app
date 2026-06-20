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
  PronunciationResult? _evaluationResult;

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
    _currentRound = GameLogic.generatePronunciationRound();
    _recognizedText = '';
    _evaluationResult = null;
    AudioService.playWord(_currentRound['word']);
    setState(() {});
  }

  void _startListening() async {
    if (!_speechEnabled) {
      try {
        _speechEnabled = await _speechToText.initialize(
          onError: (val) => debugPrint('STT Error: $val'),
          onStatus: (val) => debugPrint('STT Status: $val'),
        );
      } catch (e) {
        debugPrint('On-demand STT init failed: $e');
        _speechEnabled = false;
      }
    }
    
    if (!_speechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition is not enabled or mic permission denied.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }
    _recognizedText = '';
    _evaluationResult = null;
    setState(() => _isListening = true);

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
        });
        
        if (result.finalResult) {
          _evaluateSpeech(_recognizedText);
        }
      },
      localeId: 'ta_IN',
      listenFor: const Duration(seconds: 5),
      pauseFor: const Duration(seconds: 3),
    );
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
    if (_recognizedText.isNotEmpty) {
      _evaluateSpeech(_recognizedText);
    }
  }

  void _evaluateSpeech(String text) {
    setState(() {
      _isListening = false;
      _evaluationResult = PronunciationEvaluator.evaluate(
        recognized: text,
        expected: _currentRound['word'],
      );

      if (_evaluationResult!.isCorrect) {
        _score += 20;
        Provider.of<EnhancedProgressProvider>(context, listen: false)
            .addRewards(coins: 15, stars: 2, missionId: 'game_hero');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Pronunciation Practice', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Main Word Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                decoration: AppTheme.whiteCard(radius: 28),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _currentRound['emoji'] ?? '🎤',
                        style: const TextStyle(fontSize: 64),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _currentRound['word'],
                      style: GoogleFonts.notoSansTamil(fontSize: 38, fontWeight: FontWeight.bold, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentRound['english'],
                      style: GoogleFonts.outfit(fontSize: 20, color: AppTheme.textSlate, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => AudioService.playWord(_currentRound['word']),
                      icon: const Icon(Icons.volume_up_rounded, color: Colors.white),
                      label: Text('LISTEN', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Speech Feedback Panel
              if (_evaluationResult != null) _buildResultPanel(),

              const SizedBox(height: 32),

              // Recording Button
              GestureDetector(
                onTap: _isListening ? _stopListening : _startListening,
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: _isListening ? AppTheme.error : AppTheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening ? AppTheme.error : AppTheme.primary).withOpacity(0.35),
                            blurRadius: _isListening ? 25 : 15,
                            spreadRadius: _isListening ? 6 : 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.stop_rounded : Icons.mic_none_rounded,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isListening ? 'Listening... Tap to stop' : 'Tap to speak',
                      style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textSlate, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Navigation Buttons
              if (_evaluationResult != null && _evaluationResult!.isCorrect)
                ElevatedButton.icon(
                  onPressed: _generateRound,
                  icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                  label: Text('NEXT WORD', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultPanel() {
    final result = _evaluationResult!;
    final matchPercentage = result.matchPercentage.toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: result.isCorrect ? AppTheme.success.withOpacity(0.3) : AppTheme.error.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                result.isCorrect ? '✅ Correct Pronunciation' : '❌ Incorrect Pronunciation',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: result.isCorrect ? AppTheme.success : AppTheme.error,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (result.isCorrect ? AppTheme.success : AppTheme.error).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$matchPercentage% Match',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: result.isCorrect ? AppTheme.success : AppTheme.error,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Text(
            'Expected: ${_currentRound['word']}',
            style: GoogleFonts.notoSansTamil(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSlate,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Recognized: ${result.recognizedText.isEmpty ? "(No voice detected)" : result.recognizedText}',
            style: GoogleFonts.notoSansTamil(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: result.isCorrect ? AppTheme.textDark : AppTheme.error,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.topoLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              result.suggestion,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
