import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../constants/tamil_data.dart';
import '../providers/progress_provider.dart';
import 'tamil_letters_screen.dart';
import 'simple_words_screen.dart';
import 'pronunciation_screen.dart';
import 'quiz_screen.dart';
import 'memory_game_screen.dart';
import 'writing_practice_screen.dart';
import 'progress_screen.dart';
import 'parent_dashboard_screen.dart';
import 'stories_screen.dart';
import 'rhymes_screen.dart';
import 'letter_hunt_screen.dart';
import 'word_builder_screen.dart';
import 'avatar_shop_screen.dart';
import 'adventure_map_screen.dart';
import 'weekly_challenge_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryRed.withOpacity(0.1), AppColors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _buildOptionsGrid(context),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final progress = Provider.of<ProgressProvider>(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryRed,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryRed.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AvatarShopScreen())),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: AppColors.white,
                      child: Icon(Icons.person, size: 45, color: _getAvatarColor(progress.currentEquipped)),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                      child: Text('${progress.level}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      progress.userName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // XP Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (progress.xp % 500) / 500,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(Colors.amber),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${progress.xp % 500} / 500 XP to Level ${progress.level + 1}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                  ],
                ),
              ),
              Column(
                children: [
                  const Icon(Icons.local_fire_department, color: AppColors.warning, size: 30),
                  Text(
                    '${progress.streakDays}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(Icons.stars, '${progress.stars}', 'Stars'),
                _buildStatItem(Icons.monetization_on, '${progress.coins}', 'Coins'),
                _buildStatItem(Icons.emoji_events, '${progress.achievementBadges.length}', 'Badges'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getAvatarColor(String id) {
    switch (id) {
      case 'red_warrior': return AppColors.primaryRed;
      case 'golden_king': return Colors.amber;
      case 'forest_scout': return Colors.green;
      case 'space_explorer': return Colors.deepPurple;
      default: return Colors.grey;
    }
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryRed, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textGray,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsGrid(BuildContext context) {
    final options = [
      {'title': 'Adventure', 'subtitle': 'சாகசம்', 'icon': Icons.map, 'screen': const AdventureMapScreen()},
      {'title': 'Weekly Challenge', 'subtitle': 'சவால்', 'icon': Icons.event, 'screen': const WeeklyChallengeScreen()},
      {'title': 'Letter Hunt', 'subtitle': 'எழுத்து வேட்டை', 'icon': Icons.radar, 'screen': const LetterHuntScreen()},
      {'title': 'Word Builder', 'subtitle': 'சொல் அமைக்க', 'icon': Icons.extension, 'screen': const WordBuilderScreen()},
      {'title': 'Tamil Letters', 'subtitle': 'எழுத்துக்கள்', 'icon': Icons.text_fields, 'screen': const TamilLettersScreen()},
      {'title': 'Simple Words', 'subtitle': 'சொற்கள்', 'icon': Icons.book, 'screen': const SimpleWordsScreen()},
      {'title': 'Writing', 'subtitle': 'பயிற்சி', 'icon': Icons.edit, 'screen': const WritingPracticeScreen()},
      {'title': 'Stories', 'subtitle': 'கதைகள்', 'icon': Icons.menu_book, 'screen': const StoriesScreen()},
      {'title': 'Rhymes', 'subtitle': 'பாடல்கள்', 'icon': Icons.music_note, 'screen': const RhymesScreen()},
      {'title': 'Memory', 'subtitle': 'விளையாட்டு', 'icon': Icons.grid_on, 'screen': const MemoryGameScreen()},
      {'title': 'Tamil Quiz', 'subtitle': 'வினாடி வினா', 'icon': Icons.quiz, 'screen': const QuizScreen()},
      {'title': 'Pronunciation', 'subtitle': 'உச்சரிப்பு', 'icon': Icons.mic, 'screen': const PronunciationScreen()},
      {'title': 'Shop', 'subtitle': 'கடை', 'icon': Icons.shopping_bag, 'screen': const AvatarShopScreen()},
      {'title': 'Progress', 'subtitle': 'முன்னேற்றம்', 'icon': Icons.trending_up, 'screen': const ProgressScreen()},
      {'title': 'Parents', 'subtitle': 'பெற்றோர்', 'icon': Icons.dashboard, 'screen': const ParentDashboardScreen()},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        itemCount: options.length,
        itemBuilder: (context, index) {
          return _buildOptionCard(
            context,
            options[index]['title'] as String,
            options[index]['subtitle'] as String,
            options[index]['icon'] as IconData,
            options[index]['screen'] as Widget,
          );
        },
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, String title, String subtitle, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryRed, AppColors.lightRed],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryRed.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.primaryRed),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansTamil(
                fontSize: 12,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
