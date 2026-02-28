import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/dictionary_db_service.dart';
import '../constants/app_theme.dart';
import 'word_detail_screen.dart';

class OfflineDictionaryScreen extends StatefulWidget {
  const OfflineDictionaryScreen({super.key});

  @override
  State<OfflineDictionaryScreen> createState() => _OfflineDictionaryScreenState();
}

class _OfflineDictionaryScreenState extends State<OfflineDictionaryScreen> {
  final DictionaryDbService _dbService = DictionaryDbService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterTts flutterTts = FlutterTts();

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
    _searchFocusNode.addListener(() {
      setState(() {
        _showRecentSearches = _searchFocusNode.hasFocus && _searchQuery.isEmpty;
      });
    });
    _loadFilters();
    _loadRecentSearches(); 
    _fetchWords(reset: true);
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoading && _hasMore) {
          _fetchWords();
        }
      }
    });
  }

  Future<void> _loadFilters() async {
    try {
      final types = await _dbService.getWordTypes();
      final categories = await _dbService.getCategories();
      if (mounted) {
        setState(() {
          _types.addAll(types);
          _categories.addAll(categories);
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primary),
            borderRadius: BorderRadius.circular(12),
            style: GoogleFonts.poppins(color: AppTheme.textDark, fontSize: 13),
            onChanged: onChanged,
            items: items.toSet().toList().map<DropdownMenuItem<String>>((String val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text(
                  val,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String? text, MaterialColor color) {
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.shade200),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: color.shade700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Tamil Dictionary', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppTheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showFavorites ? Icons.favorite : Icons.favorite_border, color: _showFavorites ? Colors.redAccent : Colors.white),
            onPressed: () {
              setState(() {
                _showFavorites = !_showFavorites;
                _fetchWords(reset: true);
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  style: GoogleFonts.poppins(color: AppTheme.textDark),
                  decoration: InputDecoration(
                    hintText: 'Search meaning or word...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                    suffixIcon: _searchQuery.isNotEmpty 
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _showRecentSearches = _searchFocusNode.hasFocus;
                            });
                            _fetchWords(reset: true);
                          },
                        )
                      : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _showRecentSearches = _searchFocusNode.hasFocus && _searchQuery.isEmpty;
                    });
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      _fetchWords(reset: true);
                    });
                  },
                  onSubmitted: (value) {
                    _addRecentSearch(value);
                  },
                ),
                const SizedBox(height: 12),
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
          const SizedBox(height: 16),
          
          if (_showRecentSearches && _recentSearches.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Searches', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                        GestureDetector(
                          onTap: _clearRecentSearches,
                          child: Text('Clear', style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.primary)),
                        )
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ..._recentSearches.map((query) => ListTile(
                    leading: const Icon(Icons.history, color: Colors.grey),
                    title: Text(query, style: GoogleFonts.poppins(fontSize: 15)),
                    onTap: () {
                      _searchController.text = query;
                      _searchFocusNode.unfocus();
                      setState(() {
                        _searchQuery = query;
                        _showRecentSearches = false;
                      });
                      _fetchWords(reset: true);
                      _addRecentSearch(query);
                    },
                  )).toList(),
                ],
              ),
            ),

          if (!_showRecentSearches || _recentSearches.isEmpty)
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _words.isEmpty && !_isLoading
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  _showFavorites ? 'No favorites yet' : 'No words found',
                                  style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            physics: const BouncingScrollPhysics(),
                            itemCount: _words.length + (_hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _words.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24.0),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }

                              final entry = _words[index];
                              final isFav = entry['is_favorite'] == 1;

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WordDetailScreen(
                                        wordId: entry['id'],
                                        basicWord: entry['word'],
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Hero(
                                                    tag: 'word_${entry['id']}',
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: Text(
                                                        entry['word'],
                                                        style: GoogleFonts.notoSansTamil(
                                                          fontSize: 24,
                                                          fontWeight: FontWeight.bold,
                                                          color: AppTheme.primary,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    entry['tamil_meaning']?.toString() ?? 'No meaning',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.black87,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Wrap(
                                                    spacing: 6,
                                                    children: [
                                                      _buildTag(entry['type_name'], Colors.blue),
                                                      _buildTag(entry['category_name'], Colors.orange),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    isFav ? Icons.favorite : Icons.favorite_border,
                                                    color: isFav ? Colors.red : Colors.grey,
                                                  ),
                                                  onPressed: () => _toggleFavorite(index),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.volume_up, color: AppTheme.accent),
                                                  onPressed: () => _speak(entry['word']),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  
                  // Alphabet Navigator
                  Container(
                    width: 30,
                    color: Colors.white,
                    child: ListView.builder(
                      itemCount: _alphabets.length,
                      itemBuilder: (context, index) {
                        final alpha = _alphabets[index];
                        final isSelected = _selectedAlphabet == alpha;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedAlphabet = alpha;
                              _fetchWords(reset: true);
                            });
                          },
                          child: Container(
                            height: 25,
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primary : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              alpha == 'All' ? '*' : alpha,
                              style: GoogleFonts.notoSansTamil(
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? Colors.white : AppTheme.primary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
