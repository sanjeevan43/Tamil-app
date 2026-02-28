import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';

class WeeklyChallengeScreen extends StatelessWidget {
  const WeeklyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context);

    // Dynamic challenges based on user data
    final List<Map<String, dynamic>> challenges = [
      {'title': 'Letter Master', 'desc': 'Learn 10 new letters', 'goal': 10, 'current': progress.totalLettersLearned % 15, 'icon': Icons.abc},
      {'title': 'Story Hunter', 'desc': 'Complete 2 story quizzes', 'goal': 2, 'current': progress.storyQuizScores.length, 'icon': Icons.menu_book},
      {'title': 'Treasure Seeker', 'desc': 'Earn 500 coins', 'goal': 500, 'current': progress.totalCoins % 600, 'icon': Icons.monetization_on},
      {'title': 'Streak Hero', 'desc': 'Maintain a 7-day streak', 'goal': 7, 'current': progress.streakDays, 'icon': Icons.local_fire_department},
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Weekly Challenge',
          style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
        titleTextStyle: GoogleFonts.lexend(
          color: AppTheme.textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: challenges.length,
              itemBuilder: (context, index) {
                return _buildChallengeCard(challenges[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: AppTheme.premiumCard(),
      child: Column(
        children: [
          Text(
            'TIME REMAINING',
            style: GoogleFonts.lexend(
              color: Colors.white.withOpacity(0.8),
              letterSpacing: 2,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '4 Days : 12 Hrs',
            style: GoogleFonts.lexend(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.45,
              minHeight: 12,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(AppTheme.gold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge) {
    double percent = (challenge['current'] / challenge['goal']).clamp(0.0, 1.0);
    bool isDone = percent >= 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.whiteCard(radius: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDone ? AppTheme.success.withOpacity(0.1) : AppTheme.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              challenge['icon'] as IconData,
              color: isDone ? AppTheme.success : AppTheme.primaryRed,
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge['title'] as String,
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  challenge['desc'] as String,
                  style: GoogleFonts.lexend(
                    color: AppTheme.textSlate,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 8,
                    backgroundColor: Colors.grey[100],
                    valueColor: AlwaysStoppedAnimation(isDone ? AppTheme.success : AppTheme.primaryRed),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              if (isDone)
                const Icon(Icons.check_circle, color: AppTheme.success, size: 30)
              else
                Text(
                  '${challenge['current']}/${challenge['goal']}',
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryRed,
                    fontSize: 16,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
