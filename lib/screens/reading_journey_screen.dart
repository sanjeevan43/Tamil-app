import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_theme.dart';
import '../widgets/glass_card.dart';
import '../data/reading_journey_data.dart';
import 'reading_practice_screen.dart';

class ReadingJourneyScreen extends StatelessWidget {
  const ReadingJourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          // Background Decorative Elements
          const _BackgroundDecorations(),
          
          Column(
            children: [
              // Header
              const _ReadingJourneyHeader(),
              
              // Map Container
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    height: 1000, // Long scrollable area
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Winding Path
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _PathPainter(),
                          ),
                        ),
                        
                        // Level Nodes
                        // Note: Reversed order visually (bottom to top) in HTML logic, but here we position them.
                        // Y positions roughly match the SVG curve points.
                        // 0 at top, 800 at bottom in SVG. Flip for UI if needed?
                        // "M50 750" is bottom. "M50 0" is top.
                        // So Level 1 is at bottom (750), Level 5 at top (0).
                        
                        _LevelNode(
                          levelIndex: 0,
                          top: 800, 
                          alignment: 0, 
                          data: ReadingJourneyData.levels[0],
                          status: LevelStatus.completed,
                        ),
                        _LevelNode(
                          levelIndex: 1,
                          top: 650, 
                          alignment: 0.6, // Right
                          data: ReadingJourneyData.levels[1],
                          status: LevelStatus.completed,
                        ),
                        _LevelNode(
                          levelIndex: 2,
                          top: 500, 
                          alignment: -0.6, // Left
                          data: ReadingJourneyData.levels[2],
                          status: LevelStatus.current,
                        ),
                        _LevelNode(
                          levelIndex: 3,
                          top: 350, 
                          alignment: 0.6, // Right
                          data: ReadingJourneyData.levels[3],
                          status: LevelStatus.locked,
                        ),
                        _LevelNode(
                          levelIndex: 4,
                          top: 200, 
                          alignment: 0, 
                          data: ReadingJourneyData.levels[4],
                          status: LevelStatus.locked,
                        ),
                        
                        const SizedBox(height: 100), // Padding at bottom
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Floating Progress Footer
          const Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: _ProgressFooter(),
          ),
        ],
      ),
    );
  }
}

class _ReadingJourneyHeader extends StatelessWidget {
  const _ReadingJourneyHeader();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Text(
              'POWERED BY HOPE3 SERVICES',
              style: GoogleFonts.lexend(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: AppTheme.primaryRed.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              radius: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: AppTheme.primaryRed),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        'வாசிப்புப் பயணம்',
                        style: GoogleFonts.notoSansTamil(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        'Reading Journey',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryRed.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.stars_rounded, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '24',
                          style: GoogleFonts.lexend(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryRed,
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
      ),
    );
  }
}

enum LevelStatus { completed, current, locked }

class _LevelNode extends StatelessWidget {
  final int levelIndex;
  final double top;
  final double alignment; // -1.0 (left) to 1.0 (right)
  final Map<String, dynamic> data;
  final LevelStatus status;

  const _LevelNode({
    required this.levelIndex,
    required this.top,
    required this.alignment,
    required this.data,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    // Convert alignment to horizontal position offset contextually if needed, 
    // but Stack alignment works better with Align widget logic?
    // Actually, simple Align(alignment: Alignment(x, y)) works if parent is expanded.
    // Since we are in a massive Stack, Positioned is better.
    // We want to center horizontally roughly but offset by alignment.
    // Screen width is usually ~360-400. Offset 0.6 is quite far right.

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment(alignment, 0),
        child: Column(
          children: [
            // Node Icon
            GestureDetector(
              onTap: status == LevelStatus.locked ? null : () {
                 if (status == LevelStatus.current || status == LevelStatus.completed) {
                   Navigator.push(
                     context,
                     MaterialPageRoute(
                       builder: (_) => ReadingPracticeScreen(levelData: data),
                     ),
                   );
                 }
              },
              child: _buildNodeIcon(),
            ),
            
            // Label
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              radius: 12,
              opacity: 0.6,
              child: Column(
                children: [
                  Text(
                    'LEVEL ${data['id']}',
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: status == LevelStatus.locked ? Colors.grey : AppTheme.primaryRed,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    data['title'],
                    style: GoogleFonts.notoSansTamil(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: status == LevelStatus.locked ? Colors.grey[600] : AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNodeIcon() {
    switch (status) {
      case LevelStatus.completed:
        return Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.primaryRed,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryRed.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 32),
            ),
            Positioned(
              bottom: -10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) => 
                  Icon(
                    Icons.star_rounded, 
                    size: 16, 
                    color: index < (data['stars'] ?? 0) ? Colors.amber : Colors.grey[300]
                  )
                ),
              ),
            ),
          ],
        );
      case LevelStatus.current:
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Pulse Effect
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryRed, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryRed.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.play_arrow_rounded, color: AppTheme.primaryRed, size: 40),
            ),
            Positioned(
              top: -12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                child: Text(
                  'CURRENT STEP',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      case LevelStatus.locked:
        return Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white),
          ),
          child: Icon(Icons.lock_rounded, color: Colors.grey[400], size: 28),
        );
    }
  }
}

class _PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryRed.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      // dotted line?
      ;

    // SVG: M50 750 C 90 700, 90 650, 50 600 C 10 550, 10 500, 50 450 ...
    // Coordinate space: 0-100 X, 0-800 Y.
    // We need to scale X to size.width (mostly centered) and map Y to size.height (or manually fixed 1000 height).
    
    // Manual mapping based on 1000px height container? Or relative?
    // We fixed specific "top" positions for nodes: 800, 650, 500, 350, 200.
    // Path should connect these.
    
    final path = Path();
    final w = size.width;
    // final h = size.height; // Is 1000 approx
    
    // Start Bottom (Level 1)
    path.moveTo(w * 0.5, 800 + 32); // Center of node
    
    // Curve to Level 2 (Right aligned at 650)
    // Bezier control points need to be guessed to match smooth curve
    path.cubicTo(
      w * 0.8, 750, // Ctrl 1
      w * 0.8, 700, // Ctrl 2
      w * 0.5 + (w * 0.3), 650 + 32, // End (Level 2 center approx: 0.6 alignment is w*0.3 offset?)
      // Alignment 0.6 is (0 axis) + 0.6 * (half width).
      // Let's approximate visual look.
    );
     // Wait, simple cubicTo between nodes?
     // Actually the SVG path is continuous.
     // M50 750 ...
     
    // Drawing a simple continuous sine-like wave connecting the node centers is easier.
    // Level 1: (0.5 w, 832)
    // Level 2: (0.8 w, 682)
    // Level 3: (0.2 w, 532)
    // Level 4: (0.8 w, 382)
    // Level 5: (0.5 w, 232)
    
    // Note: Node Top + 32 (half height of 64px icon) = Center Y.
    
    final p1 = Offset(w * 0.5, 832);
    final p2 = Offset(w * 0.8, 682);
    final p3 = Offset(w * 0.2, 532);
    final p4 = Offset(w * 0.8, 382);
    final p5 = Offset(w * 0.5, 232);
    
    final path2 = Path();
    path2.moveTo(p1.dx, p1.dy);
    _drawCurve(path2, p1, p2);
    _drawCurve(path2, p2, p3);
    _drawCurve(path2, p3, p4);
    _drawCurve(path2, p4, p5);
    
    // Compute metrics for dashes
    final dashPath = Path();
    final dashWidth = 10.0;
    final dashSpace = 10.0;
    double distance = 0.0;
    for (final pathMetric in path2.computeMetrics()) {
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
  
  void _drawCurve(Path path, Offset p1, Offset p2) {
    // Simple cubic bezier with control points vertical
    // Ctrl1: moving up from p1
    // Ctrl2: moving down from p2? No, continuous flow.
    // Actually flow is p1 -> p2 (Upwards visually, so Y decreases).
    
    final ctrl1 = Offset(p1.dx, p1.dy - 70);
    final ctrl2 = Offset(p2.dx, p2.dy + 70);
    path.cubicTo(ctrl1.dx, ctrl1.dy, ctrl2.dx, ctrl2.dy, p2.dx, p2.dy);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProgressFooter extends StatelessWidget {
  const _ProgressFooter();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YOUR PROGRESS',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryRed,
                ),
              ),
              Text(
                '60%',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: AppTheme.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: FractionallySizedBox(
              widthFactor: 0.6,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to current level
                Navigator.push(
                     context,
                     MaterialPageRoute(
                       builder: (_) => ReadingPracticeScreen(levelData: ReadingJourneyData.levels[2]), // Level 3 hardcoded for demo as current
                     ),
                   );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                shadowColor: AppTheme.primaryRed.withOpacity(0.4),
                elevation: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.rocket_launch_rounded, color: Colors.white),
                   const SizedBox(width: 8),
                   Text(
                     'CONTINUE LEARNING',
                     style: GoogleFonts.lexend(
                       fontSize: 14,
                       fontWeight: FontWeight.bold,
                       color: Colors.white,
                       letterSpacing: 1.0,
                     ),
                   ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundDecorations extends StatelessWidget {
  const _BackgroundDecorations();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
           Positioned(top: 40, left: -20, child: _bgText('அ')),
           Positioned(top: 200, right: -20, child: _bgText('ஆ')),
           Positioned(bottom: 200, left: -20, child: _bgText('இ')),
           Positioned(bottom: 40, right: 20, child: _bgText('ஈ')),
        ],
      ),
    );
  }
  
  Widget _bgText(String text) {
    return Text(
      text,
      style: GoogleFonts.notoSansTamil(
        fontSize: 120,
        fontWeight: FontWeight.w900,
        color: AppTheme.primaryRed.withOpacity(0.03),
      ),
    );
  }
}
