import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_theme.dart';
import '../services/audio_service.dart';
import '../widgets/safe_image.dart';
import 'story_quiz_screen.dart';

class StoryDetailScreen extends StatefulWidget {
  final Map<String, dynamic> story;

  const StoryDetailScreen({super.key, required this.story});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  final PageController _pageController = PageController();
  int _currentSceneIndex = 0;
  List<Map<String, dynamic>> get _scenes => 
      (widget.story['scenes'] as List).map((e) => e as Map<String, dynamic>).toList();

  @override
  void initState() {
    super.initState();
    // Auto-play first scene audio if desired
    // _playCurrentSceneAudio();
  }

  void _playCurrentSceneAudio() {
    final text = _scenes[_currentSceneIndex]['content'] as String;
    AudioService.playWord(text); // Using playWord for TTS
  }

  void _nextScene() {
    if (_currentSceneIndex < _scenes.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      // End of story, suggest quiz
      _showQuizPrompt();
    }
  }

  void _previousScene() {
    if (_currentSceneIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showQuizPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Story Finished!'),
        content: const Text('Great job! Would you like to take a quiz to earn stars?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, thanks'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => StoryQuizScreen(
                    questions: widget.story['questions'] ?? [],
                    storyTitle: widget.story['title'],
                  ),
                ),
              );
            },
            child: const Text('Take Quiz'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          widget.story['title'],
          style: GoogleFonts.notoSansTamil(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryRed,
        actions: [
          IconButton(
            icon: const Icon(Icons.quiz),
            onPressed: _showQuizPrompt,
            tooltip: 'Take Quiz',
          ),
        ],
      ),
      body: Column(
        children: [
          // Scene PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _scenes.length,
              onPageChanged: (index) {
                setState(() => _currentSceneIndex = index);
                // Optional: Auto-play audio on slide change
                // _playCurrentSceneAudio(); 
              },
              itemBuilder: (context, index) {
                final scene = _scenes[index];
                return _buildSceneCard(scene);
              },
            ),
          ),
          
          // Controls
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _currentSceneIndex > 0 ? _previousScene : null,
                  icon: const Icon(Icons.arrow_back),
                  color: AppTheme.primaryRed,
                  iconSize: 32,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ElevatedButton.icon(
                      onPressed: _playCurrentSceneAudio,
                      icon: const Icon(Icons.volume_up),
                      label: const Text('Read for Me'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _nextScene, // Always enabled to allow finishing
                  icon: Icon(_currentSceneIndex < _scenes.length - 1 ? Icons.arrow_forward : Icons.check_circle),
                  color: _currentSceneIndex < _scenes.length - 1 ? AppTheme.primaryRed : AppTheme.success,
                  iconSize: 32,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSceneCard(Map<String, dynamic> scene) {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: AppTheme.whiteCard(radius: 24),
      child: Column(
        children: [
          // Image Area
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: scene['image'] != null
                  ? SafeImage(
                      assetPath: 'assets/images/${scene['image']}.png',
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(Icons.image, size: 80, color: Colors.grey[400]),
                      ),
                    ),
            ),
          ),
          
          // Text Area
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        scene['content'],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSansTamil(
                          fontSize: 22,
                          height: 1.6,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        scene['englishContent'] ?? '',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSlate,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
