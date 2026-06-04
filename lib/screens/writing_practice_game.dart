import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../data/tamil_data.dart';
import '../providers/enhanced_progress_provider.dart';
import '../services/writing_evaluator.dart';

class WritingPracticeGame extends StatefulWidget {
  const WritingPracticeGame({super.key});

  @override
  State<WritingPracticeGame> createState() => _WritingPracticeGameState();
}

class _WritingPracticeGameState extends State<WritingPracticeGame> {
  String _selectedCategory = 'Vowels'; // 'Vowels', 'Consonants', 'Aayudham', 'Combinations'
  int _currentLetterIndex = 0;
  final List<Offset> _points = [];
  int _stars = 0;
  int _pointerCount = 0;
  double _canvasWidth = 0.0;
  double _canvasHeight = 0.0;

  List<String> get _activeLetterList {
    switch (_selectedCategory) {
      case 'Consonants':
        return TamilData.meiEzhuthukkal;
      case 'Aayudham':
        return TamilData.aayudhaEzhuthu;
      case 'Combinations':
        return TamilData.uyirMeiEzhuthukkal.expand((list) => list).toList();
      case 'Vowels':
      default:
        return TamilData.uyirEzhuthukkal;
    }
  }

  void _nextLetter() {
    setState(() {
      _currentLetterIndex = (_currentLetterIndex + 1) % _activeLetterList.length;
      _points.clear();
      _stars = 0;
    });
  }

  void _clearDrawing() {
    setState(() => _points.clear());
  }

  void _submitDrawing() {
    if (_points.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please draw the letter first!', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          backgroundColor: AppTheme.primary,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final currentLetter = _activeLetterList[_currentLetterIndex];
    
    // Check how many points were actually drawn directly on/near the placeholder letter shape
    final pointsOnLetter = _points.where((p) {
      if (p == Offset.infinite) return false;
      return WritingEvaluator.isNearPath(currentLetter, p, _canvasWidth, _canvasHeight);
    }).toList();

    if (pointsOnLetter.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please trace directly over the letter guide before submitting!', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          backgroundColor: AppTheme.warning,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final similarity = WritingEvaluator.evaluateSimilarity(currentLetter, _points, _canvasWidth, _canvasHeight);
    final stars = WritingEvaluator.getStarsEarned(similarity);

    if (stars == 1 && similarity < 0.4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Try to trace the letter guide more closely!', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          backgroundColor: AppTheme.warning,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    setState(() {
      _stars = stars;
    });
    _showResult();
  }

  void _showResult() {
    final starsEarned = _stars;
    final coinsEarned = starsEarned * 10;
    
    final progress = Provider.of<EnhancedProgressProvider>(context, listen: false);
    progress.addRewards(coins: coinsEarned, stars: starsEarned, missionId: 'letter_pro');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: const Text('✨', style: TextStyle(fontSize: 40)),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Icon(
                  index < starsEarned ? Icons.star : Icons.star_border,
                  color: AppTheme.gold,
                  size: 44,
                );
              }),
            ),
            const SizedBox(height: 16),
            Text('Great Writing!', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.primary)),
            const SizedBox(height: 8),
            Text('+$coinsEarned Coins | +$starsEarned Stars', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppTheme.success)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _nextLetter();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Next Letter', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPill(String category, String label) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
          _currentLetterIndex = 0;
          _points.clear();
          _stars = 0;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.primary.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: isSelected ? AppTheme.white : AppTheme.secondary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final validPoints = _points.where((p) => p != Offset.infinite).toList();
    final currentLetter = _activeLetterList[_currentLetterIndex];
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.secondary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'WRITING PRACTICE',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.secondary, letterSpacing: 1, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Horizontal category selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildCategoryPill('Vowels', 'உயிர் (Vowels)'),
                const SizedBox(width: 8),
                _buildCategoryPill('Consonants', 'மெய் (Consonants)'),
                const SizedBox(width: 8),
                _buildCategoryPill('Aayudham', 'ஆயுதம் (Special)'),
                const SizedBox(width: 8),
                _buildCategoryPill('Combinations', 'உயிர்மெய் (Combined)'),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.secondary, AppTheme.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trace Letter',
                      style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.white.withOpacity(0.7), letterSpacing: 1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentLetter,
                      style: GoogleFonts.notoSansTamil(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primary, width: 2),
                boxShadow: [
                  BoxShadow(color: AppTheme.primary.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  _canvasWidth = constraints.maxWidth;
                  _canvasHeight = constraints.maxHeight;
 
                  return Stack(
                    children: [
                      Listener(
                        onPointerDown: (event) {
                          _pointerCount++;
                        },
                        onPointerUp: (event) {
                          _pointerCount--;
                        },
                        onPointerCancel: (event) {
                          _pointerCount--;
                        },
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            if (_pointerCount > 1) return; // Block multi-finger drawing
                            setState(() => _points.add(details.localPosition));
                          },
                          onPanEnd: (details) {
                            setState(() => _points.add(Offset.infinite));
                          },
                          child: CustomPaint(
                            painter: DrawingPainter(_points, currentLetter),
                            size: Size.infinite,
                          ),
                        ),
                      ),
                      // Guided writing tracer mini tutorial
                      Positioned(
                        top: 16,
                        right: 16,
                        child: GuidedTracerMiniWidget(
                          letter: currentLetter,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _clearDrawing,
                        icon: const Icon(Icons.refresh),
                        label: Text('Clear', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.textGray,
                          foregroundColor: AppTheme.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _submitDrawing,
                        icon: const Icon(Icons.check),
                        label: Text('Submit', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: AppTheme.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _nextLetter,
                        icon: const Icon(Icons.arrow_forward),
                        label: Text('Next', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondary,
                          foregroundColor: AppTheme.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
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
}

class DrawingPainter extends CustomPainter {
  final List<Offset> points;
  final String letter;

  DrawingPainter(this.points, this.letter);

  @override
  void paint(Canvas canvas, Size size) {
    if (letter.isEmpty) return;

    // 1. Set up TextPainter for the Tamil character (The guide track)
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: GoogleFonts.notoSansTamil(
          fontSize: size.width * 0.58, // Fits perfectly in the center
          fontWeight: FontWeight.bold,
          color: AppTheme.primary.withOpacity(0.08), // Beautiful translucent red guide track
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final textOffset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    // Draw the translucent curved guide track
    textPainter.paint(canvas, textOffset);

    // Draw an elegant thin spine outline of the letter using standard TextPainter with stroke style!
    final outlinePainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: GoogleFonts.notoSansTamil(
          fontSize: size.width * 0.58,
          fontWeight: FontWeight.bold,
          foreground: Paint()
            ..color = AppTheme.primary.withOpacity(0.12)
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    outlinePainter.layout();
    outlinePainter.paint(canvas, textOffset);

    // 2. Draw the user's strokes on top of the canvas (allows drawing everywhere, including white space!)
    final paint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 14.0 // Elegant handwriting stroke thickness
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.infinite && points[i + 1] != Offset.infinite) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => oldDelegate.letter != letter || oldDelegate.points != points;
}

class GuidedTracerMiniWidget extends StatefulWidget {
  final String letter;

  const GuidedTracerMiniWidget({super.key, required this.letter});

  @override
  State<GuidedTracerMiniWidget> createState() => _GuidedTracerMiniWidgetState();
}

class _GuidedTracerMiniWidgetState extends State<GuidedTracerMiniWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void didUpdateWidget(GuidedTracerMiniWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.letter != widget.letter) {
      _controller.reset();
      _controller.forward();
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppTheme.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondary.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4,
            right: 4,
            child: Icon(Icons.psychology_outlined, size: 12, color: AppTheme.primary.withOpacity(0.6)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: MiniTracePainter(widget.letter, _controller.value),
                  size: Size.infinite,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MiniTracePainter extends CustomPainter {
  final String letter;
  final double progress;

  MiniTracePainter(this.letter, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (letter.isEmpty) return;

    // Draw the static mini character guide faintly
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: GoogleFonts.notoSansTamil(
          fontSize: size.width * 0.65,
          fontWeight: FontWeight.bold,
          color: AppTheme.secondary.withOpacity(0.12),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final textOffset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );
    textPainter.paint(canvas, textOffset);

    // Draw a beautiful glowing trace pointer sweeping in a smooth circular path over the character!
    final double radius = size.width * 0.3;
    final double angle = progress * 2.0 * pi;
    final Offset sweepPos = Offset(
      size.width / 2 + radius * cos(angle),
      size.height / 2 + radius * sin(angle),
    );

    // Glowing golden pointer
    final glowPaint = Paint()
      ..color = AppTheme.gold.withOpacity(0.4)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawCircle(sweepPos, 8.0, glowPaint);

    final pencilPaint = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(sweepPos, 4.0, pencilPaint);
  }

  @override
  bool shouldRepaint(covariant MiniTracePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.letter != letter;
  }
}
