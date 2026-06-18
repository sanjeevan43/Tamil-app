import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';
import '../widgets/premium_animations.dart';
import '../services/audio_feedback_service.dart';

// Screens
import 'riddle_academy_screen.dart';
import 'letter_hunt_game.dart';
import 'word_builder_game.dart';
import 'memory_game_screen.dart';
import 'fill_blanks_game.dart';
import 'sentence_builder_game.dart';
import 'pronunciation_practice_game.dart';
import 'writing_practice_game.dart';
import 'word_scramble_game.dart';
import 'sound_match_game.dart';
import 'word_search_game.dart';
import 'odd_one_out_game.dart';

class GamesHubScreen extends StatelessWidget {
  const GamesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context, listen: false);
    final childAge = progress.level + 5;

    final games = [
      {'name': 'Letter Hunt', 'tamil': 'எழுத்து வேட்டை', 'icon': '🎯', 'description': 'Find the correct letter', 'color': const Color(0xFFFF7043), 'screen': const LetterHuntGame(), 'xp': '+30 XP', 'difficulty': 1},
      {'name': 'Writing Practice', 'tamil': 'எழுத்துப் பயிற்சி', 'icon': '✏️', 'description': 'Trace letters', 'color': const Color(0xFF5C6BC0), 'screen': const WritingPracticeGame(), 'xp': '+40 XP', 'difficulty': 2},
      {'name': 'Word Search', 'tamil': 'சொல் தேடல்', 'icon': '🔍', 'description': 'Find hidden words', 'color': const Color(0xFF9CCC65), 'screen': const WordSearchGame(), 'xp': '+50 XP', 'difficulty': 3},
      {'name': 'Word Scramble', 'tamil': 'சொல் கலைத்தல்', 'icon': '🧩', 'description': 'Unscramble words', 'color': const Color(0xFF7E57C2), 'screen': const WordScrambleGame(), 'xp': '+45 XP', 'difficulty': 2},
      {'name': 'Sentence Builder', 'tamil': 'வாக்கிய அமைப்பு', 'icon': '📚', 'description': 'Form sentences', 'color': const Color(0xFF26A69A), 'screen': const SentenceBuilderGame(), 'xp': '+50 XP', 'difficulty': 3},
      {'name': 'Memory Match', 'tamil': 'நினைவக போட்டி', 'icon': '🧠', 'description': 'Match Tamil letters', 'color': AppTheme.success, 'screen': const MemoryGameScreen(), 'xp': '+35 XP', 'difficulty': 1},
      {'name': 'Riddle Academy', 'tamil': 'புதிர் அரங்கம்', 'icon': '💡', 'description': 'Solve Tamil riddles', 'color': const Color(0xFFAB47BC), 'screen': RiddleAcademyScreen(childAge: childAge), 'xp': '+50 XP', 'difficulty': 3},
      {'name': 'Fill Blanks', 'tamil': 'இடம் நிரப்பு', 'icon': '📝', 'description': 'Complete the word', 'color': const Color(0xFFEF5350), 'screen': const FillBlanksGame(), 'xp': '+35 XP', 'difficulty': 2},
      {'name': 'Pronunciation', 'tamil': 'உச்சரிப்பு பயிற்சி', 'icon': '🎤', 'description': 'Practice speaking', 'color': const Color(0xFFFF8A65), 'screen': const PronunciationPracticeGame(), 'xp': '+40 XP', 'difficulty': 2},
      {'name': 'Sound Match', 'tamil': 'ஒலி பொருத்தம்', 'icon': '🔊', 'description': 'Listen and match', 'color': const Color(0xFF29B6F6), 'screen': const SoundMatchGame(), 'xp': '+30 XP', 'difficulty': 1},
      {'name': 'Odd One Out', 'tamil': 'வேறுபட்டதைத் தேடு', 'icon': '🦄', 'description': 'Find the odd word', 'color': const Color(0xFFEC407A), 'screen': const OddOneOutGame(), 'xp': '+40 XP', 'difficulty': 2},
      {'name': 'Word Builder', 'tamil': 'சொல் கட்டுதல்', 'icon': '🔨', 'description': 'Build Tamil words', 'color': const Color(0xFF42A5F5), 'screen': const WordBuilderGame(), 'xp': '+45 XP', 'difficulty': 2},
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: AppTheme.backgroundLight,
            elevation: 0,
            leading: Navigator.canPop(context)
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        AudioFeedbackService.playTap();
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: AppTheme.textDark.withOpacity(0.08), blurRadius: 8)],
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: AppTheme.secondary),
                      ),
                    ),
                  )
                : null,
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
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(8)),
                          child: Text('${games.length} GAMES AVAILABLE', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: 1)),
                        ),
                        const SizedBox(height: 8),
                        Text('விளையாட்டு அரங்கம்', style: GoogleFonts.notoSansTamil(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.white)),
                        Text('Games Arena', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.white.withOpacity(0.8))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.72,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final game = games[index];
                  return FadeInSlide(
                    direction: SlideDirection.up,
                    delay: Duration(milliseconds: 50 + (index * 40)),
                    child: _buildGameCard(context, game),
                  );
                },
                childCount: games.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, Map<String, dynamic> game) {
    final color = game['color'] as Color;
    final int difficulty = game['difficulty'] as int;
    final String xp = game['xp'] as String;

    return SpringyTap(
      onTap: () {
        AudioFeedbackService.playTap();
        Navigator.push(context, FadeInSlidePageRoute(page: game['screen'] as Widget));
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // Badges Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // XP Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      xp,
                      style: GoogleFonts.outfit(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  
                  // Difficulty Stars
                  Row(
                    children: List.generate(3, (index) {
                      return Icon(
                        Icons.star_rounded,
                        size: 11,
                        color: index < difficulty ? AppTheme.accent : AppTheme.topoSilver,
                      );
                    }),
                  ),
                ],
              ),
              const Spacer(),
              
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Text(game['icon'] as String, style: const TextStyle(fontSize: 34)),
              ),
              const SizedBox(height: 12),
              
              // Titles
              Text(
                game['name'] as String,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textDark),
              ),
              Text(
                game['tamil'] as String,
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansTamil(fontSize: 10, color: color, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              
              // Play Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'PLAY',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
