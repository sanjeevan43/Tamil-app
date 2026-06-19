import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  bool _isAutoReading = false;
  bool _ignoreCompletion = false;
  Timer? _autoReadTimer;

  @override
  void initState() {
    super.initState();
    AudioService.setCompletionHandler(() {
      if (!mounted) return;
      if (_ignoreCompletion) return;

      if (_isAutoReading) {
        _advancePage();
      }
    });
  }

  @override
  void dispose() {
    _autoReadTimer?.cancel();
    AudioService.setCompletionHandler(() {});
    AudioService.stop();
    _pageController.dispose();
    super.dispose();
  }

  void _advancePage() {
    _autoReadTimer?.cancel();
    if (_currentSceneIndex < _scenes.length - 1) {
      setState(() {
        _ignoreCompletion = true;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      setState(() {
        _isAutoReading = false;
      });
      AudioService.stop();
      _showQuizPrompt();
    }
  }

  void _startAutoReadTimer(String text) {
    _autoReadTimer?.cancel();
    // Estimate reading time: 1 character takes ~0.15 seconds at 0.4 speech rate.
    // Clamped between 5 and 25 seconds.
    final durationSeconds = (text.length * 0.15).clamp(5.0, 25.0).toInt();
    
    _autoReadTimer = Timer(Duration(seconds: durationSeconds), () {
      if (!mounted) return;
      if (_isAutoReading) {
        _advancePage();
      }
    });
  }

  void _playCurrentSceneAudio() async {
    _autoReadTimer?.cancel();
    final text = _scenes[_currentSceneIndex]['content'] as String;
    
    setState(() {
      _ignoreCompletion = true;
    });
    
    await AudioService.playWord(text);
    
    _startAutoReadTimer(text);
    
    // Allow any stop completion events to fire and clear
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) {
      setState(() {
        _ignoreCompletion = false;
      });
    }
  }

  void _toggleAutoRead() {
    if (_isAutoReading) {
      _autoReadTimer?.cancel();
      setState(() {
        _ignoreCompletion = true;
        _isAutoReading = false;
      });
      AudioService.stop();
    } else {
      setState(() {
        _ignoreCompletion = false;
        _isAutoReading = true;
      });
      _playCurrentSceneAudio();
    }
  }

  void _nextScene() {
    _autoReadTimer?.cancel();
    if (_currentSceneIndex < _scenes.length - 1) {
      setState(() {
        _ignoreCompletion = true;
        _isAutoReading = false;
      });
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
    _autoReadTimer?.cancel();
    if (_currentSceneIndex > 0) {
      setState(() {
        _ignoreCompletion = true;
        _isAutoReading = false;
      });
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
                // Check if user drag caused this page change
                bool isUserGesture = false;
                if (_pageController.hasClients) {
                  isUserGesture = _pageController.position.userScrollDirection != ScrollDirection.idle;
                }

                setState(() {
                  _currentSceneIndex = index;
                  if (isUserGesture) {
                    _autoReadTimer?.cancel();
                    _ignoreCompletion = true;
                    _isAutoReading = false;
                  }
                });

                if (_isAutoReading) {
                  _playCurrentSceneAudio();
                } else {
                  AudioService.stop();
                }
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
              color: AppTheme.white,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.textDark.withOpacity(0.05),
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
                      onPressed: _toggleAutoRead,
                      icon: Icon(_isAutoReading ? Icons.stop : Icons.volume_up),
                      label: Text(_isAutoReading ? 'Stop Reading' : 'Read for Me'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isAutoReading ? AppTheme.error : AppTheme.secondary,
                        foregroundColor: Colors.white,
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
                      color: AppTheme.topoSilver,
                      child: const Center(
                        child: Icon(Icons.image, size: 80, color: AppTheme.textGray),
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
                        style: GoogleFonts.outfit(
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
