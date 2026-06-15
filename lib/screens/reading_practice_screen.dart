import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';

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
    try {
      _flutterTts.setLanguage('ta-IN');
      _flutterTts.setPitch(1.0);
      _flutterTts.setSpeechRate(0.5);
    } catch (e) {
      debugPrint('ReadingPracticeScreen TTS Init Error: $e');
    }
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
      // Intentionally silent
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _waveController.dispose();
    super.dispose();
  }

  void _speakWord() async {
    List<dynamic> wordsList = widget.levelData['words'] ?? [];
    if (wordsList.isEmpty) return;
    await _flutterTts.speak(wordsList[_currentIndex]['tamil']!);
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
                List<dynamic> wordsList = widget.levelData['words'];
                String target = wordsList[_currentIndex]['tamil']!;
                _checkPronunciation(_lastWords, target);
              }
            });
          },
          localeId: 'ta_IN',
          listenFor: const Duration(seconds: 10),
          pauseFor: const Duration(seconds: 3),
        );
      } else {
        setState(() {
          _isListening = true;
          _lastWords = 'Listening...';
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            List<dynamic> wordsList = widget.levelData['words'];
            String target = wordsList[_currentIndex]['tamil']!;
            setState(() {
              _isListening = false;
              _lastWords = target;
              _checkPronunciation(target, target);
            });
          }
        });
      }
    } else {
      setState(() => _isListening = false);
      await _speech.stop();
    }
  }

  void _checkPronunciation(String recognized, String target) {
      bool correct = recognized.contains(target) || recognized.isNotEmpty; 
      setState(() {
          _isCorrect = correct;
          _showFeedback = true;
      });
  }

  void _nextWord() {
    final progress = Provider.of<EnhancedProgressProvider>(context, listen: false);
    List<dynamic> wordsList = widget.levelData['words'] ?? [];
    
    if (_currentIndex < wordsList.length - 1) {
      setState(() {
        _currentIndex++;
        _showFeedback = false;
        _lastWords = '';
      });
      int p = (((_currentIndex) / wordsList.length) * 100).toInt();
      progress.updateLessonProgress(widget.levelData['id'], p);
      
      // Award small reward for each word
      progress.addRewards(coins: 5, stars: 1);
    } else {
      progress.updateLessonProgress(widget.levelData['id'], 100);
      
      // Award completion reward
      progress.addRewards(coins: 100, stars: 20, missionId: 'letter_pro');
      
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars_rounded, color: AppTheme.warning, size: 80),
            const SizedBox(height: 16),
            Text(
              'EXCELLENT!',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12, color: AppTheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              'Module Completed',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Dialog
                  Navigator.pop(context); // Screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('CONTINUE', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppTheme.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> wordsList = widget.levelData['words'] ?? [];
    if (wordsList.isEmpty) return const Scaffold(body: Center(child: Text('No words in this level')));
    
    final currentWordData = wordsList[_currentIndex] as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Container(
        decoration: BoxDecoration(
           gradient: RadialGradient(
             center: Alignment.center,
             radius: 1.0,
             colors: [
               AppTheme.primary.withOpacity(0.04),
               AppTheme.backgroundLight,
             ],
           ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildProgressBar(wordsList.length),
              const Spacer(),
              _buildContent(currentWordData),
              const Spacer(),
              _buildActionButtons(),
              const SizedBox(height: 40),
              if (_showFeedback) _buildFeedbackArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              side: const BorderSide(color: AppTheme.borderLight),
            ),
          ),
          Column(
            children: [
              Text(
                'MASTERY SESSION',
                style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.primary, letterSpacing: 1.5),
              ),
              Text(
                widget.levelData['title'],
                style: GoogleFonts.notoSansTamil(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(width: 48), // Spacer for balance
        ],
      ),
    );
  }

  Widget _buildProgressBar(int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROGRESS', 
                style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textSlate)
              ),
              Text(
                '${_currentIndex + 1} OF $total', 
                style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / total,
              minHeight: 8,
              backgroundColor: AppTheme.primary.withOpacity(0.08),
              valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> word) {
    return Column(
      children: [
        Text(
          'SPEAK CLEARLY', 
          style: GoogleFonts.outfit(
            color: AppTheme.textSlate, 
            fontWeight: FontWeight.w900, 
            letterSpacing: 2.0,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: 320,
          padding: const EdgeInsets.all(40),
          decoration: AppTheme.whiteCard(radius: 40),
          child: Column(
            children: [
               Text(
                 word['tamil']!,
                 style: GoogleFonts.notoSansTamil(
                   fontSize: 60,
                   fontWeight: FontWeight.bold,
                   color: AppTheme.primary,
                 ),
               ),
               const SizedBox(height: 16),
               Text(
                 word['pronunciation']!,
                 style: GoogleFonts.outfit(
                   fontSize: 22,
                   fontWeight: FontWeight.w600,
                   color: AppTheme.textSlate,
                 ),
               ),
               Text(
                 word['meaning']!,
                 style: GoogleFonts.outfit(
                   fontSize: 16,
                   color: AppTheme.textGray,
                 ),
               ),
               const SizedBox(height: 40),
               SizedBox(
                 height: 40,
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.center,
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
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: _speakWord,
              child: Container(
                height: 80,
                decoration: AppTheme.whiteCard(radius: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.volume_up_rounded, size: 28, color: AppTheme.primary),
                    Text(
                      'LISTEN',
                      style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.primary),
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
              onTap: _startListening,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isListening 
                      ? [AppTheme.primary, AppTheme.primary] 
                      : [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_isListening ? Icons.mic_off_rounded : Icons.mic_rounded, color: AppTheme.white, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      _isListening ? 'LISTENING...' : 'TAP TO RECORD',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: AppTheme.textDark.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, -10))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: _isCorrect ? AppTheme.success.withOpacity(0.08) : AppTheme.warning.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  _isCorrect ? Icons.check_circle_rounded : Icons.priority_high_rounded,
                  color: _isCorrect ? AppTheme.success : AppTheme.warning,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isCorrect ? 'Stunning! Perfect pronunciation.' : 'Close! Let\'s try that again.',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: _isCorrect ? AppTheme.success : AppTheme.warning, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _nextWord,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('CONTINUE', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.white)),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_rounded, color: AppTheme.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedBar extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final bool isActive;

  const _AnimatedBar({required this.controller, required this.index, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final double t = controller.value;
        double height = 8.0;
        if (isActive) {
           height = 8.0 + 24.0 * sin((t * 2 * pi) + (index * 0.5)).abs();
        } else {
           final staticHeights = [8.0, 14.0, 22.0, 32.0, 22.0, 14.0, 8.0];
           height = staticHeights[index % staticHeights.length];
        }

        return Container(
          width: 5,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary : AppTheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      },
    );
  }
}
