import 'package:flutter/material.dart';
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
      {'name': 'Letter Hunt', 'icon': '🎯', 'description': 'Find the correct letter', 'screen': const LetterHuntGame()},
      {'name': 'Word Builder', 'icon': '🔨', 'description': 'Build Tamil words', 'screen': const WordBuilderGame()},
      {'name': 'Memory Match', 'icon': '🧠', 'description': 'Match Tamil letters', 'screen': const MemoryGameScreen()},
      {'name': 'Quiz', 'icon': '❓', 'description': 'Answer questions', 'screen': const QuizScreen()},
      {'name': 'Fill Blanks', 'icon': '📝', 'description': 'Complete the word', 'screen': const FillBlanksGame()},
      {'name': 'Sentence Builder', 'icon': '📚', 'description': 'Form sentences', 'screen': const SentenceBuilderGame()},
      {'name': 'Pronunciation', 'icon': '🎤', 'description': 'Practice speaking', 'screen': const PronunciationPracticeGame()},
      {'name': 'Writing', 'icon': '✏️', 'description': 'Trace letters', 'screen': const WritingPracticeGame()},
      {'name': 'Quiz Battle', 'icon': '⚔️', 'description': 'Speed quiz', 'screen': const QuizBattleGame()},
      {'name': 'Scramble', 'icon': '🧩', 'description': 'Unscramble words', 'screen': const WordScrambleGame()},
      {'name': 'Sound Match', 'icon': '🔊', 'description': 'Listen and match', 'screen': const SoundMatchGame()},
      {'name': 'Word Search', 'icon': '🔍', 'description': 'Find hidden words', 'screen': const WordSearchGame()},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Tamil Games')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return _buildGameCard(
            context,
            game['name'] as String,
            game['icon'] as String,
            game['description'] as String,
            game['screen'] as Widget,
          );
        },
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context,
    String name,
    String icon,
    String description,
    Widget screen,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Container(
        decoration: AppTheme.gameCard(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 12),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryRed),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppTheme.textGray),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
