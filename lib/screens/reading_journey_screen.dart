import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../data/reading_journey_data.dart';
import '../providers/enhanced_progress_provider.dart';
import 'level_game_screen.dart';

class ReadingJourneyScreen extends StatefulWidget {
  const ReadingJourneyScreen({super.key});

  @override
  State<ReadingJourneyScreen> createState() => _ReadingJourneyScreenState();
}

class _ReadingJourneyScreenState extends State<ReadingJourneyScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Stage color palette
  static const List<Color> stageColors = [
    Color(0xFFFF7043), // Deep Orange
    Color(0xFF42A5F5), // Blue
    Color(0xFF66BB6A), // Green
    Color(0xFFAB47BC), // Purple
    Color(0xFFEF5350), // Red
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<EnhancedProgressProvider>();
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: Stack(
        children: [
          // Background pattern
          const _TamilWatermark(),

          // Main scroll
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                elevation: 0,
                backgroundColor: const Color(0xFFF5F0E8).withOpacity(0.95),
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Color(0xFF424242)),
                    ),
                  ),
                ),
                actions: [
                  // XP Badge
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange[400]!, Colors.orange[700]!],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      child: Row(
                        children: [
                          const Text('⚡', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(
                            '${progress.xpPoints}',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Star Counter
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD600), Color(0xFFFFAB00)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${progress.totalStars}',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding:
                        const EdgeInsets.only(top: 70, left: 24, right: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'வாசிப்புப் பயணம்',
                            style: GoogleFonts.notoSansTamil(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF3E2723),
                            ),
                          ),
                        ),
                        Text(
                          'Learning Journey',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            color: const Color(0xFF8D6E63),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Overall Progress Bar
                        _buildOverallProgress(progress),
                      ],
                    ),
                  ),
                ),
              ),

              // Stage Banners + Level Nodes
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= ReadingJourneyData.stages.length) return null;
                    final stage = ReadingJourneyData.stages[index];
                    final stageLevels =
                        ReadingJourneyData.getLevelsForStage(stage['id']);
                    final stageColor =
                        stageColors[(stage['id'] - 1) % stageColors.length];

                    return Column(
                      children: [
                        // Stage Banner
                        _buildStageBanner(stage, stageColor, progress),

                        // Level Nodes (zig-zag)
                        ...List.generate(stageLevels.length, (levelIndex) {
                          final level = stageLevels[levelIndex];
                          final globalLevelIndex = ReadingJourneyData.levels
                              .indexWhere((l) => l['id'] == level['id']);
                          final isZigRight = globalLevelIndex % 2 == 0;

                          return _buildLevelNode(
                            level: level,
                            isZigRight: isZigRight,
                            stageColor: stageColor,
                            screenWidth: screenWidth,
                            progress: progress,
                            isLastInStage:
                                levelIndex == stageLevels.length - 1,
                          );
                        }),

                        const SizedBox(height: 10),
                      ],
                    );
                  },
                  childCount: ReadingJourneyData.stages.length,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverallProgress(EnhancedProgressProvider progress) {
    final completedLevels = ReadingJourneyData.levels
        .where((l) => progress.isLevelCompleted(l['id']))
        .length;
    final totalLevels = ReadingJourneyData.levels.length;
    final percent = completedLevels / totalLevels;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Level $completedLevels / $totalLevels',
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: const Color(0xFF5D4037)),
                    ),
                    Text(
                      '${(percent * 100).toInt()}%',
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: const Color(0xFF3E2723)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFEFEBE9),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFFFF7043)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageBanner(Map<String, dynamic> stage, Color stageColor,
      EnhancedProgressProvider progress) {
    final stageProgress = progress.getStageProgress(stage['id']);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: stageColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: stageColor.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        image: DecorationImage(
          image: const NetworkImage('https://www.transparenttextures.com/patterns/cubes.png'),
          opacity: 0.1,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Row(
        children: [
          // Stage Number Badge
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: Center(
              child: Text(
                '${stage['id']}',
                style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage['tamilName'],
                  style: GoogleFonts.notoSansTamil(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  stage['name'].toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Stack(
                  children: [
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      height: 8,
                      width: MediaQuery.of(context).size.width * 0.5 * stageProgress,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white.withOpacity(0.9), Colors.white],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${(stageProgress * 100).toInt()}% COMPLETED',
                  style: GoogleFonts.outfit(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
        ],
      ),
    );
  }

  Widget _buildLevelNode({
    required Map<String, dynamic> level,
    required bool isZigRight,
    required Color stageColor,
    required double screenWidth,
    required EnhancedProgressProvider progress,
    required bool isLastInStage,
  }) {
    final levelId = level['id'] as int;
    final isUnlocked = progress.isLevelUnlocked(levelId);
    final isCompleted = progress.isLevelCompleted(levelId);
    final isCurrent = levelId == progress.level;
    final stars = progress.getLevelStarRating(levelId);

    // Zig-zag positioning
    final double xOffset = isZigRight
        ? screenWidth * 0.25
        : screenWidth * 0.55;

    return SizedBox(
      height: 130,
      child: Stack(
        children: [
          // Connecting path line
          if (!isLastInStage)
            Positioned(
              left: 0,
              right: 0,
              top: 50,
              bottom: 0,
              child: CustomPaint(
                painter: _PathLinePainter(
                  startX: xOffset + 35,
                  startY: 30,
                  endX: (isZigRight
                          ? screenWidth * 0.55
                          : screenWidth * 0.25) +
                      35,
                  endY: 100,
                  color: isCompleted
                      ? stageColor.withOpacity(0.5)
                      : Colors.grey[300]!,
                ),
              ),
            ),

          // Level Circle Button
          Positioned(
            left: xOffset,
            top: 15,
            child: GestureDetector(
              onTap: isUnlocked
                  ? () => _onLevelTapped(levelId, level, stageColor, progress)
                  : null,
              child: isCurrent
                  ? AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: child,
                        );
                      },
                      child: _buildLevelCircle(
                        levelId: levelId,
                        isUnlocked: isUnlocked,
                        isCompleted: isCompleted,
                        isCurrent: isCurrent,
                        stars: stars,
                        stageColor: stageColor,
                        level: level,
                      ),
                    )
                  : _buildLevelCircle(
                      levelId: levelId,
                      isUnlocked: isUnlocked,
                      isCompleted: isCompleted,
                      isCurrent: isCurrent,
                      stars: stars,
                      stageColor: stageColor,
                      level: level,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCircle({
    required int levelId,
    required bool isUnlocked,
    required bool isCompleted,
    required bool isCurrent,
    required int stars,
    required Color stageColor,
    required Map<String, dynamic> level,
  }) {
    return Column(
      children: [
        // Main circle
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isUnlocked
                ? LinearGradient(
                    colors: [
                      stageColor,
                      stageColor.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isUnlocked ? null : const Color(0xFFE0E0E0),
            border: Border.all(
              color: isCurrent
                  ? Colors.white
                  : (isCompleted ? Colors.white : Colors.grey[300]!),
              width: isCurrent ? 4 : 3,
            ),
            boxShadow: [
              if (isCurrent)
                BoxShadow(
                  color: stageColor.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              if (isUnlocked && !isCurrent)
                BoxShadow(
                  color: stageColor.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Center(
            child: isUnlocked
                ? (isCompleted
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 32)
                    : Text(
                        '$levelId',
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ))
                : Icon(Icons.lock_rounded,
                    color: Colors.grey[500], size: 28),
          ),
        ),

        const SizedBox(height: 6),

        // Star rating
        if (isCompleted)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              return Icon(
                i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                color: i < stars
                    ? const Color(0xFFFFD600)
                    : Colors.grey[400],
                size: 16,
              );
            }),
          )
        else if (isUnlocked)
          FittedBox(
            child: Text(
              level['title'],
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF5D4037),
              ),
            ),
          )
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              return Icon(
                Icons.star_outline_rounded,
                color: Colors.grey[300],
                size: 14,
              );
            }),
          ),
      ],
    );
  }

  void _onLevelTapped(int levelId, Map<String, dynamic> level, Color stageColor,
      EnhancedProgressProvider progress) {
    final isCompleted = progress.isLevelCompleted(levelId);
    final stars = progress.getLevelStarRating(levelId);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),

              // Level circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [stageColor, stageColor.withOpacity(0.6)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: stageColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$levelId',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(
                      i < stars
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: i < stars
                          ? const Color(0xFFFFD600)
                          : Colors.grey[300],
                      size: 32,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 12),

              // Title
              Text(
                level['tamilTitle'],
                style: GoogleFonts.notoSansTamil(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF3E2723),
                ),
              ),
              Text(
                level['title'],
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 8),

              Text(
                level['description'],
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: Colors.grey[500],
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 6),

              // XP and Reward Area
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFE082), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Text('⚡', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'POTENTIAL XP',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFFF8F00),
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          '+${level['xp']} XP',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFBF360C),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Start button
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close sheet
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LevelGameScreen(
                          level: level,
                          stageColor: stageColor,
                          onComplete: (earnedStars) {
                            progress.completeLevel(levelId, earnedStars);
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: stageColor,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: stageColor.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isCompleted ? 'PLAY AGAIN' : 'START LEVEL',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.play_arrow_rounded, size: 28),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showCompletionCelebration(
      BuildContext ctx, int levelId, int stars, Color color) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 12),
                  Text(
                    'Level $levelId Complete!',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: i < stars ? 1.0 : 0.3),
                        duration:
                            Duration(milliseconds: 400 + (i * 200)),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.5 + (value * 0.5),
                            child: Opacity(
                              opacity: value.clamp(0.3, 1.0),
                              child: Icon(
                                Icons.star_rounded,
                                color: i < stars
                                    ? const Color(0xFFFFD600)
                                    : Colors.grey[300],
                                size: 48,
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    stars == 3
                        ? 'Perfect! ⭐⭐⭐'
                        : stars == 2
                            ? 'Great job! ⭐⭐'
                            : 'Good work! ⭐',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'CONTINUE',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}

// Tamil watermark background
class _TamilWatermark extends StatelessWidget {
  const _TamilWatermark();

  @override
  Widget build(BuildContext context) {
    const letters = [
      'அ', 'ஆ', 'இ', 'ஈ', 'உ', 'ஊ', 'எ', 'ஏ', 'ஐ', 'ஒ', 'ஓ', 'ஔ',
      'க', 'ச', 'ட', 'த', 'ப', 'ற'
    ];
    final random = math.Random(42); // Seed for consistent scattered layout

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: List.generate(20, (index) {
            final top = random.nextDouble() * 2000; // Scatters across long map
            final left = random.nextDouble() * MediaQuery.of(context).size.width;
            final letter = letters[random.nextInt(letters.length)];
            final rotation = (random.nextDouble() - 0.5) * 0.5;
            final size = 40.0 + random.nextDouble() * 40.0;

            return Positioned(
              top: top,
              left: left,
              child: Transform.rotate(
                angle: rotation,
                child: Opacity(
                  opacity: 0.04,
                  child: Text(
                    letter,
                    style: GoogleFonts.notoSansTamil(
                      fontSize: size,
                      fontWeight: FontWeight.w900,
                      color: Colors.brown[400],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// Custom painter for connecting path lines between level nodes
class _PathLinePainter extends CustomPainter {
  final double startX, startY, endX, endY;
  final Color color;

  _PathLinePainter({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(startX, startY);

    // Smooth S-curve between nodes
    final midY = (startY + endY) / 2;
    path.cubicTo(startX, midY, endX, midY, endX, endY);

    // Draw dashed
    final dashPath = Path();
    const dashLen = 8.0;
    const gapLen = 6.0;
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        dashPath.addPath(
            metric.extractPath(dist, dist + dashLen), Offset.zero);
        dist += dashLen + gapLen;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
