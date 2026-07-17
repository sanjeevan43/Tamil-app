import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/premium_animations.dart';
import '../services/audio_feedback_service.dart';
import '../constants/app_theme.dart';

// Game Screens
import 'letter_hunt_game.dart';
import 'word_builder_game.dart';
import 'word_scramble_game.dart';
import 'fill_blanks_game.dart';
import 'writing_practice_game.dart';
import 'word_search_game.dart';

// ─────────────────────────────────────────────────
//  RESPONSIVE HELPER
//  All sizes are % of MediaQuery screen dimensions.
//  No hardcoded px values anywhere.
// ─────────────────────────────────────────────────
class _Rsp {
  final double sw; // screen width
  final double sh; // screen height

  const _Rsp({required this.sw, required this.sh});

  factory _Rsp.of(BuildContext ctx) {
    final s = MediaQuery.sizeOf(ctx);
    return _Rsp(sw: s.width, sh: s.height);
  }

  // ── Spacing (% of screen) ──
  double get hPad => sw * 0.055;
  double get cardPad => sw * 0.042;
  double get listCardSpacing => sh * 0.016;
  double get cardRadius => sw * 0.058;

  // ── Component sizes ──
  double get backBtnSize => sw * 0.095;
  double get iconBubbleSize => sw * 0.15;
  double get arrowBtnSize => sw * 0.085;
  double get sheetIconSize => sw * 0.135;
  double get orbLarge => sw * 0.55;
  double get orbSmall => sw * 0.40;

  // ── Card heights ──
  double get featuredCardH => sh * 0.22;

  // ── Typography (% of screen width) ──
  double get titleFont => sw * 0.092;
  double get subtitleFont => sw * 0.032;
  double get gameTitleFont => sw * 0.055;
  double get listNameFont => sw * 0.037;
  double get tamilFont => sw * 0.028;
  double get xpFont => sw * 0.022;
  double get filterFont => sw * 0.03;
  double get badgeFont => sw * 0.024;
  double get sheetTitleFont => sw * 0.048;
  double get sheetSubFont => sw * 0.028;
  double get diffTitleFont => sw * 0.037;
  double get diffDescFont => sw * 0.027;
  double get starSize => sw * 0.03;
}

// ─────────────────────────────────────────────────
//  GAME DATA MODEL
// ─────────────────────────────────────────────────
class _GameItem {
  final String name;
  final String nameTamil;
  final String icon;
  final String description;
  final String xp;
  final int difficulty;
  final List<Color> gradientColors;
  final Widget Function(String) screenBuilder;

  const _GameItem({
    required this.name,
    required this.nameTamil,
    required this.icon,
    required this.description,
    required this.xp,
    required this.difficulty,
    required this.gradientColors,
    required this.screenBuilder,
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
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;
  int _filter = 0; // 0=All 1=Easy 2=Medium 3=Hard

  static const _filterLabels = ['All', 'Easy', 'Medium', 'Hard'];

  List<_GameItem> get _allGames => [
        _GameItem(
          name: 'Letter Hunt',
          nameTamil: 'எழுத்து வேட்டை',
          icon: '🎯',
          description: 'Spot the correct Tamil letter',
          xp: '+30 XP',
          difficulty: 1,
          gradientColors: [AppTheme.primary, AppTheme.primaryDark],
          screenBuilder: (d) => LetterHuntGame(difficulty: d),
        ),
        _GameItem(
          name: 'Word Builder',
          nameTamil: 'சொல் கட்டுதல்',
          icon: '🔨',
          description: 'Arrange letters to form words',
          xp: '+45 XP',
          difficulty: 2,
          gradientColors: [AppTheme.secondary, const Color(0xFF009FD0)],
          screenBuilder: (d) => WordBuilderGame(difficulty: d),
        ),
        _GameItem(
          name: 'Word Scramble',
          nameTamil: 'சொல் கலைத்தல்',
          icon: '🧩',
          description: 'Unscramble jumbled Tamil words',
          xp: '+45 XP',
          difficulty: 2,
          gradientColors: [const Color(0xFF9C27B0), const Color(0xFF6A1B9A)],
          screenBuilder: (d) => WordScrambleGame(difficulty: d),
        ),
        _GameItem(
          name: 'Fill Blanks',
          nameTamil: 'இடம் நிரப்பு',
          icon: '📝',
          description: 'Complete the missing letter',
          xp: '+35 XP',
          difficulty: 2,
          gradientColors: [AppTheme.primary, AppTheme.primaryDark],
          screenBuilder: (d) => FillBlanksGame(difficulty: d),
        ),
        _GameItem(
          name: 'Writing Practice',
          nameTamil: 'எழுத்துப் பயிற்சி',
          icon: '✏️',
          description: 'Trace and learn Tamil letters',
          xp: '+40 XP',
          difficulty: 2,
          gradientColors: [AppTheme.secondary, const Color(0xFF009FD0)],
          screenBuilder: (d) => const WritingPracticeGame(),
        ),
        _GameItem(
          name: 'Word Search',
          nameTamil: 'சொல் தேடல்',
          icon: '🔍',
          description: 'Find hidden words in a grid',
          xp: '+50 XP',
          difficulty: 3,
          gradientColors: [AppTheme.primary, AppTheme.primaryDark],
          screenBuilder: (d) => WordSearchGame(difficulty: d),
        ),
      ];

  List<_GameItem> get _filtered {
    if (_filter == 0) return _allGames;
    return _allGames.where((g) => g.difficulty == _filter).toList();
  }

  @override
  void initState() {
    super.initState();
    _fadeCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _openDifficultySheet(BuildContext ctx, _GameItem game) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DifficultySheet(game: game),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = _Rsp.of(context);
    final games = _filtered;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: AnimatedBubbleBackground(
        colors: const [
          AppTheme.primary,
          AppTheme.secondary,
          AppTheme.primary,
          AppTheme.secondary,
        ],
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── HERO ──
            SliverToBoxAdapter(child: _buildHero(context, r)),

            // ── FILTERS ──
            SliverToBoxAdapter(child: _buildFilters(r)),

            // ── FEATURED CARD ──
            if (games.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.hPad),
                  child: _buildFeatured(context, r, games.first),
                ),
              ),

            // ── REST OF GAMES ──
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                  r.hPad, r.listCardSpacing, r.hPad, sh(context) * 0.14),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final rest = games.length > 1 ? games.sublist(1) : <_GameItem>[];
                    final game = rest[i];
                    return Padding(
                      padding: EdgeInsets.only(bottom: r.listCardSpacing),
                      child: FadeInSlide(
                        direction: SlideDirection.up,
                        delay: Duration(milliseconds: 60 + i * 60),
                        child: _buildListCard(context, r, game),
                      ),
                    );
                  },
                  childCount: games.length > 1 ? games.length - 1 : 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double sh(BuildContext ctx) => MediaQuery.sizeOf(ctx).height;

  // ─────────────────────────────────────────────
  //  HERO HEADER
  // ─────────────────────────────────────────────
  Widget _buildHero(BuildContext context, _Rsp r) {
    return ClipRect(
      child: Stack(
        children: [
          // ── Background — Fills to content height ──
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFF6EE), AppTheme.backgroundLight],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // ── Primary color glow orb — top right ──
          Positioned(
            top: -r.orbLarge * 0.27,
            right: -r.orbLarge * 0.27,
            child: Container(
              width: r.orbLarge,
              height: r.orbLarge,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppTheme.primary.withValues(alpha: 0.12),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          // ── Secondary color glow orb — left ──
          Positioned(
            top: r.sh * 0.04,
            left: -r.orbSmall * 0.25,
            child: Container(
              width: r.orbSmall,
              height: r.orbSmall,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppTheme.secondary.withValues(alpha: 0.1),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          // ── Content ──
          SafeArea(
            bottom: false,
            child: FadeTransition(
              opacity: _fade,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  r.hPad,
                  r.sh * 0.018,
                  r.hPad,
                  r.sh * 0.038,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top row ──
                    Row(
                      children: [
                        if (Navigator.canPop(context))
                          GestureDetector(
                            onTap: () {
                              AudioFeedbackService.playTap();
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: r.backBtnSize,
                              height: r.backBtnSize,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.04),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black.withValues(alpha: 0.08),
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: AppTheme.textDark,
                                size: r.sw * 0.042,
                              ),
                            ),
                          ),
                        const Spacer(),
                        // Games count badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: r.sw * 0.03,
                            vertical: r.sh * 0.008,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.secondary],
                            ),
                            borderRadius: BorderRadius.circular(r.sw * 0.05),
                          ),
                          child: Text(
                            '${_allGames.length} GAMES',
                            style: GoogleFonts.outfit(
                              fontSize: r.badgeFont,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: r.sh * 0.04),

                    // ── Tamil title line 1 ──
                    Text(
                      'விளையாட்டு',
                      style: TextStyle(
                        fontFamily: GoogleFonts.notoSansTamil().fontFamily,
                        fontSize: r.titleFont,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                        height: 1.1,
                      ),
                    ),

                    // ── Tamil title line 2 — gradient ──
                    ShaderMask(
                      shaderCallback: (b) => const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryDark],
                      ).createShader(b),
                      child: Text(
                        'அரங்கம்',
                        style: TextStyle(
                          fontFamily: GoogleFonts.notoSansTamil().fontFamily,
                          fontSize: r.titleFont,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ),

                    SizedBox(height: r.sh * 0.008),

                    // ── English subtitle ──
                    Text(
                      'Spelling & Word Games Arena',
                      style: GoogleFonts.outfit(
                        fontSize: r.subtitleFont,
                        color: AppTheme.textSlate,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  FILTER PILLS
  // ─────────────────────────────────────────────
  Widget _buildFilters(_Rsp r) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: r.hPad,
        vertical: r.sh * 0.016,
      ),
      child: Row(
        children: List.generate(_filterLabels.length, (i) {
          final sel = _filter == i;
          return Padding(
            padding: EdgeInsets.only(right: r.sw * 0.025),
            child: GestureDetector(
              onTap: () {
                AudioFeedbackService.playTap();
                setState(() => _filter = i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: EdgeInsets.symmetric(
                  horizontal: r.sw * 0.045,
                  vertical: r.sh * 0.011,
                ),
                decoration: BoxDecoration(
                  gradient: sel
                      ? const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.primaryDark],
                        )
                      : null,
                  color: sel ? null : AppTheme.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(r.sw * 0.08),
                ),
                child: Text(
                  _filterLabels[i],
                  style: GoogleFonts.outfit(
                    fontSize: r.filterFont,
                    fontWeight: FontWeight.w700,
                    color: sel ? Colors.white : AppTheme.textSlate,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  FEATURED CARD
  // ─────────────────────────────────────────────
  Widget _buildFeatured(BuildContext ctx, _Rsp r, _GameItem game) {
    return SpringyTap(
      onTap: () {
        AudioFeedbackService.playTap();
        _openDifficultySheet(ctx, game);
      },
      child: Container(
        height: r.featuredCardH,
        margin: EdgeInsets.only(bottom: r.sh * 0.008),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: game.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(r.cardRadius),
          boxShadow: [
            BoxShadow(
              color: game.gradientColors[0].withValues(alpha: 0.3),
              blurRadius: r.sw * 0.05,
              offset: Offset(0, r.sh * 0.01),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Big emoji decoration
            Positioned(
              right: -r.sw * 0.02,
              bottom: -r.sh * 0.01,
              child: Text(
                game.icon,
                style: TextStyle(fontSize: r.sw * 0.27, height: 1),
              ),
            ),
            // Gradient fade on right side
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: r.sw * 0.40,
              child: ClipRRect(
                borderRadius:
                    BorderRadius.horizontal(right: Radius.circular(r.cardRadius)),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        game.gradientColors[1].withValues(alpha: 0.4),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(r.cardPad * 1.3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FEATURED badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: r.sw * 0.025,
                      vertical: r.sh * 0.006,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(r.sw * 0.02),
                    ),
                    child: Text(
                      '⭐ FEATURED',
                      style: GoogleFonts.outfit(
                        fontSize: r.xpFont,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    game.name,
                    style: GoogleFonts.outfit(
                      fontSize: r.gameTitleFont,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    game.nameTamil,
                    style: TextStyle(
                      fontFamily: GoogleFonts.notoSansTamil().fontFamily,
                      fontSize: r.tamilFont,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: r.sh * 0.014),
                  Row(
                    children: [
                      _Stars(n: game.difficulty, color: Colors.white, size: r.starSize),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: r.sw * 0.04,
                          vertical: r.sh * 0.011,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(r.sw * 0.05),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.play_arrow_rounded,
                                color: game.gradientColors[0], size: r.sw * 0.04),
                            SizedBox(width: r.sw * 0.01),
                            Text(
                              'PLAY NOW',
                              style: GoogleFonts.outfit(
                                fontSize: r.filterFont,
                                fontWeight: FontWeight.w900,
                                color: game.gradientColors[0],
                              ),
                            ),
                          ],
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

  // ─────────────────────────────────────────────
  //  LIST CARD (compact row)
  // ─────────────────────────────────────────────
  Widget _buildListCard(BuildContext ctx, _Rsp r, _GameItem game) {
    return SpringyTap(
      onTap: () {
        AudioFeedbackService.playTap();
        _openDifficultySheet(ctx, game);
      },
      child: Container(
        padding: EdgeInsets.all(r.cardPad),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(r.cardRadius * 0.88),
          border: Border.all(color: AppTheme.borderLight, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            // Icon bubble
            Container(
              width: r.iconBubbleSize,
              height: r.iconBubbleSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: game.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(r.sw * 0.045),
                boxShadow: [
                  BoxShadow(
                    color: game.gradientColors[0].withValues(alpha: 0.3),
                    blurRadius: r.sw * 0.02,
                    offset: Offset(0, r.sh * 0.003),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  game.icon,
                  style: TextStyle(fontSize: r.iconBubbleSize * 0.50),
                ),
              ),
            ),

            SizedBox(width: r.sw * 0.04),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        game.name,
                        style: GoogleFonts.outfit(
                          fontSize: r.listNameFont,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: r.sw * 0.02,
                          vertical: r.sh * 0.004,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: game.gradientColors),
                          borderRadius: BorderRadius.circular(r.sw * 0.02),
                        ),
                        child: Text(
                          game.xp,
                          style: GoogleFonts.outfit(
                            fontSize: r.xpFont,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: r.sh * 0.004),
                  Text(
                    game.nameTamil,
                    style: TextStyle(
                      fontFamily: GoogleFonts.notoSansTamil().fontFamily,
                      fontSize: r.tamilFont,
                      color: game.gradientColors[0],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: r.sh * 0.007),
                  Row(
                    children: [
                      _Stars(
                        n: game.difficulty,
                        color: game.gradientColors[0],
                        size: r.starSize,
                      ),
                      SizedBox(width: r.sw * 0.02),
                      Expanded(
                        child: Text(
                          game.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: r.xpFont,
                            color: AppTheme.textSlate.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: r.sw * 0.03),

            // Arrow button
            Container(
              width: r.arrowBtnSize,
              height: r.arrowBtnSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: game.gradientColors),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: r.arrowBtnSize * 0.45),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
//  STAR DIFFICULTY INDICATOR
// ─────────────────────────────────────────────────
class _Stars extends StatelessWidget {
  final int n;
  final Color color;
  final double size;
  const _Stars({required this.n, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (i) => Icon(
          i < n ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: i < n ? color : color.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
//  DIFFICULTY BOTTOM SHEET
// ─────────────────────────────────────────────────
class _DifficultySheet extends StatelessWidget {
  final _GameItem game;
  const _DifficultySheet({required this.game});

  @override
  Widget build(BuildContext context) {
    final r = _Rsp.of(context);
    const levels = [
      {'title': 'Easy', 'tamil': 'எளிய நிலை', 'desc': 'Simple letters & 2–3 letter words', 'hex': 0xFF4CAF50},
      {'title': 'Medium', 'tamil': 'நடுத்தர நிலை', 'desc': 'Common vocabulary & daily words', 'hex': 0xFFFF9800},
      {'title': 'Hard', 'tamil': 'கடின நிலை', 'desc': 'Complex words & challenges', 'hex': 0xFFF44336},
      {'title': 'Expert', 'tamil': 'நிபுணர் நிலை', 'desc': 'Advanced vocabulary & speed', 'hex': 0xFF9C27B0},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(r.sw * 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, -10),
          )
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        r.hPad,
        r.sh * 0.015,
        r.hPad,
        r.sh * 0.05,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: r.sw * 0.1,
            height: r.sh * 0.005,
            decoration: BoxDecoration(
              color: AppTheme.topoSilver,
              borderRadius: BorderRadius.circular(r.sw * 0.01),
            ),
          ),
          SizedBox(height: r.sh * 0.028),

          // Game identity row
          Row(
            children: [
              Container(
                width: r.sheetIconSize,
                height: r.sheetIconSize,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: game.gradientColors),
                  borderRadius: BorderRadius.circular(r.sw * 0.04),
                ),
                child: Center(
                  child: Text(game.icon,
                      style: TextStyle(fontSize: r.sheetIconSize * 0.5)),
                ),
              ),
              SizedBox(width: r.sw * 0.04),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(game.name,
                      style: GoogleFonts.outfit(
                          fontSize: r.sheetTitleFont,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textDark)),
                  Text(game.nameTamil,
                      style: TextStyle(
                        fontFamily: GoogleFonts.notoSansTamil().fontFamily,
                        fontSize: r.sheetSubFont,
                        color: game.gradientColors[0],
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ],
          ),
          SizedBox(height: r.sh * 0.01),
          Text('Choose your difficulty level',
              style: GoogleFonts.outfit(
                  fontSize: r.sheetSubFont,
                  color: AppTheme.textSlate)),
          SizedBox(height: r.sh * 0.025),

          // Difficulty rows
          ...levels.map((lv) {
            final color = Color(lv['hex']! as int);
            final title = lv['title']! as String;
            return Padding(
              padding: EdgeInsets.only(bottom: r.sh * 0.012),
              child: GestureDetector(
                onTap: () {
                  AudioFeedbackService.playTap();
                  Navigator.pop(context);
                  Navigator.push(context,
                      FadeInSlidePageRoute(page: game.screenBuilder(title)));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.sw * 0.04,
                    vertical: r.sh * 0.016,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(r.sw * 0.045),
                    border:
                        Border.all(color: color.withValues(alpha: 0.15), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: r.sw * 0.025,
                        height: r.sw * 0.025,
                        decoration:
                            BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      SizedBox(width: r.sw * 0.035),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(title,
                                    style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w900,
                                        fontSize: r.diffTitleFont,
                                        color: AppTheme.textDark)),
                                SizedBox(width: r.sw * 0.02),
                                Text(
                                  '• ${lv['tamil']}',
                                  style: TextStyle(
                                    fontFamily:
                                        GoogleFonts.notoSansTamil().fontFamily,
                                    fontSize: r.xpFont,
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(lv['desc']! as String,
                                style: GoogleFonts.outfit(
                                    fontSize: r.diffDescFont,
                                    color: AppTheme.textSlate)),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: r.sw * 0.033,
                          color: color.withValues(alpha: 0.6)),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
