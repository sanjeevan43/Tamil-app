import 'dart:math';
import 'package:characters/characters.dart';
import '../constants/tamil_data.dart';

class LevelGameData {
  static final _random = Random();

  /// Generate rounds for a specific game type
  static List<Map<String, dynamic>> generateRounds(String gameType, int count) {
    switch (gameType) {
      case 'tap_correct':
        return _generateTapCorrectRounds(count);
      case 'listen_choose':
        return _generateListenChooseRounds(count);
      case 'match_pairs':
        return _generateMatchPairsRound();
      case 'drag_drop':
        return _generateDragDropRounds(count);
      case 'arrange_letters':
        return _generateArrangeLettersRounds(count);
      case 'match_word_picture':
        return _generateWordPictureRounds(count);
      case 'find_correct':
        return _generateFindCorrectRounds(count);
      case 'pronounce':
        return _generatePronounceRounds(count);
      case 'fill_blank':
        return _generateFillBlankRounds(count);
      case 'puzzle':
        return _generateWordPuzzleRounds(count);
      case 'listen_write':
        return _generateListenWriteRounds(count);
      case 'memory_match':
        return _generateMemoryMatchRound();
      case 'arrange_words':
        return _generateArrangeWordsRounds(count);
      case 'choose_correct':
        return _generateChooseCorrectRounds(count);
      case 'fill_word':
        return _generateFillWordRounds(count);
      case 'read_aloud':
        return _generateReadAloudRounds(count);
      case 'read_paragraph':
        return _generateReadParagraphRounds(count);
      case 'comprehension':
        return _generateComprehensionRounds(count);
      case 'listening':
        return _generateListeningRounds(count);
      case 'story_read':
        return _generateStoryReadRounds(count);
      default:
        return _generateTapCorrectRounds(count);
    }
  }

  // Level 1: Tap the correct Tamil letter
  static List<Map<String, dynamic>> _generateTapCorrectRounds(int count) {
    final vowels = List<String>.from(TamilData.uyirEzhuthukkal);
    vowels.shuffle(_random);
    return List.generate(min(count, vowels.length), (i) {
      final correct = vowels[i];
      final options = [correct];
      final others = vowels.where((v) => v != correct).toList()..shuffle(_random);
      options.addAll(others.take(3));
      options.shuffle(_random);
      return {
        'type': 'multiple_choice',
        'prompt': 'Which letter is "$correct"?',
        'tamilPrompt': '"$correct" என்ற எழுத்தைத் தேர்ந்தெடுக்கவும்',
        'options': options,
        'correct': correct,
        'displayLetter': correct,
      };
    });
  }

  // Level 2: Listen and choose letter
  static List<Map<String, dynamic>> _generateListenChooseRounds(int count) {
    final vowels = List<String>.from(TamilData.uyirEzhuthukkal);
    vowels.shuffle(_random);
    return List.generate(min(count, vowels.length), (i) {
      final correct = vowels[i];
      final options = [correct];
      final others = vowels.where((v) => v != correct).toList()..shuffle(_random);
      options.addAll(others.take(3));
      options.shuffle(_random);
      return {
        'type': 'listen_choose',
        'prompt': 'Listen and tap the correct letter',
        'tamilPrompt': 'கேட்டு சரியான எழுத்தைத் தட்டவும்',
        'audioText': correct,
        'options': options,
        'correct': correct,
      };
    });
  }

  // Level 3: Match pairs
  static List<Map<String, dynamic>> _generateMatchPairsRound() {
    final vowels = List<String>.from(TamilData.uyirEzhuthukkal);
    vowels.shuffle(_random);
    final selected = vowels.take(6).toList();
    final pairs = <Map<String, String>>[];
    for (var letter in selected) {
      pairs.add({'id': letter, 'text': letter, 'type': 'a'});
      pairs.add({'id': letter, 'text': letter, 'type': 'b'});
    }
    pairs.shuffle(_random);
    return [
      {
        'type': 'match_pairs',
        'prompt': 'Match the same letters',
        'tamilPrompt': 'ஒரே எழுத்துக்களை பொருத்தவும்',
        'pairs': pairs,
        'totalPairs': selected.length,
      }
    ];
  }

  // Level 4: Drag letter to image (simplified as matching)
  static List<Map<String, dynamic>> _generateDragDropRounds(int count) {
    final categories = ['Animals', 'Fruits', 'Colors'];
    final rounds = <Map<String, dynamic>>[];
    for (var cat in categories) {
      final items = TamilData.wordCategories[cat]!;
      for (var item in items.take(2)) {
        final word = item['tamil']!;
        final firstLetter = word.characters.first;
        final options = [firstLetter];
        final others = TamilData.uyirEzhuthukkal.where((l) => l != firstLetter).toList()..shuffle(_random);
        options.addAll(others.take(3));
        options.shuffle(_random);
        rounds.add({
          'type': 'multiple_choice',
          'prompt': 'What letter does "${item['emoji']}" start with?',
          'tamilPrompt': '"${item['emoji']}" எந்த எழுத்தில் தொடங்கும்?',
          'options': options,
          'correct': firstLetter,
          'displayEmoji': item['emoji'],
        });
      }
    }
    rounds.shuffle(_random);
    return rounds.take(count).toList();
  }

  // Level 5: Arrange letters to form a word
  static List<Map<String, dynamic>> _generateArrangeLettersRounds(int count) {
    final simpleWords = [
      {'tamil': 'அம்மா', 'english': 'Mother'},
      {'tamil': 'அப்பா', 'english': 'Father'},
      {'tamil': 'நாய்', 'english': 'Dog'},
      {'tamil': 'பூனை', 'english': 'Cat'},
      {'tamil': 'மீன்', 'english': 'Fish'},
      {'tamil': 'காது', 'english': 'Ear'},
      {'tamil': 'கண்', 'english': 'Eye'},
      {'tamil': 'வாய்', 'english': 'Mouth'},
    ];
    simpleWords.shuffle(_random);
    return List.generate(min(count, simpleWords.length), (i) {
      final word = simpleWords[i]['tamil']!;
      final letters = word.characters.toList();
      final scrambled = List<String>.from(letters)..shuffle(_random);
      // Ensure scrambled is different from original
      if (scrambled.join() == letters.join()) {
        if (scrambled.length > 1) {
          final temp = scrambled[0];
          scrambled[0] = scrambled[1];
          scrambled[1] = temp;
        }
      }
      return {
        'type': 'arrange',
        'prompt': 'Arrange: ${simpleWords[i]['english']}',
        'tamilPrompt': 'எழுத்துக்களை வரிசைப்படுத்தவும்',
        'scrambled': scrambled,
        'correct': letters,
        'word': word,
        'hint': simpleWords[i]['english'],
      };
    });
  }

  // Level 6: Match word with picture
  static List<Map<String, dynamic>> _generateWordPictureRounds(int count) {
    final allWords = <Map<String, String>>[];
    TamilData.wordCategories.forEach((cat, items) {
      allWords.addAll(items);
    });
    allWords.shuffle(_random);
    return List.generate(min(count, allWords.length), (i) {
      final correct = allWords[i];
      final options = [correct['tamil']!];
      final others = allWords.where((w) => w['tamil'] != correct['tamil']).toList()..shuffle(_random);
      options.addAll(others.take(3).map((w) => w['tamil']!));
      options.shuffle(_random);
      return {
        'type': 'multiple_choice',
        'prompt': 'Which word matches ${correct['emoji']}?',
        'tamilPrompt': '${correct['emoji']} - சரியான சொல்லைத் தேர்ந்தெடுக்கவும்',
        'options': options,
        'correct': correct['tamil'],
        'displayEmoji': correct['emoji'],
      };
    });
  }

  // Level 7: Find the correct Tamil word
  static List<Map<String, dynamic>> _generateFindCorrectRounds(int count) {
    final allWords = <Map<String, String>>[];
    TamilData.wordCategories.forEach((cat, items) {
      allWords.addAll(items);
    });
    allWords.shuffle(_random);
    return List.generate(min(count, allWords.length), (i) {
      final correct = allWords[i];
      final options = [correct['tamil']!];
      final others = allWords.where((w) => w['tamil'] != correct['tamil']).toList()..shuffle(_random);
      options.addAll(others.take(3).map((w) => w['tamil']!));
      options.shuffle(_random);
      return {
        'type': 'multiple_choice',
        'prompt': 'Find the Tamil word for "${correct['english']}"',
        'tamilPrompt': '"${correct['english']}" என்பதின் தமிழ் சொல்?',
        'options': options,
        'correct': correct['tamil'],
      };
    });
  }

  // Level 8: Pronounce word
  static List<Map<String, dynamic>> _generatePronounceRounds(int count) {
    final allWords = <Map<String, String>>[];
    TamilData.wordCategories.forEach((cat, items) {
      allWords.addAll(items);
    });
    allWords.shuffle(_random);
    return List.generate(min(count, allWords.length), (i) {
      return {
        'type': 'listen_speak',
        'prompt': 'Listen and repeat this word',
        'tamilPrompt': 'கேட்டு சொல்லவும்',
        'word': allWords[i]['tamil'],
        'english': allWords[i]['english'],
        'emoji': allWords[i]['emoji'],
      };
    });
  }

  // Level 9: Fill missing letter
  static List<Map<String, dynamic>> _generateFillBlankRounds(int count) {
    final words = [
      {'tamil': 'நாய்', 'english': 'Dog'},
      {'tamil': 'பூனை', 'english': 'Cat'},
      {'tamil': 'மீன்', 'english': 'Fish'},
      {'tamil': 'அம்மா', 'english': 'Mother'},
      {'tamil': 'அப்பா', 'english': 'Father'},
      {'tamil': 'காது', 'english': 'Ear'},
      {'tamil': 'வாய்', 'english': 'Mouth'},
      {'tamil': 'நிலா', 'english': 'Moon'},
    ];
    words.shuffle(_random);
    return List.generate(min(count, words.length), (i) {
      final word = words[i]['tamil']!;
      final chars = word.characters.toList();
      if (chars.length < 2) return _generateTapCorrectRounds(1).first;
      final blankIndex = _random.nextInt(chars.length);
      final correctLetter = chars[blankIndex];
      final display = List<String>.from(chars);
      display[blankIndex] = '___';

      final options = [correctLetter];
      final others = TamilData.uyirEzhuthukkal.where((l) => l != correctLetter).toList()..shuffle(_random);
      options.addAll(others.take(3));
      options.shuffle(_random);

      return {
        'type': 'fill_blank',
        'prompt': 'Fill the missing letter: ${words[i]['english']}',
        'tamilPrompt': 'விடுபட்ட எழுத்தை நிரப்பவும்',
        'display': display.join(''),
        'options': options,
        'correct': correctLetter,
        'word': word,
      };
    });
  }

  // Level 10: Word puzzle
  static List<Map<String, dynamic>> _generateWordPuzzleRounds(int count) {
    return _generateArrangeLettersRounds(count);
  }

  // Level 11: Listen and write
  static List<Map<String, dynamic>> _generateListenWriteRounds(int count) {
    final words = <Map<String, String>>[];
    TamilData.wordCategories.forEach((cat, items) {
      words.addAll(items);
    });
    words.shuffle(_random);
    return List.generate(min(count, words.length), (i) {
      final correct = words[i];
      final options = [correct['tamil']!];
      final others = words.where((w) => w['tamil'] != correct['tamil']).toList()..shuffle(_random);
      options.addAll(others.take(3).map((w) => w['tamil']!));
      options.shuffle(_random);
      return {
        'type': 'listen_choose',
        'prompt': 'Listen and choose the word you hear',
        'tamilPrompt': 'கேட்டு சரியான சொல்லைத் தேர்ந்தெடுக்கவும்',
        'audioText': correct['tamil'],
        'options': options,
        'correct': correct['tamil'],
      };
    });
  }

  // Level 12: Memory match
  static List<Map<String, dynamic>> _generateMemoryMatchRound() {
    final allWords = <Map<String, String>>[];
    TamilData.wordCategories.forEach((cat, items) {
      allWords.addAll(items);
    });
    allWords.shuffle(_random);
    final selected = allWords.take(6).toList();
    final pairs = <Map<String, String>>[];
    for (var word in selected) {
      pairs.add({'id': word['tamil']!, 'text': word['tamil']!, 'type': 'tamil'});
      pairs.add({'id': word['tamil']!, 'text': word['emoji']!, 'type': 'emoji'});
    }
    pairs.shuffle(_random);
    return [
      {
        'type': 'match_pairs',
        'prompt': 'Match Tamil words with pictures',
        'tamilPrompt': 'தமிழ் சொற்களை படங்களுடன் பொருத்தவும்',
        'pairs': pairs,
        'totalPairs': selected.length,
      }
    ];
  }

  // Level 13: Arrange words into sentence
  static List<Map<String, dynamic>> _generateArrangeWordsRounds(int count) {
    final sentences = List<Map<String, dynamic>>.from(TamilData.sentences);
    sentences.shuffle(_random);
    return List.generate(min(count, sentences.length), (i) {
      final words = List<String>.from(sentences[i]['tamil'] as List);
      final correct = List<String>.from(words);
      words.shuffle(_random);
      if (words.join() == correct.join() && words.length > 1) {
        final temp = words[0];
        words[0] = words[1];
        words[1] = temp;
      }
      return {
        'type': 'arrange',
        'prompt': 'Build: ${sentences[i]['english']}',
        'tamilPrompt': 'சொற்களை வரிசைப்படுத்தி வாக்கியம் அமைக்கவும்',
        'scrambled': words,
        'correct': correct,
        'word': correct.join(' '),
        'hint': sentences[i]['english'],
      };
    });
  }

  // Level 14: Choose correct sentence
  static List<Map<String, dynamic>> _generateChooseCorrectRounds(int count) {
    final sentences = List<Map<String, dynamic>>.from(TamilData.sentences);
    sentences.shuffle(_random);
    return List.generate(min(count, sentences.length), (i) {
      final correct = (sentences[i]['tamil'] as List).join(' ');
      final options = [correct];
      final others = sentences.where((s) => s != sentences[i]).toList()..shuffle(_random);
      options.addAll(others.take(3).map((s) => (s['tamil'] as List).join(' ')));
      options.shuffle(_random);
      return {
        'type': 'multiple_choice',
        'prompt': 'Choose: "${sentences[i]['english']}"',
        'tamilPrompt': 'சரியான வாக்கியத்தைத் தேர்ந்தெடுக்கவும்',
        'options': options,
        'correct': correct,
      };
    });
  }

  // Level 15: Fill missing word in sentence
  static List<Map<String, dynamic>> _generateFillWordRounds(int count) {
    final sentences = List<Map<String, dynamic>>.from(TamilData.sentences);
    sentences.shuffle(_random);
    return List.generate(min(count, sentences.length), (i) {
      final words = List<String>.from(sentences[i]['tamil'] as List);
      if (words.length < 2) return _generateChooseCorrectRounds(1).first;
      final blankIndex = _random.nextInt(words.length);
      final correct = words[blankIndex];
      final display = List<String>.from(words);
      display[blankIndex] = '______';

      final options = [correct];
      final allHints = sentences.expand((s) => s['tamil'] as List<dynamic>).map((w) => w.toString()).toSet().toList();
      allHints.remove(correct);
      allHints.shuffle(_random);
      options.addAll(allHints.take(3));
      options.shuffle(_random);

      return {
        'type': 'fill_blank',
        'prompt': 'Fill: ${sentences[i]['english']}',
        'tamilPrompt': 'விடுபட்ட சொல்லை நிரப்பவும்',
        'display': display.join(' '),
        'options': options,
        'correct': correct,
        'word': words.join(' '),
      };
    });
  }

  // Level 16: Read sentence
  static List<Map<String, dynamic>> _generateReadAloudRounds(int count) {
    final sentences = List<Map<String, dynamic>>.from(TamilData.sentences);
    sentences.shuffle(_random);
    return List.generate(min(count, sentences.length), (i) {
      return {
        'type': 'listen_speak',
        'prompt': 'Read this sentence aloud',
        'tamilPrompt': 'இந்த வாக்கியத்தை உரக்கப் படிக்கவும்',
        'word': (sentences[i]['tamil'] as List).join(' '),
        'english': sentences[i]['english'],
        'emoji': '📖',
      };
    });
  }

  // Level 17: Read paragraph
  static List<Map<String, dynamic>> _generateReadParagraphRounds(int count) {
    const stories = TamilData.tamilStories;
    final rounds = <Map<String, dynamic>>[];
    for (var story in stories) {
      final scenes = story['scenes'] as List;
      for (var scene in scenes.take(2)) {
        rounds.add({
          'type': 'listen_speak',
          'prompt': 'Read this paragraph aloud',
          'tamilPrompt': 'இதை உரக்கப் படிக்கவும்',
          'word': scene['content'],
          'english': scene['englishContent'],
          'emoji': '📖',
        });
      }
    }
    rounds.shuffle(_random);
    return rounds.take(count).toList();
  }

  // Level 18: Comprehension
  static List<Map<String, dynamic>> _generateComprehensionRounds(int count) {
    const stories = TamilData.tamilStories;
    final rounds = <Map<String, dynamic>>[];
    for (var story in stories) {
      final questions = story['questions'] as List;
      for (var q in questions) {
        rounds.add({
          'type': 'multiple_choice',
          'prompt': q['question'],
          'tamilPrompt': q['question'],
          'options': q['options'],
          'correct': q['options'][q['correct']],
        });
      }
    }
    rounds.shuffle(_random);
    return rounds.take(count).toList();
  }

  // Level 19: Listening comprehension
  static List<Map<String, dynamic>> _generateListeningRounds(int count) {
    return _generateListenWriteRounds(count);
  }

  // Level 20: Story reading
  static List<Map<String, dynamic>> _generateStoryReadRounds(int count) {
    return _generateReadParagraphRounds(count);
  }
}
