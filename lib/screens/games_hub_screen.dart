import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_theme.dart';
import 'letter_hunt_game.dart';
import 'word_builder_game.dart';
import 'memory_game_screen.dart';
import 'quiz_screen.dart';
import 'fill_blanks_game.dart';
import 'sentence_builder_game.dart';
import 'pronunciation_practice_game.dart';
import 'writing_practice_game.dart';
import 'quiz_battle_game.dart';
import 'word_scramble_game.dart';
import 'sound_match_game.dart';
import 'word_search_game.dart';

class GamesHubScreen extends StatelessWidget {
  const GamesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final games = [
      {'name': 'Letter Hunt', 'tamil': 'எழுத்து வேட்டை', 'icon': '🎯', 'description': 'Find the correct letter', 'color': const Color(0xFFFF7043), 'screen': const LetterHuntGame()},
      {'name': 'Word Builder', 'tamil': 'சொல் கட்டுதல்', 'icon': '🔨', 'description': 'Build Tamil words', 'color': const Color(0xFF42A5F5), 'screen': const WordBuilderGame()},
      {'name': 'Memory Match', 'tamil': 'நினைவக போட்டி', 'icon': '🧠', 'description': 'Match Tamil letters', 'color': AppTheme.success, 'screen': const MemoryGameScreen()},
      {'name': 'Quiz', 'tamil': 'வினாடி வினா', 'icon': '❓', 'description': 'Answer questions', 'color': const Color(0xFFAB47BC), 'screen': const QuizScreen()},
      {'name': 'Fill Blanks', 'tamil': 'இடம் நிரப்பு', 'icon': '📝', 'description': 'Complete the word', 'color': const Color(0xFFEF5350), 'screen': const FillBlanksGame()},
      {'name': 'Sentence Builder', 'tamil': 'வாக்கிய அமைப்பு', 'icon': '📚', 'description': 'Form sentences', 'color': const Color(0xFF26A69A), 'screen': const SentenceBuilderGame()},
      {'name': 'Pronunciation', 'tamil': 'உச்சரிப்பு பயிற்சி', 'icon': '🎤', 'description': 'Practice speaking', 'color': const Color(0xFFFF8A65), 'screen': const PronunciationPracticeGame()},
      {'name': 'Writing', 'tamil': 'எழுத்துப் பயிற்சி', 'icon': '✏️', 'description': 'Trace letters', 'color': const Color(0xFF5C6BC0), 'screen': const WritingPracticeGame()},
      {'name': 'Quiz Battle', 'tamil': 'வினா போர்', 'icon': '⚔️', 'description': 'Speed quiz', 'color': const Color(0xFFEC407A), 'screen': const QuizBattleGame()},
      {'name': 'Scramble', 'tamil': 'சொல் கலைத்தல்', 'icon': '🧩', 'description': 'Unscramble words', 'color': const Color(0xFF7E57C2), 'screen': const WordScrambleGame()},
      {'name': 'Sound Match', 'tamil': 'ஒலி பொருத்தம்', 'icon': '🔊', 'description': 'Listen and match', 'color': const Color(0xFF29B6F6), 'screen': const SoundMatchGame()},
      {'name': 'Word Search', 'tamil': 'சொல் தேடல்', 'icon': '🔍', 'description': 'Find hidden words', 'color': const Color(0xFF9CCC65), 'screen': const WordSearchGame()},
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: AppTheme.backgroundLight,
            elevation: 0,
            leading: Navigator.canPop(context)
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
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
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.secondary, AppTheme.secondary.withOpacity(0.85)],
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
                          decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(8)),
                          child: Text('${games.length} GAMES', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.white, letterSpacing: 1)),
                        ),
                        const SizedBox(height: 12),
                        Text('விளையாட்டு அரங்கம்', style: GoogleFonts.notoSansTamil(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.white)),
                        Text('Games Arena', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.white.withOpacity(0.6))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ALL GAMES', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.primary, letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.95,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final game = games[index];
                  return _buildGameCard(context, game);
                },
                childCount: games.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, Map<String, dynamic> game) {
    final color = game['color'] as Color;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => game['screen'] as Widget)),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.15), width: 1.5),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Text(game['icon'] as String, style: const TextStyle(fontSize: 36)),
            ),
            const SizedBox(height: 12),
            Text(
              game['name'] as String,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.secondary),
            ),
            const SizedBox(height: 2),
            Text(
              game['tamil'] as String,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansTamil(fontSize: 11, color: color, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                game['description'] as String,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.textGray, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
