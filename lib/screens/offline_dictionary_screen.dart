import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:characters/characters.dart';
import '../services/dictionary_db_service.dart';
import '../constants/app_theme.dart';
import 'word_detail_screen.dart';

class OfflineDictionaryScreen extends StatefulWidget {
  const OfflineDictionaryScreen({super.key});

  @override
  State<OfflineDictionaryScreen> createState() => _OfflineDictionaryScreenState();
}

class _OfflineDictionaryScreenState extends State<OfflineDictionaryScreen> with SingleTickerProviderStateMixin {
  final DictionaryDbService _dbService = DictionaryDbService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterTts flutterTts = FlutterTts();
  late AnimationController _animationController;

  List<Map<String, dynamic>> _words = [];
  bool _isLoading = false;
  bool _hasMore = true;
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _recentSearches = [];
  bool _showRecentSearches = false;
  
  String _searchQuery = '';
  Timer? _debounce;

  int _offset = 0;
  final int _limit = 20;

  // Filters
  String _selectedType = 'All';
  String _selectedCategory = 'All';
  bool _showFavorites = false;

  // Dropdown options
  List<String> _types = ['All'];
  List<String> _categories = ['All'];
  
  final List<String> _alphabets = [
    'All', 'அ', 'ஆ', 'இ', 'ஈ', 'உ', 'ஊ', 'எ', 'ஏ', 'ஐ', 'ஒ', 'ஓ', 'ஔ',
    'க', 'ச', 'ஞ', 'ட', 'ண', 'த', 'ந', 'ப', 'ம', 'ய', 'ர', 'ல', 'வ', 'ழ', 'ள', 'ற', 'ன'
  ];
  String _selectedAlphabet = 'All';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    
    _searchFocusNode.addListener(() {
      setState(() {
        _showRecentSearches = _searchFocusNode.hasFocus && _searchQuery.isEmpty;
      });
    });
    
    _loadFilters();
    _loadRecentSearches(); 
    _fetchWords(reset: true);
    _syncWithCloud(); // Proactively sync new words from Firebase
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoading && _hasMore) {
          _fetchWords();
        }
      }
    });
  }

  Future<void> _syncWithCloud() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('dictionary').get();
      if (snapshot.docs.isNotEmpty) {
        final db = await _dbService.database;
        Batch batch = db.batch();
        for (var doc in snapshot.docs) {
          final data = doc.data();
          String w = data['word'] ?? '';
          String alphabet = '';
          try {
            alphabet = Characters(w).first;
          } catch(_) { alphabet = w.substring(0, 1); }

          batch.insert('words', {
            'word': w,
            'english_meaning': data['english_meaning'],
            'tamil_meaning': data['tamil_meaning'],
            'type_id': 100, // General
            'category_id': 100, // Common
            'alphabet_start': alphabet,
            'is_common': 1
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
        await batch.commit(noResult: true);
        debugPrint("Synced ${snapshot.docs.length} words from Cloud.");
      }
    } catch (e) {
      debugPrint("Cloud sync failed: $e");
    }
  }

  Future<void> _loadFilters() async {
    try {
      final types = await _dbService.getWordTypes();
      final categories = await _dbService.getCategories();
      if (mounted) {
        setState(() {
          _types = ['All', ...types];
          _categories = ['All', ...categories];
        });
      }
    } catch(e) {
      debugPrint("Error loading filters: $e");
    }
  }

  Future<void> _fetchWords({bool reset = false}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    if (reset) {
      _offset = 0;
      _words.clear();
      _hasMore = true;
    }

    try {
      final results = await _dbService.getWords(
        limit: _limit,
        offset: _offset,
        searchQuery: _searchQuery,
        typeFilter: _selectedType,
        categoryFilter: _selectedCategory,
        alphabetFilter: _selectedAlphabet,
        favoritesOnly: _showFavorites,
      );

      setState(() {
        if (results.length < _limit) {
          _hasMore = false;
        }
        _words.addAll(results);
        _offset += _limit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error fetching dictionary: $e');
    }
  }

  Future<void> _toggleFavorite(int index) async {
    final wordMap = _words[index];
    final id = wordMap['id'] as int;
    final currentStatus = wordMap['is_favorite'] as int;

    await _dbService.toggleFavorite(id, currentStatus);

    setState(() {
      final newStatus = currentStatus == 1 ? 0 : 1;
      final updatedWord = Map<String, dynamic>.from(_words[index]);
      updatedWord['is_favorite'] = newStatus;
      _words[index] = updatedWord;

      if (_showFavorites && newStatus == 0) {
        _words.removeAt(index);
      }
    });
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("ta-IN");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    _debounce?.cancel();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_dictionary_searches') ?? [];
    });
  }

  Future<void> _addRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.sublist(0, 10);
    }
    await prefs.setStringList('recent_dictionary_searches', _recentSearches);
    setState(() {});
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_dictionary_searches');
    setState(() {
      _recentSearches.clear();
    });
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            dropdownColor: AppTheme.primary,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
            borderRadius: BorderRadius.circular(12),
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            onChanged: onChanged,
            items: items.toSet().toList().map<DropdownMenuItem<String>>((String val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text(val, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          _buildSearchAndFilters(),
          _buildRecentSearchesSection(),
          _buildWordsList(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: Text(
          ' அகராதி',
          style: GoogleFonts.notoSansTamil(
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary, AppTheme.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(_showFavorites ? Icons.favorite : Icons.favorite_border, 
                color: _showFavorites ? Colors.redAccent : Colors.white),
          onPressed: () {
            setState(() {
              _showFavorites = !_showFavorites;
              _fetchWords(reset: true);
            });
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        decoration: const BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: GoogleFonts.poppins(color: AppTheme.textDark, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Search meaning or word...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() { _searchQuery = ''; _showRecentSearches = _searchFocusNode.hasFocus; });
                        _fetchWords(reset: true);
                      },
                    )
                  : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() { _searchQuery = value; _showRecentSearches = _searchFocusNode.hasFocus && _searchQuery.isEmpty; });
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () => _fetchWords(reset: true));
              },
              onSubmitted: (value) => _addRecentSearch(value),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildDropdown('Type', _selectedType, _types, (val) {
                  setState(() => _selectedType = val!);
                  _fetchWords(reset: true);
                }),
                _buildDropdown('Category', _selectedCategory, _categories, (val) {
                  setState(() => _selectedCategory = val!);
                  _fetchWords(reset: true);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearchesSection() {
    if (!_showRecentSearches || _recentSearches.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Searches', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                GestureDetector(
                  onTap: _clearRecentSearches,
                  child: Text('Clear All', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accent)),
                )
              ],
            ),
            const Divider(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.take(5).map((q) => ActionChip(
                label: Text(q, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
                backgroundColor: AppTheme.primary.withOpacity(0.8),
                onPressed: () {
                  _searchController.text = q;
                  setState(() { _searchQuery = q; _showRecentSearches = false; });
                  _fetchWords(reset: true);
                },
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordsList() {
    if (_words.isEmpty && !_isLoading) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_stories_rounded, size: 80, color: Colors.grey[200]),
              const SizedBox(height: 16),
              Text('No real words found here.', style: GoogleFonts.poppins(color: Colors.grey[400], fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Try searching something else!', style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 12)),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == _words.length) {
              return Center(child: Padding(padding: const EdgeInsets.all(32), child: CircularProgressIndicator(color: AppTheme.accent)));
            }
            final word = _words[index];
            return _buildWordCard(word, index);
          },
          childCount: _words.length + (_hasMore ? 1 : 0),
        ),
      ),
    );
  }

  Widget _buildWordCard(Map<String, dynamic> word, int index) {
    bool isCommon = (word['is_common'] ?? 0) == 1;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          onTap: () {
             _addRecentSearch(word['word']);
             Navigator.push(context, MaterialPageRoute(builder: (c) => WordDetailScreen(wordId: word['id'], basicWord: word['word'])));
          },
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isCommon ? [Colors.amber.shade400, Colors.orange.shade600] : [AppTheme.primary.withOpacity(0.1), AppTheme.primary.withOpacity(0.2)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                word['word'][0],
                style: GoogleFonts.notoSansTamil(
                  fontSize: 22, 
                  fontWeight: FontWeight.w900,
                  color: isCommon ? Colors.white : AppTheme.primary
                ),
              ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  word['word'],
                  style: GoogleFonts.notoSansTamil(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
              ),
              if (isCommon) 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(4)),
                  child: Text('STAR', style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.orange.shade900)),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                word['english_meaning'] ?? 'Tamil Word',
                style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.accent, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                word['tamil_meaning']?.replaceAll(RegExp(r'\(.*\)'), '').trim() ?? '',
                style: GoogleFonts.notoSansTamil(fontSize: 12, color: Colors.grey[500]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(word['is_favorite'] == 1 ? Icons.favorite : Icons.favorite_border, color: word['is_favorite'] == 1 ? Colors.redAccent : Colors.grey[300]),
            onPressed: () => _toggleFavorite(index),
          ),
        ),
      ),
    );
  }
}
