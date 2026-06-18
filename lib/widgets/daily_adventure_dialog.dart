import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_theme.dart';
import '../services/audio_feedback_service.dart';
import '../screens/riddle_academy_screen.dart';
import '../screens/linguistic_scanner_screen.dart';
import '../screens/quiz_screen.dart';
import '../widgets/premium_animations.dart';

class DailyAdventureDialog extends StatelessWidget {
  final int childAge;
  const DailyAdventureDialog({super.key, required this.childAge});

  static void show(BuildContext context, int age) {
    AudioFeedbackService.playPop();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Daily Adventure',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return DailyAdventureDialog(childAge: age);
      },
      transitionBuilder: (context, anim, secondaryAnim, child) {
        final curveValue = Curves.elasticOut.transform(anim.value);
        return Transform.scale(
          scale: curveValue,
          child: Opacity(
            opacity: anim.value,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      elevation: 16,
      backgroundColor: AppTheme.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('⭐', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 8),
                Text(
                  'DAILY ADVENTURE',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Complete your daily activities to earn extra coins!',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textGray),
            ),
            const SizedBox(height: 24),

            // Grid of choices
            _buildOption(
              context,
              emoji: '📖',
              title: 'Daily Word',
              desc: 'Learn a new Tamil word today',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, FadeInSlidePageRoute(page: LinguisticScannerScreen(childAge: childAge)));
              },
            ),
            const SizedBox(height: 12),
            _buildOption(
              context,
              emoji: '🧩',
              title: 'Daily Riddle',
              desc: 'Solve today\'s mind puzzle',
              color: Colors.purple,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, FadeInSlidePageRoute(page: RiddleAcademyScreen(childAge: childAge)));
              },
            ),
            const SizedBox(height: 12),
            _buildOption(
              context,
              emoji: '🎯',
              title: 'Daily Quiz',
              desc: 'Test your knowledge',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, FadeInSlidePageRoute(page: const QuizScreen()));
              },
            ),

            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                AudioFeedbackService.playTap();
                Navigator.pop(context);
              },
              child: Text(
                'CLOSE',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textGray,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String emoji,
    required String title,
    required String desc,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.topoLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.topoSilver),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            AudioFeedbackService.playTap();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        desc,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: AppTheme.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textGray),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
