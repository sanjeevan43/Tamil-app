import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';

class SoundMatchGame extends StatefulWidget {
  const SoundMatchGame({super.key});

  @override
  State<SoundMatchGame> createState() => _SoundMatchGameState();
}

class _SoundMatchGameState extends State<SoundMatchGame> {
  final FlutterTts _flutterTts = FlutterTts();
  
  final List<Map<String, dynamic>> _data = [
    {'correct': 'அ', 'options': ['அ', 'ஆ', 'இ', 'ஈ']},
    {'correct': 'கா', 'options': ['க', 'கா', 'கி', 'கீ']},
    {'correct': 'பந்து', 'options': ['பந்து', 'மலர்', 'யானை', 'மயில்']},
    {'correct': 'அம்மா', 'options': ['அப்பா', 'அம்மா', 'தம்பி', 'தங்கை']},
    {'correct': 'மரம்', 'options': ['கரம்', 'சரம்', 'மரம்', 'வரம்']},
  ];

  int _currentIndex = 0;
  bool _isPlaying = false;
  String? _selectedOption;
  bool? _isCorrect;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    await _flutterTts.setLanguage('ta-IN');
    await _flutterTts.setSpeechRate(0.5);
    _playSound();
  }

  Future<void> _playSound() async {
    setState(() => _isPlaying = true);
    await _flutterTts.speak(_data[_currentIndex]['correct']);
    setState(() => _isPlaying = false);
  }

  void _checkAnswer(String option) {
    if (_isCorrect != null) return;
    
    setState(() {
      _selectedOption = option;
      _isCorrect = option == _data[_currentIndex]['correct'];
    });

    if (_isCorrect!) {
      final progress = Provider.of<EnhancedProgressProvider>(context, listen: false);
      progress.addRewards(coins: 15, stars: 3, missionId: 'game_hero');
      
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % _data.length;
            _selectedOption = null;
            _isCorrect = null;
            _playSound();
          });
        }
      });
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _selectedOption = null;
            _isCorrect = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Sound Match', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Listen Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                decoration: AppTheme.whiteCard(radius: 28),
                child: Column(
                  children: [
                    Text('LISTEN CAREFULLY', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textSlate.withOpacity(0.4), letterSpacing: 2)),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _isPlaying ? null : _playSound,
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.05),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primary.withOpacity(0.1), width: 2),
                        ),
                        child: Icon(
                          _isPlaying ? Icons.volume_up_rounded : Icons.play_arrow_rounded,
                          size: 64,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text('WHICH ONE DID YOU HEAR?', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textSlate.withOpacity(0.4), letterSpacing: 2)),
              const SizedBox(height: 24),
              // Options Grid
              Expanded(
                flex: 4,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    final option = _data[_currentIndex]['options'][index];
                    bool isThisSelected = _selectedOption == option;
                    Color cardColor = AppTheme.white;
                    Color textColor = AppTheme.textDark;
                    
                    if (isThisSelected) {
                      cardColor = _isCorrect! ? AppTheme.success : AppTheme.error;
                      textColor = AppTheme.white;
                    }

                    return GestureDetector(
                      onTap: () => _checkAnswer(option),
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: isThisSelected ? cardColor.withOpacity(0.3) : AppTheme.textDark.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(
                            color: isThisSelected ? Colors.transparent : AppTheme.borderLight,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            option,
                            style: GoogleFonts.notoSansTamil(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
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
      ),
    );
  }
}
