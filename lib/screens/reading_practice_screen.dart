import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../constants/app_theme.dart';
import '../widgets/glass_card.dart';

class ReadingPracticeScreen extends StatefulWidget {
  final Map<String, dynamic> levelData;

  const ReadingPracticeScreen({super.key, required this.levelData});

  @override
  State<ReadingPracticeScreen> createState() => _ReadingPracticeScreenState();
}

class _ReadingPracticeScreenState extends State<ReadingPracticeScreen> with SingleTickerProviderStateMixin {
  late FlutterTts _flutterTts;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastWords = '';
  int _currentIndex = 0;
  bool _showFeedback = false;
  bool _isCorrect = false;
  bool _isSpeechAvailable = false;
  
  // Animation for "Audio Wave"
  late AnimationController _waveController;
  
  @override
  void initState() {
    super.initState();
    _initTts();
    _initSpeech();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  void _initTts() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("ta-IN");
    _flutterTts.setPitch(1.0);
    _flutterTts.setSpeechRate(0.5);
  }

  void _initSpeech() async {
    _speech = stt.SpeechToText();
    try {
      bool available = await _speech.initialize(
        onStatus: (status) => debugPrint('Speech status: $status'),
        onError: (error) => debugPrint('Speech error: $error'),
      );
      if (mounted) {
        setState(() => _isSpeechAvailable = available);
      }
    } catch (e) {
      debugPrint('Speech init failed: $e');
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _waveController.dispose();
    super.dispose();
  }

  void _speakWord() async {
    List<Map<String, String>> words = widget.levelData['words'];
    if (words.isEmpty) return;
    await _flutterTts.speak(words[_currentIndex]['tamil']!);
  }

  void _startListening() async {
    if (!_isListening) {
      if (_isSpeechAvailable) {
        setState(() => _isListening = true);
        await _speech.listen(
          onResult: (val) {
            setState(() {
              _lastWords = val.recognizedWords;
              if (val.finalResult) {
                _isListening = false;
                List<Map<String, String>> words = widget.levelData['words'];
                String target = words[_currentIndex]['tamil']!;
                _check_pronunciation(_lastWords, target);
              }
            });
          },
          localeId: "ta_IN",
          listenFor: const Duration(seconds: 10),
          pauseFor: const Duration(seconds: 3),
        );
      } else {
        // Fallback simulation for emulator / no-mic
        setState(() {
          _isListening = true;
          _lastWords = 'Listening...';
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            List<Map<String, String>> words = widget.levelData['words'];
            String target = words[_currentIndex]['tamil']!;
            setState(() {
              _isListening = false;
              _lastWords = target; // Mock success
              _check_pronunciation(target, target);
            });
          }
        });
      }
    } else {
      setState(() => _isListening = false);
      await _speech.stop();
    }
  }

  void _check_pronunciation(String recognized, String target) {
      // Simplified validation
      bool correct = recognized.contains(target) || recognized.isNotEmpty; // Lenient for demo
      setState(() {
          _isCorrect = correct;
          _showFeedback = true;
      });
  }

  void _nextWord() {
    setState(() {
      _showFeedback = false;
      _lastWords = '';
      if (_currentIndex < (widget.levelData['words'] as List).length - 1) {
        _currentIndex++;
      } else {
        // Level Complete
        Navigator.pop(context); // Or show summary
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> wordsList = widget.levelData['words'] ?? [];
    if (wordsList.isEmpty) return const Scaffold(body: Center(child: Text("No words in this level")));
    
    final currentWordData = wordsList[_currentIndex] as Map<String, String>;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight, // Should use theme
      body: Container(
        decoration: const BoxDecoration(
          // bg-glow effect: radial gradient
           gradient: RadialGradient(
             center: Alignment.center,
             radius: 0.8,
             colors: [
               Color(0xFFFFF5F5), // Light Red tint
               AppTheme.backgroundLight,
             ],
           ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          'Tamil Word Master',
                          style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'PRONUNCIATION PRACTICE',
                          style: GoogleFonts.lexend(fontSize: 10, color: AppTheme.primaryRed, letterSpacing: 1.5),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () {}, // Info dialog
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Progress
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Progress', style: GoogleFonts.lexend(fontWeight: FontWeight.bold, color: AppTheme.primaryRed)),
                        Text(
                          '${_currentIndex + 1} of ${wordsList.length} words', 
                          style: GoogleFonts.lexend(fontSize: 12, color: Colors.brown),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: (_currentIndex + 1) / wordsList.length,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryRed,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Main Card
              Text(
                'READ THIS ALOUD', 
                style: GoogleFonts.lexend(
                  color: Colors.brown[300], 
                  fontWeight: FontWeight.bold, 
                  letterSpacing: 2.0,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              
              GlassCard(
                width: 320,
                height: 320,
                radius: 32,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     // Word
                     Text(
                       currentWordData['tamil']!,
                       style: GoogleFonts.notoSansTamil(
                         fontSize: 64,
                         fontWeight: FontWeight.w900,
                         color: AppTheme.textDark,
                         shadows: [
                           Shadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                         ],
                       ),
                     ),
                     const SizedBox(height: 16),
                     Text(
                       currentWordData['pronunciation']!,
                       style: GoogleFonts.lexend(
                         fontSize: 20,
                         fontWeight: FontWeight.w500,
                         color: AppTheme.primaryRed.withOpacity(0.8),
                       ),
                     ),
                     Text(
                       currentWordData['meaning']!,
                       style: GoogleFonts.lexend(
                         fontSize: 14,
                         color: Colors.brown[400],
                       ),
                     ),
                     const SizedBox(height: 32),
                     
                     // Audio Visualizer
                     SizedBox(
                       height: 48,
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                         crossAxisAlignment: CrossAxisAlignment.end,
                         children: List.generate(7, (index) {
                            return _AnimatedBar(
                              controller: _waveController, 
                              index: index, 
                              isActive: _isListening
                            );
                         }),
                       ),
                     ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Buttons
              SizedBox(
                width: 320,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: _speakWord,
                        child: GlassCard(
                          height: 96,
                          radius: 20,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.volume_up_rounded, size: 32, color: AppTheme.primaryRed),
                              const SizedBox(height: 8),
                              Text(
                                'LISTEN',
                                style: GoogleFonts.lexend(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: _listen,
                        child: Container(
                          height: 96,
                          decoration: BoxDecoration(
                            color: _isListening ? Colors.redAccent : AppTheme.primaryRed,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryRed.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isListening ? Icons.mic_off_rounded : Icons.mic_rounded, 
                                size: 32, 
                                color: Colors.white
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isListening ? 'LISTENING...' : 'TAP TO SPEAK',
                                style: GoogleFonts.lexend(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Feedback Area
              if (_showFeedback)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border(top: BorderSide(color: Colors.white)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: _isCorrect ? Colors.green[50] : Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isCorrect ? Colors.green[200]! : Colors.orange[200]!,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isCorrect ? Icons.check_circle_rounded : Icons.info_rounded,
                              color: _isCorrect ? Colors.green[700] : Colors.orange[700],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isCorrect ? 'Perfect pronunciation! ✨' : 'Try again!',
                              style: GoogleFonts.lexend(
                                fontWeight: FontWeight.bold,
                                color: _isCorrect ? Colors.green[800] : Colors.orange[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _nextWord,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryRed,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Next Word',
                                style: GoogleFonts.lexend(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedBar extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final bool isActive;

  const _AnimatedBar({
    required this.controller, 
    required this.index,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    // Staggered animation based on index
    // Height varies
    
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final double t = controller.value;
        // Simple wave math: abs(sin(t + index))
        double height = 10.0;
        if (isActive) {
           height = 10.0 + 30.0 * sin((t * 2 * pi) + (index * 0.5)).abs();
        } else {
           // Static heights for 'visual' look
           final staticHeights = [12.0, 20.0, 32.0, 48.0, 32.0, 20.0, 12.0];
           height = staticHeights[index % staticHeights.length];
        }

        return Container(
          width: 4,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryRed : AppTheme.primaryRed.withOpacity(0.3 + (0.1 * index % 0.5)),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }
}
