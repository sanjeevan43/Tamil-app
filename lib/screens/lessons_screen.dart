import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../constants/tamil_data.dart';
import '../providers/enhanced_progress_provider.dart';
import 'tamil_letters_screen.dart';
import 'simple_words_screen.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn Tamil'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                const Icon(Icons.star, color: AppTheme.gold),
                Text(' ${progress.totalStars}', style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: TamilData.lessons.length,
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: isUnlocked ? AppTheme.glassCard() : BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: isUnlocked ? () => _navigateToLesson(context, lessonId) : null,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUnlocked ? AppTheme.primaryRed : Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isUnlocked ? Icons.book : Icons.lock,
                        color: AppTheme.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isUnlocked ? AppTheme.textDark : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: levelColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              level,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: levelColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isUnlocked && progress > 0)
                      CircleAvatar(
                        backgroundColor: AppTheme.success,
                        child: Text(
                          '$progress%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.white,
                          ),
                        ),
                      ),
                  ],
                ),
                if (isUnlocked && progress > 0) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: Colors.grey.shade300,
                      color: AppTheme.primaryRed,
                      minHeight: 8,
                    ),
                  ),
                ],
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
      default:
        screen = const TamilLettersScreen();
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
