import 'dart:math';
import 'package:characters/characters.dart';
import '../data/tamil_data.dart';

class GameLogic {
  static final Random _random = Random();

  static final List<String> _recentlyShownQuestions = [];
  static const int _maxRepetitionHistory = 50;

  static void trackShown(String id) {
    _recentlyShownQuestions.add(id);
    if (_recentlyShownQuestions.length > _maxRepetitionHistory) {
      _recentlyShownQuestions.removeAt(0);
    }
  }

  static bool isRecentlyShown(String id) {
    return _recentlyShownQuestions.contains(id);
  }

  // Filter list by difficulty and anti-repetition
  static List<T> _filterContent<T extends Map<String, dynamic>>(
    List<T> source,
    String? difficulty,
  ) {
    var filtered = source.where((item) {
      final id = item['id'] as String?;
      if (id != null && isRecentlyShown(id)) return false;
      if (difficulty != null && difficulty != 'Any' && difficulty.isNotEmpty) {
        final diff = item['difficulty'] as String?;
        if (diff != difficulty) return false;
      }
      return true;
    }).toList();

    // Fallback if everything is filtered out
    if (filtered.isEmpty) {
      filtered = source.where((item) {
        if (difficulty != null && difficulty != 'Any' && difficulty.isNotEmpty) {
          final diff = item['difficulty'] as String?;
          if (diff != difficulty) return false;
        }
        return true;
      }).toList();
    }

    if (filtered.isEmpty) {
      filtered = List<T>.from(source);
    }
    return filtered;
  }

  // Letter Hunt Game
  static Map<String, dynamic> generateLetterHuntRound() {
    final targetLetter = TamilData.uyirEzhuthukkal[_random.nextInt(TamilData.uyirEzhuthukkal.length)];
    final options = [targetLetter];
    
    while (options.length < 6) {
      final letter = TamilData.uyirEzhuthukkal[_random.nextInt(TamilData.uyirEzhuthukkal.length)];
      if (!options.contains(letter)) options.add(letter);
    }
    options.shuffle();
    
    return {
      'targetLetter': targetLetter,
      'options': options,
      'correctIndex': options.indexOf(targetLetter),
    };
  }

  // Word Builder Game
  static Map<String, dynamic> generateWordBuilderRound({String? difficulty}) {
    final pool = _filterContent(TamilData.masterWords.isEmpty ? [
      {'tamil': 'நாய்', 'english': 'Dog', 'emoji': '🐕', 'id': 'fallback_1', 'difficulty': 'Easy'}
    ] : TamilData.masterWords, difficulty);
    
    final wordData = pool[_random.nextInt(pool.length)];
    final id = wordData['id'] as String?;
    if (id != null) trackShown(id);
    
    final word = wordData['tamil']!;
    final scrambled = word.characters.toList()..shuffle();
    
    return {
      'word': word,
      'scrambled': scrambled,
      'english': wordData['english'],
      'emoji': wordData['emoji'],
    };
  }

  // Fill Blanks Game
  static Map<String, dynamic> generateFillBlanksRound({String? difficulty}) {
    final pool = _filterContent(TamilData.masterWords.isEmpty ? [
      {'tamil': 'நாய்', 'english': 'Dog', 'emoji': '🐕', 'id': 'fallback_1', 'difficulty': 'Easy'}
    ] : TamilData.masterWords, difficulty);
    
    final wordData = pool[_random.nextInt(pool.length)];
    final id = wordData['id'] as String?;
    if (id != null) trackShown(id);
    
    final word = wordData['tamil']!;
    final wordChars = word.characters.toList();
    int blankIndex = _random.nextInt(wordChars.length);
    if (wordChars[blankIndex] == ' ') {
      blankIndex = ((blankIndex + 1) % wordChars.length).toInt();
    }
    final correctLetter = wordChars[blankIndex];
    
    final options = [correctLetter];
    while (options.length < 4) {
      final letter = TamilData.uyirEzhuthukkal[_random.nextInt(TamilData.uyirEzhuthukkal.length)];
      if (!options.contains(letter)) options.add(letter);
    }
    options.shuffle();
    
    return {
      'word': word,
      'blankIndex': blankIndex,
      'options': options,
      'correctLetter': correctLetter,
      'english': wordData['english'],
    };
  }

  // Memory Match Game
  static Map<String, dynamic> generateMemoryGame({int pairs = 6}) {
    final letters = TamilData.uyirEzhuthukkal.take(pairs).toList();
    final cards = [...letters, ...letters];
    cards.shuffle();
    
    return {
      'cards': cards,
      'totalPairs': pairs,
    };
  }

  // Quiz Game
  static List<Map<String, dynamic>> getQuizQuestions({String? difficulty}) {
    return _filterContent(TamilData.quizQuestions, difficulty);
  }

  // Sentence Builder Game
  static Map<String, dynamic> generateSentenceBuilderRound({String? difficulty}) {
    final pool = _filterContent(TamilData.sentences, difficulty);
    final sentenceData = pool[_random.nextInt(pool.length)];
    final id = sentenceData['id'] as String?;
    if (id != null) trackShown(id);
    
    final words = List<String>.from(sentenceData['tamil'] as List);
    final correctSentence = words.join(' ');
    final scrambledWords = List<String>.from(words)..shuffle();
    
    return {
      'correctSentence': correctSentence,
      'english': sentenceData['english'],
      'words': scrambledWords,
      'correctOrder': words,
    };
  }

  // Pronunciation Practice
  static Map<String, dynamic> generatePronunciationRound({String? difficulty}) {
    final pool = _filterContent(TamilData.masterWords.isEmpty ? [
      {'tamil': 'நாய்', 'english': 'Dog', 'emoji': '🐕', 'id': 'fallback_1', 'difficulty': 'Easy'}
    ] : TamilData.masterWords, difficulty);
    
    final wordData = pool[_random.nextInt(pool.length)];
    final id = wordData['id'] as String?;
    if (id != null) trackShown(id);
    
    return {
      'word': wordData['tamil'],
      'english': wordData['english'],
      'emoji': wordData['emoji'],
    };
  }

  // Calculate score based on performance
  static int calculateScore({
    required int correctAnswers,
    required int totalQuestions,
    required int timeSpent,
    int maxTime = 300,
  }) {
    final accuracy = (correctAnswers / totalQuestions) * 100;
    final speedBonus = ((maxTime - timeSpent) / maxTime) * 20;
    final baseScore = (accuracy / 100) * 100;
    
    return (baseScore + speedBonus).toInt().clamp(0, 100);
  }

  // Check if answer is correct
  static bool checkAnswer({
    required String userAnswer,
    required String correctAnswer,
  }) {
    return userAnswer.trim().toLowerCase() == correctAnswer.trim().toLowerCase();
  }

  // Get achievement based on score
  static String? getAchievement(int score) {
    if (score >= 90) return 'Perfect Score';
    if (score >= 80) return 'Great Job';
    if (score >= 70) return 'Good Work';
    if (score >= 60) return 'Keep Trying';
    return null;
  }

  // Generate random difficulty
  static String getRandomDifficulty() {
    final difficulties = ['Easy', 'Medium', 'Hard'];
    return difficulties[_random.nextInt(difficulties.length)];
  }

  // Validate Tamil text
  static bool isValidTamilText(String text) {
    final tamilRegex = RegExp(r'[\u0B80-\u0BFF]+');
    return tamilRegex.hasMatch(text);
  }

  // Get hint for current question
  static String getHint(String word) {
    final wordChars = word.characters.toList();
    if (wordChars.length <= 2) return word;
    return wordChars.first + '*' * (wordChars.length - 2) + wordChars.last;
  }

  // Sound Match Game
  static Map<String, dynamic> generateSoundMatchRound() {
    final allWords = <Map<String, String>>[];
    for (var cat in TamilData.wordCategories.values) {
      allWords.addAll(cat);
    }
    
    final correctWord = allWords[_random.nextInt(allWords.length)];
    final options = [correctWord];
    
    while (options.length < 4) {
      final word = allWords[_random.nextInt(allWords.length)];
      if (!options.any((w) => w['tamil'] == word['tamil'])) {
        options.add(word);
      }
    }
    options.shuffle();
    
    return {
      'correctWord': correctWord['tamil'],
      'options': options.map((w) => w['tamil']).toList(),
      'english': correctWord['english'],
      'emoji': correctWord['emoji'],
      'correctIndex': options.indexWhere((w) => w['tamil'] == correctWord['tamil']),
    };
  }

  // Word Search Game
  static Map<String, dynamic> generateWordSearchRound({String? difficulty}) {
    final pool = _filterContent(TamilData.masterWords.isEmpty ? [
      {'tamil': 'நாய்', 'english': 'Dog', 'emoji': '🐕', 'id': 'fallback_1', 'difficulty': 'Easy'}
    ] : TamilData.masterWords, difficulty);

    int count = 5;
    int size = 8;
    if (difficulty == 'Easy') {
      count = 3;
      size = 6;
    } else if (difficulty == 'Medium') {
      count = 4;
      size = 8;
    } else if (difficulty == 'Hard') {
      count = 5;
      size = 9;
    } else if (difficulty == 'Expert') {
      count = 6;
      size = 10;
    }

    final selectedWords = <Map<String, dynamic>>[];
    final maxAttempts = 100;
    int attempts = 0;
    while (selectedWords.length < count && attempts < maxAttempts) {
      final word = pool[_random.nextInt(pool.length)];
      if (!selectedWords.any((w) => w['tamil'] == word['tamil'])) {
        selectedWords.add(word);
      }
      attempts++;
    }

    if (selectedWords.isEmpty) {
      selectedWords.add({'tamil': 'நாய்', 'english': 'Dog'});
    }

    return {
      'words': selectedWords,
      'gridSize': size,
    };
  }

  // Word Scramble Game
  static Map<String, dynamic> generateWordScrambleRound({String? difficulty}) {
    final pool = _filterContent(TamilData.masterWords.isEmpty ? [
      {'tamil': 'நாய்', 'english': 'Dog', 'emoji': '🐕', 'id': 'fallback_1', 'difficulty': 'Easy'}
    ] : TamilData.masterWords, difficulty);
    
    final wordData = pool[_random.nextInt(pool.length)];
    final id = wordData['id'] as String?;
    if (id != null) trackShown(id);
    
    final word = wordData['tamil']!;
    final scrambled = word.characters.toList()..shuffle();
    
    return {
      'word': word,
      'scrambled': scrambled,
      'english': wordData['english'],
      'emoji': wordData['emoji'],
      'hint': getHint(word),
    };
  }

  // Letter Hunt Game with difficulty
  static Map<String, dynamic> generateLetterHuntRoundWithDifficulty(String difficulty) {
    List<String> letterPool;
    
    if (difficulty == 'Easy') {
      letterPool = TamilData.uyirEzhuthukkal;
    } else if (difficulty == 'Medium') {
      letterPool = [...TamilData.uyirEzhuthukkal, ...TamilData.meiEzhuthukkal];
    } else {
      letterPool = [...TamilData.uyirEzhuthukkal, ...TamilData.meiEzhuthukkal, ...TamilData.aayudhaEzhuthu];
    }
    
    final targetLetter = letterPool[_random.nextInt(letterPool.length)];
    final options = [targetLetter];
    
    while (options.length < 6) {
      final letter = letterPool[_random.nextInt(letterPool.length)];
      if (!options.contains(letter)) options.add(letter);
    }
    options.shuffle();
    
    return {
      'targetLetter': targetLetter,
      'options': options,
      'correctIndex': options.indexOf(targetLetter),
      'difficulty': difficulty,
    };
  }

  // Calculate streak bonus
  static int getStreakBonus(int streakDays) {
    if (streakDays >= 30) return 50;
    if (streakDays >= 7) return 25;
    if (streakDays >= 3) return 10;
    return 0;
  }

  // Get level from XP
  static int getLevelFromXP(int xp) {
    return (xp ~/ 100) + 1;
  }

  // Get next level XP requirement
  static int getNextLevelXP(int currentLevel) {
    return currentLevel * 100;
  }
}
