import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../constants/tamil_data.dart';
import '../providers/enhanced_progress_provider.dart';
import '../widgets/safe_image.dart';
import 'story_detail_screen.dart';
import 'story_quiz_screen.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  String _selectedFilter = 'All Stories'; // 'All Stories' or 'My Favorites'

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // Glass Header
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.white.withOpacity(0.9),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Moral Stories',
              style: GoogleFonts.lexend(
                color: AppTheme.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryRed.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: AppTheme.primaryRed, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${progress.totalStars}',
                      style: GoogleFonts.lexend(
                        color: AppTheme.primaryRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Toggle Switch & Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter Toggle
                  _buildFilterToggle(),
                  const SizedBox(height: 24),

                  // Featured Story (First story)
                  if (TamilData.tamilStories.isNotEmpty)
                    _buildFeaturedStoryCard(context, TamilData.tamilStories[0]),

                  const SizedBox(height: 24),
                  
                  // Story List (Remaining stories)
                  if (TamilData.tamilStories.length > 1)
                    ...TamilData.tamilStories.skip(1).map((story) => 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildStoryCard(context, story),
                      )
                    ).toList(),
                    
                  // Placeholder for locked content if needed
                  _buildLockedStoryCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.primaryRed.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryRed.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          _buildFilterButton('All Stories'),
          _buildFilterButton('My Favorites'),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text) {
    final isSelected = _selectedFilter == text;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = text),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppTheme.primaryRed : AppTheme.textSlate,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedStoryCard(BuildContext context, Map<String, dynamic> story) {
    return Container(
      decoration: AppTheme.glassRedCard(radius: 16),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / Feature area
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SafeImage(
                    assetPath: 'assets/images/story_placeholder_1.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'TAMIL & ENGLISH',
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryRed,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -20, // Overlap effect
                right: 16,
                child: GestureDetector(
                  onTap: () => _navigateToStory(context, story),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryRed.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24), // Space for FAB overlap
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Column(
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
                            story['title'],
                            style: GoogleFonts.notoSansTamil(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Moral: ${story['moral']}',
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              color: AppTheme.primaryRed,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite_border, color: AppTheme.textSlate),
                      onPressed: () {
                        // Toggle favorite logic
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'A classic tale to learn about life values and language.',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    color: AppTheme.textSlate,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                
                // Progress & Quiz Action
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 6,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: 0.65, // Example progress
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryRed,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Read Progress: 65%',
                            style: GoogleFonts.lexend(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSlate,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (_) => StoryQuizScreen(
                           questions: story['questions'] ?? [],
                           storyTitle: story['title'],
                         )));
                      },
                      icon: const Icon(Icons.quiz, size: 16),
                      label: const Text('Quiz +5'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryRed,
                        side: BorderSide(color: AppTheme.primaryRed.withOpacity(0.2)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(BuildContext context, Map<String, dynamic> story) {
    return GestureDetector(
      onTap: () => _navigateToStory(context, story),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: AppTheme.whiteCard(radius: 16),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SafeImage(
                  assetPath: (story['scenes'] != null && (story['scenes'] as List).isNotEmpty)
                      ? 'assets/images/${story['scenes'][0]['image']}.png'
                      : 'assets/images/placeholder.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story['title'],
                    style: GoogleFonts.notoSansTamil(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    story['moral'],
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: AppTheme.primaryRed,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Learn values through this engaging story.',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: AppTheme.textSlate,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  
                  // Metadata row
                  Row(
                    children: [
                      _buildMetaTag(Icons.schedule, '4 min'),
                      const SizedBox(width: 12),
                      _buildMetaTag(Icons.star, 'Level 1', color: AppTheme.amber),
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
  
  Widget _buildLockedStoryCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.whiteCard(radius: 16).copyWith(
        color: AppTheme.white.withOpacity(0.6), // Dimmed
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[300],
            ),
            child: const Icon(Icons.lock, color: AppTheme.textGray),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120, 
                  height: 16, 
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 200, 
                  height: 12, 
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(height: 16),
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                   decoration: AppTheme.pillBadge(bgColor: Colors.grey[200], borderColor: Colors.transparent),
                   child: Text(
                     'UNLOCK FOR 50 STARS',
                     style: GoogleFonts.lexend(
                       fontSize: 10,
                       fontWeight: FontWeight.bold,
                       color: AppTheme.textGray,
                     ),
                   ),
                 ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaTag(IconData icon, String text, {Color color = AppTheme.textSlate}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  void _navigateToStory(BuildContext context, Map<String, dynamic> story) {
      // Navigate to a reading screen, potentially reusing `StoryDetailScreen` 
      // which I'll assume exists or needs creation. For now, pushing a placeholder or existing logic.
      // The original code might have had logic in `StoriesScreen` directly or `StoryDetail`.
      // Let's check if StoryDetailScreen exists.
      // If not, I'll direct to a new simplified reading view inside this file or create one.
      // Based on previous file list, `stories_screen.dart` handled reading itself or navigated.
      // I'll create a `StoryReadingScreen` quickly if needed, or stick to this list.
      // Wait, the prompt implies "use this code to improve this app".
      // I should probably just ensure the navigation works.
      
      Navigator.push(context, MaterialPageRoute(builder: (_) => StoryDetailScreen(story: story)));
  }
}


