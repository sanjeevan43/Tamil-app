import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';
import 'games_hub_screen.dart';
import 'tamil_letters_screen.dart';
import 'stories_screen.dart';
import 'profile_screen.dart';
import 'reading_journey_screen.dart';
import 'lessons_screen.dart';
import 'classroom_connect_screen.dart';

class EnhancedHomeScreen extends StatelessWidget {
  const EnhancedHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          // Dynamic Background Glow
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primary.withOpacity(0.08),
                    AppTheme.primary.withOpacity(0.01),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: _buildHeader(context, progress),
                  ),
                  const SizedBox(height: 24),
                  _buildQuickStats(progress),
                  const SizedBox(height: 32),
                  
                  // Main Content Area
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Daily Goal', Icons.auto_awesome_rounded),
                        const SizedBox(height: 16),
                        _buildDailyMission(context),
                        
                        const SizedBox(height: 32),
                        _buildSectionHeader('Quick Practice', Icons.bolt_rounded),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickPracticeScroll(context),
                  
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Learning Paths', Icons.map_rounded),
                        const SizedBox(height: 16),
                        _buildMainPath(context),
                        const SizedBox(height: 16),
                        _buildSecondaryPaths(context),
                        
                        const SizedBox(height: 32),
                        _buildSectionHeader('Your Progress', Icons.insights_rounded),
                        const SizedBox(height: 16),
                        _buildLevelSection(progress),
                        
                        const SizedBox(height: 32),
                        _buildWeekendChallenge(context),
                        
                        const SizedBox(height: 32),
                        _buildSectionHeader('Library & More', Icons.library_books_rounded),
                        const SizedBox(height: 16),
                        _buildStoriesCard(context),
                        const SizedBox(height: 16),
                        _buildConnectCard(context),
                        
                        const SizedBox(height: 80), // Extra space at bottom
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getTamilTitle(title),
              style: GoogleFonts.notoSansTamil(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            Text(
              title.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppTheme.textSlate,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, EnhancedProgressProvider progress) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
          child: Hero(
            tag: 'avatar_hero',
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: AppTheme.primary.withOpacity(0.1), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  progress.avatar,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vanakkam,',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSlate,
                ),
              ),
              Text(
                progress.userName,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        _buildNotificationButton(),
      ],
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderLight),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.textDark),
          ),
        ),
        Positioned(
          right: 12,
          top: 12,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(EnhancedProgressProvider progress) {
    return Container(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildStatCard('⭐', '${progress.totalStars}', 'Stars', AppTheme.amber),
          const SizedBox(width: 12),
          _buildStatCard('🔥', '${progress.streakDays}', 'Streak', AppTheme.primary),
          const SizedBox(width: 12),
          _buildStatCard('💰', '${progress.totalCoins}', 'Coins', AppTheme.gold),
          const SizedBox(width: 12),
          _buildStatCard('🏆', '${progress.level}', 'Level', Colors.blue),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, Color color) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.whiteCard(radius: 20).copyWith(
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppTheme.textSlate.withOpacity(0.6),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyMission(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context);
    final mission = progress.dailyMissions.firstWhere((m) => !m['completed'], orElse: () => progress.dailyMissions.first);
    double percent = (mission['current'] / mission['target']).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.premiumCard(radius: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TODAY\'S TASK',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mission['title'],
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percent,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(percent * 100).toInt()}% Completed',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                '${mission['current']}/${mission['target']}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPracticeScroll(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        physics: const BouncingScrollPhysics(),
        children: [
          _practiceItem(
            context,
            'Vocabulary',
            'Learn words',
            Icons.translate_rounded,
            const Color(0xFFE0F2FE),
            Colors.blue,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TamilLettersScreen())),
          ),
          const SizedBox(width: 16),
          _practiceItem(
            context,
            'Pronounce',
            'Speak Tamil',
            Icons.mic_none_rounded,
            const Color(0xFFF0FDF4),
            Colors.green,
            () {}, // Add proper navigation
          ),
          const SizedBox(width: 16),
          _practiceItem(
            context,
            'Games',
            'Fun drills',
            Icons.sports_esports_rounded,
            const Color(0xFFFFF7ED),
            Colors.orange,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GamesHubScreen())),
          ),
        ],
      ),
    );
  }

  Widget _practiceItem(BuildContext context, String title, String sub, IconData icon, Color bg, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.whiteCard(radius: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark),
            ),
            Text(
              sub,
              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSlate.withOpacity(0.5), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainPath(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReadingJourneyScreen())),
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          image: const DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?auto=format&fit=crop&q=80&w=800'),
            fit: BoxFit.cover,
            opacity: 0.2,
          ),
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.4)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ADVENTURE',
                  style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Reading Journey',
                style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              Text(
                'Explore the map of Tamil words',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryPaths(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _pathItem(
            context,
            'Lessons',
            'Full course',
            Icons.school_rounded,
            AppTheme.primary,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LessonsScreen())),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _pathItem(
            context,
            'Mini Games',
            'Fun Hub',
            Icons.gamepad_rounded,
            Colors.deepPurple,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GamesHubScreen())),
          ),
        ),
      ],
    );
  }

  Widget _pathItem(BuildContext context, String title, String sub, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.whiteCard(radius: 24),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textDark),
            ),
            Text(
              sub,
              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSlate.withOpacity(0.5)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelSection(EnhancedProgressProvider progress) {
    int currentXP = progress.totalStars % 100 * 10;
    int targetXP = 1000;
    double progressPercent = (currentXP / targetXP).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.03),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.primary.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level ${progress.level}',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                  ),
                  Text(
                    '$currentXP / $targetXP XP',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary),
                  ),
                ],
              ),
              const Icon(Icons.stars_rounded, color: AppTheme.amber, size: 32),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressPercent,
              minHeight: 10,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Keep going! ${((targetXP - currentXP) / 10).toInt()} stars to Level ${progress.level + 1}',
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSlate, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekendChallenge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LIMITED EVENT',
                  style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.accent, letterSpacing: 2),
                ),
                const SizedBox(height: 4),
                Text(
                  'The Word Hunter',
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                Text(
                  'Win a rare badge!',
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 8)],
            ),
            child: const Icon(Icons.emoji_events_rounded, color: AppTheme.accent, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildStoriesCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoriesScreen())),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.whiteCard(radius: 24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.auto_stories_rounded, color: AppTheme.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Moral Stories',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                  ),
                  Text(
                    'Read ancient wisdom tales',
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSlate.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textSlate),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClassroomConnectScreen())),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.whiteCard(radius: 24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.forum_rounded, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Classroom Connect',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                  ),
                  Text(
                    'Talk to your teacher',
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSlate.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textSlate),
          ],
        ),
      ),
    );
  }

  String _getTamilTitle(String title) {
    switch (title) {
      case 'Daily Goal': return 'தினசரி குறிக்கோள்';
      case 'Quick Practice': return 'விரைவான பயிற்சி';
      case 'Learning Paths': return 'கற்றல் வழிகள்';
      case 'Your Progress': return 'உங்கள் முன்னேற்றம்';
      case 'Library & More': return 'நூலகம் மற்றும் கூடுதல்';
      default: return title;
    }
  }
}
