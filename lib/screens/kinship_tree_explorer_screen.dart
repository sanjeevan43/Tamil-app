import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tamil_app/constants/app_theme.dart';
import 'package:tamil_app/services/claude_api_service.dart';

class KinshipTreeExplorerScreen extends StatefulWidget {
  final int childAge;

  const KinshipTreeExplorerScreen({super.key, required this.childAge});

  @override
  State<KinshipTreeExplorerScreen> createState() => _KinshipTreeExplorerScreenState();
}

class _KinshipTreeExplorerScreenState extends State<KinshipTreeExplorerScreen> {
  final List<String> relations = [
    'Mother\'s younger sister',
    'Father\'s older brother',
    'Grandfather',
    'Older brother',
    'Younger sister',
  ];

  Map<String, dynamic>? kinshipData;
  bool isLoading = false;
  String? selectedRelation;
  final Map<int, String> _selectedAnswers = {};

  Future<void> _loadKinshipWord(String relation) async {
    setState(() {
      isLoading = true;
      selectedRelation = relation;
    });

    try {
      final result = await ClaudeApiService.getKinshipWord(
        relation: relation,
        childAge: widget.childAge,
      );
      if (!mounted) return;
      setState(() {
        kinshipData = result;
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
          'Kinship Tree Explorer',
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
              'Select a family relation:',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.secondary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: relations.map((relation) {
                final isSelected = selectedRelation == relation;
                return ChoiceChip(
                  label: Text(
                    relation,
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
                  onSelected: (_) => _loadKinshipWord(relation),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
              )
            else if (kinshipData != null)
              _buildKinshipCard()
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60.0),
                  child: Column(
                    children: [
                      const Text('🌳', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text(
                        'Select a relation to start exploring relations',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildKinshipCard() {
    return Container(
      decoration: AppTheme.whiteCard(radius: 24),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  kinshipData!['tamil_word'] ?? '',
                  style: GoogleFonts.notoSansTamil(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: AppTheme.pillBadge(bgColor: AppTheme.success.withOpacity(0.08)),
                child: Text(
                  'Kinship Word',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Transliteration: ${kinshipData!['transliteration'] ?? ''}',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textGray,
            ),
          ),
          const SizedBox(height: 20),
          _buildDefinitionRow('English Relation', kinshipData!['meaning_english'] ?? '', AppTheme.info),
          const SizedBox(height: 12),
          _buildDefinitionRow('Tamil Relation', kinshipData!['meaning_tamil'] ?? '', AppTheme.success),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.warning.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.warning.withOpacity(0.12), width: 1.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_rounded, color: AppTheme.warning, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FUN FACT',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.warning,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        kinshipData!['fun_fact'] ?? '',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.secondary.withOpacity(0.8),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'EXAMPLE SENTENCE',
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppTheme.textGray,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            kinshipData!['example_sentence'] ?? '',
            style: GoogleFonts.notoSansTamil(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          if (kinshipData!['quiz'] != null) ...[
            const Divider(color: AppTheme.borderLight, height: 1),
            const SizedBox(height: 20),
            _buildQuiz(kinshipData!['quiz'] as List),
          ],
        ],
      ),
    );
  }

  Widget _buildDefinitionRow(String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textGray,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuiz(List quiz) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.help_outline_rounded, color: AppTheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Linguistic Quiz',
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
