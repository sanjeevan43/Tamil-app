import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tamil_app/constants/app_theme.dart';
import 'package:tamil_app/screens/kinship_tree_explorer_screen.dart';
import 'package:tamil_app/screens/linguistic_scanner_screen.dart';
import 'package:tamil_app/screens/dialectics_analyzer_screen.dart';
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
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'AI Cognitive Academy',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            color: AppTheme.secondary,
          ),
        ),
        elevation: 0,
        backgroundColor: AppTheme.backgroundLight,
        iconTheme: const IconThemeData(color: AppTheme.secondary),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Powered by Claude AI',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.secondary,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              icon: '🌳',
              title: 'Kinship Tree Explorer',
              description: 'Learn Tamil kinship words with interactive quizzes',
              color: AppTheme.success,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => KinshipTreeExplorerScreen(childAge: childAge),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              icon: '📸',
              title: 'Linguistic Text Scanner',
              description: 'Scan Tamil text and get word-by-word explanations',
              color: AppTheme.info,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LinguisticScannerScreen(childAge: childAge),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              icon: '🗣️',
              title: 'Colloquial Dialectics Analyzer',
              description: 'Understand formal and colloquial Tamil differences',
              color: AppTheme.warning,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DialecticsAnalyzerScreen(childAge: childAge),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              icon: '🎭',
              title: 'Tolkappiyar\'s Riddle Academy',
              description: 'Solve age-appropriate Tamil riddles (விடுகதை)',
              color: AppTheme.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RiddleAcademyScreen(childAge: childAge),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              icon: '✍️',
              title: 'AI Moral Story Weaver',
              description: 'Create personalized Tamil stories with morals',
              color: AppTheme.primaryDark,
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
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.info.withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.info.withOpacity(0.15), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_rounded, color: AppTheme.info, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'AI Personalization Active',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppTheme.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Each feature dynamically adapts to your child\'s age and learning speed to deliver a tailored, world-class linguistic experience.',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.secondary.withOpacity(0.7),
                      height: 1.4,
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

  Widget _buildFeatureCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.12), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(icon, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
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
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward_ios_rounded, color: color, size: 14),
            ),
          ],
        ),
      ),
    );
  }
}
