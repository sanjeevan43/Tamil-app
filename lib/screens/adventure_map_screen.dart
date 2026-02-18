import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';
import 'quiz_screen.dart';
import 'letter_hunt_screen.dart';
import 'word_builder_screen.dart';
import 'tamil_letters_screen.dart';

class AdventureMapScreen extends StatelessWidget {
  const AdventureMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context);
    
    final List<Map<String, dynamic>> levels = [
      {'id': 1, 'title': 'உயிர் கிராமம்', 'icon': Icons.home, 'type': 'letters', 'pos': const Offset(0.5, 0.85)},
      {'id': 2, 'title': 'எழுத்து வேட்டை', 'icon': Icons.terrain, 'type': 'hunt', 'pos': const Offset(0.25, 0.65)},
      {'id': 3, 'title': 'சொல் காடு', 'icon': Icons.park, 'type': 'build', 'pos': const Offset(0.75, 0.45)},
      {'id': 4, 'title': 'வினாடி வினா கோட்டை', 'icon': Icons.fort, 'type': 'quiz', 'pos': const Offset(0.5, 0.2)},
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('தமிழ் சாகசம்', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryRed, AppTheme.lightRed, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.4, 0.9],
          ),
        ),
        child: Stack(
          children: [
            // Decorative background patterns
            Positioned(
              top: 100,
              left: -50,
              child: Opacity(
                opacity: 0.1,
                child: Text('அ', style: TextStyle(fontSize: 200, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            Positioned(
              bottom: 100,
              right: -50,
              child: Opacity(
                opacity: 0.1,
                child: Text('க', style: TextStyle(fontSize: 200, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),

            // Paths
            CustomPaint(
              painter: MapPathPainter(levels.map((l) => l['pos'] as Offset).toList()),
              size: Size.infinite,
            ),

            // Level Nodes
            ...levels.map((level) {
              bool isUnlocked = progress.level >= level['id'];
              bool isCurrent = progress.level == level['id'];
              return Positioned(
                left: MediaQuery.of(context).size.width * level['pos'].dx - 45,
                top: MediaQuery.of(context).size.height * level['pos'].dy - 45,
                child: _buildLevelNode(context, level, isUnlocked, isCurrent),
              );
            }),

            // Floating Avatar Indicator
            Positioned(
              left: MediaQuery.of(context).size.width * levels[(progress.level - 1).clamp(0, levels.length-1)]['pos'].dx - 30,
              top: MediaQuery.of(context).size.height * levels[(progress.level - 1).clamp(0, levels.length-1)]['pos'].dy - 100,
              child: _buildCurrentAvatar(progress.avatar),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelNode(BuildContext context, Map<String, dynamic> level, bool isUnlocked, bool isCurrent) {
    return GestureDetector(
      onTap: () {
        if (isUnlocked) {
          _navigateToGame(context, level['type']);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('இந்த நிலையை அடைய இன்னும் முன்னேறுங்கள்! (Level up to unlock)'),
              backgroundColor: AppTheme.primaryRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: isUnlocked ? AppTheme.white : Colors.grey[300],
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isUnlocked ? AppTheme.primaryRed : Colors.black).withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ],
              border: Border.all(
                color: isCurrent ? AppTheme.gold : (isUnlocked ? AppTheme.primaryRed : Colors.grey),
                width: 4,
              ),
            ),
            child: Icon(
              level['icon'] as IconData, 
              color: isUnlocked ? AppTheme.primaryRed : Colors.grey[600], 
              size: 45,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (isUnlocked ? AppTheme.primaryRed : Colors.black54),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
            child: Text(
              level['title'] as String,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentAvatar(String avatar) {
     return Column(
       children: [
         Container(
           padding: const EdgeInsets.all(8),
           decoration: BoxDecoration(
             color: AppTheme.white,
             shape: BoxShape.circle,
             boxShadow: [BoxShadow(color: AppTheme.primaryRed.withOpacity(0.5), blurRadius: 15, spreadRadius: 5)],
             border: Border.all(color: AppTheme.gold, width: 2),
           ),
           child: Text(avatar, style: const TextStyle(fontSize: 40)),
         ),
         const Icon(Icons.arrow_drop_down, color: AppTheme.gold, size: 30),
       ],
     );
  }

  void _navigateToGame(BuildContext context, String type) {
    Widget screen;
    switch (type) {
      case 'letters': screen = const TamilLettersScreen(); break;
      case 'hunt': screen = const LetterHuntScreen(); break;
      case 'build': screen = const WordBuilderScreen(); break;
      case 'quiz': screen = const QuizScreen(); break;
      default: screen = const QuizScreen();
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

class MapPathPainter extends CustomPainter {
  final List<Offset> points;
  MapPathPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryRed.withOpacity(0.15)
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(size.width * points[0].dx, size.height * points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(size.width * points[i].dx, size.height * points[i].dy);
      }
    }
    canvas.drawPath(path, paint);

    // Dotted line effect
    final dotPaint = Paint()
      ..color = AppTheme.primaryRed.withOpacity(0.4)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    // Draw dashing line
    var pathMetric = path.computeMetrics().first;
    double dashWidth = 10.0;
    double dashSpace = 10.0;
    double distance = 0.0;
    while (distance < pathMetric.length) {
      canvas.drawPath(
        pathMetric.extractPath(distance, distance + dashWidth),
        dotPaint,
      );
      distance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
