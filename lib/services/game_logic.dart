import 'dart:math';
import '../constants/tamil_data.dart';

class GameLogic {
  static final Random _random = Random();

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
  static Map<String, dynamic> generateWordBuilderRound() {
    final categories = TamilData.wordCategories.values.toList();
    final words = categories[_random.nextInt(categories.length)];
    final wordData = words[_random.nextInt(words.length)];
    final word = wordData['tamil']!;
    final scrambled = word.split('')..shuffle();
    
    return {
      'word': word,
      'scrambled': scrambled,
      'english': wordData['english'],
      'emoji': wordData['emoji'],
    };
  }

  // Fill Blanks Game
  static Map<String, dynamic> generateFillBlanksRound() {
    final categories = TamilData.wordCategories.values.toList();
    final words = categories[_random.nextInt(categories.length)];
    final wordData = words[_random.nextInt(words.length)];
    final word = wordData['tamil']!;
    final blankIndex = _random.nextInt(word.length);
    final correctLetter = word[blankIndex];
    
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
  static List<Map<String, dynamic>> getQuizQuestions() {
    return TamilData.quizQuestions;
  }

  // Sentence Builder Game
  static Map<String, dynamic> generateSentenceBuilderRound() {
    final sentences = TamilData.sentences;
    final sentenceData = sentences[_random.nextInt(sentences.length)];
    
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
  static Map<String, dynamic> generatePronunciationRound() {
    final allWords = <Map<String, String>>[];
    TamilData.wordCategories.values.forEach((cat) => allWords.addAll(cat));
    
    final word = allWords[_random.nextInt(allWords.length)];
    
    return {
      'word': word['tamil'],
      'english': word['english'],
      'emoji': word['emoji'],
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
    if (word.length <= 2) return word;
    return word[0] + '*' * (word.length - 2) + word[word.length - 1];
  }

  // Sound Match Game
  static Map<String, dynamic> generateSoundMatchRound() {
    final allWords = <Map<String, String>>[];
    TamilData.wordCategories.values.forEach((cat) => allWords.addAll(cat));
    
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
  static Map<String, dynamic> generateWordSearchRound() {
    final categories = TamilData.wordCategories.values.toList();
    final words = categories[_random.nextInt(categories.length)];
    final selectedWords = <Map<String, String>>[];
    
    while (selectedWords.length < 5) {
      final word = words[_random.nextInt(words.length)];
      if (!selectedWords.any((w) => w['tamil'] == word['tamil'])) {
        selectedWords.add(word);
      }
    }
    
    return {
      'words': selectedWords,
      'gridSize': 8,
    };
  }

  // Word Scramble Game
  static Map<String, dynamic> generateWordScrambleRound() {
    final categories = TamilData.wordCategories.values.toList();
    final words = categories[_random.nextInt(categories.length)];
    final wordData = words[_random.nextInt(words.length)];
    final word = wordData['tamil']!;
    final scrambled = word.split('')..shuffle();
    
    return {
      'word': word,
      'scrambled': scrambled.join(''),
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
