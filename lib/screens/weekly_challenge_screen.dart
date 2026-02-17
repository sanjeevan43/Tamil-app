import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/progress_provider.dart';

class WeeklyChallengeScreen extends StatelessWidget {
  const WeeklyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<ProgressProvider>(context);
    
    // In a real app, these would change based on the current week's date.
    final List<Map<String, dynamic>> challenges = [
      {'title': 'Letter Master', 'desc': 'Learn 10 new letters', 'goal': 10, 'current': progress.totalLettersLearned % 15, 'icon': Icons.abc},
      {'title': 'Story Hunter', 'desc': 'Finish 2 story quizzes', 'goal': 2, 'current': progress.storyQuizScores.length % 3, 'icon': Icons.menu_book},
      {'title': 'Fortune Seeker', 'desc': 'Earn 500 coins', 'goal': 500, 'current': progress.coins % 600, 'icon': Icons.monetization_on},
      {'title': 'Streak Hero', 'desc': 'Keep a 7-day streak', 'goal': 7, 'current': progress.streakDays, 'icon': Icons.local_fire_department},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Challenges')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: Column(
              children: [
                const Text('TIME REMAINING', style: TextStyle(color: Colors.white70, letterSpacing: 2)),
                const SizedBox(height: 8),
                const Text('4 Days : 12 Hours', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    value: 0.45,
                    minHeight: 12,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation(Colors.amber),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: challenges.length,
              itemBuilder: (context, index) {
                final challenge = challenges[index];
                double percent = (challenge['current'] / challenge['goal']).clamp(0.0, 1.0);
                bool isDone = percent >= 1.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: isDone ? Colors.green[50] : Colors.grey[100], shape: BoxShape.circle),
                        child: Icon(challenge['icon'] as IconData, color: isDone ? Colors.green : Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(challenge['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Text(challenge['desc'] as String, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(
                              value: percent,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation(isDone ? Colors.green : AppColors.primaryRed),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      isDone 
                        ? const Icon(Icons.check_circle, color: Colors.green, size: 30)
                        : Text('${challenge['current']}/${challenge['goal']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
