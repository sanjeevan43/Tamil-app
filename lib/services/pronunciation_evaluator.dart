import 'dart:math';

class PronunciationResult {
  final String recognizedText;
  final String expectedText;
  final double matchPercentage;
  final bool isCorrect;
  final String suggestion;

  PronunciationResult({
    required this.recognizedText,
    required this.expectedText,
    required this.matchPercentage,
    required this.isCorrect,
    required this.suggestion,
  });
}

class PronunciationEvaluator {
  /// Cleans the string from punctuation, leading/trailing whitespaces,
  /// and normalizes Tamil Unicode characters where applicable.
  static String cleanText(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[.,\/#!$%\^&\*;:{}=\-_`~()?\"!]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Calculates the Levenshtein distance between two strings.
  static int levenshteinDistance(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.generate(t.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = min(v0[j + 1] + 1, min(v1[j] + 1, v0[j] + cost));
      }
      v0 = List<int>.from(v1);
    }
    return v0[t.length];
  }

  /// Calculates a similarity percentage between recognized and expected text.
  static double calculateSimilarity(String recognized, String expected) {
    final cleanRecognized = cleanText(recognized);
    final cleanExpected = cleanText(expected);

    if (cleanRecognized == cleanExpected) return 100.0;
    if (cleanRecognized.isEmpty || cleanExpected.isEmpty) return 0.0;

    // Use Levenshtein distance to find similarity
    final dist = levenshteinDistance(cleanRecognized, cleanExpected);
    final maxLength = max(cleanRecognized.length, cleanExpected.length);
    final similarity = (1.0 - (dist / maxLength)) * 100.0;
    return similarity;
  }

  /// Evaluates the pronunciation and returns detailed feedback.
  static PronunciationResult evaluate({
    required String recognized,
    required String expected,
    double passingScore = 65.0,
  }) {
    final similarity = calculateSimilarity(recognized, expected);
    final isCorrect = similarity >= passingScore;

    String suggestion = '';
    if (!isCorrect) {
      if (recognized.trim().isEmpty) {
        suggestion = 'No voice detected. Please speak clearly into the microphone (மைக் அருகில் பேசவும்).';
      } else {
        suggestion = 'Try breaking the word down letter by letter and listen to the pronunciation sample again (உச்சரிப்பைக் கேட்டு மீண்டும் முயற்சிக்கவும்).';
      }
    } else {
      if (similarity < 90.0) {
        suggestion = 'Good job! A minor variation was detected, but overall correct (மிகவும் நன்று!).';
      } else {
        suggestion = 'Perfect pronunciation! Keep it up (அற்புதம்!).';
      }
    }

    return PronunciationResult(
      recognizedText: recognized,
      expectedText: expected,
      matchPercentage: similarity,
      isCorrect: isCorrect,
      suggestion: suggestion,
    );
  }
}
