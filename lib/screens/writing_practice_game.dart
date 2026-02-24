import 'package:flutter/material.dart';
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
  List<Offset> _points = [];
  int _stars = 0;

  void _nextLetter() {
    setState(() {
      _currentLetterIndex = (_currentLetterIndex + 1) % TamilData.uyirEzhuthukkal.length;
      _points.clear();
      _stars = _points.length > 10 ? 3 : 0;
    });
  }

  void _clearDrawing() {
    setState(() => _points.clear());
  }

  void _submitDrawing() {
    setState(() {
      _stars = _points.length > 20 ? 3 : _points.length > 10 ? 2 : 1;
    });
    _showResult();
  }

  void _showResult() {
    final starsEarned = _stars;
    final coinsEarned = starsEarned * 10;
    
    // Award rewards
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
              decoration: BoxDecoration(color: AppTheme.warning.withOpacity(0.1), shape: BoxShape.circle),
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
            const Text('Great Writing!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryRed)),
            const SizedBox(height: 8),
            Text('+$coinsEarned Coins | +$starsEarned Stars', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.success)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _nextLetter();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Next Letter'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Writing Practice'),
        actions: [
          IconButton(icon: const Icon(Icons.delete), onPressed: _clearDrawing),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryRed,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trace: ${TamilData.uyirEzhuthukkal[_currentLetterIndex]}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.white),
                ),
                Row(
                  children: List.generate(3, (index) {
                    return Icon(
                      index < _stars ? Icons.star : Icons.star_border,
                      color: AppTheme.warning,
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
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryRed, width: 3),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Opacity(
                      opacity: 0.2,
                      child: Text(
                        TamilData.uyirEzhuthukkal[_currentLetterIndex],
                        style: const TextStyle(fontSize: 200, fontWeight: FontWeight.bold, color: AppTheme.primaryRed),
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
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _clearDrawing,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Clear'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkRed),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _submitDrawing,
                    icon: const Icon(Icons.check),
                    label: const Text('Submit'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _nextLetter,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
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
      ..color = AppTheme.primaryRed
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.infinite && points[i + 1] != Offset.infinite) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
