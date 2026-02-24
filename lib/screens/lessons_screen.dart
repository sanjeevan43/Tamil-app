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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        title: Text(
          'LEARNING PATH',
          style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: 2, fontSize: 13),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars_rounded, color: Colors.amber, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${progress.totalStars}',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppTheme.primary, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 60),
        physics: const BouncingScrollPhysics(),
        itemCount: TamilData.lessons.length,
        separatorBuilder: (context, index) => _buildPathConnector(context, index, progress),
        itemBuilder: (context, index) {
          final lesson = TamilData.lessons[index];
          final isUnlocked = progress.unlockedLessons.contains(lesson['id']);
          final lessonProgress = progress.lessonProgress[lesson['id']] ?? 0;
          
          return _buildLessonCard(
            context,
            lesson['title'] as String,
            lesson['english'] as String,
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
    bool nextUnlocked = (index + 1 < TamilData.lessons.length) && 
                       progress.unlockedLessons.contains(TamilData.lessons[index + 1]['id']);
    return Row(
      children: [
        const SizedBox(width: 44), // Alignment with the icon center
        Container(
          height: 32,
          width: 3,
          decoration: BoxDecoration(
            color: nextUnlocked ? AppTheme.primary.withOpacity(0.2) : AppTheme.borderLight.withOpacity(0.5),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildLessonCard(
    BuildContext context,
    String title,
    String englishTitle,
    String level,
    bool isUnlocked,
    int progress,
    int lessonId,
  ) {
    Color levelColor = level == 'Beginner'
        ? AppTheme.success
        : level == 'Intermediate'
            ? AppTheme.primary
            : AppTheme.accent;

    return Container(
      decoration: isUnlocked 
          ? AppTheme.whiteCard(radius: 32)
          : BoxDecoration(
              color: AppTheme.offWhite,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppTheme.borderLight),
            ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: isUnlocked ? () => _navigateToLesson(context, lessonId) : null,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isUnlocked ? AppTheme.primary.withOpacity(0.06) : AppTheme.offWhite,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isUnlocked ? (progress >= 100 ? AppTheme.success : AppTheme.primary).withOpacity(0.2) : AppTheme.borderLight,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isUnlocked ? (progress >= 100 ? Icons.check_rounded : Icons.play_arrow_rounded) : Icons.lock_outline_rounded,
                    color: isUnlocked ? (progress >= 100 ? AppTheme.success : AppTheme.primary) : AppTheme.textGray,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isUnlocked ? levelColor.withOpacity(0.1) : AppTheme.textGray.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              level.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: isUnlocked ? levelColor : AppTheme.textGray,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          if (isUnlocked && progress > 0)
                            Text(
                              '$progress%',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.primary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: GoogleFonts.notoSansTamil(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? AppTheme.textDark : AppTheme.textGray,
                          height: 1.3,
                        ),
                      ),
                      Text(
                        englishTitle,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isUnlocked ? AppTheme.textSlate : AppTheme.textGray.withOpacity(0.6),
                        ),
                      ),
                      if (isUnlocked) ...[
                        const SizedBox(height: 20),
                        Stack(
                          children: [
                            Container(
                              height: 6,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppTheme.offWhite,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: progress / 100,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.accent]),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
