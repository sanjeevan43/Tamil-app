import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';
import '../widgets/safe_image.dart';
import '../data/moral_stories_data.dart';
import '../widgets/premium_animations.dart';
import '../services/audio_feedback_service.dart';
import 'story_detail_screen.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  final List<Map<String, dynamic>> _allStories = MoralStoriesData.moralStories;

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context);

    // Categories
    final continueReading = _allStories.take(2).toList();
    final moralTales = _allStories;
    final thirukkuralTales = _allStories.reversed.toList();
    final audioStories = _allStories.skip(1).take(3).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Elegant Header
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: AppTheme.backgroundLight,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.secondary, AppTheme.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'கதை உலகம்',
                          style: GoogleFonts.notoSansTamil(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'STORY WORLD',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withOpacity(0.8),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Scrollable Sections
          SliverPadding(
            padding: const EdgeInsets.only(top: 20, bottom: 120),
            sliver: SliverList(
              delegate: SliverChildListExpandedDelegate([
                // Category 1: Continue Reading
                _buildNetflixSection(
                  title: 'CONTINUE READING',
                  subtitle: 'கற்றலைத் தொடரவும்',
                  stories: continueReading,
                  showProgress: true,
                ),
                const SizedBox(height: 32),

                // Category 2: Tamil Moral Tales
                _buildNetflixSection(
                  title: 'TAMIL MORAL TALES',
                  subtitle: 'நீதிக்கதைகள்',
                  stories: moralTales,
                ),
                const SizedBox(height: 32),

                // Category 3: Thirukkural Tales
                _buildNetflixSection(
                  title: 'THIRUKKURAL TALES',
                  subtitle: 'திருக்குறள் கதைகள்',
                  stories: thirukkuralTales,
                ),
                const SizedBox(height: 32),

                // Category 4: Audio Stories
                _buildNetflixSection(
                  title: 'AUDIO STORIES',
                  subtitle: 'ஒலிக் கதைகள்',
                  stories: audioStories,
                  isAudioOnly: true,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetflixSection({
    required String title,
    required String subtitle,
    required List<Map<String, dynamic>> stories,
    bool showProgress = false,
    bool isAudioOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle,
                    style: GoogleFonts.notoSansTamil(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textSlate,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.topoSilver),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              return _buildNetflixCard(story, showProgress, isAudioOnly);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNetflixCard(Map<String, dynamic> story, bool showProgress, bool isAudioOnly) {
    return SpringyTap(
      onTap: () {
        AudioFeedbackService.playTap();
        Navigator.push(
          context,
          FadeInSlidePageRoute(page: StoryDetailScreen(story: story)),
        );
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppTheme.topoSilver.withOpacity(0.5)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SafeImage(
                      assetPath: (story['scenes'] != null && (story['scenes'] as List).isNotEmpty)
                          ? 'assets/images/${story['scenes'][0]['image']}.png'
                          : 'assets/images/placeholder.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (isAudioOnly)
                    Container(
                      color: Colors.black38,
                      child: const Center(
                        child: Icon(Icons.play_circle_outline_rounded, color: Colors.white, size: 36),
                      ),
                    ),
                  if (showProgress)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 6,
                        color: Colors.black26,
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: 0.65,
                          child: Container(color: AppTheme.primary),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story['title'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.notoSansTamil(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    story['englishTitle'] ?? '',
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
          ],
        ),
      ),
    );
  }
}

class SliverChildListExpandedDelegate extends SliverChildDelegate {
  final List<Widget> children;
  SliverChildListExpandedDelegate(this.children);

  @override
  Widget? build(BuildContext context, int index) {
    if (index < 0 || index >= children.length) return null;
    return children[index];
  }

  @override
  int get estimateChildCount => children.length;

  @override
  bool shouldRebuild(covariant SliverChildListExpandedDelegate oldDelegate) {
    return oldDelegate.children != children;
  }
}
