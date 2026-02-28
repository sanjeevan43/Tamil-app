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
import 'classroom_connect_screen.dart';
import 'pronunciation_practice_game.dart';
import 'offline_dictionary_screen.dart';
import 'daily_word_screen.dart';
import 'admin_control_screen.dart';

class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen> {
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
                  const SizedBox(height: 20),
                  _buildQuickStats(progress),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Daily Goal', Icons.auto_awesome_rounded),
                        const SizedBox(height: 16),
                        _buildDailyMission(context),
                        
                        const SizedBox(height: 32),
                        _buildSectionHeader('Learning Journey', Icons.map_rounded),
                        const SizedBox(height: 16),
                        _buildMainPath(context),
                        
                        const SizedBox(height: 32),
                        _buildSectionHeader('Fun & Games', Icons.sports_esports_rounded),
                        const SizedBox(height: 16),
                        _buildFastAccessGrid(context),
                        
                        const SizedBox(height: 32),
                        _buildSectionHeader('Community & Stories', Icons.library_books_rounded),
                        const SizedBox(height: 16),
                        _buildStoriesCard(context),
                        const SizedBox(height: 12),
                        _buildConnectCard(context),
                        
                        const SizedBox(height: 32),
                        _buildSectionHeader('Your Progress', Icons.insights_rounded),
                        const SizedBox(height: 16),
                        _buildLevelSection(progress),
                        
                        const SizedBox(height: 32),
                        _buildSectionHeader('Events', Icons.event_note_rounded),
                        const SizedBox(height: 16),
                        _buildWeekendChallenge(context),
                        
                        const SizedBox(height: 48),
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

  // --- SHARED COMPONENTS ---

  Widget _buildHeader(BuildContext context, EnhancedProgressProvider progress) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          child: Hero(
            tag: 'avatar_hero',
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: Text(progress.avatar, style: const TextStyle(fontSize: 22)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vanakkam, ${progress.userName}',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Ready to master Tamil today?',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSlate.withOpacity(0.6),
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
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderLight),
          ),
          child: const Center(
            child: Icon(Icons.notifications_none_rounded, color: AppTheme.textDark, size: 22),
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildStatCard('🔥', '${progress.streakDays}', 'Streak', AppTheme.primary),
          const SizedBox(width: 12),
          _buildStatCard('⭐', '${progress.totalStars}', 'Stars', AppTheme.amber),
          const SizedBox(width: 12),
          _buildStatCard('💰', '${progress.totalCoins}', 'Coins', AppTheme.gold),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.whiteCard(radius: 20).copyWith(
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textDark),
          ),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: AppTheme.textSlate.withOpacity(0.4), letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildFastAccessGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _fastItem(context, 'Letters', 'Basic sounds', Icons.translate_rounded, const Color(0xFFEFF6FF), Colors.blue, 
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TamilLettersScreen()))),
        _fastItem(context, 'Games', 'Fun drills', Icons.sports_esports_rounded, const Color(0xFFFAF5FF), Colors.purple,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GamesHubScreen()))),
        _fastItem(context, 'Dictionary', 'New words', Icons.menu_book_rounded, const Color(0xFFF0FDF4), Colors.green,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OfflineDictionaryScreen()))),
        _fastItem(context, 'Pronounce', 'Mic check', Icons.mic_rounded, const Color(0xFFFFF7ED), Colors.orange,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PronunciationPracticeGame()))),
        _fastItem(context, 'Daily Word', 'Power word', Icons.wb_sunny_rounded, const Color(0xfffff8e1), Colors.amber,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyTamilPowerWordScreen()))),
        _fastItem(context, 'Admin', 'Manage app', Icons.admin_panel_settings_rounded, const Color(0xffffebee), Colors.red,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminControlScreen()))),
      ],
    );
  }

  Widget _fastItem(BuildContext context, String title, String sub, IconData icon, Color bg, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.whiteCard(radius: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(decoration: BoxDecoration(color: bg, shape: BoxShape.circle), padding: const EdgeInsets.all(6), child: Icon(icon, color: color, size: 18)),
            const SizedBox(height: 8),
            Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            Text(sub, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSlate.withOpacity(0.5))),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppTheme.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getTamilTitle(title), style: GoogleFonts.notoSansTamil(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            Text(title.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.textSlate, letterSpacing: 1)),
          ],
        ),
      ],
    );
  }

  Widget _buildDailyMission(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context);
    final mission = progress.dailyMissions.firstWhere((m) => !m['completed'], orElse: () => progress.dailyMissions.first);
    double percent = (mission['current'] / mission['target']).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCard(radius: 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TODAY\'S CHALLENGE', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.8), letterSpacing: 1)),
                    Text(mission['title'], style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                  ],
                ),
              ),
              const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 32),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: percent, minHeight: 6, backgroundColor: Colors.white.withOpacity(0.2), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white))),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${(percent * 100).toInt()}% Done', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
            Text('${mission['current']}/${mission['target']}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
          ]),
        ],
      ),
    );
  }

  Widget _buildMainPath(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReadingJourneyScreen())),
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
             BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
          ],
          gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(6)), child: Text('ADVENTURE', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5))),
                    const SizedBox(height: 8),
                    Text('Reading Journey', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                    Text('Explore the map of Tamil words', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withOpacity(0.7))),
                  ],
                ),
              ),
              const Icon(Icons.map_rounded, color: Colors.white24, size: 64),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelSection(EnhancedProgressProvider progress) {
    int currentXP = progress.totalStars % 100 * 10;
    int targetXP = 1000;
    double progressPercent = (currentXP / targetXP).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.03), borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.primary.withOpacity(0.05))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Level ${progress.level}', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                Text('$currentXP / $targetXP XP', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary)),
              ]),
              const Icon(Icons.stars_rounded, color: AppTheme.amber, size: 28),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: progressPercent, minHeight: 6, backgroundColor: Colors.white, valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary))),
        ],
      ),
    );
  }

  Widget _buildWeekendChallenge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.textDark, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('LIMITED', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: AppTheme.accent, letterSpacing: 1)),
            Text('The Word Hunter', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
          ])),
          const Icon(Icons.emoji_events_rounded, color: AppTheme.accent, size: 28),
        ],
      ),
    );
  }

  Widget _buildStoriesCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoriesScreen())),
      child: Container(padding: const EdgeInsets.all(16), decoration: AppTheme.whiteCard(radius: 20), child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.auto_stories_rounded, color: AppTheme.primary, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Text('Moral Stories', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textDark))),
        const Icon(Icons.chevron_right_rounded, color: AppTheme.textSlate, size: 20),
      ])),
    );
  }

  Widget _buildConnectCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClassroomConnectScreen())),
      child: Container(padding: const EdgeInsets.all(16), decoration: AppTheme.whiteCard(radius: 20), child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.forum_rounded, color: Colors.blue, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Text('Classroom Connect', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textDark))),
        const Icon(Icons.chevron_right_rounded, color: AppTheme.textSlate, size: 20),
      ])),
    );
  }

  String _getTamilTitle(String title) {
    switch (title) {
      case 'Daily Goal': return 'தினசரி பணி';
      case 'Learning Journey': return 'கற்றல் வழிகள்';
      case 'Fun & Games': return 'விளையாட்டுகள்';
      case 'Community & Stories': return 'சமூகம்';
      case 'Events': return 'நிகழ்வுகள்';
      case 'Your Progress': return 'முன்னேற்றம்';
      default: return title;
    }
  }
}
