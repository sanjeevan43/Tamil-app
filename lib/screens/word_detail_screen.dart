import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/dictionary_db_service.dart';
import '../constants/app_theme.dart';

class WordDetailScreen extends StatefulWidget {
  final int wordId;
  final String basicWord; // passed for immediate display
  const WordDetailScreen({super.key, required this.wordId, required this.basicWord});

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  final DictionaryDbService _dbService = DictionaryDbService();
  final FlutterTts _tts = FlutterTts();
  Map<String, dynamic>? _details;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final res = await _dbService.getWordDetails(widget.wordId);
    setState(() {
      _details = res;
      _isLoading = false;
    });
  }

  Future<void> _speak(String text) async {
    await _tts.setLanguage("ta-IN");
    await _tts.speak(text);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.whiteCard(radius: 20).copyWith(
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                title.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textSlate.withOpacity(0.6),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppTheme.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: _isLoading 
                ? Text(widget.basicWord, style: GoogleFonts.notoSansTamil(fontWeight: FontWeight.bold))
                : null,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryDark, AppTheme.primary],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Hero(
                              tag: 'word_${widget.wordId}',
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  _details!['word'],
                                  style: GoogleFonts.notoSansTamil(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _details!['pronunciation'] ?? 'No pronunciation',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 16),
                            IconButton(
                              icon: const Icon(Icons.volume_up_rounded, size: 40, color: AppTheme.accent),
                              onPressed: () => _speak(_details!['word']),
                            ),
                          ],
                        ),
                  ),
                ),
              ),
            ),
          ),
          if (!_isLoading && _details != null) 
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meta Overview
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildBadge(_details!['type_name'], Colors.blue),
                        _buildBadge(_details!['category_name'], Colors.orange),
                        if (_details!['english_meaning'] != null && _details!['english_meaning'] != 'Translation Pending')
                          _buildBadge('ENG: ${_details!['english_meaning']}', Colors.green),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Tamil Meaning Big
                    Text(
                      'விளக்கம் (Meaning)',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textSlate),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _details!['tamil_meaning']?.toString() ?? 'No meaning available',
                      style: GoogleFonts.notoSansTamil(fontSize: 22, fontWeight: FontWeight.w500, color: AppTheme.textDark, height: 1.5),
                    ),
                    const SizedBox(height: 32),

                    // Examples Section
                    _buildSection('Examples', Icons.format_quote_rounded, 
                      (_details!['examples'] as List).map((ex) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      ex['example_tamil'],
                                      style: GoogleFonts.notoSansTamil(fontSize: 18, color: AppTheme.textDark, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.volume_down, color: AppTheme.primary),
                                    onPressed: () => _speak(ex['example_tamil']),
                                  )
                                ],
                              ),
                              Text(ex['example_english'], style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700])),
                              const Divider(height: 20),
                            ],
                          ),
                        );
                      }).toList()
                    ),

                    // Synonyms Section
                    _buildSection('Synonyms (பொருள்)', Icons.all_inclusive_rounded, [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (_details!['synonyms'] as List).map((s) {
                          return ActionChip(
                            label: Text(s, style: GoogleFonts.notoSansTamil(color: AppTheme.textDark)),
                            backgroundColor: AppTheme.accent.withOpacity(0.3),
                            onPressed: () => _speak(s),
                          );
                        }).toList(),
                      )
                    ]),

                    // Antonyms Section
                    _buildSection('Antonyms (எதிர்ச்சொல்)', Icons.compare_arrows_rounded, [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (_details!['antonyms'] as List).map((a) {
                          return ActionChip(
                            label: Text(a, style: GoogleFonts.notoSansTamil(color: Colors.red[900])),
                            backgroundColor: Colors.red[50],
                            onPressed: () {},
                          );
                        }).toList(),
                      )
                    ]),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildBadge(String? text, MaterialColor color) {
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.shade200),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: color.shade800),
      ),
    );
  }
}
