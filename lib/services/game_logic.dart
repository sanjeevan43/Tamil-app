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
}
