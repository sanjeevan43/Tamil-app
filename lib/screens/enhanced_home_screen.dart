import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';
import '../services/auth_service.dart';
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
import 'leaderboard_screen.dart';
import 'community_forum_screen.dart';

class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: _buildSearchBar(),
                  ),
                  const SizedBox(height: 24),
                  if (_searchQuery.isNotEmpty)
                    _buildSearchResults()
                  else ...[
                    _buildQuickStats(progress),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          _buildDailyMission(context),
                          const SizedBox(height: 32),
                          _buildSectionHeader('Leaderboard', Icons.leaderboard_rounded),
                          const SizedBox(height: 16),
                          _buildLeaderboardPreview(context, progress),
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
                          _buildSectionHeader('Your Achievements', Icons.emoji_events_rounded),
                          const SizedBox(height: 16),
                          _buildAchievementGallery(progress),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.topoSilver.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search letters, stories, rhymes...',
          hintStyle: GoogleFonts.outfit(
            color: AppTheme.textGray.withOpacity(0.6),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          icon: const Icon(Icons.search_rounded, color: AppTheme.primary, size: 22),
          suffixIcon: _searchQuery.isNotEmpty 
            ? IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tune_rounded, color: AppTheme.primary, size: 16),
              ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, EnhancedProgressProvider progress) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          child: Hero(
            tag: 'profile_avatar',
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary, width: 2),
                boxShadow: [
                  BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: AppTheme.offWhite,
                child: Text(progress.avatar, style: const TextStyle(fontSize: 24)),
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
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textGray,
                ),
              ),
              Text(
                progress.userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.secondary,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 54,
          width: 54,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.topoSilver, width: 1),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8)),
            ],
          ),
          child: Image.asset(
            'assets/images/29099e40-2686-49d2-af50-5d939b785f80.png',
            fit: BoxFit.contain,
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
          _buildStatCard('🎯', '${progress.totalStars}', 'Stars', const Color(0xFF6200EA)),
          const SizedBox(width: 12),
          _buildStatCard('💎', '${progress.totalCoins}', 'Coins', const Color(0xFF00B0FF)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, Color color) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Text(emoji, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.secondary),
          ),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.textGray, letterSpacing: 0.5),
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
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.05,
      children: [
        _fastItem(context, 'Letters', 'Basic sounds', Icons.translate_rounded, const Color(0xFFE3F2FD), Colors.blue,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TamilLettersScreen()))),
        _fastItem(context, 'Games', 'Fun drills', Icons.sports_esports_rounded, const Color(0xFFF3E5F5), Colors.purple,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GamesHubScreen()))),
        _fastItem(context, 'Dictionary', 'New words', Icons.menu_book_rounded, const Color(0xFFE8F5E9), Colors.green,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OfflineDictionaryScreen()))),
        _fastItem(context, 'Pronounce', 'Mic check', Icons.mic_rounded, const Color(0xFFFFF3E0), Colors.orange,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PronunciationPracticeGame()))),
        _fastItem(context, 'Daily Word', 'Power word', Icons.wb_sunny_rounded, const Color(0xFFFFFDE7), Colors.amber,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyTamilPowerWordScreen()))),
        _fastItem(context, 'Q&A Forum', 'Ask others', Icons.forum_rounded, const Color(0xFFF1F8E9), Colors.teal,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunityForumScreen()))),
        _fastItem(context, 'Classrooms', 'Learn together', Icons.school_rounded, const Color(0xFFE8EAF6), Colors.indigo,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClassroomConnectScreen()))),
        if (Provider.of<AuthService>(context, listen: false).userRole == 'admin')
          _fastItem(context, 'Admin', 'Manage app', Icons.admin_panel_settings_rounded, const Color(0xFFFFEBEE), AppTheme.primary,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminControlScreen()))),
      ],
    );
  }

  Widget _fastItem(BuildContext context, String title, String sub, IconData icon, Color bg, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.1), width: 1.5),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: color, size: 22),
            ),
            const Spacer(),
            Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.secondary), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(sub, style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.textGray, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.secondary.withOpacity(0.05), borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: AppTheme.secondary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_getTamilTitle(title), style: GoogleFonts.notoSansTamil(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.secondary), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(title.toUpperCase(), style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textGray, letterSpacing: 1.5)),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.topoSilver),
      ],
    );
  }

  Widget _buildDailyMission(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context);
    final mission = progress.dailyMissions.firstWhere((m) => !m['completed'], orElse: () => progress.dailyMissions.first);
    double percent = (mission['current'] / mission['target']).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.secondary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 25, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CORE CHALLENGE', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.6), letterSpacing: 2)),
                    const SizedBox(height: 4),
                    Text(
                      mission['title'], 
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(percent * 100).toInt()}% COMPLETED', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white.withOpacity(0.9))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text('${mission['current']}/${mission['target']}', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainPath(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReadingJourneyScreen())),
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [AppTheme.secondary, Color(0xFF2C2C2E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: AppTheme.secondary.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 15)),
          ],
        ),
        child: Stack(
          children: [
            Positioned(right: -20, bottom: -20, child: Icon(Icons.explore_rounded, size: 140, color: Colors.white.withOpacity(0.05))),
            Padding(
              padding: const EdgeInsets.all(28),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(8)),
                          child: Text('EPIC JOURNEY', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                        ),
                        const SizedBox(height: 12),
                        Text('Reading Path', style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
                        Text('Master Tamil one word at a time', style: GoogleFonts.outfit(fontSize: 13, color: Colors.white.withOpacity(0.6))),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 32),
                ],
              ),
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
        color: AppTheme.topoLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.topoSilver, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                    child: Text('${progress.level}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CURRENT LEVEL', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textGray, letterSpacing: 1)),
                      Text('Novice Pro', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.secondary)),
                    ],
                  ),
                ],
              ),
              Text('$currentXP/$targetXP XP', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.primary)),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressPercent,
              minHeight: 10,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekendChallenge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppTheme.secondary.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('EXCLUSIVE EVENT', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.primary, letterSpacing: 2)),
                const SizedBox(height: 4),
                Text('The Word Hunter', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.emoji_events_rounded, color: AppTheme.primary, size: 28),
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.primary.withOpacity(0.1), width: 1.5),
          boxShadow: [
            BoxShadow(color: AppTheme.primary.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.auto_stories_rounded, color: AppTheme.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text('Moral Stories', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.secondary))),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.topoSilver, size: 24),
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.blue.withOpacity(0.1), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.forum_rounded, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text('Classroom Connect', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.secondary))),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.topoSilver, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardPreview(BuildContext context, EnhancedProgressProvider progress) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppTheme.topoSilver, width: 1.5),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GLOBAL RANKING', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textGray, letterSpacing: 1)),
                      Text('Top Performers', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.secondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars_rounded, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text('${progress.totalStars}', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.secondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .orderBy('progress.totalStars', descending: true)
                  .limit(4)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final topUsers = snapshot.data!.docs;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(topUsers.length, (index) {
                    final userData = topUsers[index].data() as Map<String, dynamic>;
                    final userProgress = userData['progress'] as Map<String, dynamic>?;
                    final totalStars = userProgress?['totalStars'] ?? 0;
                    final displayName = userData['displayName'] ?? 'User';
                    final isMe = topUsers[index].id == progress.userId;
                    
                    return _miniRank(
                      '${index + 1}',
                      userData['photoURL'] != null && userData['photoURL'].isNotEmpty ? userData['photoURL'] : (isMe ? progress.avatar : '👤'),
                      displayName,
                      isMe: isMe,
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniRank(String rank, String avatar, String name, {bool isMe = false}) {
    bool isUrl = avatar.startsWith('http');
    
    return Column(
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isMe ? AppTheme.primary : AppTheme.topoLight,
                shape: BoxShape.circle,
                border: Border.all(color: isMe ? AppTheme.primary : AppTheme.topoSilver, width: 2),
              ),
              child: ClipOval(
                child: Center(
                  child: isUrl 
                    ? Image.network(
                        avatar, 
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Text('👤', style: TextStyle(fontSize: 20)),
                      )
                    : Text(avatar, style: const TextStyle(fontSize: 20)),
                ),
              ),
            ),
            if (isMe)
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                child: const Icon(Icons.check, size: 8, color: Colors.white),
              ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 70,
          child: Text(
            name, 
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 10, fontWeight: isMe ? FontWeight.w900 : FontWeight.w600, color: isMe ? AppTheme.primary : AppTheme.secondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text('#$rank', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.textGray)),
      ],
    );
  }

  Widget _buildAchievementGallery(EnhancedProgressProvider progress) {
    final List<String> badges = ['🏆', '🏅', '🌟', '🎯', '🔥', '📚'];
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: badges.length,
        itemBuilder: (context, index) {
          final isUnlocked = index < 3; // Mocking first 3 as unlocked
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: isUnlocked ? Colors.white : AppTheme.topoLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isUnlocked ? AppTheme.primary.withOpacity(0.2) : Colors.transparent, width: 1.5),
              boxShadow: isUnlocked ? [BoxShadow(color: AppTheme.primary.withOpacity(0.05), blurRadius: 10)] : null,
            ),
            child: Center(
              child: Opacity(
                opacity: isUnlocked ? 1.0 : 0.4,
                child: Text(badges[index], style: const TextStyle(fontSize: 32)),
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildCompanion(EnhancedProgressProvider progress) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFFFFEBEE),
              child: Text('👋', style: TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TAMIL BUDDY',
                  style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.8), letterSpacing: 1.5),
                ),
                const SizedBox(height: 4),
                Text(
                  _getCompanionMessage(progress),
                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCompanionMessage(EnhancedProgressProvider progress) {
    if (progress.streakDays == 0) return "Vanakkam! Let's start your learning journey today!";
    if (progress.streakDays > 5) return "You're on fire! ${progress.streakDays} days in a row. Amazing!";
    return "Great to see you again! Ready to earn some stars?";
  }



  String _getTamilTitle(String title) {
    switch (title) {
      case 'Daily Goal':
        return 'தினசரி பணி';
      case 'Leaderboard':
        return 'முன்னணியில் உள்ளவர்கள்';
      case 'Learning Journey':
        return 'கற்றல் வழிகள்';
      case 'Fun & Games':
        return 'விளையாட்டுகள்';
      case 'Community & Stories':
        return 'சமூகம்';
      case 'Your Achievements':
        return 'வெற்றிகள்';
      case 'Events':
        return 'நிகழ்வுகள்';
      case 'Your Progress':
        return 'முன்னேற்றம்';
      default:
        return title;
    }
  }

  Widget _buildSearchResults() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Results for "${_searchQuery}"',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.secondary),
          ),
          const SizedBox(height: 20),
          _buildSearchItem('Stories', Icons.auto_stories_rounded, AppTheme.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoriesScreen()))),
          _buildSearchItem('Rhymes', Icons.music_note_rounded, Colors.pink, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RhymesScreen()))),
          _buildSearchItem('Games Hub', Icons.sports_esports_rounded, Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GamesHubScreen()))),
          _buildSearchItem('Tamil Letters', Icons.translate_rounded, Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TamilLettersScreen()))),
          _buildSearchItem('Daily Word', Icons.wb_sunny_rounded, Colors.amber, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyTamilPowerWordScreen()))),
          _buildSearchItem('Leaderboard', Icons.leaderboard_rounded, Colors.deepPurple, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen()))),
        ],
      ),
    );
  }

  Widget _buildSearchItem(String title, IconData icon, Color color, VoidCallback onTap) {
    if (!title.toLowerCase().contains(_searchQuery.toLowerCase())) return const SizedBox.shrink();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.1))),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
            const SizedBox(width: 16),
            Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.secondary)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.topoSilver),
          ],
        ),
      ),
    );
  }
}
