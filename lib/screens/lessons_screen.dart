import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../constants/tamil_data.dart';
import '../providers/enhanced_progress_provider.dart';
import 'tamil_letters_screen.dart';
import 'simple_words_screen.dart';
import 'sentence_builder_game.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Learning Path',
          style: GoogleFonts.lexend(fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.gold),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: AppTheme.gold, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${progress.totalStars}',
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: TamilData.lessons.length,
        separatorBuilder: (context, index) => _buildPathConnector(context, index, progress),
        itemBuilder: (context, index) {
          final lesson = TamilData.lessons[index];
          final isUnlocked = progress.unlockedLessons.contains(lesson['id']);
          final lessonProgress = progress.lessonProgress[lesson['id']] ?? 0;
          
          return _buildLessonCard(
            context,
            lesson['title'] as String,
            lesson['level'] as String,
            isUnlocked,
            lessonProgress,
            lesson['id'] as int,
          );
        },
      ),
    );
  }

  Widget _buildPathConnector(BuildContext context, int index, EnhancedProgressProvider progress) {
    final isUnlocked = progress.unlockedLessons.contains(TamilData.lessons[index + 1]['id']);
    return Center(
      child: Container(
        height: 20,
        width: 4,
        color: isUnlocked ? AppTheme.primaryRed.withOpacity(0.5) : Colors.grey[300],
      ),
    );
  }

  Widget _buildLessonCard(
    BuildContext context,
    String title,
    String level,
    bool isUnlocked,
    int progress,
    int lessonId,
  ) {
    Color levelColor = level == 'Beginner'
        ? AppTheme.success
        : level == 'Intermediate'
            ? AppTheme.warning
            : AppTheme.primaryRed;

    return Container(
      decoration: isUnlocked 
          ? AppTheme.whiteCard(radius: 20)
          : BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[300]!),
            ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isUnlocked ? () => _navigateToLesson(context, lessonId) : null,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUnlocked ? AppTheme.primaryRed.withOpacity(0.1) : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isUnlocked ? (progress >= 100 ? Icons.check_circle : Icons.play_arrow_rounded) : Icons.lock,
                    color: isUnlocked ? (progress >= 100 ? AppTheme.success : AppTheme.primaryRed) : Colors.grey[500],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: levelColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              level.toUpperCase(),
                              style: GoogleFonts.lexend(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: levelColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (isUnlocked && progress > 0)
                            Text(
                              '$progress%',
                              style: GoogleFonts.lexend(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textSlate,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: GoogleFonts.notoSansTamil(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? AppTheme.textDark : AppTheme.textSlate,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isUnlocked)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            minHeight: 4,
                            backgroundColor: AppTheme.primaryRed.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation(AppTheme.primaryRed),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToLesson(BuildContext context, int lessonId) {
    Widget screen;
    switch (lessonId) {
      case 1:
      case 2:
        screen = const TamilLettersScreen();
        break;
      case 3:
      case 4:
      case 5:
      case 6:
        screen = const SimpleWordsScreen();
        break;
      case 7:
        screen = const SentenceBuilderGame();
        break;
      default:
        screen = const TamilLettersScreen();
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
