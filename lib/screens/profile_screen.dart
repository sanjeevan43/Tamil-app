import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAvatarSection(context, progress),
            const SizedBox(height: 30),
            _buildStatsGrid(progress),
            const SizedBox(height: 30),
            _buildAchievements(progress),
            const SizedBox(height: 30),
            _buildActions(context, progress),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context, EnhancedProgressProvider progress) {
    final avatars = ['👦', '👧', '🧒', '👶', '🐻', '🐱', '🐶', '🦁'];
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.premiumCard(),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showAvatarPicker(context, avatars, progress),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.gold, width: 4),
              ),
              child: Center(
                child: Text(progress.avatar, style: const TextStyle(fontSize: 60)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            progress.userName,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.white),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.gold,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Level ${progress.level}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkRed),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(EnhancedProgressProvider progress) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard('⭐', '${progress.totalStars}', 'Stars'),
        _buildStatCard('🪙', '${progress.totalCoins}', 'Coins'),
        _buildStatCard('🔥', '${progress.streakDays}', 'Streak'),
        _buildStatCard('🏆', '${progress.achievementBadges.length}', 'Badges'),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCard(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryRed),
          ),
          Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.textGray)),
        ],
      ),
    );
  }

  Widget _buildAchievements(EnhancedProgressProvider progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Achievements',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryRed),
          ),
          const SizedBox(height: 16),
          if (progress.achievementBadges.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No badges yet. Keep learning!', style: TextStyle(color: AppTheme.textGray)),
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: progress.achievementBadges.map((badge) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.gold, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(badge, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, EnhancedProgressProvider progress) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => _showNameDialog(context, progress),
          icon: const Icon(Icons.edit),
          label: const Text('Change Name'),
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _showResetDialog(context, progress),
          icon: const Icon(Icons.refresh),
          label: const Text('Reset Progress'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.darkRed,
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }

  void _showAvatarPicker(BuildContext context, List<String> avatars, EnhancedProgressProvider progress) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Avatar'),
        content: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: avatars.map((avatar) {
            return GestureDetector(
              onTap: () {
                progress.setAvatar(avatar);
                Navigator.pop(context);
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.offWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryRed, width: 2),
                ),
                child: Center(child: Text(avatar, style: const TextStyle(fontSize: 36))),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showNameDialog(BuildContext context, EnhancedProgressProvider progress) {
    final controller = TextEditingController(text: progress.userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter your name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              progress.setUserName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, EnhancedProgressProvider progress) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text('This will delete all your progress. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              progress.resetProgress();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
