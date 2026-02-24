import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
          'USER PROFILE',
          style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: 2, fontSize: 13),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            _buildAvatarSection(context, progress),
            const SizedBox(height: 32),
            _buildStatsGrid(progress),
            const SizedBox(height: 32),
            _buildAchievements(progress),
            const SizedBox(height: 32),
            _buildActions(context, progress),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context, EnhancedProgressProvider progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: AppTheme.premiumCard(radius: 40),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppTheme.primaryDark.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 10)),
              ],
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: Center(
              child: Text(progress.avatar, style: const TextStyle(fontSize: 64)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            progress.userName,
            style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  'LEVEL ${progress.level} EXPLORER',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
                ),
              ],
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
      childAspectRatio: 1.1,
      children: [
        _buildStatCard('⭐', '${progress.totalStars}', 'STARS COLLECTED'),
        _buildStatCard('🔥', '${progress.streakDays}', 'DAY STREAK'),
        _buildStatCard('🪙', '${progress.totalCoins}', 'TOTAL COINS'),
        _buildStatCard('🏆', '${progress.achievementBadges.length}', 'BADGES WON'),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.whiteCard(radius: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark),
          ),
          const SizedBox(height: 4),
          Text(
            label, 
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.textSlate, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(EnhancedProgressProvider progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: AppTheme.whiteCard(radius: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.06), borderRadius: BorderRadius.circular(10)),
                 child: const Icon(Icons.emoji_events_rounded, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'ACHIEVEMENTS',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.primary, letterSpacing: 1.5),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (progress.achievementBadges.isEmpty)
            Center(
              child: Column(
                children: [
                   const Icon(Icons.lock_outline_rounded, size: 48, color: AppTheme.borderLight),
                   const SizedBox(height: 12),
                   Text(
                     'No badges earned yet.\nStart learning to win them!',
                     textAlign: TextAlign.center,
                     style: GoogleFonts.inter(color: AppTheme.textGray, fontWeight: FontWeight.w500, height: 1.4),
                   ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: progress.achievementBadges.map((badge) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars_rounded, color: Colors.amber, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        badge, 
                        style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark),
                      ),
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
        _profileAction(
          icon: Icons.edit_rounded,
          label: 'Change My Name',
          color: AppTheme.primary,
          onTap: () => _showNameDialog(context, progress),
        ),
        const SizedBox(height: 16),
        _profileAction(
          icon: Icons.delete_forever_rounded,
          label: 'Reset My Progress',
          color: Colors.redAccent,
          onTap: () => _showResetDialog(context, progress),
        ),
      ],
    );
  }

  Widget _profileAction({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: AppTheme.whiteCard(radius: 20),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: AppTheme.borderLight),
          ],
        ),
      ),
    );
  }

  void _showNameDialog(BuildContext context, EnhancedProgressProvider progress) {
    final controller = TextEditingController(text: progress.userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('Edit Name', style: GoogleFonts.inter(fontWeight: FontWeight.w900)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            filled: true,
            fillColor: AppTheme.offWhite,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppTheme.textGray)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                progress.setUserName(controller.text);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('SAVE', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, EnhancedProgressProvider progress) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('Reset Progress?', style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.redAccent)),
        content: Text(
          'This will permanently delete all your stars, coins, and levels. This cannot be undone.',
          style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: AppTheme.textSlate),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('KEEP MY DATA', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppTheme.textGray)),
          ),
          ElevatedButton(
            onPressed: () {
              progress.resetProgress();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('RESET EVERYTHING', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
