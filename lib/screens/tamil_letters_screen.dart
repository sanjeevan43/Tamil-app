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
  
  // Mapping letters to example words
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

  void _nextLetter() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _letters.length;
    });
    // Auto-play sound on change
    // AudioService.playLetter(_letters[_currentIndex]);
  }

  void _prevLetter() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + _letters.length) % _letters.length;
    });
    // AudioService.playLetter(_letters[_currentIndex]);
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
            // Top Navigation & Progress
            _buildHeader(context, progress),
            
            // Main Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Glass Card with Trace Guide
                    _buildLetterCard(letter, exampleData['desc']!),
                    
                    const SizedBox(height: 32),
                    
                    // Audio Action
                    _buildAudioAction(letter),
                     
                    const SizedBox(height: 32),
                    
                    // Example Word
                    _buildExampleWord(exampleData),
                  ],
                ),
              ),
            ),
            
            // Bottom Controls (Optional, as swipe is implied)
            // _buildBottomNav(), 
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, EnhancedProgressProvider progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight.withOpacity(0.9),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavButton(
                icon: Icons.arrow_back,
                onTap: () => Navigator.pop(context),
              ),
              Column(
                children: [
                  Text(
                    'TAMIL VOWELS',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryRed.withOpacity(0.8),
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    'உயிர் எழுத்துகள்',
                    style: GoogleFonts.notoSansTamil(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              _buildNavButton(
                icon: Icons.map,
                onTap: () {
                  // Map navigation
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'PROGRESS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryRed,
                        letterSpacing: 1.0,
                      ),
                    ),
                     Text(
                      '${_currentIndex + 1} / ${_letters.length} Letters',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  height: 12, // h-3 in html
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999), // full rounded
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (_currentIndex + 1) / _letters.length,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryRed, // bg-primary
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryRed.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppTheme.primaryRed, size: 24),
      ),
    );
  }

  Widget _buildLetterCard(String letter, String desc) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      // Glass card effect
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryRed.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryRed.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none, // Allow blobs outside
        children: [
          // Background blobs
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 128, // w-32
              height: 128, // h-32
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryRed.withOpacity(0.05),
                // Blur happens via BackdropFilter usually, but simple opacity is fine for perf
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryRed.withOpacity(0.05),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Text Display
                Text(
                  letter,
                  style: GoogleFonts.notoSansTamil(
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryRed,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: GoogleFonts.lexend(
                    fontSize: 20, // text-xl
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryRed.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          // Trace Guide Visual Overlay (Dashed Circle)
          Positioned.fill(
             child: IgnorePointer(
               child: CustomPaint(
                 painter: DashedRingPainter(color: AppTheme.primaryRed.withOpacity(0.3)),
               ),
             ),
          ),

          // Trace Hand Icon
          Positioned(
            bottom: 32, // bottom-8
            right: 32, // right-8
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryRed.withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 24),
            ),
          ),
          
          // Swipe Detectors for Navigation
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
        ],
      ),
    );
  }

  Widget _buildAudioAction(String letter) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => AudioService.playLetter(letter),
          child: Container(
            width: 80, // w-20
            height: 80, // h-20
            decoration: BoxDecoration(
              color: AppTheme.primaryRed,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryRed.withOpacity(0.4),
                  blurRadius: 30, // shadow-[0_8px_30px_...]
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
        ),
        const SizedBox(height: 8),
        Text(
          'LISTEN TO SOUND',
          style: GoogleFonts.lexend(
            fontSize: 14, // text-sm
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryRed,
            letterSpacing: -0.5, // tracking-tighter
          ),
        ),
      ],
    );
  }

  Widget _buildExampleWord(Map<String, String> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // rounded-xl
        border: Border.all(color: AppTheme.primaryRed.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80, // w-20
            height: 80, // h-20
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8), // rounded-lg
              child: SafeImage(
                assetPath: 'assets/images/${data['image']}.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EXAMPLE WORD',
                  style: GoogleFonts.lexend(
                    fontSize: 12, // text-xs approx
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryRed.withOpacity(0.6),
                  ),
                ),
                Text(
                  data['tamil']!,
                  style: GoogleFonts.notoSansTamil(
                    fontSize: 30, // text-3xl
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  data['english']!,
                  style: GoogleFonts.lexend(
                    fontSize: 18, // text-lg
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.primaryRed.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
