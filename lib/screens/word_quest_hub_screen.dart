import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_theme.dart';
import '../data/tamil_data.dart';
import '../widgets/premium_animations.dart';
import 'lesson_screen.dart';

class WordQuestHubScreen extends StatefulWidget {
  const WordQuestHubScreen({super.key});

  @override
  State<WordQuestHubScreen> createState() => _WordQuestHubScreenState();
}

class _WordQuestHubScreenState extends State<WordQuestHubScreen> {
  String _searchQuery = '';
  
  // Custom theme mapping for categories
  final Map<String, Map<String, dynamic>> _categoryMetadata = {
    'fruits': {
      'icon': '🍎',
      'level': 'Easy',
      'color': Colors.orange,
      'tamil': 'பழங்கள்',
    },
    'animals': {
      'icon': '🦁',
      'level': 'Easy',
      'color': Colors.green,
      'tamil': 'விலங்குகள்',
    },
    'colors': {
      'icon': '🎨',
      'level': 'Medium',
      'color': Colors.purple,
      'tamil': 'நிறங்கள்',
    },
    'family': {
      'icon': '👨‍👩‍👧‍👦',
      'level': 'Medium',
      'color': Colors.pink,
      'tamil': 'குடும்பம்',
    },
    'school': {
      'icon': '🎒',
      'level': 'Hard',
      'color': Colors.blue,
      'tamil': 'பள்ளி',
    },
  };

  @override
  Widget build(BuildContext context) {
    // Group categories dynamically
    final pool = TamilData.lessonQuestions;
    final Map<String, int> categoryCounts = {};
    for (var item in pool) {
      final String cat = (item['category'] ?? 'General').toString();
      categoryCounts[cat] = (categoryCounts[cat] ?? 0) + 1;
    }

    final categories = categoryCounts.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    final filteredCategories = categories.where((cat) {
      final meta = _categoryMetadata[cat.toLowerCase()];
      final tamilName = meta?['tamil'] ?? '';
      return cat.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tamilName.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'WORD QUEST',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: AppTheme.textDark,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'வார்த்தை தேடல்',
                style: GoogleFonts.notoSansTamil(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a category to start your vocabulary quest. Match English words to correct Tamil terms.',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppTheme.textSlate,
                ),
              ),
              const SizedBox(height: 20),
              
              // Search Bar
              Container(
                decoration: AppTheme.whiteCard(radius: 16).copyWith(
                  border: Border.all(color: AppTheme.borderLight, width: 1.5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: const Icon(Icons.search_rounded, color: AppTheme.textGray),
                    hintText: 'Search categories...',
                    hintStyle: GoogleFonts.outfit(color: AppTheme.textGray),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Categories List
              Expanded(
                child: filteredCategories.isEmpty
                    ? Center(
                        child: Text(
                          'No categories found.',
                          style: GoogleFonts.outfit(color: AppTheme.textGray, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredCategories.length,
                        itemBuilder: (context, index) {
                          final category = filteredCategories[index];
                          final count = categoryCounts[category] ?? 0;
                          final key = category.toLowerCase();
                          final meta = _categoryMetadata[key] ?? {
                            'icon': '📝',
                            'level': 'General',
                            'color': Colors.blueGrey,
                            'tamil': category,
                          };
                          
                          final Color color = meta['color'] as Color;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Container(
                              decoration: AppTheme.whiteCard(radius: 24).copyWith(
                                border: Border.all(color: color.withOpacity(0.15), width: 1.5),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        FadeInSlidePageRoute(
                                          page: LessonScreen(lessonId: category),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Row(
                                        children: [
                                          // Icon circle
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              meta['icon'],
                                              style: const TextStyle(fontSize: 30),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          
                                          // Title & info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      category,
                                                      style: GoogleFonts.outfit(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 18,
                                                        color: AppTheme.textDark,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: color.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Text(
                                                        meta['level'],
                                                        style: GoogleFonts.outfit(
                                                          color: color,
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  meta['tamil'],
                                                  style: GoogleFonts.notoSansTamil(
                                                    color: AppTheme.textSlate,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  '$count Words Available',
                                                  style: GoogleFonts.outfit(
                                                    color: AppTheme.textGray,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          
                                          const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: AppTheme.textGray,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
