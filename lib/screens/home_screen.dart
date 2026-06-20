import 'dart:async';
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

import 'stories_screen.dart';
import 'profile_screen.dart';
import 'pronunciation_practice_game.dart';
import 'riddle_academy_screen.dart';
import 'linguistic_scanner_screen.dart';
import 'word_quest_hub_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Thirukkural? _dailyKural;
  bool _isLoadingKural = true;
  TamilProverb? _dailyProverb;
  int _selectedWisdomTab = 0; // 0 for Thirukkural, 1 for Proverb
  final ScrollController _quickActionsScrollController = ScrollController();
  final ScrollController _homeScrollController = ScrollController();
  bool _showWisdomCard = true;

  @override
  void initState() {
    super.initState();
    _fetchKural();
    _fetchProverb();
    _homeScrollController.addListener(_onHomeScroll);
  }

  void _onHomeScroll() {
    if (!mounted) return;
    if (_homeScrollController.offset > 180.0 && _showWisdomCard) {
      setState(() {
        _showWisdomCard = false;
      });
    } else if (_homeScrollController.offset <= 180.0 && !_showWisdomCard) {
      setState(() {
        _showWisdomCard = true;
      });
    }
  }

  @override
  void dispose() {
    _quickActionsScrollController.dispose();
    _homeScrollController.removeListener(_onHomeScroll);
    _homeScrollController.dispose();
    super.dispose();
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
              controller: _homeScrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: Greeting & Stats Row
                  _buildGreetingAndStats(progress),
                  const SizedBox(height: 24),
                  


                  // Section 3: Daily Wisdom Tabbed Section (Thirukkural/Proverb)
                  _buildWisdomSection(),
                  
                  // Section 4: Quick Learning Tools (Horizontal Scroll)
                  _buildQuickLearningTools(context, adaptiveAge),
                  const SizedBox(height: 24),
                  
                  // Section 5: Daily Mission Card
                  _buildDailyMissions(progress),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VANAKKAM,',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    progress.userName,
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    'Level ${progress.level} Scholar',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textGray,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                AudioFeedbackService.playTap();
                Navigator.push(context, FadeInSlidePageRoute(page: const ProfileScreen()));
              },
              child: Hero(
                tag: 'profile_avatar',
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primary.withOpacity(0.2), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primary.withOpacity(0.08),
                    child: Text(progress.avatar, style: const TextStyle(fontSize: 28)),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        
        // Stats Row (Compact cards)
        Row(
          children: [
            Expanded(child: _buildStatBadge('🔥', '${progress.streakDays} days', 'Streak', AppTheme.primary)),
            const SizedBox(width: 8),
            Expanded(child: _buildStatBadge('💎', '${progress.totalCoins} coins', 'Coins', AppTheme.secondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBadge(String emoji, String val, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15), width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              val,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
              ),
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
        border: Border.all(color: AppTheme.primary.withOpacity(0.1), width: 1.5),
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
                  fontSize: 14,
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

  Widget _buildWisdomSection() {
    if (_isLoadingKural) {
      return AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _showWisdomCard ? 1.0 : 0.0,
          child: _showWisdomCard
              ? Container(
                  height: 180,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: AppTheme.whiteCard(radius: 28),
                  child: const Center(child: CircularProgressIndicator()),
                )
              : const SizedBox(width: double.infinity, height: 0),
        ),
      );
    }

    final hasKural = _dailyKural != null;
    final hasProverb = _dailyProverb != null;

    if (!hasKural && !hasProverb) return const SizedBox.shrink();

    // Default to whichever is available, or use the selected index
    int activeTab = _selectedWisdomTab;
    if (!hasKural) activeTab = 1;
    if (!hasProverb) activeTab = 0;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _showWisdomCard ? 1.0 : 0.0,
        child: _showWisdomCard
            ? Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Container(
                  key: const ValueKey('wisdom_card_visible'),
                  decoration: AppTheme.whiteCard(radius: 28).copyWith(
                    border: Border.all(color: AppTheme.primary.withOpacity(0.1), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tab bar switcher
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            if (hasKural)
                              GestureDetector(
                                onTap: () {
                                  AudioFeedbackService.playPop();
                                  setState(() {
                                    _selectedWisdomTab = 0;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: activeTab == 0 ? AppTheme.primary.withOpacity(0.1) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      const Text('📜 ', style: TextStyle(fontSize: 14)),
                                      Text(
                                        'THIRUKKURAL',
                                        style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          color: activeTab == 0 ? AppTheme.primary : AppTheme.textSlate,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (hasKural && hasProverb) const SizedBox(width: 8),
                            if (hasProverb)
                              GestureDetector(
                                onTap: () {
                                  AudioFeedbackService.playPop();
                                  setState(() {
                                    _selectedWisdomTab = 1;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: activeTab == 1 ? AppTheme.primary.withOpacity(0.1) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      const Text('💡 ', style: TextStyle(fontSize: 14)),
                                      Text(
                                        'PROVERB',
                                        style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          color: activeTab == 1 ? AppTheme.primary : AppTheme.textSlate,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const Spacer(),
                            if (activeTab == 0)
                              IconButton(
                                icon: const Icon(Icons.volume_up_rounded, color: AppTheme.primary, size: 20),
                                onPressed: _speakKural,
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                          ],
                        ),
                      ),
                      
                      const Divider(color: AppTheme.borderLight, height: 1),

                      // Content body
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: activeTab == 0
                              ? Column(
                                  key: const ValueKey('kural_content'),
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _dailyKural!.line1,
                                      style: GoogleFonts.notoSansTamil(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textDark,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _dailyKural!.line2,
                                      style: GoogleFonts.notoSansTamil(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textDark,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _dailyKural!.explanation,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.notoSansTamil(
                                        fontSize: 12,
                                        color: AppTheme.textSlate,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  key: const ValueKey('proverb_content'),
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _dailyProverb!.proverb,
                                      style: GoogleFonts.notoSansTamil(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textDark,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      _dailyProverb!.meaning,
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        color: AppTheme.textSlate,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox(width: double.infinity, height: 0),
      ),
    );
  }



  Widget _buildQuickLearningTools(BuildContext context, int adaptiveAge) {
    final items = [
      _quickActionItem('Dictionary', 'Explore words', Icons.menu_book_rounded, Colors.green,
          () => Navigator.push(context, FadeInSlidePageRoute(page: LinguisticScannerScreen(childAge: adaptiveAge)))),
      _quickActionItem('Stories', 'Read moral tales', Icons.auto_stories_rounded, Colors.pink,
          () => Navigator.push(context, FadeInSlidePageRoute(page: const StoriesScreen()))),
      _quickActionItem('Word Quest', 'Vocabulary hub', Icons.casino_rounded, Colors.blue,
          () => Navigator.push(context, FadeInSlidePageRoute(page: const WordQuestHubScreen()))),
      _quickActionItem('Pronounce', 'Mic practice', Icons.mic_rounded, Colors.teal,
          () => Navigator.push(context, FadeInSlidePageRoute(page: const PronunciationPracticeGame()))),
      _quickActionItem('Riddle Hub', 'Solve puzzles', Icons.wb_sunny_rounded, Colors.indigo,
          () => Navigator.push(context, FadeInSlidePageRoute(page: RiddleAcademyScreen(childAge: adaptiveAge)))),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK LEARNING TOOLS',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppTheme.textSlate,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 136,
          child: ListView.builder(
            controller: _quickActionsScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return items[index];
            },
          ),
        ),
      ],
    );
  }

  Widget _quickActionItem(String title, String desc, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
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
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
}
