import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_theme.dart';
import '../services/audio_service.dart';
import '../services/audio_feedback_service.dart';
import '../services/claude_api_service.dart';

class LinguisticScannerScreen extends StatefulWidget {
  final int childAge;

  const LinguisticScannerScreen({super.key, required this.childAge});

  @override
  State<LinguisticScannerScreen> createState() => _LinguisticScannerScreenState();
}

class _LinguisticScannerScreenState extends State<LinguisticScannerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Local Dictionary Search States
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allWords = [];
  List<Map<String, dynamic>> _filteredWords = [];
  Map<String, dynamic>? _selectedWord;
  bool _isLoadingWords = true;
  
  // AI Explainer States
  final TextEditingController _explainController = TextEditingController();
  Map<String, dynamic>? _explanationData;
  bool _isExplaining = false;
  final Map<int, String> _selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadWords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _explainController.dispose();
    super.dispose();
  }

  Future<void> _loadWords() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/words.json');
      final List<dynamic> data = json.decode(jsonString);
      setState(() {
        _allWords = data.map((item) => Map<String, dynamic>.from(item)).toList();
        _filteredWords = _allWords;
        _isLoadingWords = false;
      });
    } catch (e) {
      debugPrint('Error loading words dictionary: $e');
      setState(() {
        _isLoadingWords = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _filteredWords = _allWords;
      });
      return;
    }
    
    final lowerQuery = query.toLowerCase().trim();
    setState(() {
      _filteredWords = _allWords.where((word) {
        final tamil = (word['tamil'] ?? '').toString();
        final english = (word['english'] ?? '').toString().toLowerCase();
        final category = (word['category'] ?? '').toString().toLowerCase();
        return tamil.contains(lowerQuery) || english.contains(lowerQuery) || category.contains(lowerQuery);
      }).toList();
    });
  }

  Future<void> _explainText() async {
    if (_explainController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Tamil text to analyze')),
      );
      return;
    }

    setState(() => _isExplaining = true);

    try {
      final result = await ClaudeApiService.explainScannedText(
        scannedText: _explainController.text,
        childAge: widget.childAge,
      );
      if (!mounted) return;
      setState(() {
        _explanationData = result;
        _selectedAnswers.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isExplaining = false);
      }
    }
  }

  Future<void> _explainSelectedWord(String wordText) async {
    setState(() => _isExplaining = true);
    _tabController.animateTo(1); // switch to AI Explainer tab
    _explainController.text = wordText;

    try {
      final result = await ClaudeApiService.explainScannedText(
        scannedText: wordText,
        childAge: widget.childAge,
      );
      if (!mounted) return;
      setState(() {
        _explanationData = result;
        _selectedAnswers.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isExplaining = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          // Background soft accent circle
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withOpacity(0.04),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Panel
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          AudioFeedbackService.playTap();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.secondary),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DICTIONARY & AI EXPLAINER',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primary,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tamil Word Bank',
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Premium Tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.topoLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.secondary.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      labelColor: AppTheme.secondary,
                      unselectedLabelColor: AppTheme.textGray,
                      labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13),
                      unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13),
                      tabs: const [
                        Tab(text: 'Local Search'),
                        Tab(text: 'AI Text Explainer'),
                      ],
                    ),
                  ),
                ),

                // Tab Contents
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLocalSearchTab(),
                      _buildAiExplainerTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalSearchTab() {
    if (_isLoadingWords) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: AppTheme.secondary,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'Search Tamil, English or Categories...',
              hintStyle: GoogleFonts.outfit(
                color: AppTheme.textGray.withOpacity(0.6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textGray, size: 22),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: AppTheme.textGray),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: AppTheme.topoSilver, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: AppTheme.topoSilver, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: AppTheme.primary, width: 2),
              ),
              filled: true,
              fillColor: AppTheme.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),

        // Content
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side: Matching List
              Expanded(
                flex: 4,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: 24, right: 12, bottom: 24),
                  itemCount: _filteredWords.length,
                  itemBuilder: (context, index) {
                    final item = _filteredWords[index];
                    final isSelected = _selectedWord != null && _selectedWord!['id'] == item['id'];
                    
                    return GestureDetector(
                      onTap: () {
                        AudioFeedbackService.playTap();
                        setState(() {
                          _selectedWord = item;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primary.withOpacity(0.06) : AppTheme.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppTheme.primary.withOpacity(0.3) : AppTheme.borderLight,
                            width: isSelected ? 2 : 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              item['emoji'] ?? '📖',
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['tamil'] ?? '',
                                    style: GoogleFonts.notoSansTamil(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.secondary,
                                    ),
                                  ),
                                  Text(
                                    item['english'] ?? '',
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: AppTheme.textGray,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.textGray),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Right side: Detail Panel (For wider view or just side container)
              if (_selectedWord != null)
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(right: 24, left: 12, bottom: 24),
                    child: Container(
                      decoration: AppTheme.whiteCard(radius: 24),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Big Emoji
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.06),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              _selectedWord!['emoji'] ?? '📖',
                              style: const TextStyle(fontSize: 48),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Tamil Word
                          Text(
                            _selectedWord!['tamil'] ?? '',
                            style: GoogleFonts.notoSansTamil(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // English Meaning
                          Text(
                            _selectedWord!['english'] ?? '',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              color: AppTheme.textGray,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Pronounce Button
                          ElevatedButton.icon(
                            onPressed: () {
                              AudioFeedbackService.playPop();
                              AudioService.playWord(_selectedWord!['tamil']);
                            },
                            icon: const Icon(Icons.volume_up_rounded, color: AppTheme.white),
                            label: Text(
                              'Pronounce',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w800),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              elevation: 0,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          const Divider(color: AppTheme.topoSilver),
                          const SizedBox(height: 12),
                          
                          // Category and Difficulty tags
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Category',
                                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textGray),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: AppTheme.pillBadge(bgColor: AppTheme.secondary.withOpacity(0.08)),
                                child: Text(
                                  _selectedWord!['category'] ?? 'General',
                                  style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.secondary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Difficulty',
                                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textGray),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: AppTheme.pillBadge(bgColor: AppTheme.info.withOpacity(0.08)),
                                child: Text(
                                  _selectedWord!['difficulty'] ?? 'Easy',
                                  style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.info),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // AI Explain Button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                AudioFeedbackService.playTap();
                                _explainSelectedWord(_selectedWord!['tamil']);
                              },
                              icon: const Icon(Icons.auto_awesome, size: 16, color: AppTheme.secondary),
                              label: Text(
                                'Explain with AI',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.secondary,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppTheme.secondary, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  flex: 5,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.menu_book_rounded, size: 48, color: AppTheme.textGray),
                          const SizedBox(height: 12),
                          Text(
                            'Select a word from the list to see the definition and hear how it sounds!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: AppTheme.textGray,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAiExplainerTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter or paste Tamil text (single word or whole sentence):',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.secondary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _explainController,
            maxLines: 4,
            style: GoogleFonts.notoSansTamil(
              fontSize: 16,
              color: AppTheme.secondary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'வணக்கம் தமிழ்நாடு (Greetings Tamil Nadu)',
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
            child: ElevatedButton.icon(
              onPressed: _isExplaining ? null : _explainText,
              icon: _isExplaining 
                  ? const SizedBox.shrink() 
                  : const Icon(Icons.auto_awesome, color: AppTheme.white, size: 20),
              label: _isExplaining
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: AppTheme.white, strokeWidth: 2.5),
                    )
                  : Text(
                      'Analyze & Explain with AI',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 28),
          
          if (_isExplaining)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: AppTheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'AI is analyzing vocabulary and grammar...',
                      style: GoogleFonts.outfit(color: AppTheme.textGray, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            )
          else if (_explanationData != null)
            _buildExplanationResults(),
        ],
      ),
    );
  }

  Widget _buildExplanationResults() {
    final words = _explanationData!['words'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Text Explainer Card
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
                      'AI TEXT ANALYSIS',
                      style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.info, letterSpacing: 1),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, color: AppTheme.info),
                        onPressed: () {
                          AudioFeedbackService.playPop();
                          AudioService.playWord(_explanationData!['full_text'] ?? '');
                        },
                      ),
                      const Icon(Icons.analytics_rounded, color: AppTheme.info, size: 20),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _explanationData!['full_text'] ?? '',
                style: GoogleFonts.notoSansTamil(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _explanationData!['full_meaning'] ?? '',
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
        
        // Vocabulary Breakdown
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
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.volume_up_rounded, color: AppTheme.info, size: 20),
                            onPressed: () {
                              AudioFeedbackService.playPop();
                              AudioService.playWord(word['word'] ?? '');
                            },
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
                    ],
                  ),
                  Text(
                    'Transliteration: ${word['word'] != null ? word['transliteration'] ?? '' : ''}',
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
                  if (word['example'] != null && word['example'].toString().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Example: ${word['example'] ?? ''}',
                      style: GoogleFonts.notoSansTamil(
                        fontSize: 13,
                        color: AppTheme.textSlate,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (word['fun_fact'] != null && word['fun_fact'].toString().isNotEmpty) ...[
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
                ],
              ),
            );
          }),
        ],
        
        // Comprehension Quiz
        if (_explanationData!['quiz'] != null) ...[
          const SizedBox(height: 16),
          _buildQuiz(),
        ],
      ],
    );
  }

  Widget _buildQuiz() {
    final quiz = _explanationData!['quiz'] as List? ?? [];
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
                          _selectedAnswers[index] = option.toString();
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
                              option.toString(),
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
