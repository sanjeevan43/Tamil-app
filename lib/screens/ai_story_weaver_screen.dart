import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tamil_app/constants/app_theme.dart';
import 'package:tamil_app/services/claude_api_service.dart';

class AIStoryWeaverScreen extends StatefulWidget {
  final int childAge;
  final String? childName;

  const AIStoryWeaverScreen({
    super.key,
    required this.childAge,
    this.childName,
  });

  @override
  State<AIStoryWeaverScreen> createState() => _AIStoryWeaverScreenState();
}

class _AIStoryWeaverScreenState extends State<AIStoryWeaverScreen> {
  final List<String> heroes = ['குரங்கு', 'சிறுமி', 'ரோபோ', 'பூனை', 'பாம்பு'];
  final List<String> places = ['விண்வெளி', 'கடலுக்கடியில்', 'காட்டில்', 'மலையில்', 'நகரத்தில்'];
  final List<String> problems = ['தொலைந்துவிட்டது', 'பொக்கிஷம் தேடுகிறது', 'நண்பனை தேடுகிறது', 'வீடு திரும்ப வேண்டும்'];

  String selectedHero = 'குரங்கு';
  String selectedPlace = 'விண்வெளி';
  String selectedProblem = 'தொலைந்துவிட்டது';

  Map<String, dynamic>? storyData;
  bool isLoading = false;
  int currentSceneIndex = 0;
  final Map<int, String> _selectedAnswers = {};

  Future<void> _generateStory() async {
    setState(() => isLoading = true);

    try {
      final result = await ClaudeApiService.generateStory(
        hero: selectedHero,
        place: selectedPlace,
        problem: selectedProblem,
        childName: widget.childName ?? 'Friend',
        childAge: widget.childAge,
      );
      if (!mounted) return;
      setState(() {
        storyData = result;
        currentSceneIndex = 0;
        _selectedAnswers.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'AI Moral Story Weaver',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            color: AppTheme.secondary,
          ),
        ),
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.secondary),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (storyData == null) ...[
              _buildSelector('Hero', heroes, selectedHero, (value) {
                setState(() => selectedHero = value);
              }),
              const SizedBox(height: 20),
              _buildSelector('Place', places, selectedPlace, (value) {
                setState(() => selectedPlace = value);
              }),
              const SizedBox(height: 20),
              _buildSelector('Problem', problems, selectedProblem, (value) {
                setState(() => selectedProblem = value);
              }),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _generateStory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondary,
                    foregroundColor: AppTheme.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: AppTheme.white, strokeWidth: 2.5),
                        )
                      : Text(
                          'Weave AI Moral Story',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ] else
              _buildStoryView(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelector(String label, List<String> items, String selected, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Story $label:',
          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.secondary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            final isSelected = selected == item;
            return ChoiceChip(
              label: Text(
                item,
                style: GoogleFonts.outfit(
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected ? AppTheme.white : AppTheme.secondary,
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              selectedColor: AppTheme.primary,
              backgroundColor: AppTheme.topoLight,
              checkmarkColor: AppTheme.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected ? AppTheme.primary : AppTheme.topoSilver.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              onSelected: (sel) => onChanged(item),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStoryView() {
    final scenes = storyData!['scenes'] as List? ?? [];
    if (scenes.isEmpty) return const SizedBox.shrink();

    final currentScene = scenes[currentSceneIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storyData!['story_title_tamil'] ?? '',
                    style: GoogleFonts.notoSansTamil(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.secondary),
                  ),
                  Text(
                    storyData!['story_title_english'] ?? '',
                    style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textGray, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppTheme.primary, size: 24),
              onPressed: () => setState(() => storyData = null),
              tooltip: 'Start Over',
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          decoration: AppTheme.whiteCard(radius: 24),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: AppTheme.pillBadge(bgColor: AppTheme.info.withOpacity(0.08)),
                    child: Text(
                      'SCENE ${currentScene['scene_number']}',
                      style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.info, letterSpacing: 1),
                    ),
                  ),
                  const Icon(Icons.movie_creation_rounded, color: AppTheme.info, size: 20),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                currentScene['text_tamil'] ?? '',
                style: GoogleFonts.notoSansTamil(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                currentScene['text_english'] ?? '',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppTheme.textGray,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: currentSceneIndex > 0
                  ? () => setState(() => currentSceneIndex--)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text('← Previous', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.topoLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.topoSilver),
              ),
              child: Text(
                'Scene ${currentSceneIndex + 1} of ${scenes.length}',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.secondary),
              ),
            ),
            ElevatedButton(
              onPressed: currentSceneIndex < scenes.length - 1
                  ? () => setState(() => currentSceneIndex++)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text('Next →', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        if (currentSceneIndex == scenes.length - 1) ...[
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.gold.withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.gold.withOpacity(0.35), width: 1.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📖', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STORY MORAL (நீதி)',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.warning,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        storyData!['moral_tamil'] ?? '',
                        style: GoogleFonts.notoSansTamil(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        storyData!['moral_english'] ?? '',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppTheme.textGray,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _buildQuiz(),
          const SizedBox(height: 28),
          _buildNewWords(),
        ],
      ],
    );
  }

  Widget _buildQuiz() {
    final quiz = storyData!['quiz'] as List? ?? [];
    if (quiz.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.help_outline_rounded, color: AppTheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Reading Comprehension Quiz',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(quiz.length, (index) {
          final q = quiz[index] as Map? ?? {};
          final questionText = q['question'] ?? '';
          final options = q['options'] as List? ?? [];
          final correctOption = q['correct'] ?? '';
          final selectedOption = _selectedAnswers[index];
          final hasAnswered = selectedOption != null;

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.topoLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.topoSilver.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  questionText,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.secondary,
                  ),
                ),
                const SizedBox(height: 12),
                ...options.map((option) {
                  final isSelected = selectedOption == option;
                  final isCorrect = option == correctOption;

                  Color itemBgColor = AppTheme.white;
                  Color borderColor = AppTheme.borderLight;
                  IconData iconData = Icons.radio_button_off_rounded;
                  Color contentColor = AppTheme.secondary;
                  FontWeight fontWeight = FontWeight.w500;

                  if (hasAnswered) {
                    if (isCorrect) {
                      itemBgColor = AppTheme.success.withOpacity(0.06);
                      borderColor = AppTheme.success.withOpacity(0.3);
                      iconData = Icons.check_circle_rounded;
                      contentColor = AppTheme.success;
                      fontWeight = FontWeight.w800;
                    } else if (isSelected) {
                      itemBgColor = AppTheme.error.withOpacity(0.06);
                      borderColor = AppTheme.error.withOpacity(0.3);
                      iconData = Icons.cancel_rounded;
                      contentColor = AppTheme.error;
                      fontWeight = FontWeight.w800;
                    }
                  }

                  return GestureDetector(
                    onTap: () {
                      if (!hasAnswered) {
                        setState(() {
                          _selectedAnswers[index] = option;
                        });
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: itemBgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: borderColor,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            iconData,
                            color: contentColor == AppTheme.secondary ? AppTheme.textGray : contentColor,
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: fontWeight,
                                color: contentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildNewWords() {
    final words = storyData!['new_words_learned'] as List? ?? [];
    if (words.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.style_rounded, color: AppTheme.info, size: 20),
            const SizedBox(width: 8),
            Text(
              'Linguistic Vocabulary Acquired',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...words.map((w) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.info.withOpacity(0.12), width: 1.5),
              boxShadow: [
                BoxShadow(color: AppTheme.info.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.info.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('🔤', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        w['tamil'] ?? '',
                        style: GoogleFonts.notoSansTamil(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.secondary,
                        ),
                      ),
                      Text(
                        w['transliteration'] ?? '',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppTheme.textGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: AppTheme.pillBadge(bgColor: AppTheme.info.withOpacity(0.08)),
                  child: Text(
                    w['english'] ?? '',
                    style: GoogleFonts.outfit(
                      color: AppTheme.info,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
