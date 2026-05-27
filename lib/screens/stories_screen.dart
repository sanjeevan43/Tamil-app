import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../constants/tamil_data.dart';
import '../providers/enhanced_progress_provider.dart';
import '../widgets/safe_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import 'story_detail_screen.dart';
import 'story_quiz_screen.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  final FirestoreService _firestore = FirestoreService();
  String _selectedFilter = 'All Stories'; // 'All Stories' or 'My Favorites'

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Elegant Header
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.white.withOpacity(0.9),
            elevation: 0,
            leading: Navigator.canPop(context)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textDark),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                : null,
            centerTitle: true,
            title: Text(
              'MORAL STORIES',
              style: GoogleFonts.outfit(
                color: AppTheme.textDark,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: AppTheme.warning, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${progress.totalStars}',
                      style: GoogleFonts.outfit(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Content
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.getStoriesStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }

              final stories = snapshot.data?.docs ?? [];
              
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterToggle(),
                      const SizedBox(height: 32),

                      Text(
                        'FEATURED STORY',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Featured Story
                      if (stories.isNotEmpty)
                        _buildFeaturedStoryCard(context, stories[0].data() as Map<String, dynamic>)
                      else if (!snapshot.hasData || stories.isEmpty)
                         _buildEmptyBox('No stories found. Add some from Admin Panel!'),

                      const SizedBox(height: 32),

                      Text(
                        'DISCOVER MORE',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Story List
                      if (stories.length > 1)
                        ...stories.skip(1).map((doc) => 
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _buildStoryCard(context, doc.data() as Map<String, dynamic>),
                          )
                        ),
                        
                      _buildLockedStoryCard(),
                      const SizedBox(height: 40),
                      Text(
                        'WORLD OF TAMIL',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildWorldMapSection(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBox(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: AppTheme.offWhite, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          const Icon(Icons.auto_stories_rounded, size: 48, color: AppTheme.borderLight),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center, style: GoogleFonts.outfit(color: AppTheme.textGray)),
        ],
      ),
    );
  }

  Widget _buildFilterToggle() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppTheme.offWhite,
        borderRadius: BorderRadius.circular(16),
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.textDark.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? AppTheme.primary : AppTheme.textSlate,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedStoryCard(BuildContext context, Map<String, dynamic> story) {
    return Container(
      decoration: AppTheme.whiteCard(radius: 32),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              const SizedBox(
                height: 240,
                width: double.infinity,
                child: SafeImage(
                  assetPath: 'assets/images/story_placeholder_1.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'BILINGUAL',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () => _navigateToStory(context, story),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(color: AppTheme.white, width: 3),
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: AppTheme.white, size: 40),
                  ),
                ),
              ),
            ],
          ),
          
          Padding(
            padding: const EdgeInsets.all(24.0),
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
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          Text(
                            story['englishTitle'] ?? '',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSlate,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Moral: ${story['moral']}',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite_outline_rounded, color: AppTheme.textSlate),
                      onPressed: () {},
                      style: IconButton.styleFrom(backgroundColor: AppTheme.offWhite),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'A timeless classic that teaches essential life values while improving your Tamil reading skills.',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppTheme.textSlate,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: const LinearProgressIndicator(
                              value: 0.65,
                              minHeight: 8,
                              backgroundColor: AppTheme.offWhite,
                              valueColor: AlwaysStoppedAnimation(AppTheme.primary),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Reading Progress: 65%',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (_) => StoryQuizScreen(
                           questions: story['questions'] ?? [],
                           storyTitle: story['title'],
                         )));
                      },
                      icon: const Icon(Icons.quiz_outlined, size: 18),
                      label: const Text('QUIZ'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.whiteCard(radius: 24),
        child: Row(
          children: [
            Hero(
              tag: 'story_${story['id'] ?? story['title']}',
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppTheme.offWhite,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SafeImage(
                    assetPath: (story['scenes'] != null && (story['scenes'] as List).isNotEmpty)
                        ? 'assets/images/${story['scenes'][0]['image']}.png'
                        : 'assets/images/placeholder.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story['title'] ?? 'Tamil Story',
                    style: GoogleFonts.notoSansTamil(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    story['englishTitle'] ?? '',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSlate,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (story['moral'] != null)
                    Text(
                      story['moral'],
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMetaTag(Icons.timer_outlined, '4 min'),
                      const SizedBox(width: 16),
                      _buildMetaTag(Icons.star_outline_rounded, 'Level 1', color: AppTheme.warning),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.borderLight, size: 28),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLockedStoryCard() {
    return Opacity(
      opacity: 0.6,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.offWhite,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.borderLight, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppTheme.borderLight,
              ),
              child: const Icon(Icons.lock_person_rounded, color: AppTheme.textGray, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 140, 
                    height: 16, 
                    decoration: BoxDecoration(color: AppTheme.borderLight, borderRadius: BorderRadius.circular(8)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 200, 
                    height: 12, 
                    decoration: BoxDecoration(color: AppTheme.borderLight.withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'UNLOCK FOR 50 STARS',
                      style: GoogleFonts.outfit(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                        letterSpacing: 0.5,
                      ),
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

  Widget _buildWorldMapSection() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: TamilData.globalFacts.length,
        itemBuilder: (context, index) {
          final fact = TamilData.globalFacts[index];
          return _buildWorldCityCard(fact);
        },
      ),
    );
  }

  Widget _buildWorldCityCard(Map<String, String> data) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.topoSilver, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(data['flag'] ?? '📍', style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data['country'] ?? 'Unknown',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.secondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data['fact'] ?? '',
            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textSlate, height: 1.4),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMetaTag(IconData icon, String text, {Color color = AppTheme.textGray}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  void _navigateToStory(BuildContext context, Map<String, dynamic> story) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => StoryDetailScreen(story: story)));
  }
}
