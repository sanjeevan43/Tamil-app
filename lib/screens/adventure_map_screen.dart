import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/progress_provider.dart';
import 'quiz_screen.dart';
import 'letter_hunt_screen.dart';
import 'word_builder_screen.dart';

class AdventureMapScreen extends StatelessWidget {
  const AdventureMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<ProgressProvider>(context);
    
    final List<Map<String, dynamic>> levels = [
      {'id': 1, 'title': 'Vowel Village', 'icon': Icons.home, 'type': 'letters', 'pos': const Offset(0.5, 0.8)},
      {'id': 2, 'title': 'Consonant Cave', 'icon': Icons.terrain, 'type': 'hunt', 'pos': const Offset(0.2, 0.6)},
      {'id': 3, 'title': 'Word Woods', 'icon': Icons.park, 'type': 'build', 'pos': const Offset(0.7, 0.4)},
      {'id': 4, 'title': 'Quiz Castle', 'icon': Icons.fort, 'type': 'quiz', 'pos': const Offset(0.5, 0.2)},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Tamil Adventure')),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.green[100],
          image: const DecorationImage(
            image: NetworkImage('https://img.freepik.com/free-vector/cartoon-game-map-island-sea_107791-3705.jpg'), // Placeholder for map background
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: Stack(
          children: [
            // Paths
            CustomPaint(
              painter: MapPathPainter(levels.map((l) => l['pos'] as Offset).toList()),
              size: Size.infinite,
            ),

            // Level Nodes
            ...levels.map((level) {
              bool isUnlocked = progress.level >= level['id'];
              return Positioned(
                left: MediaQuery.of(context).size.width * level['pos'].dx - 40,
                top: MediaQuery.of(context).size.height * level['pos'].dy - 40,
                child: _buildLevelNode(context, level, isUnlocked, progress),
              );
            }),

            // Avatar at current position
            if (levels.isNotEmpty)
               Positioned(
                left: MediaQuery.of(context).size.width * levels[progress.level.clamp(0, levels.length-1)]['pos'].dx - 30,
                top: MediaQuery.of(context).size.height * levels[progress.level.clamp(0, levels.length-1)]['pos'].dy - 80,
                child: _buildCurrentAvatar(progress.currentEquipped),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelNode(BuildContext context, Map<String, dynamic> level, bool isUnlocked, ProgressProvider progress) {
    return GestureDetector(
      onTap: () {
        if (isUnlocked) {
          _navigateToGame(context, level['type']);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reach higher Level to unlock!')));
        }
      },
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isUnlocked ? AppColors.primaryRed : Colors.grey,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: Icon(level['icon'] as IconData, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
            child: Text(level['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentAvatar(String id) {
     Color color = Colors.grey;
     if (id == 'red_warrior') color = AppColors.primaryRed;
     if (id == 'golden_king') color = Colors.amber;
     if (id == 'forest_scout') color = Colors.green;
     
     return Column(
       children: [
         Container(
           padding: const EdgeInsets.all(4),
           decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
           child: Icon(Icons.person_pin_circle, color: color, size: 50),
         ),
         const Icon(Icons.arrow_drop_down, color: Colors.white),
       ],
     );
  }

  void _navigateToGame(BuildContext context, String type) {
    Widget screen;
    switch (type) {
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
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 10
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

    // Draw dashing effect
    final dashPaint = Paint()
      ..color = AppColors.primaryRed.withOpacity(0.3)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, dashPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
