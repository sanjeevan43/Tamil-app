import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tamil_app/constants/app_theme.dart';
import 'package:tamil_app/services/claude_api_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
// FEATURE 3: Colloquial Dialectics Analyzer — Code Switch Teacher
// ═══════════════════════════════════════════════════════════════════════════

class DialecticsAnalyzerScreen extends StatefulWidget {
  final int childAge;

  const DialecticsAnalyzerScreen({super.key, required this.childAge});

  @override
  State<DialecticsAnalyzerScreen> createState() => _DialecticsAnalyzerScreenState();
}

class _DialecticsAnalyzerScreenState extends State<DialecticsAnalyzerScreen> {
  final TextEditingController _sentenceController = TextEditingController();
  final List<String> topics = ['school', 'food', 'family', 'playing', 'home'];
  final List<String> modes = ['formal_to_spoken', 'spoken_to_formal', 'generate_new'];

  String selectedTopic = 'school';
  String selectedMode = 'formal_to_spoken';
  Map<String, dynamic>? conversionData;
  bool isLoading = false;
  final Map<int, String> _selectedAnswers = {};

  Future<void> _convertTamil() async {
    if (_sentenceController.text.isEmpty && selectedMode != 'generate_new') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a sentence')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await ClaudeApiService.convertTamil(
        sentence: _sentenceController.text,
        mode: selectedMode,
        topic: selectedTopic,
        childAge: widget.childAge,
      );
      if (!mounted) return;
      setState(() {
        conversionData = result;
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
          'Colloquial Dialectics Analyzer',
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
            Text(
              'Select Analysis Mode:',
              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.secondary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: modes.map((mode) {
                final isSelected = selectedMode == mode;
                final readableMode = mode == 'formal_to_spoken'
                    ? 'Formal to Spoken'
                    : mode == 'spoken_to_formal'
                        ? 'Spoken to Formal'
                        : 'Generate Dialectics';
                return ChoiceChip(
                  label: Text(
                    readableMode,
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
                  onSelected: (sel) {
                    setState(() => selectedMode = mode);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Conversation Topic:',
              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.secondary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: topics.map((topic) {
                final isSelected = selectedTopic == topic;
                final capitalizedTopic = topic[0].toUpperCase() + topic.substring(1);
                return ChoiceChip(
                  label: Text(
                    capitalizedTopic,
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
                  onSelected: (sel) {
                    setState(() => selectedTopic = topic);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (selectedMode != 'generate_new') ...[
              Text(
                'Enter Sentence to Convert:',
                style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.secondary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _sentenceController,
                maxLines: 3,
                style: GoogleFonts.notoSansTamil(
                  fontSize: 16,
                  color: AppTheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'நான் பள்ளிக்கூடம் போகிறேன். (e.g., I am going to school.)',
                  hintStyle: GoogleFonts.notoSansTamil(
                    color: AppTheme.textGray.withOpacity(0.6),
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppTheme.topoSilver, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppTheme.topoSilver, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: AppTheme.topoLight,
                  contentPadding: const EdgeInsets.all(18),
                ),
              ),
              const SizedBox(height: 20),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _convertTamil,
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
                        'Analyze & Convert Dialectics',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 28),
            if (conversionData != null) _buildConversion(),
          ],
        ),
      ),
    );
  }

  Widget _buildConversion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: AppTheme.whiteCard(radius: 20),
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Written Tamil (எழுத்து தமிழ்)',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.info,
                    ),
                  ),
                  const Icon(Icons.menu_book_rounded, color: AppTheme.info, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                conversionData!['written_tamil'] ?? '',
                style: GoogleFonts.notoSansTamil(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                conversionData!['written_transliteration'] ?? '',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppTheme.textGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          decoration: AppTheme.whiteCard(radius: 20),
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Spoken Tamil (பேச்சு தமிழ்)',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.success,
                    ),
                  ),
                  const Icon(Icons.record_voice_over_rounded, color: AppTheme.success, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                conversionData!['spoken_tamil'] ?? '',
                style: GoogleFonts.notoSansTamil(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                conversionData!['spoken_transliteration'] ?? '',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppTheme.textGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          decoration: AppTheme.whiteCard(radius: 20),
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'English Translation',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.secondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                conversionData!['english'] ?? '',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: AppTheme.textSlate,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.warning.withOpacity(0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.warning.withOpacity(0.25), width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📝', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DIALECTIC DIFFERENCE EXPLAINED',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.warning,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      conversionData!['difference_explained'] ?? '',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: AppTheme.secondary,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (conversionData!['key_changes'] != null) ...[
          const SizedBox(height: 28),
          _buildKeyChanges(),
        ],
        if (conversionData!['quiz'] != null) ...[
          const SizedBox(height: 28),
          _buildQuiz(),
        ],
      ],
    );
  }

  Widget _buildKeyChanges() {
    final changes = conversionData!['key_changes'] as List? ?? [];
    if (changes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.swap_horiz_rounded, color: AppTheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Key Dialectic Alterations',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...changes.map((change) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.whiteCard(radius: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        change['formal'] ?? '',
                        style: GoogleFonts.notoSansTamil(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.secondary,
                        ),
                      ),
                      Text(
                        'Formal / Written',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: AppTheme.textGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppTheme.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        change['spoken'] ?? '',
                        style: GoogleFonts.notoSansTamil(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.secondary,
                        ),
                      ),
                      Text(
                        'Colloquial / Spoken',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: AppTheme.textGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuiz() {
    final quiz = conversionData!['quiz'] as List? ?? [];
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
}
