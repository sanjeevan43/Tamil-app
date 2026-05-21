import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../constants/tamil_data.dart';
import '../providers/enhanced_progress_provider.dart';

class WritingPracticeGame extends StatefulWidget {
  const WritingPracticeGame({super.key});

  @override
  State<WritingPracticeGame> createState() => _WritingPracticeGameState();
}

class _WritingPracticeGameState extends State<WritingPracticeGame> {
  int _currentLetterIndex = 0;
  final List<Offset> _points = [];
  int _stars = 0;

  void _nextLetter() {
    setState(() {
      _currentLetterIndex = (_currentLetterIndex + 1) % TamilData.uyirEzhuthukkal.length;
      _points.clear();
      _stars = 0;
    });
  }

  void _clearDrawing() {
    setState(() => _points.clear());
  }

  void _submitDrawing() {
    // Validation: Check if user drew something
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

    // Validation: Check minimum drawing length
    final validPoints = _points.where((p) => p != Offset.infinite).toList();
    if (validPoints.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Draw more to complete the letter!', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          backgroundColor: AppTheme.warning,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _stars = validPoints.length > 50 ? 3 : validPoints.length > 30 ? 2 : 1;
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

  @override
  Widget build(BuildContext context) {
    final validPoints = _points.where((p) => p != Offset.infinite).toList();
    
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
          Container(
            margin: const EdgeInsets.all(16),
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
                      TamilData.uyirEzhuthukkal[_currentLetterIndex],
                      style: GoogleFonts.notoSansTamil(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.white),
                    ),
                  ],
                ),
                Row(
                  children: List.generate(3, (index) {
                    return Icon(
                      index < _stars ? Icons.star : Icons.star_border,
                      color: AppTheme.gold,
                      size: 32,
                    );
                  }),
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
              child: Stack(
                children: [
                  Center(
                    child: Opacity(
                      opacity: 0.15,
                      child: Text(
                        TamilData.uyirEzhuthukkal[_currentLetterIndex],
                        style: GoogleFonts.notoSansTamil(fontSize: 200, fontWeight: FontWeight.bold, color: AppTheme.primary),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onPanUpdate: (details) {
                      setState(() => _points.add(details.localPosition));
                    },
                    onPanEnd: (details) {
                      setState(() => _points.add(Offset.infinite));
                    },
                    child: CustomPaint(
                      painter: DrawingPainter(_points),
                      size: Size.infinite,
                    ),
                  ),
                  // Drawing progress indicator
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: validPoints.length < 10 ? AppTheme.warning : AppTheme.success,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${validPoints.length} strokes',
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.white),
                      ),
                    ),
                  ),
                ],
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
                const SizedBox(height: 12),
                if (validPoints.length < 10)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.warning, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppTheme.warning, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Draw more strokes to complete the letter (${10 - validPoints.length} more needed)',
                            style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.warning.withOpacity(0.8), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
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

class DrawingPainter extends CustomPainter {
  final List<Offset> points;

  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.infinite && points[i + 1] != Offset.infinite) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
