import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';
import '../services/auth_service.dart';
import 'avatar_shop_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.secondary, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          'MY PROFILE',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.secondary, letterSpacing: 2, fontSize: 13),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            _buildAvatarSection(context, progress),
            const SizedBox(height: 32),
            _buildStatsGrid(progress),
            const SizedBox(height: 32),
            _buildStreakCalendar(progress),
            const SizedBox(height: 32),
            _buildXPProgress(progress),
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
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AvatarShopScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: AppTheme.premiumCard(radius: 40),
        child: Column(
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: AppTheme.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppTheme.textDark.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 15)),
                ],
                border: Border.all(color: AppTheme.white.withOpacity(0.3), width: 8),
              ),
              child: Center(
                child: Text(progress.avatar, style: const TextStyle(fontSize: 70)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              progress.userName,
              style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.white, letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap avatar to customize style 🛍️',
              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.white.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_rounded, color: AppTheme.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'LVL ${progress.level} TAMIL SCHOLAR',
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.white, letterSpacing: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        _buildStatCard('🎯', '${progress.totalStars}', 'STARS HELD', AppTheme.primary),
        _buildStatCard('🔥', '${progress.streakDays}', 'DAY STREAK', AppTheme.warning),
        _buildStatCard('💎', '${progress.totalCoins}', 'TOTAL COINS', AppTheme.info),
        _buildStatCard('🏆', '${progress.achievementBadges.length}', 'BADGES WON', AppTheme.success),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, Color accent) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.whiteCard(radius: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: accent.withOpacity(0.1), shape: BoxShape.circle),
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.secondary),
          ),
          Text(
            label, 
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.textGray, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCalendar(EnhancedProgressProvider progress) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final today = DateTime.now().weekday - 1;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: AppTheme.whiteCard(radius: 32).copyWith(
        border: Border.all(color: AppTheme.topoSilver, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.local_fire_department_rounded, color: AppTheme.warning, size: 22),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('STREAK CALENDAR', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.secondary, letterSpacing: 1)),
                  Text('${progress.streakDays} day streak', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textGray)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final isCurrent = index == today;
              final isDone = index <= today;
              return Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: isDone
                          ? LinearGradient(colors: [AppTheme.warning, AppTheme.warning.withOpacity(0.7)])
                          : null,
                      color: isDone ? null : AppTheme.topoLight,
                      shape: BoxShape.circle,
                      border: isCurrent ? Border.all(color: AppTheme.warning, width: 3) : null,
                      boxShadow: isDone
                          ? [BoxShadow(color: AppTheme.warning.withOpacity(0.3), blurRadius: 8)]
                          : null,
                    ),
                    child: Center(
                      child: isDone
                          ? const Icon(Icons.check_rounded, color: AppTheme.white, size: 18)
                          : Text(days[index], style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textGray)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(days[index], style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: isDone ? AppTheme.warning : AppTheme.textGray)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildXPProgress(EnhancedProgressProvider progress) {
    int currentXP = progress.totalStars * 10;
    int nextLevelXP = progress.level * 1000;
    double xpPercent = (currentXP % nextLevelXP) / nextLevelXP;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.secondary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LEVEL ${progress.level}', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.white.withOpacity(0.7), letterSpacing: 2)),
                  const SizedBox(height: 4),
                  Text('XP Progress', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.white)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.white.withOpacity(0.15), shape: BoxShape.circle),
                child: const Text('⚡', style: TextStyle(fontSize: 24)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: xpPercent.clamp(0.0, 1.0),
              minHeight: 14,
              backgroundColor: AppTheme.white.withOpacity(0.15),
              valueColor: const AlwaysStoppedAnimation(AppTheme.warning),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${currentXP % nextLevelXP} XP', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.warning)),
              Text('$nextLevelXP XP to Level ${progress.level + 1}', style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.white.withOpacity(0.7))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(EnhancedProgressProvider progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: AppTheme.whiteCard(radius: 40).copyWith(
        color: AppTheme.topoLight,
        border: Border.all(color: AppTheme.topoSilver, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                 padding: const EdgeInsets.all(10),
                 decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                 child: const Icon(Icons.stars_rounded, color: AppTheme.primary, size: 22),
              ),
              const SizedBox(width: 16),
              Text(
                'HALL OF FAME',
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.secondary, letterSpacing: 2),
              ),
            ],
          ),
          const SizedBox(height: 28),
          if (progress.achievementBadges.isEmpty)
            Center(
              child: Column(
                children: [
                   Icon(Icons.lock_person_rounded, size: 56, color: AppTheme.secondary.withOpacity(0.05)),
                   const SizedBox(height: 16),
                   Text(
                     'No badges earned yet.\nStart learning to win them!',
                     textAlign: TextAlign.center,
                     style: GoogleFonts.outfit(color: AppTheme.textGray, fontWeight: FontWeight.w600, height: 1.5),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.topoSilver),
                    boxShadow: [
                      BoxShadow(color: AppTheme.textDark.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded, color: AppTheme.primary, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        badge, 
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.secondary),
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
          icon: Icons.storefront_rounded,
          label: 'Visit Avatar Shop',
          color: AppTheme.info,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AvatarShopScreen()),
            );
          },
        ),
        const SizedBox(height: 16),
        _profileAction(
          icon: Icons.badge_rounded,
          label: 'Edit Profile Name',
          color: AppTheme.secondary,
          onTap: () => _showNameDialog(context, progress),
        ),
        const SizedBox(height: 16),
        _profileAction(
          icon: Icons.refresh_rounded,
          label: 'Factory Reset Progress',
          color: AppTheme.primary,
          onTap: () => _showResetDialog(context, progress),
        ),
        const SizedBox(height: 16),
        _profileAction(
          icon: Icons.power_settings_new_rounded,
          label: 'Sign Out Account',
          color: AppTheme.textGray,
          onTap: () {
            Provider.of<AuthService>(context, listen: false).signOut();
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ],
    );
  }

  Widget _profileAction({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: AppTheme.whiteCard(radius: 28),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color, size: 24)),
            const SizedBox(width: 20),
            Text(
              label,
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.secondary),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.topoSilver, size: 16),
          ],
        ),
      ),
    );
  }

  void _showNameDialog(BuildContext context, EnhancedProgressProvider progress) {
    final controller = TextEditingController(text: progress.userName);
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: Text('Update Identity', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.secondary)),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              hintText: 'Enter your name',
              filled: true,
              fillColor: AppTheme.topoLight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Name cannot be empty';
              }
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }
              if (value.trim().length > 50) {
                return 'Name must be less than 50 characters';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppTheme.textGray)),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                progress.setUserName(controller.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: Text('UPDATE', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.white)),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, EnhancedProgressProvider progress) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: Text('Reset Explorer Stats?', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.primary)),
        content: Text(
          'This will permanently erase all your milestones, coins, and scholarly level. This action is irreversible.',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: AppTheme.textGray, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('KEEP DATA', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppTheme.textGray)),
          ),
          ElevatedButton(
            onPressed: () {
              progress.resetProgress();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: Text('ERASE ALL', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.white)),
          ),
        ],
      ),
    );
  }
}
