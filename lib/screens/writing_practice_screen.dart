import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../constants/tamil_data.dart';
import '../services/audio_service.dart';

class WritingPracticeScreen extends StatefulWidget {
  const WritingPracticeScreen({super.key});

  @override
  State<WritingPracticeScreen> createState() => _WritingPracticeScreenState();
}

class _WritingPracticeScreenState extends State<WritingPracticeScreen> {
  List<Offset?> _points = [];
  int _currentIndex = 0;
  final List<String> _letters =
      TamilData.uyirEzhuthukkal + TamilData.meiEzhuthukkal.take(5).toList();
  final GlobalKey _canvasKey = GlobalKey();
  Color _penColor = AppTheme.primaryRed;
  double _penWidth = 6.0;

  void _clearCanvas() {
    setState(() {
      _points = [];
    });
  }

  void _nextLetter() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _letters.length;
      _clearCanvas();
    });
    AudioService.playLetter(_letters[_currentIndex]);
  }

  void _prevLetter() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + _letters.length) % _letters.length;
      _clearCanvas();
    });
    AudioService.playLetter(_letters[_currentIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Writing Practice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearCanvas,
            tooltip: 'Clear',
          ),
        ],
      ),
      body: Column(
        children: [
          // Letter Display Area
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryRed.withOpacity(0.1),
                  AppTheme.primaryRed.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios,
                      color: AppTheme.primaryRed),
                  onPressed: _prevLetter,
                ),
                Column(
                  children: [
                    const Text(
                      'Write this letter:',
                      style: TextStyle(fontSize: 14, color: AppTheme.textGray),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () =>
                          AudioService.playLetter(_letters[_currentIndex]),
                      child: Row(
                        children: [
                          Text(
                            _letters[_currentIndex],
                            style: const TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryRed,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.volume_up,
                              color: AppTheme.primaryRed, size: 28),
                        ],
                      ),
                    ),
                    Text(
                      '${_currentIndex + 1} / ${_letters.length}',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textGray),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios,
                      color: AppTheme.primaryRed),
                  onPressed: _nextLetter,
                ),
              ],
            ),
          ),

          // Canvas Area
          Expanded(
            child: Container(
              key: _canvasKey,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppTheme.primaryRed.withOpacity(0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05), blurRadius: 10),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Guide letter (watermark)
                    Center(
                      child: Text(
                        _letters[_currentIndex],
                        style: TextStyle(
                          fontSize: 200,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryRed.withOpacity(0.06),
                        ),
                      ),
                    ),
                    // Drawing canvas
                    GestureDetector(
                      onPanStart: (details) {
                        final RenderBox? renderBox = _canvasKey.currentContext
                            ?.findRenderObject() as RenderBox?;
                        if (renderBox != null) {
                          setState(() {
                            _points.add(renderBox
                                .globalToLocal(details.globalPosition));
                          });
                        }
                      },
                      onPanUpdate: (details) {
                        final RenderBox? renderBox = _canvasKey.currentContext
                            ?.findRenderObject() as RenderBox?;
                        if (renderBox != null) {
                          setState(() {
                            _points.add(renderBox
                                .globalToLocal(details.globalPosition));
                          });
                        }
                      },
                      onPanEnd: (details) {
                        setState(() {
                          _points.add(null);
                        });
                      },
                      child: CustomPaint(
                        painter:
                            WritingPainter(_points, _penColor, _penWidth),
                        size: Size.infinite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Pen size and color options
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Pen: ',
                    style: TextStyle(fontSize: 12, color: AppTheme.textGray)),
                _buildColorOption(AppTheme.primaryRed),
                _buildColorOption(Colors.blue),
                _buildColorOption(Colors.green),
                _buildColorOption(Colors.black),
                const SizedBox(width: 16),
                const Text('Size: ',
                    style: TextStyle(fontSize: 12, color: AppTheme.textGray)),
                _buildSizeOption(4.0, 'S'),
                _buildSizeOption(6.0, 'M'),
                _buildSizeOption(10.0, 'L'),
              ],
            ),
          ),

          // Controls
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _clearCanvas,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Clear'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _nextLetter,
                    icon: const Icon(Icons.check),
                    label: const Text('Next'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(14),
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

  Widget _buildColorOption(Color color) {
    final isSelected = _penColor == color;
    return GestureDetector(
      onTap: () => setState(() => _penColor = color),
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppTheme.gold : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6)]
              : null,
        ),
      ),
    );
  }

  Widget _buildSizeOption(double size, String label) {
    final isSelected = _penWidth == size;
    return GestureDetector(
      onTap: () => setState(() => _penWidth = size),
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryRed.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryRed : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppTheme.primaryRed : AppTheme.textGray,
            ),
          ),
        ),
      ),
    );
  }
}

class WritingPainter extends CustomPainter {
  final List<Offset?> points;
  final Color color;
  final double strokeWidth;

  WritingPainter(this.points, this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(WritingPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}
