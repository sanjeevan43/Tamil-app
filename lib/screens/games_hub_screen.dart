import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../constants/tamil_data.dart';
import 'letter_hunt_game.dart';
import 'word_builder_game.dart';
import 'memory_game_screen.dart';
import 'quiz_screen.dart';
import 'fill_blanks_game.dart';

class GamesHubScreen extends StatelessWidget {
  const GamesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tamil Games'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: TamilData.games.length,
        itemBuilder: (context, index) {
          final game = TamilData.games[index];
          return _buildGameCard(
            context,
            game['name'] as String,
            game['icon'] as String,
            game['description'] as String,
            index,
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
    int gameId,
  ) {
    return GestureDetector(
      onTap: () => _navigateToGame(context, gameId),
      child: Container(
        decoration: AppTheme.gameCard(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryRed,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textGray,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToGame(BuildContext context, int gameId) {
    Widget screen;
    switch (gameId) {
      case 0:
        screen = const LetterHuntGame();
        break;
      case 1:
        screen = const WordBuilderGame();
        break;
      case 2:
        screen = const MemoryGameScreen();
        break;
      case 3:
        screen = const QuizScreen();
        break;
      case 4:
        screen = const FillBlanksGame();
        break;
      default:
        screen = const LetterHuntGame();
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
