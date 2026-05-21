import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tamil_app/constants/app_theme.dart';
import 'package:tamil_app/services/claude_api_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
// FEATURE 2: Linguistic Text Scanner — Tamil Text Explainer
// ═══════════════════════════════════════════════════════════════════════════

class LinguisticScannerScreen extends StatefulWidget {
  final int childAge;

  const LinguisticScannerScreen({super.key, required this.childAge});

  @override
  State<LinguisticScannerScreen> createState() => _LinguisticScannerScreenState();
}

class _LinguisticScannerScreenState extends State<LinguisticScannerScreen> {
  final TextEditingController _textController = TextEditingController();
  Map<String, dynamic>? explanationData;
  bool isLoading = false;
  final Map<int, String> _selectedAnswers = {};

  Future<void> _explainText() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Tamil text')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await ClaudeApiService.explainScannedText(
        scannedText: _textController.text,
        childAge: widget.childAge,
      );
      if (!mounted) return;
      setState(() {
        explanationData = result;
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
          'Linguistic Text Scanner',
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
              'Enter or paste Tamil text:',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.secondary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textController,
              maxLines: 4,
              style: GoogleFonts.notoSansTamil(
                fontSize: 16,
                color: AppTheme.secondary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'வணக்கம் தமிழ்நாடு (e.g., Hello Tamil Nadu)',
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _explainText,
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
                        'Analyze Linguistic Text',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 28),
            if (explanationData != null) _buildExplanation(),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanation() {
    final words = explanationData!['words'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
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
                      'SCANNED INPUT',
                      style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.info, letterSpacing: 1),
                    ),
                  ),
                  const Icon(Icons.analytics_rounded, color: AppTheme.info, size: 20),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                explanationData!['full_text'] ?? '',
                style: GoogleFonts.notoSansTamil(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                explanationData!['full_meaning'] ?? '',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: AppTheme.textGray,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        if (words.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 28, bottom: 16),
            child: Row(
              children: [
                const Icon(Icons.translate_rounded, color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Linguistic Vocabulary Breakdown',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          ...words.map((word) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: double.infinity,
              decoration: AppTheme.whiteCard(radius: 20),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          word['word'] ?? '',
                          style: GoogleFonts.notoSansTamil(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: AppTheme.pillBadge(bgColor: AppTheme.info.withOpacity(0.08)),
                        child: Text(
                          'VOCABULARY',
                          style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.info, letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Transliteration: ${word['word'] != null ? word['transliteration'] ?? '' : ''}', // Safe check
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppTheme.textGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Meaning: ${word['meaning'] ?? ''}',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppTheme.secondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Example: ${word['example'] ?? ''}',
                    style: GoogleFonts.notoSansTamil(
                      fontSize: 13,
                      color: AppTheme.textSlate,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.warning.withOpacity(0.25), width: 1.5),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            word['fun_fact'] ?? '',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppTheme.secondary,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
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
        if (explanationData!['quiz'] != null) ...[
          const SizedBox(height: 16),
          _buildQuiz(),
        ],
      ],
    );
  }

  Widget _buildQuiz() {
    final quiz = explanationData!['quiz'] as List? ?? [];
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
