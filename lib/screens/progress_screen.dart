import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('எனது முன்னேற்றம் (My Progress)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(progress),
            const SizedBox(height: 24),
            _buildStatGrid(progress),
            const SizedBox(height: 24),
            _buildAchievementSection(progress),
            const SizedBox(height: 24),
            _buildChartPlaceholder(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(EnhancedProgressProvider progress) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.premiumCard(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Text(progress.avatar, style: const TextStyle(fontSize: 40)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  progress.userName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'நிலை ${progress.level} (Level ${progress.level})',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: (progress.xp % 500) / 500,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Colors.amber),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid(EnhancedProgressProvider progress) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('⭐', '${progress.stars}', 'நட்சத்திரங்கள்'),
        _buildStatCard('🔥', '${progress.streakDays}', 'தொடர் நாட்கள்'),
        _buildStatCard('🔤', '${progress.totalLettersLearned}', 'எழுத்துக்கள்'),
        _buildStatCard('🪙', '${progress.coins}', 'நாணயங்கள்'),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassCard(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryRed)),
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textGray)),
        ],
      ),
    );
  }

  Widget _buildAchievementSection(EnhancedProgressProvider progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCard(),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'சாதனைகள் (Achievements)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryRed),
          ),
          const SizedBox(height: 16),
          if (progress.achievementBadges.isEmpty)
            const Text('சாதனைகள் இன்னும் இல்லை. விளையாட்டைத் தொடரவும்!', style: TextStyle(color: Colors.grey))
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: progress.achievementBadges.map((badge) => _buildBadge(badge)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildBadge(String name) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(color: Colors.amberAccent, shape: BoxShape.circle),
          child: const Icon(Icons.emoji_events, color: Colors.orange),
        ),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildChartPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCard(),
      width: double.infinity,
      child: const Column(
        children: [
          Text(
            'வாராந்திர முன்னேற்றம் (Weekly Activity)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryRed),
          ),
          SizedBox(height: 40),
          Icon(Icons.bar_chart, size: 100, color: Colors.grey),
          Text('Activity data will appear here', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
