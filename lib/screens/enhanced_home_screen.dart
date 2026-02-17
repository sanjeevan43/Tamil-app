import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../constants/tamil_data.dart';
import '../providers/enhanced_progress_provider.dart';
import 'lessons_screen.dart';
import 'games_hub_screen.dart';
import 'profile_screen.dart';
import 'teacher_dashboard_screen.dart';

class EnhancedHomeScreen extends StatelessWidget {
  const EnhancedHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryRed.withOpacity(0.05), AppTheme.offWhite],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildQuickStats(context),
                const SizedBox(height: 30),
                _buildMainOptions(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.premiumCard(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.gold, width: 3),
                ),
                child: Center(
                  child: Text(
                    progress.avatar,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      progress.userName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.gold,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Level ${progress.level}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkRed,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.local_fire_department, color: AppTheme.warning, size: 20),
                        Text(
                          '${progress.streakDays}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
                icon: const Icon(Icons.settings, color: AppTheme.white, size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              '⭐',
              '${progress.totalStars}',
              'Stars',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              '🪙',
              '${progress.totalCoins}',
              'Coins',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              '🏆',
              '${progress.achievementBadges.length}',
              'Badges',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassCard(),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryRed,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainOptions(BuildContext context) {
    final options = [
      {
        'title': 'Learn Lessons',
        'subtitle': 'பாடங்கள்',
        'icon': Icons.school,
        'gradient': [AppTheme.primaryRed, AppTheme.darkRed],
        'screen': const LessonsScreen(),
      },
      {
        'title': 'Play Games',
        'subtitle': 'விளையாட்டுகள்',
        'icon': Icons.games,
        'gradient': [AppTheme.accentRed, AppTheme.primaryRed],
        'screen': const GamesHubScreen(),
      },
      {
        'title': 'Teacher Mode',
        'subtitle': 'ஆசிரியர்',
        'icon': Icons.person,
        'gradient': [AppTheme.darkRed, AppTheme.primaryRed],
        'screen': const TeacherDashboardScreen(),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: options.map((option) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildOptionCard(
              context,
              option['title'] as String,
              option['subtitle'] as String,
              option['icon'] as IconData,
              option['gradient'] as List<Color>,
              option['screen'] as Widget,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    List<Color> gradient,
    Widget screen,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 40, color: AppTheme.primaryRed),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.white,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppTheme.white, size: 24),
          ],
        ),
      ),
    );
  }
}
