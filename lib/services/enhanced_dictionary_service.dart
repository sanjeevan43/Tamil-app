import 'package:cloud_firestore/cloud_firestore.dart';
import 'tamil_word_filter_service.dart';

class EnhancedDictionaryService {
  static final EnhancedDictionaryService _instance = EnhancedDictionaryService._internal();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TamilWordFilterService _filterService = TamilWordFilterService();

  factory EnhancedDictionaryService() {
    return _instance;
  }

  EnhancedDictionaryService._internal();

  /// Get everyday Tamil words from Firestore with filtering
  Future<List<Map<String, dynamic>>> getEverydayWords({
    int limit = 50,
    int minCommonalityScore = 60,
  }) async {
    try {
      final snapshot = await _db
          .collection('tamil_words')
          .where('is_everyday', isEqualTo: true)
          .limit(limit)
          .get();

      final words = snapshot.docs.map((doc) => doc.data()).toList();
      return _filterService.getFilteredWordsSortedByCommonality(
        words,
        minCommonalityScore: minCommonalityScore,
      );
    } catch (e) {
      print('Error getting everyday words: $e');
      return [];
    }
  }

  /// Get words by category (filtered for everyday use)
  Future<List<Map<String, dynamic>>> getWordsByCategory({
    required String category,
    int limit = 50,
    int minCommonalityScore = 60,
  }) async {
    try {
      final snapshot = await _db
          .collection('tamil_words')
          .where('category', isEqualTo: category)
          .where('is_everyday', isEqualTo: true)
          .limit(limit)
          .get();

      final words = snapshot.docs.map((doc) => doc.data()).toList();
      return _filterService.getFilteredWordsSortedByCommonality(
        words,
        minCommonalityScore: minCommonalityScore,
      );
    } catch (e) {
      print('Error getting words by category: $e');
      return [];
    }
  }

  /// Search for everyday Tamil words
  Future<List<Map<String, dynamic>>> searchEverydayWords({
    required String query,
    int limit = 50,
    int minCommonalityScore = 60,
  }) async {
    try {
      final snapshot = await _db
          .collection('tamil_words')
          .where('is_everyday', isEqualTo: true)
          .limit(limit * 2) // Get more to filter
          .get();

      var words = snapshot.docs.map((doc) => doc.data()).toList();

      // Filter by search query
      words = words.where((word) {
        final wordText = (word['word'] as String? ?? '').toLowerCase();
        final meaning = (word['meaning'] as String? ?? '').toLowerCase();
        final queryLower = query.toLowerCase();
        return wordText.contains(queryLower) || meaning.contains(queryLower);
      }).toList();

      return _filterService.getFilteredWordsSortedByCommonality(
        words,
        minCommonalityScore: minCommonalityScore,
      );
    } catch (e) {
      print('Error searching everyday words: $e');
      return [];
    }
  }

  /// Get word with detailed information (meaning, example, pronunciation)
  Future<Map<String, dynamic>?> getWordDetails(String word) async {
    try {
      final snapshot = await _db
          .collection('tamil_words')
          .where('word', isEqualTo: word)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final wordData = snapshot.docs.first.data();

      // Check if it's an everyday word
      if (!_filterService.isCommonEverydayWord(word)) {
        print('Warning: "$word" is not a common everyday word');
      }

      return {
        'word': wordData['word'],
        'english_meaning': wordData['english_meaning'] ?? 'Not available',
        'tamil_meaning': _filterService._simplifyTamilMeaning(
          wordData['tamil_meaning'] as String?,
        ),
        'pronunciation': wordData['pronunciation'] ?? word,
        'example_tamil': wordData['example_tamil'] ?? 'Not available',
        'example_english': wordData['example_english'] ?? 'Not available',
        'category': wordData['category'] ?? 'General',
        'word_type': wordData['word_type'] ?? 'Noun',
        'commonality_score': _filterService.getCommonalityScore(word),
        'is_everyday_word': _filterService.isCommonEverydayWord(word),
        'recommendation': _filterService._getRecommendation(word),
      };
    } catch (e) {
      print('Error getting word details: $e');
      return null;
    }
  }

  /// Get daily word of the day (everyday word)
  Future<Map<String, dynamic>?> getDailyWord() async {
    try {
      final today = DateTime.now();
      final dateStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      final snapshot = await _db
          .collection('daily_words')
          .where('date', isEqualTo: dateStr)
          .where('is_everyday', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data();
      }

      // Fallback: get random everyday word
      final randomSnapshot = await _db
          .collection('tamil_words')
          .where('is_everyday', isEqualTo: true)
          .limit(100)
          .get();

      if (randomSnapshot.docs.isNotEmpty) {
        final random = randomSnapshot.docs[
            DateTime.now().millisecondsSinceEpoch % randomSnapshot.docs.length
        ];
        return random.data();
      }

      return null;
    } catch (e) {
      print('Error getting daily word: $e');
      return null;
    }
  }

  /// Get words by difficulty level (based on commonality)
  Future<List<Map<String, dynamic>>> getWordsByDifficulty({
    required String difficulty, // 'beginner', 'intermediate', 'advanced'
    int limit = 50,
  }) async {
    try {
      int minScore, maxScore;

      switch (difficulty.toLowerCase()) {
        case 'beginner':
          minScore = 80;
          maxScore = 100;
          break;
        case 'intermediate':
          minScore = 60;
          maxScore = 79;
          break;
        case 'advanced':
          minScore = 40;
          maxScore = 59;
          break;
        default:
          minScore = 60;
          maxScore = 100;
      }

      final snapshot = await _db
          .collection('tamil_words')
          .where('is_everyday', isEqualTo: true)
          .limit(limit * 2)
          .get();

      var words = snapshot.docs.map((doc) => doc.data()).toList();

      // Filter by difficulty
      words = words.where((word) {
        final score = _filterService.getCommonalityScore(word['word'] as String? ?? '');
        return score >= minScore && score <= maxScore;
      }).toList();

      return _filterService.getFilteredWordsSortedByCommonality(words);
    } catch (e) {
      print('Error getting words by difficulty: $e');
      return [];
    }
  }

  /// Get words for a specific topic (filtered for everyday use)
  Future<List<Map<String, dynamic>>> getWordsByTopic({
    required String topic, // 'family', 'food', 'animals', 'nature', etc.
    int limit = 50,
  }) async {
    try {
      final snapshot = await _db
          .collection('tamil_words')
          .where('topic', isEqualTo: topic)
          .where('is_everyday', isEqualTo: true)
          .limit(limit)
          .get();

      final words = snapshot.docs.map((doc) => doc.data()).toList();
      return _filterService.getFilteredWordsSortedByCommonality(words);
    } catch (e) {
      print('Error getting words by topic: $e');
      return [];
    }
  }

  /// Get words with examples (for learning)
  Future<List<Map<String, dynamic>>> getWordsWithExamples({
    int limit = 50,
    int minCommonalityScore = 60,
  }) async {
    try {
      final snapshot = await _db
          .collection('tamil_words')
          .where('is_everyday', isEqualTo: true)
          .where('has_example', isEqualTo: true)
          .limit(limit)
          .get();

      final words = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'tamil_meaning': _filterService._simplifyTamilMeaning(
            data['tamil_meaning'] as String?,
          ),
          'example': _filterService._simplifyExample(
            data['example'] as String?,
          ),
        };
      }).toList();

      return _filterService.getFilteredWordsSortedByCommonality(
        words,
        minCommonalityScore: minCommonalityScore,
      );
    } catch (e) {
      print('Error getting words with examples: $e');
      return [];
    }
  }

  /// Get commonly used verbs
  Future<List<Map<String, dynamic>>> getCommonVerbs({int limit = 50}) async {
    try {
      final snapshot = await _db
          .collection('tamil_words')
          .where('word_type', isEqualTo: 'Verb')
          .where('is_everyday', isEqualTo: true)
          .limit(limit)
          .get();

      final words = snapshot.docs.map((doc) => doc.data()).toList();
      return _filterService.getFilteredWordsSortedByCommonality(words);
    } catch (e) {
      print('Error getting common verbs: $e');
      return [];
    }
  }

  /// Get commonly used adjectives
  Future<List<Map<String, dynamic>>> getCommonAdjectives({int limit = 50}) async {
    try {
      final snapshot = await _db
          .collection('tamil_words')
          .where('word_type', isEqualTo: 'Adjective')
          .where('is_everyday', isEqualTo: true)
          .limit(limit)
          .get();

      final words = snapshot.docs.map((doc) => doc.data()).toList();
      return _filterService.getFilteredWordsSortedByCommonality(words);
    } catch (e) {
      print('Error getting common adjectives: $e');
      return [];
    }
  }

  /// Get commonly used nouns
  Future<List<Map<String, dynamic>>> getCommonNouns({int limit = 50}) async {
    try {
      final snapshot = await _db
          .collection('tamil_words')
          .where('word_type', isEqualTo: 'Noun')
          .where('is_everyday', isEqualTo: true)
          .limit(limit)
          .get();

      final words = snapshot.docs.map((doc) => doc.data()).toList();
      return _filterService.getFilteredWordsSortedByCommonality(words);
    } catch (e) {
      print('Error getting common nouns: $e');
      return [];
    }
  }

  /// Get words for conversation practice
  Future<List<Map<String, dynamic>>> getConversationWords({int limit = 50}) async {
    try {
      final snapshot = await _db
          .collection('tamil_words')
          .where('is_everyday', isEqualTo: true)
          .where('is_conversational', isEqualTo: true)
          .limit(limit)
          .get();

      final words = snapshot.docs.map((doc) => doc.data()).toList();
      return _filterService.getFilteredWordsSortedByCommonality(words);
    } catch (e) {
      print('Error getting conversation words: $e');
      return [];
    }
  }

  /// Analyze and filter words from external API
  Future<List<Map<String, dynamic>>> filterAndEnhanceAPIWords(
    List<Map<String, dynamic>> apiWords, {
    int minCommonalityScore = 60,
  }) async {
    try {
      // Filter for everyday words
      var filtered = _filterService.filterEverydayWords(
        apiWords,
        minCommonalityScore: minCommonalityScore,
      );

      // Enhance with simplified meanings and examples
      filtered = filtered.map((word) {
        return {
          ...word,
          'tamil_meaning': _filterService._simplifyTamilMeaning(
            word['tamil_meaning'] as String?,
          ),
          'example': _filterService._simplifyExample(
            word['example'] as String?,
          ),
          'commonality_score': _filterService.getCommonalityScore(
            word['word'] as String? ?? '',
          ),
          'recommendation': _filterService._getRecommendation(
            word['word'] as String? ?? '',
          ),
        };
      }).toList();

      // Sort by commonality
      filtered.sort((a, b) {
        final scoreA = a['commonality_score'] as int;
        final scoreB = b['commonality_score'] as int;
        return scoreB.compareTo(scoreA);
      });

      return filtered;
    } catch (e) {
      print('Error filtering and enhancing API words: $e');
      return [];
    }
  }

  /// Get statistics about word collection
  Future<Map<String, dynamic>> getWordStatistics() async {
    try {
      final totalSnapshot = await _db.collection('tamil_words').count().get();
      final everydaySnapshot = await _db
          .collection('tamil_words')
          .where('is_everyday', isEqualTo: true)
          .count()
          .get();

      return {
        'total_words': totalSnapshot.count,
        'everyday_words': everydaySnapshot.count,
        'percentage_everyday': (everydaySnapshot.count / (totalSnapshot.count + 1) * 100).toStringAsFixed(2),
      };
    } catch (e) {
      print('Error getting word statistics: $e');
      return {};
    }
  }

  /// Get recommended words for a learner level
  Future<List<Map<String, dynamic>>> getRecommendedWordsForLevel({
    required String level, // 'beginner', 'intermediate', 'advanced'
    int limit = 50,
  }) async {
    try {
      final words = await getWordsByDifficulty(
        difficulty: level,
        limit: limit,
      );

      // Add learning tips
      return words.map((word) {
        return {
          ...word,
          'learning_tip': _getLearningTip(word['word'] as String? ?? ''),
        };
      }).toList();
    } catch (e) {
      print('Error getting recommended words: $e');
      return [];
    }
  }

  /// Get learning tip for a word
  String _getLearningTip(String word) {
    if (_filterService.isCommonEverydayWord(word)) {
      return 'This is a very common word used in daily conversations.';
    } else if (_filterService.isLiteraryWord(word)) {
      return 'This word is more formal/literary. Use simpler alternatives in casual speech.';
    } else if (_filterService.isTechnicalWord(word)) {
      return 'This is a technical term. Learn it for specific contexts.';
    } else {
      return 'This word is less common. Focus on more frequently used words first.';
    }
  }
}
