import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';
import '../services/auth_service.dart';
import '../services/audio_feedback_service.dart';
import 'avatar_shop_screen.dart';
import 'splash_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context);

    // Calculate XP percentages
    int currentXP = progress.totalStars * 10;
    int nextLevelXP = progress.level * 1000;
    double xpPercent = (currentXP % nextLevelXP) / nextLevelXP;
    if (xpPercent.isNaN || xpPercent.isInfinite) xpPercent = 0.0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.secondary, size: 20),
                onPressed: () {
                  AudioFeedbackService.playTap();
                  Navigator.pop(context);
                },
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
            // Large Avatar & Scholar Title Card
            _buildLargeAvatarSection(context, progress, xpPercent),
            const SizedBox(height: 32),

            // Achievement Shelf
            _buildAchievementShelf(progress),
            const SizedBox(height: 32),

            // Stats Grid
            _buildStatsGrid(progress),
            const SizedBox(height: 32),

            // Actions & Settings
            _buildActions(context, progress),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeAvatarSection(BuildContext context, EnhancedProgressProvider progress, double xpPercent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.primary.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular Progress Ring around Avatar
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: xpPercent,
                  strokeWidth: 10,
                  backgroundColor: AppTheme.topoSilver.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                ),
              ),
              GestureDetector(
                onTap: () {
                  AudioFeedbackService.playTap();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AvatarShopScreen()),
                  );
                },
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: AppTheme.topoLight,
                  child: Text(progress.avatar, style: const TextStyle(fontSize: 56)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Name & Scholar status
          Text(
            progress.userName,
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return const Icon(Icons.star_rounded, color: AppTheme.accent, size: 18);
            }),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'LEVEL ${progress.level} • SCHOLAR APPRENTICE',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppTheme.primary,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementShelf(EnhancedProgressProvider progress) {
    final defaultBadges = [
      {'title': 'Streak Keeper', 'emoji': '🔥', 'desc': 'Keep a daily learning streak active'},
      {'title': 'Story Master', 'emoji': '📚', 'desc': 'Read 5 moral tales complete'},
      {'title': 'Tamil Genius', 'emoji': '🏆', 'desc': 'Score 100% on any vocabulary quiz'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.whiteCard(radius: 28).copyWith(
        border: Border.all(color: AppTheme.secondary.withOpacity(0.15), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'ACHIEVEMENT SHELF',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.secondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Badge list layout
          Column(
            children: defaultBadges.map((badge) {
              // Mark as unlocked if it matches unlocked status (or mock unlocked for visual demo)
              final isUnlocked = progress.streakDays > 0 && badge['title'] == 'Streak Keeper' || progress.achievementBadges.contains(badge['title']);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Opacity(
                  opacity: isUnlocked ? 1.0 : 0.5,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.topoLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isUnlocked ? AppTheme.secondary.withOpacity(0.3) : AppTheme.topoSilver),
                    ),
                    child: Row(
                      children: [
                        Text(
                          badge['emoji'] ?? '🏅',
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                badge['title'] ?? '',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              Text(
                                badge['desc'] ?? '',
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  color: AppTheme.textGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isUnlocked ? Icons.verified_rounded : Icons.lock_rounded,
                          color: isUnlocked ? AppTheme.success : AppTheme.textGray,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(EnhancedProgressProvider progress) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.9,
      children: [
        _buildStatCard('🎯', '${progress.totalStars}', 'STARS'),
        _buildStatCard('🔥', '${progress.streakDays}', 'STREAK'),
        _buildStatCard('💎', '${progress.totalCoins}', 'COINS'),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String val, String label) {
    return Container(
      decoration: AppTheme.whiteCard(radius: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            val,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppTheme.textDark,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppTheme.textGray,
              letterSpacing: 0.5,
            ),
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
          color: AppTheme.secondary,
          onTap: () {
            AudioFeedbackService.playTap();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AvatarShopScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        _profileAction(
          icon: Icons.badge_rounded,
          label: 'Edit Profile Name',
          color: AppTheme.primary,
          onTap: () {
            AudioFeedbackService.playTap();
            _showNameDialog(context, progress);
          },
        ),
        const SizedBox(height: 12),
        _profileAction(
          icon: Icons.power_settings_new_rounded,
          label: 'Sign Out Account',
          color: AppTheme.textGray,
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('auto_login_username');
            await prefs.remove('auto_login_age');
            await prefs.remove('auto_login_gender');

            progress.clearProgress();
            if (context.mounted) {
              Provider.of<AuthService>(context, listen: false).signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SplashScreen()),
                (route) => false,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _profileAction({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Container(
      decoration: AppTheme.whiteCard(radius: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.topoSilver, size: 14),
              ],
            ),
          ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('Update Identity', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.textDark)),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: 'Enter your name',
              filled: true,
              fillColor: AppTheme.topoLight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Name cannot be empty';
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
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('UPDATE', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.white)),
          ),
        ],
      ),
    );
  }
}
