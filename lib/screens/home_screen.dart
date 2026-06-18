import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/validation_service.dart';
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
import '../widgets/premium_animations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Thirukkural? _dailyKural;
  bool _isLoadingKural = true;
  bool _isKuralExpanded = false;
  TamilProverb? _dailyProverb;

  @override
  void initState() {
    super.initState();
    _fetchKural();
    _fetchProverb();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowSetupDialog();
    });
  }

  void _checkAndShowSetupDialog() {
    final progress = Provider.of<EnhancedProgressProvider>(context, listen: false);
    if (progress.userName == 'Student' || progress.userName.isEmpty) {
      _showSetupDialog();
    }
  }

  void _showSetupDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const _SetupDialogContent();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curve,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
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
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: FadeInSlide(
                          direction: SlideDirection.down,
                          delay: const Duration(milliseconds: 100),
                          child: _buildHeader(),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInSlide(
                        direction: SlideDirection.up,
                        delay: const Duration(milliseconds: 300),
                        child: _buildQuickStats(),
                      ),
                      const SizedBox(height: 24),
                      FadeInSlide(
                        direction: SlideDirection.up,
                        delay: const Duration(milliseconds: 400),
                        child: _buildDailyKuralSection(),
                      ),
                      FadeInSlide(
                        direction: SlideDirection.up,
                        delay: const Duration(milliseconds: 450),
                        child: _buildDailyProverbSection(),
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: FadeInSlide(
                          direction: SlideDirection.up,
                          delay: const Duration(milliseconds: 500),
                          child: _buildSectionHeader('AI Cognitive Academy', Icons.auto_awesome_rounded),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: FadeInSlide(
                          direction: SlideDirection.up,
                          delay: const Duration(milliseconds: 550),
                          child: _buildAIAcademyCard(),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: FadeInSlide(
                          direction: SlideDirection.up,
                          delay: const Duration(milliseconds: 600),
                          child: _buildSectionHeader('Fun & Games', Icons.sports_esports_rounded),
                        ),
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
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildHeader() {
    return Consumer<EnhancedProgressProvider>(
      builder: (context, progress, child) {
        return Row(
          children: [
            SpringyTap(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
              child: AnimatedPulse(
                pulseOpacity: false,
                minScale: 0.96,
                maxScale: 1.04,
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
            (context, index) {
              return FadeInSlide(
                direction: SlideDirection.up,
                delay: Duration(milliseconds: 650 + (index * 80)),
                child: items[index],
              );
            },
            childCount: items.length,
          ),
        );
      },
    );
  }

  Widget _fastItem(BuildContext context, String title, String sub, IconData icon, Color bg, Color color, VoidCallback onTap) {
    return SpringyTap(
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
        return SpringyTap(
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
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.primary.withOpacity(0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isKuralExpanded = !_isKuralExpanded;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: AppTheme.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'இன்றைய திருக்குறள்',
                                style: GoogleFonts.notoSansTamil(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.secondary,
                                ),
                              ),
                              Text(
                                _isLoadingKural 
                                    ? 'Loading daily Kural...' 
                                    : _dailyKural == null 
                                        ? 'Not available' 
                                        : 'Thirukkural #${_dailyKural!.number}',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textGray,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedRotation(
                          turns: _isKuralExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppTheme.primary,
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: _isLoadingKural
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        ),
                      )
                    : _dailyKural == null
                        ? Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              'Today\'s Thirukkural is not available.',
                              style: GoogleFonts.notoSansTamil(
                                fontSize: 14,
                                color: AppTheme.textGray,
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(height: 1, color: AppTheme.borderLight),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.offWhite,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppTheme.borderLight),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _dailyKural!.line1,
                                        style: GoogleFonts.notoSansTamil(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.secondary,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _dailyKural!.line2,
                                        style: GoogleFonts.notoSansTamil(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.secondary,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Theme(
                                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                  child: Column(
                                    children: [
                                      ExpansionTile(
                                        title: Text(
                                          'Show Tamil Explanation',
                                          style: GoogleFonts.outfit(
                                            fontSize: 13,
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        tilePadding: EdgeInsets.zero,
                                        childrenPadding: EdgeInsets.zero,
                                        collapsedIconColor: AppTheme.primary,
                                        iconColor: AppTheme.primary,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                            child: Text(
                                              _dailyKural!.explanation,
                                              style: GoogleFonts.notoSansTamil(
                                                fontSize: 13,
                                                color: AppTheme.textSlate,
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
                                            fontSize: 13,
                                            color: AppTheme.info,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        tilePadding: EdgeInsets.zero,
                                        childrenPadding: EdgeInsets.zero,
                                        collapsedIconColor: AppTheme.info,
                                        iconColor: AppTheme.info,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                            child: Text(
                                              _dailyKural!.englishMeaning,
                                              style: GoogleFonts.outfit(
                                                fontSize: 13,
                                                color: AppTheme.textSlate,
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
                crossFadeState: _isKuralExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetupDialogContent extends StatefulWidget {
  const _SetupDialogContent();

  @override
  State<_SetupDialogContent> createState() => _SetupDialogContentState();
}

class _SetupDialogContentState extends State<_SetupDialogContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedGender = 'boy'; // 'boy' or 'girl'
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final name = _nameController.text.trim();
      final age = int.tryParse(_ageController.text.trim()) ?? 6;
      final avatarEmoji = _selectedGender == 'boy' ? '👦' : '👧';

      final authService = Provider.of<AuthService>(context, listen: false);
      final progress = Provider.of<EnhancedProgressProvider>(context, listen: false);

      if (authService.user != null) {
        final firestore = FirestoreService();
        await firestore.saveUser(
          authService.user!,
          role: 'student',
          displayName: name,
          age: age,
        );
      }

      await progress.setUserName(name);
      await progress.setAge(age);
      await progress.updateAvatar(avatarEmoji);

      if (mounted) {
        Navigator.of(context).pop(); // Dismiss setup pop-up
      }
    } catch (e) {
      debugPrint('Error saving user profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: screenWidth * 0.9 < 420.0 ? screenWidth * 0.9 : 420.0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
            border: Border.all(color: AppTheme.topoSilver, width: 2),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    'Choose Your Character!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.secondary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Let\'s build your profile to start learning',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppTheme.textGray,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Gender/Character Selector (Boy / Girl)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Boy card
                      _buildCharacterCard(
                        gender: 'boy',
                        imagePath: 'assets/images/avatar_boy.png',
                        label: 'Boy',
                        accentColor: const Color(0xFF42A5F5),
                      ),
                      const SizedBox(width: 16),
                      // Girl card
                      _buildCharacterCard(
                        gender: 'girl',
                        imagePath: 'assets/images/avatar_girl.png',
                        label: 'Girl',
                        accentColor: const Color(0xFFEC407A),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Name Input
                  TextFormField(
                    controller: _nameController,
                    style: GoogleFonts.outfit(fontSize: 15, color: AppTheme.secondary),
                    decoration: InputDecoration(
                      hintText: 'Your Name',
                      hintStyle: GoogleFonts.outfit(color: AppTheme.textGray),
                      prefixIcon: const Icon(Icons.person_outline, size: 20, color: AppTheme.textGray),
                      filled: true,
                      fillColor: AppTheme.topoLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                    ),
                    validator: (val) => ValidationService.validateName(val),
                  ),
                  const SizedBox(height: 14),

                  // Age Input
                  TextFormField(
                    controller: _ageController,
                    style: GoogleFonts.outfit(fontSize: 15, color: AppTheme.secondary),
                    decoration: InputDecoration(
                      hintText: 'Your Age',
                      hintStyle: GoogleFonts.outfit(color: AppTheme.textGray),
                      prefixIcon: const Icon(Icons.cake_outlined, size: 20, color: AppTheme.textGray),
                      filled: true,
                      fillColor: AppTheme.topoLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      final age = int.tryParse(val ?? '');
                      return ValidationService.validateAge(age);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Let's Go Button
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 4,
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                          : Text(
                              'LET\'S GO!',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterCard({
    required String gender,
    required String imagePath,
    required String label,
    required Color accentColor,
  }) {
    final isSelected = _selectedGender == gender;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGender = gender;
          });
        },
        child: AnimatedScale(
          scale: isSelected ? 1.05 : 0.95,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? accentColor.withOpacity(0.08) : AppTheme.topoLight,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isSelected ? accentColor : AppTheme.topoSilver,
                width: isSelected ? 3.0 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: accentColor.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                // Illustration
                Container(
                  height: 100,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
                // Label
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: isSelected ? accentColor : AppTheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
