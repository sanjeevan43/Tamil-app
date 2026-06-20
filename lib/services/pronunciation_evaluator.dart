import 'dart:math';
import 'package:characters/characters.dart';

class PronunciationEvaluator {
  // Helper to calculate Levenshtein Distance
  static int _getLevenshteinDistance(List<String> s, List<String> t) {
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.filled(t.length + 1, 0);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < v0.length; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = min(min(v1[j] + 1, v0[j + 1] + 1), v0[j] + cost);
      }

      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }

    return v0[t.length];
  }

  // Normalizes text by removing punctuation and excess spacing
  static String normalize(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[.,\/#!$%\^&\*;:{}=\-_`~()??"“’‘]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  // Compares expected text with recognized spoken text
  static Map<String, dynamic> evaluate(String expected, String recognized) {
    final normExpected = normalize(expected);
    final normRecognized = normalize(recognized);

    if (normExpected.isEmpty) {
      return {
        'matchPercentage': 0.0,
        'isCorrect': false,
        'feedback': 'Expected word is empty.',
      };
    }

    if (normRecognized.isEmpty) {
      return {
        'matchPercentage': 0.0,
        'isCorrect': false,
        'feedback': 'No speech recognized. Try speaking louder or closer to the microphone.',
      };
    }

    final expChars = normExpected.characters.toList();
    final recChars = normRecognized.characters.toList();

    final distance = _getLevenshteinDistance(expChars, recChars);
    final maxLength = max(expChars.length, recChars.length);

    double similarity = (1.0 - (distance / maxLength)) * 100;
    
    // Threshold set at 70% to handle accent/recording noise variations comfortably
    bool isCorrect = similarity >= 70.0;
    
    String feedback = '';
    if (similarity >= 90.0) {
      feedback = 'அற்புதம்! Perfect pronunciation!';
    } else if (similarity >= 70.0) {
      feedback = 'மிக நன்று! Good pronunciation with minor variations.';
    } else if (similarity >= 45.0) {
      feedback = 'நன்று, ஆனால் உச்சரிப்பை இன்னும் மேம்படுத்தலாம். Focus on each letter sound.';
    } else {
      feedback = 'மீண்டும் முயற்சிக்கவும். Listen to the guide and try speaking clearly.';
    }

    return {
      'matchPercentage': similarity.clamp(0.0, 100.0),
      'isCorrect': isCorrect,
      'feedback': feedback,
    };
  }
}
