import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../constants/colors.dart';
import '../constants/tamil_data.dart';
import 'story_quiz_screen.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  final FlutterTts flutterTts = FlutterTts();
  int _storyIndex = 0;
  int _sceneIndex = 0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    await flutterTts.setLanguage("ta-IN");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text) async {
    setState(() => _isPlaying = true);
    await flutterTts.speak(text);
    flutterTts.setCompletionHandler(() {
      setState(() => _isPlaying = false);
    });
  }

  Future<void> _stop() async {
    await flutterTts.stop();
    setState(() => _isPlaying = false);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  void _nextScene() {
    _stop();
    final scenes = TamilData.tamilStories[_storyIndex]['scenes'] as List;
    if (_sceneIndex < scenes.length - 1) {
      setState(() => _sceneIndex++);
    } else if (_storyIndex < TamilData.tamilStories.length - 1) {
      // Show "The End / Moral" dialog or just move to next story
      _showMoralDialog();
    }
  }

  void _prevScene() {
    _stop();
    if (_sceneIndex > 0) {
      setState(() => _sceneIndex--);
    }
  }

  void _showMoralDialog() {
    final story = TamilData.tamilStories[_storyIndex];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('நீதி (Moral)', style: GoogleFonts.notoSansTamil(fontWeight: FontWeight.bold, color: AppColors.primaryRed)),
        content: Text(story['moral'], style: GoogleFonts.notoSansTamil(fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StoryQuizScreen(
                    questions: List<Map<String, dynamic>>.from(story['questions']),
                    storyTitle: story['title'],
                  ),
                ),
              ).then((_) {
                // After quiz, move to next story or reset
                if (_storyIndex < TamilData.tamilStories.length - 1) {
                  setState(() {
                    _storyIndex++;
                    _sceneIndex = 0;
                  });
                } else {
                  setState(() {
                    _storyIndex = 0;
                    _sceneIndex = 0;
                  });
                }
              });
            },
            child: const Text('Take Quiz'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (_storyIndex < TamilData.tamilStories.length - 1) {
                setState(() {
                  _storyIndex++;
                  _sceneIndex = 0;
                });
              } else {
                setState(() {
                  _storyIndex = 0;
                  _sceneIndex = 0;
                });
              }
            },
            child: const Text('Skip Quiz'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final story = TamilData.tamilStories[_storyIndex];
    final scenes = story['scenes'] as List;
    final currentScene = scenes[_sceneIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(story['title']),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                '${_sceneIndex + 1} / ${scenes.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Image Section
                  Container(
                    width: double.infinity,
                    height: 300,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryRed.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/${currentScene['image']}.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.primaryRed.withOpacity(0.05),
                        child: const Icon(Icons.image, size: 100, color: AppColors.primaryRed),
                      ),
                    ),
                  ),
                  
                  // Text Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primaryRed.withOpacity(0.1)),
                      ),
                      child: Text(
                        currentScene['content'],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSansTamil(
                          fontSize: 24,
                          height: 1.8,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Controls Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: 'prev',
                  onPressed: _sceneIndex > 0 ? _prevScene : null,
                  backgroundColor: _sceneIndex > 0 ? AppColors.primaryRed : Colors.grey[300],
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                FloatingActionButton.large(
                  heroTag: 'play',
                  onPressed: () => _isPlaying ? _stop() : _speak(currentScene['content']),
                  backgroundColor: AppColors.primaryRed,
                  child: Icon(_isPlaying ? Icons.stop : Icons.play_arrow, size: 48, color: Colors.white),
                ),
                FloatingActionButton(
                  heroTag: 'next',
                  onPressed: _nextScene,
                  backgroundColor: AppColors.primaryRed,
                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
