import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../constants/tamil_data.dart';
import '../services/audio_service.dart';
import '../providers/enhanced_progress_provider.dart';

class TamilLettersScreen extends StatelessWidget {
  const TamilLettersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tamil Letters'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('உயிர் எழுத்துக்கள் (Vowels)'),
              _buildLetterGrid(context, TamilData.uyirEzhuthukkal),
              const SizedBox(height: 30),
              _buildSectionTitle('மெய் எழுத்துக்கள் (Consonants)'),
              _buildLetterGrid(context, TamilData.meiEzhuthukkal),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.primaryRed,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.white,
        ),
      ),
    );
  }

  Widget _buildLetterGrid(BuildContext context, List<String> letters) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: letters.length,
      itemBuilder: (context, index) {
        return _buildLetterCard(context, letters[index]);
      },
    );
  }

  Widget _buildLetterCard(BuildContext context, String letter) {
    return GestureDetector(
      onTap: () {
        AudioService.playLetter(letter);
        Provider.of<EnhancedProgressProvider>(context, listen: false).incrementLettersLearned();
        _showLetterDialog(context, letter);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.white, AppTheme.offWhite],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryRed, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryRed.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            letter,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryRed,
            ),
          ),
        ),
      ),
    );
  }

  void _showLetterDialog(BuildContext context, String letter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppTheme.primaryRed,
                shape: BoxShape.circle,
              ),
              child: Text(
                letter,
                style: const TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => AudioService.playLetter(letter),
              icon: const Icon(Icons.volume_up),
              label: const Text('Play Sound'),
            ),
          ],
        ),
      ),
    );
  }
}
