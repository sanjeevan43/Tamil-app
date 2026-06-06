import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';
import '../services/auth_service.dart';
import 'games_hub_screen.dart';
import 'tamil_letters_screen.dart';
import 'stories_screen.dart';
import 'profile_screen.dart';
import 'classroom_connect_screen.dart';
import 'pronunciation_practice_game.dart';
import 'admin_control_screen.dart';
import '../services/thirukkural_service.dart';
import '../services/proverb_service.dart';
import 'rhymes_screen.dart';
import 'community_forum_screen.dart';
import 'lesson_screen.dart';

// Newly renamed/split AI screens
import 'ai_cognitive_academy_screen.dart';
import 'riddle_academy_screen.dart';
import 'linguistic_scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Thirukkural? _dailyKural;
  bool _isLoadingKural = true;
  TamilProverb? _dailyProverb;

  @override
  void initState() {
    super.initState();
    _fetchKural();
    _fetchProverb();
  }

  Future<void> _fetchProverb() async {
    final proverb = await ProverbService.getDailyProverb();
    if (mounted) {
      setState(() {
        _dailyProverb = proverb;
      });
    }
  }

  Future<void> _fetchKural() async {
    try {
      final kural = await ThirukkuralService.fetchDailyKural();
      if (mounted) {
        setState(() {
          _dailyKural = kural;
          _isLoadingKural = false;
        });
      }
    } catch (e) {
      debugPrint('HomeScreen: Error fetching Kural: $e');
      if (mounted) {
        setState(() {
          _isLoadingKural = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildDailyKuralSection(),
                      _buildDailyProverbSection(),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: _buildHeader(),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: _buildSearchBar(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    sliver: SliverToBoxAdapter(
                      child: _buildSearchResults(),
                    ),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildQuickStats(),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: _buildSectionHeader('AI Cognitive Academy', Icons.auto_awesome_rounded),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: _buildAIAcademyCard(),
                        ),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: _buildSectionHeader('Fun & Games', Icons.sports_esports_rounded),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    sliver: _buildFastAccessSliverGrid(),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 120), // Padding to scroll past the bottom bar
                  ),
                ],
              ],
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
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.topoSilver.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textDark.withOpacity(0.04),
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

  Widget _buildHeader() {
    return Consumer<EnhancedProgressProvider>(
      builder: (context, progress, child) {
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
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.topoSilver, width: 1),
                boxShadow: [
                  BoxShadow(color: AppTheme.textDark.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: Image.asset(
                'assets/images/29099e40-2686-49d2-af50-5d939b785f80.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return Consumer<EnhancedProgressProvider>(
      builder: (context, progress, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildStatCard('🔥', '${progress.streakDays}', 'Streak', AppTheme.primary),
              const SizedBox(width: 12),
              _buildStatCard('🎯', '${progress.totalStars}', 'Stars', AppTheme.warning),
              const SizedBox(width: 12),
              _buildStatCard('💎', '${progress.totalCoins}', 'Coins', AppTheme.info),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, Color color) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
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

  Widget _buildFastAccessSliverGrid() {
    return Consumer<EnhancedProgressProvider>(
      builder: (context, progress, child) {
        final adaptiveAge = progress.level + 5;
        final items = [
          _fastItem(context, 'Dictionary', 'New words', Icons.menu_book_rounded, AppTheme.success.withOpacity(0.1), AppTheme.success,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => LinguisticScannerScreen(childAge: adaptiveAge)))),
          _fastItem(context, 'Pronounce', 'Mic check', Icons.mic_rounded, const Color(0xFFFFF3E0), AppTheme.warning,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PronunciationPracticeGame()))),
          _fastItem(context, 'Daily Word', 'Power word', Icons.wb_sunny_rounded, const Color(0xFFFFFDE7), AppTheme.warning,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => RiddleAcademyScreen(childAge: adaptiveAge)))),
          _fastItem(context, 'Q&A Forum', 'Ask others', Icons.forum_rounded, const Color(0xFFF1F8E9), AppTheme.success,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunityForumScreen()))),
          _fastItem(context, 'Learn English', 'Duolingo style', Icons.language_rounded, const Color(0xFFE0F7FA), AppTheme.info,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LessonScreen(lessonId: 'animals_1')))),
          _fastItem(context, 'Classrooms', 'Learn together', Icons.school_rounded, const Color(0xFFE8EAF6), AppTheme.secondary,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClassroomConnectScreen()))),
          if (Provider.of<AuthService>(context, listen: false).userRole == 'admin')
            _fastItem(context, 'Admin', 'Manage app', Icons.admin_panel_settings_rounded, const Color(0xFFFFEBEE), AppTheme.primary,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminControlScreen()))),
        ];

        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.05,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => items[index],
            childCount: items.length,
          ),
        );
      },
    );
  }

  Widget _fastItem(BuildContext context, String title, String sub, IconData icon, Color bg, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.white,
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

  // Removed unwanted _buildDailyMission and _buildMainPath

  Widget _buildAIAcademyCard() {
    return Consumer<EnhancedProgressProvider>(
      builder: (context, progress, child) {
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AICognitiveAcademyScreen(
                childAge: progress.level + 5,
                childName: progress.userName,
              ),
            ),
          ),
          child: Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(color: const Color(0xFF3F51B5).withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 15)),
              ],
            ),
            child: Stack(
              children: [
                Positioned(right: -10, bottom: -10, child: Icon(Icons.auto_awesome_rounded, size: 130, color: Colors.white.withOpacity(0.06))),
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
                              child: Text('AI ACADEMY', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                            ),
                            const SizedBox(height: 12),
                            Text('AI Cognitive Academy', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                            Text('Personalized learning powered by AI', style: GoogleFonts.outfit(fontSize: 13, color: Colors.white.withOpacity(0.7))),
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
      },
    );
  }

  // Removed unwanted _buildLevelSection and _buildWeekendChallenge


  String _getTamilTitle(String title) {
    switch (title) {
      case 'Daily Goal':
        return 'தினசரி பணி';
      case 'Leaderboard':
        return 'முன்னணியில் உள்ளவர்கள்';
      case 'Learning Journey':
        return 'கற்றல் வழிகள்';
      case 'AI Cognitive Academy':
        return 'செயற்கை நுண்ணறிவு அகாடமி';
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
    return Consumer<EnhancedProgressProvider>(
      builder: (context, progress, child) {
        final adaptiveAge = progress.level + 5;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Results for "$_searchQuery"',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.secondary),
              ),
              const SizedBox(height: 20),
              _buildSearchItem('Stories', Icons.auto_stories_rounded, AppTheme.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoriesScreen()))),
              _buildSearchItem('Rhymes', Icons.music_note_rounded, AppTheme.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RhymesScreen()))),
              _buildSearchItem('Games Hub', Icons.sports_esports_rounded, AppTheme.warning, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GamesHubScreen()))),
              _buildSearchItem('Tamil Letters', Icons.translate_rounded, AppTheme.info, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TamilLettersScreen()))),
              _buildSearchItem('Daily Word', Icons.wb_sunny_rounded, AppTheme.warning, () => Navigator.push(context, MaterialPageRoute(builder: (_) => RiddleAcademyScreen(childAge: adaptiveAge)))),
              _buildSearchItem('Leaderboard', Icons.leaderboard_rounded, AppTheme.primaryDark, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Top rankings are dynamically calculated from Firestore! 🏆', style: GoogleFonts.outfit(fontWeight: FontWeight.w600))),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchItem(String title, IconData icon, Color color, VoidCallback onTap) {
    if (!title.toLowerCase().contains(_searchQuery.toLowerCase())) return const SizedBox.shrink();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.1))),
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

  Widget _buildDailyProverbSection() {
    if (_dailyProverb == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.warning.withOpacity(0.05), AppTheme.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.warning.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppTheme.warning.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.warning.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Text('💡', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'இன்றைய பழமொழி',
                    style: GoogleFonts.notoSansTamil(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.warning.withOpacity(0.9),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _dailyProverb!.proverb,
                    style: GoogleFonts.notoSansTamil(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyKuralSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primary.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _isLoadingKural 
          ? const Center(child: Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ))
          : _dailyKural == null
              ? Text(
                  'Today\'s Thirukkural is not available.',
                  style: GoogleFonts.notoSansTamil(
                    fontSize: 14,
                    color: AppTheme.textGray,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Thirukkural #${_dailyKural!.number}',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                            letterSpacing: 1,
                          ),
                        ),
                        const Icon(Icons.auto_awesome_rounded, size: 16, color: AppTheme.primary),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _dailyKural!.line1,
                      style: GoogleFonts.notoSansTamil(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondary,
                      ),
                    ),
                    Text(
                      _dailyKural!.line2,
                      style: GoogleFonts.notoSansTamil(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: Column(
                        children: [
                          ExpansionTile(
                            title: Text(
                              'Show Tamil Explanation',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            tilePadding: EdgeInsets.zero,
                            childrenPadding: EdgeInsets.zero,
                            collapsedIconColor: AppTheme.primary,
                            iconColor: AppTheme.primary,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  _dailyKural!.explanation,
                                  style: GoogleFonts.notoSansTamil(
                                    fontSize: 13,
                                    color: AppTheme.textGray,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ExpansionTile(
                            title: Text(
                              'Show English Meaning',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: AppTheme.info,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            tilePadding: EdgeInsets.zero,
                            childrenPadding: EdgeInsets.zero,
                            collapsedIconColor: AppTheme.info,
                            iconColor: AppTheme.info,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  _dailyKural!.englishMeaning,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: AppTheme.textGray,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
