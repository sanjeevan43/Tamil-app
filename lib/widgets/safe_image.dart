import 'package:flutter/material.dart';


class SafeImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BorderRadius? borderRadius;

  const SafeImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
  });

  Widget _buildFallback(String path) {
    final lowerPath = path.toLowerCase();
    String emoji = '🌟';
    String category = 'Tamil Academy';

    if (lowerPath.contains('lion') || lowerPath.contains('singam')) {
      emoji = '🦁';
      category = 'The Lion & Mouse';
    } else if (lowerPath.contains('mouse') || lowerPath.contains('eli')) {
      emoji = '🐭';
      category = 'The Lion & Mouse';
    } else if (lowerPath.contains('hare') || lowerPath.contains('muyal')) {
      emoji = '🐰';
      category = 'The Tortoise & Hare';
    } else if (lowerPath.contains('tortoise') || lowerPath.contains('aamai')) {
      emoji = '🐢';
      category = 'The Tortoise & Hare';
    } else if (lowerPath.contains('crow') || lowerPath.contains('kaagam')) {
      emoji = '🐦';
      category = 'The Thirsty Crow';
    } else if (lowerPath.contains('sparrow') || lowerPath.contains('kuruvi')) {
      emoji = '🐦';
      category = 'The Clever Sparrow';
    } else if (lowerPath.contains('doves')) {
      emoji = '🕊️';
      category = 'Unity is Strength';
    } else if (lowerPath.contains('woodcutter')) {
      emoji = '🪓';
      category = 'Honest Woodcutter';
    } else if (lowerPath.contains('goddess')) {
      emoji = '🧚‍♀️';
      category = 'River Goddess';
    } else if (lowerPath.contains('sheep')) {
      emoji = '🐑';
      category = 'The Shepherd Boy';
    } else if (lowerPath.contains('wolf') || lowerPath.contains('fox') || lowerPath.contains('nari')) {
      emoji = '🦊';
      category = 'The Fox & Grapes';
    } else if (lowerPath.contains('grapes')) {
      emoji = '🍇';
      category = 'The Fox & Grapes';
    } else if (lowerPath.contains('monkey')) {
      emoji = '🐵';
      category = 'Monkey & Crocodile';
    } else if (lowerPath.contains('crocodile') || lowerPath.contains('croc')) {
      emoji = '🐊';
      category = 'Monkey & Crocodile';
    } else if (lowerPath.contains('ant')) {
      emoji = '🐜';
      category = 'The Ant & Grasshopper';
    } else if (lowerPath.contains('grasshopper')) {
      emoji = '🦗';
      category = 'The Ant & Grasshopper';
    } else if (lowerPath.contains('goose') || lowerPath.contains('egg')) {
      emoji = '🥚';
      category = 'The Golden Egg Goose';
    } else if (lowerPath.contains('magic_tree') || lowerPath.contains('tree')) {
      emoji = '🌳';
      category = 'The Magic Tree';
    } else if (lowerPath.contains('rhyme') || lowerPath.contains('music')) {
      emoji = '🎶';
      category = 'Tamil Rhyme Melodies';
    } else if (lowerPath.contains('story') || lowerPath.contains('placeholder')) {
      emoji = '📖';
      category = 'Bilingual Moral Story';
    }

    final List<Color> gradientColors;
    if (emoji == '🦁' || emoji == '🐰' || emoji == '🪓') {
      gradientColors = [const Color(0xFFFF7043), const Color(0xFFFF5252)];
    } else if (emoji == '🐢' || emoji == '🌳' || emoji == '🐜') {
      gradientColors = [const Color(0xFF66BB6A), const Color(0xFF2E7D32)];
    } else if (emoji == '🐦' || emoji == '🧚‍♀️' || emoji == '🕊️') {
      gradientColors = [const Color(0xFF29B6F6), const Color(0xFF0288D1)];
    } else if (emoji == '🦊' || emoji == '🍇' || emoji == '🎶') {
      gradientColors = [const Color(0xFFAB47BC), const Color(0xFF7B1FA2)];
    } else {
      gradientColors = [const Color(0xFF0F1E36), const Color(0xFF1E3A8A)];
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 10,
            right: 15,
            child: Icon(Icons.star_rounded, color: Colors.white.withOpacity(0.12), size: 14),
          ),
          Positioned(
            bottom: 15,
            left: 10,
            child: Icon(Icons.star_rounded, color: Colors.white.withOpacity(0.12), size: 18),
          ),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 42),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pre-verified list of physically existing assets in the assets/images directory
    const existingAssets = {
      'assets/images/29099e40-2686-49d2-af50-5d939b785f80.png',
    };

    final cleanPath = assetPath.trim();

    // If it's an image asset and not physically present, immediately use the fallback
    // This avoids throwing noisy "Unable to load asset" assertion exceptions in the console/log
    if (cleanPath.startsWith('assets/') && !existingAssets.contains(cleanPath)) {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: _buildFallback(cleanPath),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.asset(
        cleanPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallback(cleanPath);
        },
      ),
    );
  }
}
