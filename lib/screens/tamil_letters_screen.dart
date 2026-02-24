import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../constants/tamil_data.dart';
import '../services/audio_service.dart';
import '../providers/enhanced_progress_provider.dart';
import '../widgets/safe_image.dart';

class TamilLettersScreen extends StatefulWidget {
  const TamilLettersScreen({super.key});

  @override
  State<TamilLettersScreen> createState() => _TamilLettersScreenState();
}

class _TamilLettersScreenState extends State<TamilLettersScreen> {
  int _currentIndex = 0;
  final List<String> _letters = TamilData.uyirEzhuthukkal;
  
  final Map<String, Map<String, String>> _examples = {
    'அ': {'tamil': 'அம்மா', 'english': 'Amma (Mother)', 'desc': 'A - sounds like "Up"', 'image': 'amma'},
    'ஆ': {'tamil': 'ஆடு', 'english': 'Aadu (Goat)', 'desc': 'Aa - sounds like "Art"', 'image': 'aadu'},
    'இ': {'tamil': 'இலை', 'english': 'Ilai (Leaf)', 'desc': 'E - sounds like "Ink"', 'image': 'ilai'},
    'ஈ': {'tamil': 'ஈட்டி', 'english': 'Eetti (Spear)', 'desc': 'Ee - sounds like "Eel"', 'image': 'eetti'},
    'உ': {'tamil': 'உலகு', 'english': 'Ulagu (World)', 'desc': 'U - sounds like "Put"', 'image': 'ulagu'},
    'ஊ': {'tamil': 'ஊஞ்சல்', 'english': 'Oonjal (Swing)', 'desc': 'Oo - sounds like "Pool"', 'image': 'oonjal'},
    'எ': {'tamil': 'எலி', 'english': 'Eli (Rat)', 'desc': 'E - sounds like "Elephant"', 'image': 'eli'},
    'ஏ': {'tamil': 'ஏணி', 'english': 'Eni (Ladder)', 'desc': 'AE - sounds like "Eight"', 'image': 'eni'},
    'ஐ': {'tamil': 'ஐவர்', 'english': 'Aivar (Five People)', 'desc': 'Ai - sounds like "Ice"', 'image': 'aivar'},
    'ஒ': {'tamil': 'ஒட்டகம்', 'english': 'Ottagam (Camel)', 'desc': 'O - sounds like "One"', 'image': 'ottagam'},
    'ஓ': {'tamil': 'ஓடம்', 'english': 'Odam (Boat)', 'desc': 'OA - sounds like "Boat"', 'image': 'odam'},
    'ஔ': {'tamil': 'ஔவை', 'english': 'Avvai (Poet)', 'desc': 'Au - sounds like "Owl"', 'image': 'avvai'},
  };

  void _updateProgress(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context, listen: false);
    int percent = (((_currentIndex + 1) / _letters.length) * 100).toInt();
    progress.updateLessonProgress(1, percent); // Lesson 1: Vowels
    
    // Increment total letters learned if this is the first time seeing it in this session
    progress.incrementLettersLearned();
    progress.addRewards(coins: 1, stars: 1); // Small reward for each letter viewed
  }

  void _nextLetter() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _letters.length;
    });
    _updateProgress(context);
    AudioService.playLetter(_letters[_currentIndex]);
  }

  void _prevLetter() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + _letters.length) % _letters.length;
    });
    _updateProgress(context);
    AudioService.playLetter(_letters[_currentIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final letter = _letters[_currentIndex];
    final progress = Provider.of<EnhancedProgressProvider>(context);
    final exampleData = _examples[letter] ?? _examples['அ']!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, progress),
            
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
                child: Column(
                  children: [
                    _buildLetterCard(letter, exampleData['desc']!),
                    const SizedBox(height: 40),
                    _buildAudioAction(letter),
                    const SizedBox(height: 40),
                    _buildExampleWord(exampleData),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, EnhancedProgressProvider progress) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.borderLight)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavButton(
                icon: Icons.close_rounded,
                onTap: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'LEARNING FOUNDATIONS',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tamil Vowels',
                      style: GoogleFonts.notoSansTamil(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              _buildNavButton(
                icon: Icons.info_outline_rounded,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MASTERY',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textSlate,
                        letterSpacing: 1.0,
                      ),
                    ),
                     Text(
                      '${_currentIndex + 1} OF ${_letters.length} LETTERS',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 8,
                      width: MediaQuery.of(context).size.width * ((_currentIndex + 1) / _letters.length),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.offWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Icon(icon, color: AppTheme.textDark, size: 22),
      ),
    );
  }

  Widget _buildLetterCard(String letter, String desc) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: AppTheme.whiteCard(radius: 32),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 24),
            child: Column(
              children: [
                Text(
                  letter,
                  style: GoogleFonts.notoSansTamil(
                    fontSize: 140,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSlate,
                  ),
                ),
              ],
            ),
          ),
          
          Positioned.fill(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 0) {
                  _prevLetter();
                } else if (details.primaryVelocity! < 0) {
                  _nextLetter();
                }
              },
              behavior: HitTestBehavior.translucent,
            ),
          ),
          
          Positioned(
            bottom: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 10),
                ],
              ),
              child: const Icon(Icons.gesture_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioAction(String letter) {
    return GestureDetector(
      onTap: () => AudioService.playLetter(letter),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.volume_up_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'LISTEN AND PRONOUNCE',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppTheme.primary,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleWord(Map<String, String> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.whiteCard(radius: 24),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: Text(
                  _getEmojiForImage(data['image']!),
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VOCABULARY LINK',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textGray,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  data['tamil']!,
                  style: GoogleFonts.notoSansTamil(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  data['english']!,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getEmojiForImage(String imageName) {
    switch (imageName) {
      case 'amma': return '👩';
      case 'aadu': return '🐐';
      case 'ilai': return '🍃';
      case 'eetti': return '🏹';
      case 'ulagu': return '🌍';
      case 'oonjal': return '🎡';
      case 'eli': return '🐭';
      case 'eni': return '🪜';
      case 'aivar': return '🖐️';
      case 'ottagam': return '🐪';
      case 'odam': return '⛵';
      case 'avvai': return '👵';
      default: return '📖';
    }
  }
}


class DashedRingPainter extends CustomPainter {
  final Color color;
  const DashedRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = 90.0; // r=45% of 200 size, here approx fixed for look

    // Draw dashed circle
    final path = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    
    // Manual dashed effect
    final dashPath = Path();
    final dashWidth = 5.0;
    final dashSpace = 5.0;
    double distance = 0.0;
    
    for (final pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
