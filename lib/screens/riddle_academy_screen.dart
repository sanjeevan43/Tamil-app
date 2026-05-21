import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tamil_app/constants/app_theme.dart';
import 'package:tamil_app/services/claude_api_service.dart';

class RiddleAcademyScreen extends StatefulWidget {
  final int childAge;

  const RiddleAcademyScreen({super.key, required this.childAge});

  @override
  State<RiddleAcademyScreen> createState() => _RiddleAcademyScreenState();
}

class _RiddleAcademyScreenState extends State<RiddleAcademyScreen> {
  final List<String> categories = ['nature', 'animals', 'body_parts', 'food', 'home_objects', 'sky', 'school'];
  final List<String> difficulties = ['easy', 'medium', 'hard'];

  String selectedCategory = 'nature';
  String selectedDifficulty = 'easy';
  Map<String, dynamic>? riddleData;
  bool isLoading = false;
  bool showAnswer = false;
  List<String> shownRiddles = [];

  Future<void> _generateRiddle() async {
    setState(() {
      isLoading = true;
      showAnswer = false;
    });

    try {
      final result = await ClaudeApiService.generateRiddle(
        category: selectedCategory,
        difficulty: selectedDifficulty,
        childAge: widget.childAge,
        shownRiddles: shownRiddles,
      );
      if (!mounted) return;
      setState(() {
        riddleData = result;
        shownRiddles.add(result['riddle_tamil'] ?? '');
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
          'Tolkappiyar\'s Riddle Academy',
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
              'Select Riddle Category:',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                final isSelected = selectedCategory == cat;
                return ChoiceChip(
                  label: Text(
                    cat.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected ? AppTheme.white : AppTheme.secondary,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppTheme.primary,
                  backgroundColor: AppTheme.topoLight,
                  checkmarkColor: AppTheme.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primary : AppTheme.topoSilver.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  onSelected: (selected) {
                    setState(() => selectedCategory = cat);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Riddle Difficulty:',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: difficulties.map((diff) {
                final isSelected = selectedDifficulty == diff;
                return ChoiceChip(
                  label: Text(
                    diff.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected ? AppTheme.white : AppTheme.secondary,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppTheme.primary,
                  backgroundColor: AppTheme.topoLight,
                  checkmarkColor: AppTheme.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primary : AppTheme.topoSilver.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  onSelected: (selected) {
                    setState(() => selectedDifficulty = diff);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _generateRiddle,
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
                        'Generate Custom Riddle',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 28),
            if (riddleData != null) _buildRiddleCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildRiddleCard() {
    return Container(
      decoration: AppTheme.whiteCard(radius: 24),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: AppTheme.pillBadge(bgColor: AppTheme.primary.withOpacity(0.08)),
                child: Text(
                  'RIDDLE (விடுகதை)',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Icon(Icons.psychology_rounded, color: AppTheme.primary, size: 24),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            riddleData!['riddle_tamil'] ?? '',
            style: GoogleFonts.notoSansTamil(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            riddleData!['riddle_english'] ?? '',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppTheme.textGray,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.info.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.info.withOpacity(0.12), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHintRow('Hint 1', riddleData!['hint_1'] ?? ''),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(color: AppTheme.topoSilver, height: 1),
                ),
                _buildHintRow('Hint 2', riddleData!['hint_2'] ?? ''),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() => showAnswer = !showAnswer);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                showAnswer ? 'Hide Riddle Answer' : 'Reveal Riddle Answer',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ),
          ),
          if (showAnswer) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.success.withOpacity(0.15), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'ANSWER REVEALED',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.success,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    riddleData!['answer_tamil'] ?? '',
                    style: GoogleFonts.notoSansTamil(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondary,
                    ),
                  ),
                  Text(
                    riddleData!['answer_english'] ?? '',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppTheme.textGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppTheme.borderLight, height: 1),
                  const SizedBox(height: 12),
                  Text(
                    riddleData!['explanation'] ?? '',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.secondary.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.success.withOpacity(0.1), width: 1),
                    ),
                    child: Text(
                      '🎯 Fun Fact: ${riddleData!['fun_fact'] ?? ''}',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHintRow(String label, String hintText) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.lightbulb_rounded, color: AppTheme.info, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.info,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                hintText,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.secondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
