import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tamil_app/constants/app_theme.dart';
import 'package:tamil_app/screens/kinship_tree_explorer_screen.dart';
import 'package:tamil_app/screens/linguistic_scanner_screen.dart';
import 'package:tamil_app/screens/akaran_mentor_screen.dart';
import 'package:tamil_app/screens/riddle_academy_screen.dart';
import 'package:tamil_app/screens/ai_story_weaver_screen.dart';

class AICognitiveAcademyScreen extends StatelessWidget {
  final int childAge;
  final String? childName;

  const AICognitiveAcademyScreen({
    super.key,
    required this.childAge,
    this.childName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Breathtaking Gradient Hero Header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            elevation: 0,
            backgroundColor: AppTheme.secondary,
            leading: Navigator.canPop(context)
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: AppTheme.white, size: 20),
                      ),
                    ),
                  )
                : null,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.secondary, AppTheme.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Sparkles overlay decor
                    Positioned(
                      top: 40,
                      right: 30,
                      child: Text('✨', style: TextStyle(fontSize: 48, color: AppTheme.white.withOpacity(0.15))),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 30,
                      child: Text('🚀', style: TextStyle(fontSize: 56, color: AppTheme.white.withOpacity(0.1))),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'CLAUDE AI ACTIVE',
                                style: GoogleFonts.outfit(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'AI Cognitive Academy',
                              style: GoogleFonts.outfit(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.white,
                              ),
                            ),
                            Text(
                              'Interactive smart tools tailored for your child',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.white.withOpacity(0.7),
                              ),
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

          // Main body options
          SliverPadding(
            padding: const EdgeInsets.all(24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildFeatureCard(
                  context,
                  icon: '🌳',
                  title: 'Kinship Tree Explorer',
                  description: 'Learn Tamil family relationships and kinship words with visual interactive quizzes.',
                  color: AppTheme.success,
                  tag: 'SOCIAL & FAMILY',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KinshipTreeExplorerScreen(childAge: childAge),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _buildFeatureCard(
                  context,
                  icon: '📸',
                  title: 'Linguistic Text Scanner',
                  description: 'Snap or scan any Tamil text to get real-time word meanings and smart explanations.',
                  color: AppTheme.info,
                  tag: 'OCR TECHNOLOGY',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LinguisticScannerScreen(childAge: childAge),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _buildFeatureCard(
                  context,
                  icon: '🤖',
                  title: 'Akaran Interactive Mentor',
                  description: 'Chat, play interactive word games, and master spoken & written Tamil with our AI.',
                  color: AppTheme.primary,
                  tag: 'CONVERSATIONAL AI',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AkaranMentorScreen(childAge: childAge),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _buildFeatureCard(
                  context,
                  icon: '🎭',
                  title: 'Tolkappiyar\'s Riddle Academy',
                  description: 'Solve age-appropriate Tamil riddles (விடுகதை) to boost vocabulary and creativity.',
                  color: const Color(0xFFAB47BC),
                  tag: 'RIDDLES & LOGIC',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RiddleAcademyScreen(childAge: childAge),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _buildFeatureCard(
                  context,
                  icon: '✍️',
                  title: 'AI Moral Story Weaver',
                  description: 'Weave personalized moral Tamil stories starring your child, with premium full narration.',
                  color: const Color(0xFFFF7043),
                  tag: 'STORY CREATIVE ENGINE',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AIStoryWeaverScreen(
                        childAge: childAge,
                        childName: childName,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                
                // Adaptive Personalization Banner
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppTheme.borderLight, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.secondary.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.psychology_outlined, color: AppTheme.primary, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'Personalized for ${childName ?? "Explorer"}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: AppTheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Each AI-powered feature in the Cognitive Academy automatically scales vocabulary, complexity, and quizzes to match a child of age $childAge.',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textGray,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
    required Color color,
    required String tag,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: color.withOpacity(0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Floating Animated-Like Avatar Box
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.1), width: 1.5),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.outfit(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: color,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppTheme.textGray,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(Icons.arrow_forward_ios_rounded, color: color, size: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
