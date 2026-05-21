import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../constants/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/safe_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class RhymesScreen extends StatefulWidget {
  const RhymesScreen({super.key});

  @override
  State<RhymesScreen> createState() => _RhymesScreenState();
}

class _RhymesScreenState extends State<RhymesScreen> {
  final FirestoreService _firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.getRhymesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final rhymes = snapshot.data?.docs ?? [];
                  
                  if (rhymes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.music_note_rounded, size: 48, color: AppTheme.borderLight),
                          const SizedBox(height: 16),
                          Text('No rhymes found.', style: GoogleFonts.outfit(color: AppTheme.textGray)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: rhymes.length,
                    itemBuilder: (context, index) {
                      final rhyme = rhymes[index].data() as Map<String, dynamic>;
                      return _buildRhymeCard(context, rhyme);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight.withOpacity(0.9),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
          Column(
            children: [
              Text(
                'SING ALONG',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryRed.withOpacity(0.8),
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'Tamil Rhymes',
                style: GoogleFonts.notoSansTamil(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryRed.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppTheme.primaryRed, size: 24),
      ),
    );
  }

  Widget _buildRhymeCard(BuildContext context, Map<String, dynamic> rhyme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryRed.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textDark.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RhymePlayerScreen(rhyme: rhyme),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Hero(
                  tag: 'rhyme_${rhyme['id'] ?? rhyme['title']}',
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SafeImage(
                        assetPath: 'assets/images/${rhyme["image"] ?? "music_placeholder"}.png', 
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rhyme['title'] ?? 'Tamil Rhyme',
                        style: GoogleFonts.notoSansTamil(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        rhyme['englishTitle'] ?? '',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSlate,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(rhyme['lines'] as List).length} Lines',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryRed.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: AppTheme.white, size: 30),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RhymePlayerScreen extends StatefulWidget {
  final Map<String, dynamic> rhyme;
  const RhymePlayerScreen({super.key, required this.rhyme});

  @override
  State<RhymePlayerScreen> createState() => _RhymePlayerScreenState();
}

class _RhymePlayerScreenState extends State<RhymePlayerScreen> {
  final FlutterTts flutterTts = FlutterTts();
  int _lineIndex = 0;
  bool _isPlaying = false;
  List<dynamic> get _lines => widget.rhyme['lines'] as List;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    await flutterTts.setLanguage('ta-IN');
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.3);
  }

  Future<void> _speak(String text) async {
    setState(() => _isPlaying = true);
    await flutterTts.speak(text);
    flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  Future<void> _stop() async {
    await flutterTts.stop();
    if (mounted) setState(() => _isPlaying = false);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLine = _lines[_lineIndex];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
             Container(
              padding: const EdgeInsets.all(16),
              color: Colors.transparent, 
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                   Expanded(
                    child: Text(
                      widget.rhyme['title'],
                      style: GoogleFonts.notoSansTamil(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                   const SizedBox(width: 48), // Balance back button
                ],
              ),
            ),
            
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image Placeholder with Glass or Premium style
                  GlassCard(
                    width: 300,
                    height: 300,
                    radius: 30,
                    child: Center(
                      child: SafeImage(
                          assetPath: 'assets/images/${widget.rhyme["image"] ?? "rhyme_bg"}.png',
                          fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Lyrics Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        currentLine['content'],
                        key: ValueKey(_lineIndex),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSansTamil(
                          fontSize: 28,
                          height: 1.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Controls
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.textDark.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Prev
                  IconButton(
                    iconSize: 40,
                    icon: const Icon(Icons.skip_previous_rounded),
                    color: _lineIndex > 0 ? AppTheme.textSlate : AppTheme.topoSilver,
                    onPressed: _lineIndex > 0 ? () {
                      _stop();
                      setState(() => _lineIndex--);
                    } : null,
                  ),
                  
                  // Play/Pause
                  GestureDetector(
                    onTap: () => _isPlaying ? _stop() : _speak(currentLine['content']),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _isPlaying ? AppTheme.accentRed : AppTheme.primaryRed,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryRed.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                        color: AppTheme.white,
                        size: 40,
                      ),
                    ),
                  ),
                  
                  // Next
                  IconButton(
                    iconSize: 40,
                    icon: const Icon(Icons.skip_next_rounded),
                    color: _lineIndex < _lines.length - 1 ? AppTheme.textSlate : AppTheme.topoSilver,
                    onPressed: _lineIndex < _lines.length - 1 ? () {
                      _stop();
                      setState(() => _lineIndex++);
                    } : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
