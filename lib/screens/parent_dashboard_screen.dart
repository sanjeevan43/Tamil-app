import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';
import 'teaching_guide_screen.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              height: 36,
              width: 36,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.topoSilver),
                boxShadow: [
                  BoxShadow(color: AppTheme.textDark.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Image.asset('assets/images/29099e40-2686-49d2-af50-5d939b785f80.png'),
            ),
            const SizedBox(width: 12),
            Text(
              'PARENT HUB',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.secondary, fontSize: 16, letterSpacing: 1.5),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(progress),
            const SizedBox(height: 32),
            
            Text(
              'WEEKLY REPORT',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppTheme.primary,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildWeeklyReport(progress),
            const SizedBox(height: 32),

            Text(
              'SKILL BREAKDOWN',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppTheme.primary,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildSkillBreakdown(progress),
            const SizedBox(height: 32),
            
            Text(
              'Teaching Tools',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildActionCard(
              context,
              'Curriculum Guide',
              'How to teach effectively',
              Icons.menu_book,
              AppTheme.primaryRed,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TeachingGuideScreen())),
            ),
            const SizedBox(height: 16),
            
            _buildActionCard(
              context,
              'Daily Goals',
              'Check today\'s progress',
              Icons.check_circle_outline,
              AppTheme.success,
              () {},
            ),
            
            const SizedBox(height: 32),
            Text(
              'Settings',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            
            Container(
              decoration: AppTheme.whiteCard(radius: 20),
              child: Column(
                children: [
                  _buildSettingTile('Focus Mode', Icons.visibility, true, (val) {}),
                  const Divider(height: 1, color: AppTheme.topoLight),
                  _buildSettingTile('Notifications', Icons.notifications, true, (val) {}),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            Center(
              child: OutlinedButton.icon(
                onPressed: () => _showResetDialog(context, progress),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reset All Progress'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.error,
                  side: const BorderSide(color: AppTheme.error),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(EnhancedProgressProvider progress) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.premiumCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.family_restroom, color: AppTheme.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Parent Mode',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                      ),
                    ),
                    Text(
                      'Track & guide your child',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppTheme.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('Level', '${progress.level}'),
                Container(width: 1, height: 24, color: AppTheme.white.withOpacity(0.3)),
                _buildStatItem('Stars', '${progress.totalStars}'),
                Container(width: 1, height: 24, color: AppTheme.white.withOpacity(0.3)),
                _buildStatItem('Learned', '${progress.totalLettersLearned}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppTheme.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 10,
            color: AppTheme.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
      BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.whiteCard(radius: 20),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 20),
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
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      color: AppTheme.textSlate,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textGray),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(String title, IconData icon, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryRed,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      title: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSlate),
          const SizedBox(width: 16),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyReport(EnhancedProgressProvider progress) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final values = [0.6, 0.8, 0.4, 0.9, 0.7, 0.3, 0.5]; // Mocked

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.whiteCard(radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('This Week', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.secondary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text('Active', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.success)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) => _buildDayBar(days[i], values[i], i == DateTime.now().weekday - 1)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Stars: ${progress.totalStars}', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary)),
              Text('Letters: ${progress.totalLettersLearned}', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textGray)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayBar(String day, double value, bool isToday) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 80 * value,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isToday
                  ? [AppTheme.primary, AppTheme.primary.withOpacity(0.7)]
                  : [AppTheme.topoSilver, AppTheme.topoLight],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: GoogleFonts.outfit(fontSize: 10, fontWeight: isToday ? FontWeight.w900 : FontWeight.w600, color: isToday ? AppTheme.primary : AppTheme.textGray)),
      ],
    );
  }

  Widget _buildSkillBreakdown(EnhancedProgressProvider progress) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.whiteCard(radius: 24),
      child: Column(
        children: [
          _buildSkillRow('Reading', 0.75, AppTheme.info),
          const SizedBox(height: 16),
          _buildSkillRow('Writing', 0.45, AppTheme.success),
          const SizedBox(height: 16),
          _buildSkillRow('Listening', 0.60, AppTheme.warning),
          const SizedBox(height: 16),
          _buildSkillRow('Speaking', 0.30, AppTheme.primaryDark),
        ],
      ),
    );
  }

  Widget _buildSkillRow(String skill, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(skill, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.secondary)),
            Text('${(value * 100).toInt()}%', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  void _showResetDialog(BuildContext context, EnhancedProgressProvider progress) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text('This will delete all progress permanently. Are you sure?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSlate)),
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
