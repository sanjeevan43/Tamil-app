import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';
import '../services/auth_service.dart';
import '../services/audio_service.dart';
import '../services/audio_feedback_service.dart';
import '../services/thirukkural_service.dart';
import '../services/proverb_service.dart';
import '../widgets/premium_animations.dart';

// Screens to navigate
import 'games_hub_screen.dart';
import 'tamil_letters_screen.dart';
import 'stories_screen.dart';
import 'profile_screen.dart';
import 'classroom_connect_screen.dart';
import 'pronunciation_practice_game.dart';
import 'admin_control_screen.dart';
import 'community_forum_screen.dart';
import 'lesson_screen.dart';
import 'riddle_academy_screen.dart';
import 'linguistic_scanner_screen.dart';
import 'ai_cognitive_academy_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Thirukkural? _dailyKural;
  bool _isLoadingKural = true;
  TamilProverb? _dailyProverb;
  bool _showAllQuickActions = false;

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

  void _speakKural() {
    if (_dailyKural != null) {
      AudioFeedbackService.playPop();
      AudioService.playWord('${_dailyKural!.line1} ${_dailyKural!.line2}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context);
    final adaptiveAge = progress.level + 5;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          // Background soft accent circle
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withOpacity(0.05),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: Greeting & Stats Row
                  _buildGreetingAndStats(progress),
                  const SizedBox(height: 28),
                  
                  // Section 2: Daily Mission Card
                  _buildDailyMissions(progress),
                  const SizedBox(height: 28),
                  
                  // Section 3: Daily Thirukkural (Glass Card + Audio)
                  _buildDailyKuralSection(),
                  const SizedBox(height: 28),
                  
                  // Proverb Section
                  if (_dailyProverb != null) ...[
                    _buildDailyProverbSection(),
                    const SizedBox(height: 28),
                  ],
                  
                  // Section 4: Quick Learning Grid (with View All)
                  _buildQuickLearningGrid(context, adaptiveAge),
                  const SizedBox(height: 28),
                  
                  // Section 5: Continue Learning (Recently played)
                  _buildContinueLearning(context, progress),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingAndStats(EnhancedProgressProvider progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vanakkam,',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSlate,
                  ),
                ),
                Text(
                  '${progress.userName} 👋',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                AudioFeedbackService.playTap();
                Navigator.push(context, FadeInSlidePageRoute(page: const ProfileScreen()));
              },
              child: CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.primary.withOpacity(0.1),
                child: Text(progress.avatar, style: const TextStyle(fontSize: 28)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Stats Badges
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatBadge('🔥', '${progress.streakDays} Days', 'Streak', AppTheme.primary),
            _buildStatBadge('⭐', '${progress.totalStars} Stars', 'Stars', AppTheme.accent),
            _buildStatBadge('💎', '${progress.totalCoins} Coins', 'Coins', AppTheme.secondary),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBadge(String emoji, String val, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            val,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyMissions(EnhancedProgressProvider progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.whiteCard(radius: 28).copyWith(
        border: Border.all(color: AppTheme.primary.withOpacity(0.15), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🚀', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'TODAY\'S ADVENTURE',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Checklist
          _buildMissionItem('Learn 3 new words today', true),
          _buildMissionItem('Read 1 Tamil moral story', progress.totalStars > 5),
          _buildMissionItem('Play any 1 educational game', progress.quizScore > 0),
          
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.66,
              minHeight: 8,
              backgroundColor: AppTheme.topoSilver.withOpacity(0.4),
              valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionItem(String desc, bool done) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: done ? AppTheme.success : AppTheme.textGray,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              desc,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: done ? AppTheme.textDark : AppTheme.textSlate,
                decoration: done ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyKuralSection() {
    if (_isLoadingKural) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_dailyKural == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassCard(opacity: 0.9, radius: 28).copyWith(
        border: Border.all(color: AppTheme.secondary.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('📜', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    'DAILY THIRUKKURAL',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.secondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, color: AppTheme.secondary, size: 24),
                onPressed: _speakKural,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _dailyKural!.line1,
            style: GoogleFonts.notoSansTamil(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _dailyKural!.line2,
            style: GoogleFonts.notoSansTamil(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _dailyKural!.explanation,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.notoSansTamil(
              fontSize: 13,
              color: AppTheme.textSlate,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyProverbSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.whiteCard(radius: 28).copyWith(
        border: Border.all(color: AppTheme.accent.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAILY PROVERB',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _dailyProverb!.proverb,
                  style: GoogleFonts.notoSansTamil(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLearningGrid(BuildContext context, int adaptiveAge) {
    final actions = [
      _quickActionItem('Dictionary', 'New words', Icons.menu_book_rounded, Colors.green,
          () => Navigator.push(context, FadeInSlidePageRoute(page: LinguisticScannerScreen(childAge: adaptiveAge)))),
      _quickActionItem('Learn English', 'Duolingo style', Icons.language_rounded, Colors.blue,
          () => Navigator.push(context, FadeInSlidePageRoute(page: const LessonScreen(lessonId: 'animals_1')))),
      _quickActionItem('Q&A Forum', 'Ask others', Icons.forum_rounded, Colors.purple,
          () => Navigator.push(context, FadeInSlidePageRoute(page: const CommunityForumScreen()))),
      _quickActionItem('Classrooms', 'Learn together', Icons.school_rounded, Colors.orange,
          () => Navigator.push(context, FadeInSlidePageRoute(page: const ClassroomConnectScreen()))),
      if (_showAllQuickActions) ...[
        _quickActionItem('Pronounce', 'Mic check', Icons.mic_rounded, Colors.teal,
            () => Navigator.push(context, FadeInSlidePageRoute(page: const PronunciationPracticeGame()))),
        _quickActionItem('Daily Word', 'Power word', Icons.wb_sunny_rounded, Colors.indigo,
            () => Navigator.push(context, FadeInSlidePageRoute(page: RiddleAcademyScreen(childAge: adaptiveAge)))),
        if (Provider.of<AuthService>(context, listen: false).userRole == 'admin')
          _quickActionItem('Admin Panel', 'Manage app', Icons.admin_panel_settings_rounded, Colors.red,
              () => Navigator.push(context, FadeInSlidePageRoute(page: const AdminControlScreen()))),
      ],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK LEARNING',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppTheme.textSlate,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.25,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) => actions[index],
        ),
        const SizedBox(height: 14),
        Center(
          child: TextButton.icon(
            onPressed: () {
              AudioFeedbackService.playTap();
              setState(() {
                _showAllQuickActions = !_showAllQuickActions;
              });
            },
            icon: Icon(
              _showAllQuickActions ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
              color: AppTheme.primary,
            ),
            label: Text(
              _showAllQuickActions ? 'VIEW LESS' : 'VIEW ALL',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w900,
                color: AppTheme.primary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _quickActionItem(String title, String desc, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: AppTheme.whiteCard(radius: 20).copyWith(
        border: Border.all(color: color.withOpacity(0.15), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            AudioFeedbackService.playTap();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    color: AppTheme.textGray,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueLearning(BuildContext context, EnhancedProgressProvider progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONTINUE LEARNING',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppTheme.textSlate,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.whiteCard(radius: 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Text('🎓', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tamil Letters Path',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      'Level ${progress.level} | Continue where you left off',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppTheme.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  AudioFeedbackService.playTap();
                  Navigator.push(context, FadeInSlidePageRoute(page: const TamilLettersScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'RESUME',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
