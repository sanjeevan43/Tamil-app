import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../widgets/glass_card.dart';
import '../data/reading_journey_data.dart';
import '../providers/enhanced_progress_provider.dart';
import 'reading_practice_screen.dart';

class ReadingJourneyScreen extends StatelessWidget {
  const ReadingJourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          const _BackgroundDecorations(),
          
          Column(
            children: [
              _ReadingJourneyHeader(progress: progress),
              
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    height: 1100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _PathPainter(),
                          ),
                        ),
                        
                        ...List.generate(ReadingJourneyData.levels.length, (index) {
                          final data = ReadingJourneyData.levels[index];
                          final lessonId = data['id'];
                          
                          LevelStatus status;
                          if (progress.unlockedLessons.contains(lessonId)) {
                            final p = progress.lessonProgress[lessonId] ?? 0;
                            status = p >= 100 ? LevelStatus.completed : LevelStatus.current;
                          } else {
                            status = LevelStatus.locked;
                          }

                          // Manual layout mapping for the winding path
                          final layoutMap = [
                            {'top': 900.0, 'alignment': 0.0},
                            {'top': 730.0, 'alignment': 0.7},
                            {'top': 560.0, 'alignment': -0.7},
                            {'top': 390.0, 'alignment': 0.7},
                            {'top': 220.0, 'alignment': 0.0},
                          ];

                          final layout = layoutMap[index % layoutMap.length];

                          return _LevelNode(
                            levelIndex: index,
                            top: layout['top'] as double,
                            alignment: layout['alignment'] as double,
                            data: data,
                            status: status,
                          );
                        }),
                        
                        const SizedBox(height: 150),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReadingJourneyHeader extends StatelessWidget {
  final EnhancedProgressProvider progress;
  const _ReadingJourneyHeader({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 20),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            'MILESTONE TRACKER',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppTheme.primary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavButton(
                  context,
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                Column(
                  children: [
                    Text(
                      'வாசிப்புப் பயணம்',
                      style: GoogleFonts.notoSansTamil(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      'Learning Journey',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSlate,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: AppTheme.pillBadge(bgColor: AppTheme.primary.withOpacity(0.08)),
                  child: Row(
                    children: [
                      const Icon(Icons.stars_rounded, color: AppTheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${progress.totalStars}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
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

  Widget _buildNavButton(BuildContext context, {required IconData icon, required VoidCallback onTap}) {
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
        child: Icon(icon, color: AppTheme.textDark, size: 20),
      ),
    );
  }
}

enum LevelStatus { completed, current, locked }

class _LevelNode extends StatelessWidget {
  final int levelIndex;
  final double top;
  final double alignment;
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
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment(alignment, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: status == LevelStatus.locked ? null : () {
                 Navigator.push(
                   context,
                   MaterialPageRoute(
                     builder: (_) => ReadingPracticeScreen(levelData: data),
                   ),
                 );
              },
              child: _buildNodeIcon(),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: AppTheme.whiteCard(radius: 16),
              child: Column(
                children: [
                  Text(
                    'MODULE ${data['id']}',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: status == LevelStatus.locked ? AppTheme.textGray : AppTheme.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data['title'],
                    style: GoogleFonts.notoSansTamil(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: status == LevelStatus.locked ? AppTheme.textGray : AppTheme.textDark,
                    ),
                  ),
                  Text(
                    data['subtitle'] ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: status == LevelStatus.locked ? AppTheme.textGray.withOpacity(0.6) : AppTheme.textSlate,
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
        return Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 6),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
        );
      case LevelStatus.current:
        return Stack(
          alignment: Alignment.center,
          children: [
            _PulseEffect(color: AppTheme.primary),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.25),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Icon(Icons.rocket_launch_rounded, color: AppTheme.primary, size: 40),
            ),
          ],
        );
      case LevelStatus.locked:
        return Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: AppTheme.offWhite,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.borderLight, width: 2),
          ),
          child: Icon(Icons.lock_outline_rounded, color: AppTheme.textGray.withOpacity(0.3), size: 30),
        );
    }
  }
}

class _PulseEffect extends StatefulWidget {
  final Color color;
  const _PulseEffect({required this.color});

  @override
  State<_PulseEffect> createState() => _PulseEffectState();
}

class _PulseEffectState extends State<_PulseEffect> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Container(
          width: 80 + (_ctrl.value * 40),
          height: 80 + (_ctrl.value * 40),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(0.2 * (1 - _ctrl.value)),
          ),
        );
      },
    );
  }
}

class _PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final path = Path();
    
    // Centers mapped to node positions
    final points = [
      Offset(w * 0.5, 936),
      Offset(w * 0.85, 766),
      Offset(w * 0.15, 596),
      Offset(w * 0.85, 426),
      Offset(w * 0.5, 256),
    ];
    
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final ctrl1 = Offset(p1.dx, p1.dy - 100);
      final ctrl2 = Offset(p2.dx, p2.dy + 100);
      path.cubicTo(ctrl1.dx, ctrl1.dy, ctrl2.dx, ctrl2.dy, p2.dx, p2.dy);
    }

    final dashPath = Path();
    const dashWidth = 12.0;
    const dashSpace = 8.0;
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


class _BackgroundDecorations extends StatelessWidget {
  const _BackgroundDecorations();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.04,
        child: Stack(
          children: [
            Positioned(top: 100, left: 20, child: _bgText('அ')),
            Positioned(top: 400, right: 30, child: _bgText('ஆ')),
            Positioned(bottom: 300, left: 40, child: _bgText('இ')),
            Positioned(bottom: 100, right: 10, child: _bgText('ஈ')),
          ],
        ),
      ),
    );
  }
  
  Widget _bgText(String text) {
    return Text(
      text,
      style: GoogleFonts.notoSansTamil(fontSize: 160, fontWeight: FontWeight.bold),
    );
  }
}

