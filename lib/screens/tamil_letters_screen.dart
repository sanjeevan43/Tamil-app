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
          backgroundColor: AppTheme.primary,
          title: Text(
            'Tamil Alphabet',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          bottom: TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppTheme.accent,
            indicatorWeight: 4,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12),
            tabs: const [
              Tab(text: 'Vowels\n(உயிர் - 12)'),
              Tab(text: 'Consonants\n(மெய் - 18)'),
              Tab(text: 'Combined\n(உயிர்மெய் - 216)'),
              Tab(text: 'Special\n(ஆய்தம் - 1)'),
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
        
        // Reward users silently
        Provider.of<EnhancedProgressProvider>(context, listen: false).addRewards(coins: 1);
        
        // Show subtle feedback
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.volume_up, color: Colors.white),
                const SizedBox(width: 10),
                Text('Playing $letter', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              ],
            ),
            duration: const Duration(milliseconds: 800),
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          )
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              letter,
              style: GoogleFonts.notoSansTamil(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.textSlate,
                  fontWeight: FontWeight.w500
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class _VowelsGrid extends StatelessWidget {
  const _VowelsGrid();

  // Mapping generic transliterations for display
  static const List<String> _transliteration = [
    'a', 'aa', 'i', 'ii', 'u', 'uu', 'e', 'ee', 'ai', 'o', 'oo', 'au'
  ];

  @override
  Widget build(BuildContext context) {
    final letters = TamilData.uyirEzhuthukkal;
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
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

  // Mapping generic transliterations for display
  static const List<String> _transliteration = [
    'ik', 'ing', 'ich', 'inj', 'it', 'in', 'ith', 'ind', 'ip', 'im',
    'iy', 'ir', 'il', 'iv', 'izh', 'ill', 'irr', 'in'
  ];

  @override
  Widget build(BuildContext context) {
    final letters = TamilData.meiEzhuthukkal;
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: Text(
              '${baseCon[i]} Series',
              style: GoogleFonts.notoSansTamil(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark
              ),
            ),
            subtitle: Text('Tap to view 12 variations', style: GoogleFonts.poppins(fontSize: 12)),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: combinations[i].length,
                  itemBuilder: (context, j) {
                    return _LetterCard(letter: combinations[i][j]);
                  },
                ),
              )
            ],
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
              height: 150,
              width: 150,
              child: _LetterCard(
                letter: letters[0],
                subtitle: 'ak',
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Aayudha Ezhuthu',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 10),
            Text(
              'A special Tamil letter commonly used to add a slightly guttural, stop-consonant sound.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSlate),
            )
          ],
        ),
      ),
    );
  }
}
