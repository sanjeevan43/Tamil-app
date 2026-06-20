import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';
import '../widgets/premium_animations.dart';
import '../services/audio_feedback_service.dart';

// Game Screens
import 'riddle_academy_screen.dart';
import 'letter_hunt_game.dart';
import 'word_builder_game.dart';
import 'memory_game_screen.dart';
import 'fill_blanks_game.dart';
import 'sentence_builder_game.dart';
import 'pronunciation_practice_game.dart';
import 'writing_practice_game.dart';
import 'word_scramble_game.dart';
import 'sound_match_game.dart';
import 'word_search_game.dart';
import 'odd_one_out_game.dart';

// ─────────────────────────────────────────────────
//  GAME CATEGORY MODEL
// ─────────────────────────────────────────────────
class _GameCategory {
  final String title;
  final String titleTamil;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final List<Map<String, dynamic>> games;

  const _GameCategory({
    required this.title,
    required this.titleTamil,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.games,
  });
}

// ─────────────────────────────────────────────────
//  GAMES HUB SCREEN
// ─────────────────────────────────────────────────
class GamesHubScreen extends StatefulWidget {
  const GamesHubScreen({super.key});

  @override
  State<GamesHubScreen> createState() => _GamesHubScreenState();
}

class _GamesHubScreenState extends State<GamesHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_GameCategory> _buildCategories(int childAge) {
    return [
      // ── Category 1: Letters & Words
      _GameCategory(
        title: 'Letters & Words',
        titleTamil: 'எழுத்தும் சொல்லும்',
        subtitle: '6 games to master Tamil letters and vocabulary',
        icon: Icons.translate_rounded,
        gradientColors: [const Color(0xFFFF7043), const Color(0xFFFF5722)],
        games: [
          {
            'name': 'Letter Hunt',
            'tamil': 'எழுத்து வேட்டை',
            'icon': '🎯',
            'description': 'Find the correct letter',
            'color': const Color(0xFFFF7043),
            'screenBuilder': (String diff) => LetterHuntGame(difficulty: diff),
            'xp': '+30 XP',
            'difficulty': 1,
            'isNew': false,
          },
          {
            'name': 'Word Builder',
            'tamil': 'சொல் கட்டுதல்',
            'icon': '🔨',
            'description': 'Build Tamil words',
            'color': const Color(0xFF42A5F5),
            'screenBuilder': (String diff) => WordBuilderGame(difficulty: diff),
            'xp': '+45 XP',
            'difficulty': 2,
            'isNew': false,
          },
          {
            'name': 'Word Scramble',
            'tamil': 'சொல் கலைத்தல்',
            'icon': '🧩',
            'description': 'Unscramble words',
            'color': const Color(0xFF7E57C2),
            'screenBuilder': (String diff) => WordScrambleGame(difficulty: diff),
            'xp': '+45 XP',
            'difficulty': 2,
            'isNew': false,
          },
          {
            'name': 'Fill Blanks',
            'tamil': 'இடம் நிரப்பு',
            'icon': '📝',
            'description': 'Complete the word',
            'color': const Color(0xFFEF5350),
            'screenBuilder': (String diff) => FillBlanksGame(difficulty: diff),
            'xp': '+35 XP',
            'difficulty': 2,
            'isNew': false,
          },
          {
            'name': 'Memory Match',
            'tamil': 'நினைவக போட்டி',
            'icon': '🧠',
            'description': 'Match Tamil letters',
            'color': AppTheme.success,
            'screenBuilder': (String diff) => const MemoryGameScreen(),
            'xp': '+35 XP',
            'difficulty': 1,
            'isNew': false,
          },
          {
            'name': 'Writing Practice',
            'tamil': 'எழுத்துப் பயிற்சி',
            'icon': '✏️',
            'description': 'Trace letters',
            'color': const Color(0xFF5C6BC0),
            'screenBuilder': (String diff) => const WritingPracticeGame(),
            'xp': '+40 XP',
            'difficulty': 2,
            'isNew': false,
          },
        ],
      ),

      // ── Category 2: Sentences
      _GameCategory(
        title: 'Sentences',
        titleTamil: 'வாக்கியம்',
        subtitle: '4 games to build and understand Tamil sentences',
        icon: Icons.chat_bubble_rounded,
        gradientColors: [const Color(0xFF26A69A), const Color(0xFF00897B)],
        games: [
          {
            'name': 'Sentence Builder',
            'tamil': 'வாக்கிய அமைப்பு',
            'icon': '📚',
            'description': 'Form sentences',
            'color': const Color(0xFF26A69A),
            'screenBuilder': (String diff) => SentenceBuilderGame(difficulty: diff),
            'xp': '+50 XP',
            'difficulty': 3,
            'isNew': false,
          },
          {
            'name': 'Odd One Out',
            'tamil': 'வேறுபட்டதைத் தேடு',
            'icon': '🦄',
            'description': 'Find the odd word',
            'color': const Color(0xFFEC407A),
            'screenBuilder': (String diff) => const OddOneOutGame(),
            'xp': '+40 XP',
            'difficulty': 2,
            'isNew': false,
          },
          {
            'name': 'Riddle Academy',
            'tamil': 'புதிர் அரங்கம்',
            'icon': '💡',
            'description': 'Solve Tamil riddles',
            'color': const Color(0xFFAB47BC),
            'screenBuilder': (String diff) => RiddleAcademyScreen(childAge: childAge),
            'xp': '+50 XP',
            'difficulty': 3,
            'isNew': false,
          },
          {
            'name': 'Word Search',
            'tamil': 'சொல் தேடல்',
            'icon': '🔍',
            'description': 'Find hidden words',
            'color': const Color(0xFF9CCC65),
            'screenBuilder': (String diff) => WordSearchGame(difficulty: diff),
            'xp': '+50 XP',
            'difficulty': 3,
            'isNew': false,
          },
        ],
      ),

      // ── Category 3: Listen & Speak
      _GameCategory(
        title: 'Listen & Speak',
        titleTamil: 'கேட்டல் & பேசுதல்',
        subtitle: '2 games to train your ears and voice',
        icon: Icons.hearing_rounded,
        gradientColors: [const Color(0xFF29B6F6), const Color(0xFF0288D1)],
        games: [
          {
            'name': 'Sound Match',
            'tamil': 'ஒலி பொருத்தம்',
            'icon': '🔊',
            'description': 'Listen and match',
            'color': const Color(0xFF29B6F6),
            'screenBuilder': (String diff) => const SoundMatchGame(),
            'xp': '+30 XP',
            'difficulty': 1,
            'isNew': false,
          },
          {
            'name': 'Pronunciation',
            'tamil': 'உச்சரிப்பு பயிற்சி',
            'icon': '🎤',
            'description': 'Practice speaking',
            'color': const Color(0xFFFF8A65),
            'screenBuilder': (String diff) => const PronunciationPracticeGame(),
            'xp': '+40 XP',
            'difficulty': 2,
            'isNew': false,
          },
        ],
      ),
    ];
  }

  void _showDifficultySelection(BuildContext context, Map<String, dynamic> game) {
    final color = game['color'] as Color;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pull handle
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppTheme.topoSilver,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),

              // Game Name Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(game['icon'] as String, style: const TextStyle(fontSize: 30)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game['name'] as String,
                        style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                      ),
                      Text(
                        game['tamil'] as String,
                        style: TextStyle(
                          fontFamily: GoogleFonts.notoSansTamil().fontFamily,
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Choose Difficulty / நிலையைத் தேர்ந்தெடுக்கவும்',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSlate),
              ),
              const SizedBox(height: 20),

              _buildDifficultyOption(context, game: game,
                title: 'Easy', tamil: 'எளிய நிலை',
                desc: 'Simple letters & short 2-3 letter words. Ideal for beginners.',
                color: const Color(0xFF4CAF50)),
              const SizedBox(height: 10),
              _buildDifficultyOption(context, game: game,
                title: 'Medium', tamil: 'நடுத்தர நிலை',
                desc: 'Common vocabulary & daily expressions.',
                color: const Color(0xFFFF9800)),
              const SizedBox(height: 10),
              _buildDifficultyOption(context, game: game,
                title: 'Hard', tamil: 'கடின நிலை',
                desc: 'Complex words, spelling challenges, and full sentences.',
                color: const Color(0xFFF44336)),
              const SizedBox(height: 10),
              _buildDifficultyOption(context, game: game,
                title: 'Expert', tamil: 'நிபுணர் நிலை',
                desc: 'Advanced level quizzes, complex sentences & speed trials.',
                color: const Color(0xFF9C27B0)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDifficultyOption(
    BuildContext context, {
    required Map<String, dynamic> game,
    required String title,
    required String tamil,
    required String desc,
    required Color color,
  }) {
    return SpringyTap(
      onTap: () {
        AudioFeedbackService.playTap();
        Navigator.pop(context);
        final builder = game['screenBuilder'] as Widget Function(String);
        Navigator.push(context, FadeInSlidePageRoute(page: builder(title)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.25), width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.textDark)),
                      const SizedBox(width: 8),
                      Text('• $tamil',
                        style: TextStyle(
                          fontFamily: GoogleFonts.notoSansTamil().fontFamily,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: color,
                        )),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(desc, style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textGray)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context, listen: false);
    final childAge = progress.level + 5;
    final categories = _buildCategories(childAge);
    final totalGames = categories.fold<int>(0, (sum, c) => sum + c.games.length);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // ── HERO APP BAR ──
          SliverAppBar(
            pinned: true,
            expandedHeight: 210,
            backgroundColor: AppTheme.backgroundLight,
            elevation: 0,
            leading: Navigator.canPop(context)
                ? Padding(
                    padding: const EdgeInsets.all(8),
                    child: GestureDetector(
                      onTap: () {
                        AudioFeedbackService.playTap();
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      ),
                    ),
                  )
                : null,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      top: -40,
                      right: -40,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary.withOpacity(0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      left: -30,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.secondary.withOpacity(0.07),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$totalGames GAMES • 3 CATEGORIES',
                                style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFF1A1A2E), letterSpacing: 1),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'விளையாட்டு அரங்கம்',
                              style: TextStyle(
                                fontFamily: GoogleFonts.notoSansTamil().fontFamily,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.white,
                              ),
                            ),
                            Text(
                              'Games Arena',
                              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.white.withOpacity(0.6)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── CATEGORY TAB BAR ──
          SliverPersistentHeader(
            pinned: true,
            delegate: _CategoryTabDelegate(
              tabController: _tabController,
              categories: categories,
            ),
          ),
        ],

        // ── GAME CARDS ──
        body: TabBarView(
          controller: _tabController,
          children: categories.asMap().entries.map((catEntry) {
            final category = catEntry.value;
            return _buildCategoryTab(context, category, catEntry.key);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryTab(BuildContext context, _GameCategory category, int categoryIndex) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Category Banner
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: FadeInSlide(
              direction: SlideDirection.down,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: category.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: category.gradientColors[0].withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(category.icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.title,
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                          Text(
                            category.titleTamil,
                            style: TextStyle(
                              fontFamily: GoogleFonts.notoSansTamil().fontFamily,
                              fontSize: 12,
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category.subtitle,
                            style: GoogleFonts.outfit(fontSize: 11, color: Colors.white60),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${category.games.length}',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Game Cards Grid
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final game = category.games[index];
                return FadeInSlide(
                  direction: SlideDirection.up,
                  delay: Duration(milliseconds: 60 + (index * 50)),
                  child: _buildGameCard(context, game),
                );
              },
              childCount: category.games.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameCard(BuildContext context, Map<String, dynamic> game) {
    final color = game['color'] as Color;
    final int difficulty = game['difficulty'] as int;
    final String xp = game['xp'] as String;
    final bool isNew = game['isNew'] as bool? ?? false;

    return SpringyTap(
      onTap: () {
        AudioFeedbackService.playTap();
        _showDifficultySelection(context, game);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.12), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: XP + Stars + NEW badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      xp,
                      style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.primary),
                    ),
                  ),
                  if (isNew)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('NEW',
                        style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.w900, color: AppTheme.secondary, letterSpacing: 0.5)),
                    )
                  else
                    // Difficulty stars
                    Row(
                      children: List.generate(3, (i) => Icon(
                        Icons.star_rounded,
                        size: 11,
                        color: i < difficulty ? color : AppTheme.topoSilver,
                      )),
                    ),
                ],
              ),

              const Spacer(),

              // Emoji icon
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.04)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(game['icon'] as String, style: const TextStyle(fontSize: 36)),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Name
              Text(
                game['name'] as String,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textDark),
              ),
              const SizedBox(height: 2),
              Center(
                child: Text(
                  game['tamil'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: GoogleFonts.notoSansTamil().fontFamily,
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const Spacer(),

              // Play Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.85)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'PLAY',
                      style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
//  STICKY CATEGORY TAB BAR DELEGATE
// ─────────────────────────────────────────────────
class _CategoryTabDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final List<_GameCategory> categories;

  _CategoryTabDelegate({required this.tabController, required this.categories});

  @override
  double get minExtent => 72;
  @override
  double get maxExtent => 72;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.backgroundLight,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppTheme.topoLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.topoSilver.withValues(alpha: 0.5)),
        ),
        child: TabBar(
          controller: tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          indicator: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                categories[tabController.index].gradientColors[0],
                categories[tabController.index].gradientColors[1],
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: categories[tabController.index].gradientColors[0].withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: AppTheme.textGray,
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          labelStyle: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900),
          unselectedLabelStyle: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700),
          tabs: categories.map((cat) {
            return Tab(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat.icon, size: 16),
                  const SizedBox(height: 2),
                  Text(
                    cat.title.split(' ').first,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
