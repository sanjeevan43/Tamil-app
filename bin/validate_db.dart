import 'dart:convert';
import 'dart:io';

void main() {
  print('Starting database validation...');

  bool hasErrors = false;

  void reportError(String message) {
    print('❌ ERROR: $message');
    hasErrors = true;
  }

  // Helper to check valid Tamil range (includes standard Tamil blocks)
  bool isTamilText(String text) {
    final regex = RegExp(r'[\u0B80-\u0BFF\s]+');
    return regex.hasMatch(text);
  }

  // 1. Validate words.json
  final wordsFile = File('assets/data/words.json');
  if (!wordsFile.existsSync()) {
    reportError('words.json does not exist');
  } else {
    try {
      final List<dynamic> list = jsonDecode(wordsFile.readAsStringSync());
      print('✓ words.json loaded: ${list.length} items');

      if (list.length < 1000) {
        reportError('words.json must contain at least 1000 items (found ${list.length})');
      }

      final ids = <String>{};
      final tamilWords = <String>{};

      for (var item in list) {
        final id = item['id'];
        final tamil = item['tamil'];
        final english = item['english'];
        final category = item['category'];
        final difficulty = item['difficulty'];

        if (id == null || !ids.add(id)) {
          reportError('words.json has duplicate or null ID: $id');
        }

        if (tamil == null || tamil.toString().isEmpty) {
          reportError('words.json item $id has empty tamil word');
        } else if (!tamilWords.add(tamil.toString())) {
          reportError('words.json has duplicate tamil word: "$tamil"');
        }

        if (english == null || english.toString().isEmpty) {
          reportError('words.json item $id has empty english translation');
        }

        if (category == null || category.toString().isEmpty) {
          reportError('words.json item $id has empty category');
        }

        if (difficulty == null || !['Easy', 'Medium', 'Hard', 'Expert'].contains(difficulty)) {
          reportError('words.json item $id has invalid difficulty: $difficulty');
        }
      }
    } catch (e) {
      reportError('Failed to parse words.json: $e');
    }
  }

  // 2. Validate sentences.json
  final sentencesFile = File('assets/data/sentences.json');
  if (!sentencesFile.existsSync()) {
    reportError('sentences.json does not exist');
  } else {
    try {
      final List<dynamic> list = jsonDecode(sentencesFile.readAsStringSync());
      print('✓ sentences.json loaded: ${list.length} items');

      if (list.length < 750) {
        reportError('sentences.json must contain at least 750 items (found ${list.length})');
      }

      final ids = <String>{};
      for (var item in list) {
        final id = item['id'];
        final tamil = item['tamil'];
        final english = item['english'];
        final hint = item['hint'];
        final difficulty = item['difficulty'];

        if (id == null || !ids.add(id)) {
          reportError('sentences.json has duplicate or null ID: $id');
        }

        if (tamil == null || tamil is! List || tamil.isEmpty) {
          reportError('sentences.json item $id has empty or invalid tamil tokens');
        }

        if (english == null || english.toString().isEmpty) {
          reportError('sentences.json item $id has empty english meaning');
        }

        if (hint == null || hint.toString().isEmpty) {
          reportError('sentences.json item $id has empty hint');
        }

        if (difficulty == null || !['Easy', 'Medium', 'Hard', 'Expert'].contains(difficulty)) {
          reportError('sentences.json item $id has invalid difficulty: $difficulty');
        }
      }
    } catch (e) {
      reportError('Failed to parse sentences.json: $e');
    }
  }

  // 3. Validate quiz_questions.json
  final quizFile = File('assets/data/quiz_questions.json');
  if (!quizFile.existsSync()) {
    reportError('quiz_questions.json does not exist');
  } else {
    try {
      final List<dynamic> list = jsonDecode(quizFile.readAsStringSync());
      print('✓ quiz_questions.json loaded: ${list.length} items');

      if (list.length < 1000) {
        reportError('quiz_questions.json must contain at least 1000 items (found ${list.length})');
      }

      final ids = <String>{};
      for (var item in list) {
        final id = item['id'];
        final question = item['question'];
        final options = item['options'];
        final correct = item['correct'];
        final category = item['category'];
        final difficulty = item['difficulty'];

        if (id == null || !ids.add(id)) {
          reportError('quiz_questions.json has duplicate or null ID: $id');
        }

        if (question == null || question.toString().isEmpty) {
          reportError('quiz_questions.json item $id has empty question');
        }

        if (options == null || options is! List || options.length < 2) {
          reportError('quiz_questions.json item $id has insufficient options');
        } else {
          if (correct == null || correct is! int || correct < 0 || correct >= options.length) {
            reportError('quiz_questions.json item $id has invalid correct index: $correct');
          }
        }

        if (category == null || category.toString().isEmpty) {
          reportError('quiz_questions.json item $id has empty category');
        }

        if (difficulty == null || !['Easy', 'Medium', 'Hard', 'Expert'].contains(difficulty)) {
          reportError('quiz_questions.json item $id has invalid difficulty: $difficulty');
        }
      }
    } catch (e) {
      reportError('Failed to parse quiz_questions.json: $e');
    }
  }

  // 4. Validate fill_blanks.json
  final fillFile = File('assets/data/fill_blanks.json');
  if (!fillFile.existsSync()) {
    reportError('fill_blanks.json does not exist');
  } else {
    try {
      final List<dynamic> list = jsonDecode(fillFile.readAsStringSync());
      print('✓ fill_blanks.json loaded: ${list.length} items');

      if (list.length < 750) {
        reportError('fill_blanks.json must contain at least 750 items (found ${list.length})');
      }

      final ids = <String>{};
      for (var item in list) {
        final id = item['id'];
        final prompt = item['prompt'];
        final display = item['display'];
        final options = item['options'];
        final correct = item['correct'];
        final word = item['word'];
        final difficulty = item['difficulty'];

        if (id == null || !ids.add(id)) {
          reportError('fill_blanks.json has duplicate or null ID: $id');
        }

        if (prompt == null || prompt.toString().isEmpty) {
          reportError('fill_blanks.json item $id has empty prompt');
        }

        if (display == null || !display.toString().contains('___')) {
          reportError('fill_blanks.json item $id display string does not contain blank pattern: "$display"');
        }

        if (options == null || options is! List || !options.contains(correct)) {
          reportError('fill_blanks.json item $id options do not contain the correct letter');
        }

        if (word == null || word.toString().isEmpty) {
          reportError('fill_blanks.json item $id has empty word');
        }

        if (difficulty == null || !['Easy', 'Medium', 'Hard', 'Expert'].contains(difficulty)) {
          reportError('fill_blanks.json item $id has invalid difficulty: $difficulty');
        }
      }
    } catch (e) {
      reportError('Failed to parse fill_blanks.json: $e');
    }
  }

  if (hasErrors) {
    print('❌ VALIDATION FAILED!');
    exit(1);
  } else {
    print('🎉 DATABASE VALIDATION PASSED SUCCESSFULLY! ALL ASSETS ARE PRODUCTION READY.');
  }
}
