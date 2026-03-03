import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../constants/tamil_data.dart';
import '../services/audio_service.dart';
import '../providers/enhanced_progress_provider.dart';

class TamilLettersScreen extends StatelessWidget {
  const TamilLettersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.secondary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: false,
          title: Text(
            'TAMIL ALPHABET',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.secondary, fontSize: 18, letterSpacing: 1),
          ),
          bottom: TabBar(
            isScrollable: true,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textGray,
            indicatorColor: AppTheme.primary,
            indicatorWeight: 4,
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1),
            unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13),
            tabs: const [
              Tab(text: 'VOWELS (12)'),
              Tab(text: 'CONSONANTS (18)'),
              Tab(text: 'COMBINED (216)'),
              Tab(text: 'SPECIAL (1)'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _VowelsGrid(),
            _ConsonantsGrid(),
            _CombinedList(),
            _SpecialGrid(),
          ],
        ),
      ),
    );
  }
}

class _LetterCard extends StatelessWidget {
  final String letter;
  final String? subtitle;

  const _LetterCard({required this.letter, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AudioService.playLetter(letter);
        Provider.of<EnhancedProgressProvider>(context, listen: false).addRewards(coins: 1);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.volume_up, color: Colors.white),
                const SizedBox(width: 10),
                Text('Playing $letter', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ],
            ),
            duration: const Duration(milliseconds: 800),
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: AppTheme.primary.withOpacity(0.1), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              letter,
              style: GoogleFonts.notoSansTamil(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            if (subtitle != null) ...{
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: AppTheme.textGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
            },
          ],
        ),
      ),
    );
  }
}

class _VowelsGrid extends StatelessWidget {
  const _VowelsGrid();

  static const List<String> _transliteration = [
    'a', 'aa', 'i', 'ii', 'u', 'uu', 'e', 'ee', 'ai', 'o', 'oo', 'au'
  ];

  @override
  Widget build(BuildContext context) {
    final letters = TamilData.uyirEzhuthukkal;
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.0,
      ),
      itemCount: letters.length,
      itemBuilder: (context, index) {
        return _LetterCard(
          letter: letters[index],
          subtitle: _transliteration[index],
        );
      },
    );
  }
}

class _ConsonantsGrid extends StatelessWidget {
  const _ConsonantsGrid();

  static const List<String> _transliteration = [
    'ik', 'ing', 'ich', 'inj', 'it', 'in', 'ith', 'ind', 'ip', 'im',
    'iy', 'ir', 'il', 'iv', 'izh', 'ill', 'irr', 'in'
  ];

  @override
  Widget build(BuildContext context) {
    final letters = TamilData.meiEzhuthukkal;
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.0,
      ),
      itemCount: letters.length,
      itemBuilder: (context, index) {
        return _LetterCard(
          letter: letters[index],
          subtitle: _transliteration[index],
        );
      },
    );
  }
}

class _CombinedList extends StatelessWidget {
  const _CombinedList();

  @override
  Widget build(BuildContext context) {
    final baseCon = TamilData.uyirMeiBase;
    final combinations = TamilData.uyirMeiEzhuthukkal;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: baseCon.length,
      itemBuilder: (context, i) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          color: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primary.withOpacity(0.1), width: 1.5),
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              title: Text(
                '${baseCon[i]} Series',
                style: GoogleFonts.notoSansTamil(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              subtitle: Text('Tap to view 12 variations', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textGray)),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: combinations[i].length,
                    itemBuilder: (context, j) {
                      return _LetterCard(letter: combinations[i][j]);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SpecialGrid extends StatelessWidget {
  const _SpecialGrid();

  @override
  Widget build(BuildContext context) {
    final letters = TamilData.aayudhaEzhuthu;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 160,
              width: 160,
              child: _LetterCard(
                letter: letters[0],
                subtitle: 'ak',
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aayudha Ezhuthu',
              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.secondary),
            ),
            const SizedBox(height: 12),
            Text(
              'A special Tamil letter commonly used to add a slightly guttural, stop-consonant sound.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textGray, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
