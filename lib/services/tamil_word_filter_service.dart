import 'package:flutter/foundation.dart';

class TamilWordFilterService {
  static final TamilWordFilterService _instance = TamilWordFilterService._internal();

  factory TamilWordFilterService() {
    return _instance;
  }

  TamilWordFilterService._internal();

  // Literary/Old Tamil markers
  static const Set<String> literaryMarkers = {
    'அரிய', 'பழைய', 'வேதம்', 'சாஸ்திரம்', 'ஆன்மீக', 'மந்திரம்',
    'சிலப்பதிகாரம்', 'கம்பராமாயணம்', 'பெரியபுராணம்', 'திருக்குறள்', 'சங்கம்', 'பண்டைய',
    'ஐதிஹ்யம்', 'புராணம்', 'ஆகமம்',
  };

  // Rare/Archaic word patterns
  static const Set<String> rareWordPatterns = {
    'ஐ', 'ஔ', 'ஃ',
  };

  // Common everyday Tamil words (spoken Tamil)
  static const Set<String> commonEverydayWords = {
    'அம்மா', 'அப்பா', 'அக்கா', 'அண்ணா', 'தம்பி', 'தங்கை',
    'பாட்டி', 'தாத்தா', 'மாமா', 'அத்தை', 'சித்தப்பா', 'சித்தி',
    'மாமி', 'மாமியார்', 'மாமன்', 'மாமனார்', 'சாப்பிடு', 'குடி',
    'தூங்கு', 'எழு', 'நடக்கு', 'ஓடு', 'பாடு', 'நாடு',
    'விளையாடு', 'படி', 'எழுது', 'பேசு', 'கேட்கு', 'பார்க்கு',
    'சிரிக்கு', 'அழு', 'சிந்திக்கு', 'வீடு', 'பள்ளி', 'புத்தகம்',
    'பேனா', 'பேப்பர்', 'மேஜை', 'நாற்காலி', 'கதவு', 'ஜன்னல்',
    'விளக்கு', 'ரேடியோ', 'தொலைக்காட்சி', 'மொபைல்', 'கணினி', 'பாத்திரம்',
    'கப்பு', 'தட்டு', 'கரண்டி', 'சாதம்', 'சாம்பார்', 'ரசம்',
    'பொரியல்', 'பூரி', 'தோசை', 'இட்லி', 'வடை', 'பிரியாணி',
    'பிரெட்', 'பால்', 'தண்ணீர்', 'தேநீர்', 'காபி', 'பழம்',
    'பொரி', 'சாக்லேட்', 'ஐஸ்கிரீம்', 'மரம்', 'பூ', 'இலை',
    'கிளை', 'வேர்', 'விதை', 'சூரியன்', 'நிலா', 'நட்சத்திரம்',
    'மேகம்', 'மழை', 'காற்று', 'நீர்', 'கடல்', 'மலை',
    'வயல்', 'பூங்கா', 'காடு', 'நாய்', 'பூனை', 'யானை',
    'சிங்கம்', 'புலி', 'குரங்கு', 'பறவை', 'மீன்', 'பாம்பு',
    'தவளை', 'சிலந்தி', 'எறும்பு', 'வண்டு', 'தேனீ', 'பூச்சி',
    'கோழி', 'வாத்து', 'ஆடு', 'சிவப்பு', 'நீலம்', 'பச்சை',
    'மஞ்சள்', 'வெள்ளை', 'கருப்பு', 'ஆரஞ்சு', 'ஊதா', 'சாம்பல்',
    'பழுப்பு', 'இளஞ்சிவப்பு', 'ஒன்று', 'இரண்டு', 'மூன்று', 'நான்கு',
    'ஐந்து', 'ஆறு', 'ஏழு', 'எட்டு', 'ஒன்பது', 'பத்து',
    'பதினொன்று', 'பன்னிரண்டு', 'பதிமூன்று', 'பதினான்கு', 'பதினைந்து', 'பதினாறு',
    'பதினேழு', 'பதினெட்டு', 'பத்தொன்பது', 'இருபது', 'தலை', 'முகம்',
    'கண்', 'மூக்கு', 'வாய்', 'பல்', 'நாக்கு', 'காது',
    'கை', 'விரல்', 'கால்', 'கணுக்கால்', 'மார்பு', 'வயிறு',
    'முதுகு', 'தோல்', 'எலும்பு', 'இரத்தம்', 'மகிழ்ச்சி', 'சந்தோஷம்',
    'அன்பு', 'பயம்', 'கோபம்', 'வருத்தம்', 'சோகம்', 'ஆச்சரியம்',
    'வெட்கம்', 'பெருமை', 'நம்பிக்கை', 'நாள்', 'இரவு', 'பகல்',
    'மணி', 'நிமிடம்', 'வினாடி', 'வாரம்', 'மாதம்', 'வருடம்',
    'ஆண்டு', 'இன்று', 'நாளை', 'நேற்று', 'இப்போது', 'பிறகு',
    'முன்', 'கோடை', 'குளிர்', 'மழைக்காலம்', 'வசந்தம்', 'இலையுதிர்',
    'இருக்கு', 'இல்லை', 'உண்டு', 'வேண்டும்', 'கூடும்', 'முடியும்',
    'தெரியும்', 'நினைக்கு', 'மறக்கு', 'கொடு', 'வாங்கு', 'விற்கு',
    'வாழ்கு', 'இறக்கு', 'பிறக்கு', 'வளர்கு', 'சாக்கு', 'நோய்',
    'பெரிய', 'சிறிய', 'நல்ல', 'கெட்ட', 'அழகான', 'கொடிய',
    'வெப்பமான', 'குளிர்ந்த', 'ஈரமான', 'உலர்ந்த', 'புதிய', 'பழைய',
    'விரைவான', 'மெதுவான', 'வலிமையான', 'பலவீனமான', 'ஆரோக்கியமான', 'கோயில்',
    'மசூதி', 'சர்ச்', 'கடை', 'சந்தை', 'பொலிசு', 'மருத்துவமனை',
    'பேருந்து', 'ரயில்', 'விமானம்', 'நகரம்', 'கிராமம்', 'தெரு',
    'சாலை', 'பாலம்', 'ஆசிரியர்', 'மாணவர்', 'மாணவி', 'வேலைக்காரர்',
    'வைத்தியர்', 'நர்ஸ்', 'பொறியாளர்', 'கணக்கர்', 'வக்கீல்', 'விவசாயி',
    'வணிகர்', 'வணக்கம்', 'நமஸ்காரம்', 'ஆசிர்வாதம்', 'தகவல்', 'செய்தி',
    'கேள்வி', 'பதில்', 'ஆம்', 'சரி', 'சரியல்ல', 'தவறு',
    'என்ன', 'யார்', 'எங்கே', 'எப்போது', 'ஏன்', 'எப்படி',
    'எவ்வளவு', 'எந்த', 'இந்த', 'அந்த', 'இவ்வளவு', 'அவ்வளவு',
    'மேல்', 'கீழ்', 'உள்ளே', 'வெளியே', 'பின்', 'வலது',
    'இடது', 'நடுவே', 'பக்கத்தில்', 'அருகில்', 'தூரத்தில்', 'மற்றும்',
    'அல்லது', 'ஆனால்', 'ஏனெனில்', 'அதனால்', 'இருந்தாலும்', 'ஒரு',
    'சில', 'பல', 'அனைத்து', 'ஒவ்வொரு', 'என்', 'உன்',
    'நம்', 'உங்கள்', 'அவர்களின்', 'நான்', 'நீ', 'அவன்',
    'அவள்', 'அது', 'நாம்', 'நீங்கள்', 'அவர்கள்', 'ஸ்மார்ட்ஃபோன்',
    'ஆப்', 'ইন்டர்நெட்', 'ওয়াய்ஃபை', 'ভিডியோ', 'ফটோ', 'ক্যামেরা',
    'ডিজিটல்', 'ইমেல்', 'চ্যাট்',
  };

  // Words that are too formal/literary
  static const Set<String> formalLiteraryWords = {
    'ஆகிய', 'ஆகும்', 'ஆயிற்று', 'ஆயினும்', 'ஆயினால்', 'ஆயிரம்',
    'ஆயுள்', 'ஆயுஷ்', 'ஆயுஷ்மான்', 'ஆயோ', 'அவ்வாறு', 'அவ்வாறே',
    'அவ்வாறிய', 'இவ்வாறு', 'இவ்வாறே', 'இவ்வாறிய', 'உவ்வாறு', 'உவ்வாறே',
    'உவ்வாறிய', 'ஏவம்', 'ஏவ', 'ஏவல்', 'ஐயம்', 'ஐயோ',
    'ஒவ்வொரு', 'ஒவ்வொருவர்', 'கூறிய', 'கூறினர்', 'கூறினாள்', 'கூறினான்',
    'சொல்லிய', 'சொல்லினர்', 'சொல்லினாள்', 'சொல்லினான்', 'தெரிந்த', 'தெரிந்தவர்',
    'தெரிந்தவள்', 'தெரிந்தவன்', 'நினைந்த', 'நினைந்தவர்', 'நினைந்தவள்', 'நினைந்தவன்',
    'பெற்ற', 'பெற்றவர்', 'பெற்றவள்', 'பெற்றவன்', 'வந்த', 'வந்தவர்',
    'வந்தவள்', 'வந்தவன்', 'செய்த', 'செய்தவர்', 'செய்தவள்', 'செய்தவன்',
    'கொண்ட', 'கொண்டவர்', 'கொண்டவள்', 'கொண்டவன்', 'விட்ட', 'விட்டவர்',
    'விட்டவள்', 'விட்டவன்', 'போன', 'போனவர்', 'போனவள்', 'போனவன்',
    'வாழ்ந்த', 'வாழ்ந்தவர்', 'வாழ்ந்தவள்', 'வாழ்ந்தவன்', 'இறந்த', 'இறந்தவர்',
    'இறந்தவள்', 'இறந்தவன்', 'பிறந்த', 'பிறந்தவர்', 'பிறந்தவள்', 'பிறந்தவன்',
    'வளர்ந்த', 'வளர்ந்தவர்', 'வளர்ந்தவள்', 'வளர்ந்தவன்', 'கற்ற', 'கற்றவர்',
    'கற்றவள்', 'கற்றவன்', 'கேட்ட', 'கேட்டவர்', 'கேட்டவள்', 'கேட்டவன்',
    'பார்த்த', 'பார்த்தவர்', 'பார்த்தவள்', 'பார்த்தவன்', 'சிந்தித்த', 'சிந்தித்தவர்',
    'சிந்தித்தவள்', 'சிந்தித்தவன்', 'மறந்த', 'மறந்தவர்', 'மறந்தவள்', 'மறந்தவன்',
    'நினைத்த', 'நினைத்தவர்', 'நினைத்தவள்', 'நினைத்தவன்', 'விரும்பிய', 'விரும்பியவர்',
    'விரும்பியவள்', 'விரும்பியவன்', 'விரும்பாத', 'விரும்பாதவர்', 'விரும்பாதவள்', 'விரும்பாதவன்',
  };

  // Words that are too technical/specialized
  static const Set<String> technicalSpecializedWords = {
    'ஆயுர்வேதம்', 'சித்தவைத்தியம்', 'ইউனानী', 'হোমিওপ্যাথি', 'ফিজিওথেরাপি', 'সাইকোলজি',
    'সোশিওলজি', 'এন্থ্রোপোলজি', 'আর্কিওলজি', 'জিওলজি', 'বায়োলজি', 'কেমিস্ট্রি',
    'ফিজিক্স', 'ম্যাথমেটিক্স', 'জিওমেট্রি', 'এলজেব্রা', 'ট্রিগোনোমেট্রি', 'ক্যালকুলাস',
    'স্ট্যাটিস্টিক্স', 'প্রোবাবিলিটি',
  };

  /// Check if a word is commonly used in everyday Tamil
  bool isCommonEverydayWord(String word) {
    if (word.isEmpty) return false;
    return commonEverydayWords.contains(word);
  }

  /// Check if a word is literary/formal
  bool isLiteraryWord(String word) {
    if (word.isEmpty) return false;
    return formalLiteraryWords.contains(word);
  }

  /// Check if a word is technical/specialized
  bool isTechnicalWord(String word) {
    if (word.isEmpty) return false;
    return technicalSpecializedWords.contains(word);
  }

  /// Check if a word contains rare Tamil characters
  bool containsRareCharacters(String word) {
    for (String pattern in rareWordPatterns) {
      if (word.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// Check if a word is likely to be rare/archaic based on patterns
  bool isLikelyRareWord(String word) {
    // Words with excessive consonant clusters
    if (RegExp(r'[க-ன]{3,}').hasMatch(word)) return true;

    // Words with rare character combinations
    if (word.contains('ஃ')) return true;

    // Very long words (likely compound or archaic)
    if (word.length > 15) return true;

    // Words ending in archaic suffixes
    if (word.endsWith('ஆய்') || word.endsWith('ஆயிற்று')) return true;

    return false;
  }

  /// Get commonality score (0-100)
  /// Higher score = more common/everyday word
  int getCommonalityScore(String word) {
    int score = 0;

    // Base score
    if (isCommonEverydayWord(word)) {
      score += 100;
    } else if (isLiteraryWord(word)) {
      score -= 50;
    } else if (isTechnicalWord(word)) {
      score -= 30;
    } else if (containsRareCharacters(word)) {
      score -= 40;
    } else if (isLikelyRareWord(word)) {
      score -= 20;
    } else {
      score += 30; // Unknown words get moderate score
    }

    // Adjust based on word length (shorter words are usually more common)
    if (word.length <= 3) {
      score += 10;
    } else if (word.length <= 6) {
      score += 5;
    } else if (word.length > 12) {
      score -= 10;
    }

    // Clamp score between 0 and 100
    return score.clamp(0, 100);
  }

  /// Filter words and return only everyday Tamil words
  List<Map<String, dynamic>> filterEverydayWords(
    List<Map<String, dynamic>> words, {
    int minCommonalityScore = 50,
  }) {
    return words.where((word) {
      final wordText = word['word'] as String? ?? '';
      final score = getCommonalityScore(wordText);
      return score >= minCommonalityScore;
    }).toList();
  }

  /// Get filtered words sorted by commonality
  List<Map<String, dynamic>> getFilteredWordsSortedByCommonality(
    List<Map<String, dynamic>> words, {
    int minCommonalityScore = 50,
  }) {
    final filtered = filterEverydayWords(words, minCommonalityScore: minCommonalityScore);

    filtered.sort((a, b) {
      final scoreA = getCommonalityScore(a['word'] as String? ?? '');
      final scoreB = getCommonalityScore(b['word'] as String? ?? '');
      return scoreB.compareTo(scoreA); // Descending order
    });

    return filtered;
  }

  /// Categorize words by commonality level
  Map<String, List<Map<String, dynamic>>> categorizeByCommonality(
    List<Map<String, dynamic>> words,
  ) {
    return {
      'very_common': words.where((w) {
        final score = getCommonalityScore(w['word'] as String? ?? '');
        return score >= 80;
      }).toList(),
      'common': words.where((w) {
        final score = getCommonalityScore(w['word'] as String? ?? '');
        return score >= 60 && score < 80;
      }).toList(),
      'moderate': words.where((w) {
        final score = getCommonalityScore(w['word'] as String? ?? '');
        return score >= 40 && score < 60;
      }).toList(),
      'rare': words.where((w) {
        final score = getCommonalityScore(w['word'] as String? ?? '');
        return score < 40;
      }).toList(),
    };
  }

  /// Get word analysis with detailed information
  Map<String, dynamic> analyzeWord(String word) {
    return {
      'word': word,
      'is_common_everyday': isCommonEverydayWord(word),
      'is_literary': isLiteraryWord(word),
      'is_technical': isTechnicalWord(word),
      'has_rare_characters': containsRareCharacters(word),
      'is_likely_rare': isLikelyRareWord(word),
      'commonality_score': getCommonalityScore(word),
      'recommendation': _getRecommendation(word),
    };
  }

  /// Get recommendation for a word
  String _getRecommendation(String word) {
    final score = getCommonalityScore(word);

    if (score >= 80) {
      return 'Excellent - Very common everyday word';
    } else if (score >= 60) {
      return 'Good - Common word, suitable for learning';
    } else if (score >= 40) {
      return 'Fair - Moderate usage, can be learned';
    } else if (score >= 20) {
      return 'Poor - Rare or literary word, not recommended for beginners';
    } else {
      return 'Not recommended - Too rare or archaic';
    }
  }

  /// Get simple meaning and example for a word
  Map<String, dynamic> getSimplifiedWordInfo(
    String word,
    String? englishMeaning,
    String? tamilMeaning,
    String? example,
  ) {
    return {
      'word': word,
      'english_meaning': englishMeaning ?? 'Not available',
      'tamil_meaning': _simplifyTamilMeaning(tamilMeaning),
      'example': _simplifyExample(example),
      'is_everyday_word': isCommonEverydayWord(word),
      'commonality_score': getCommonalityScore(word),
      'recommendation': _getRecommendation(word),
    };
  }

  /// Simplify Tamil meaning to simple language
  String _simplifyTamilMeaning(String? meaning) {
    if (meaning == null || meaning.isEmpty) return 'Not available';

    // Remove complex markers
    String simplified = meaning
        .replaceAll(RegExp(r'\([^)]*\)'), '') // Remove parentheses
        .replaceAll(RegExp(r';.*'), '') // Remove semicolon and after
        .replaceAll(RegExp(r'\..*'), '') // Remove period and after
        .trim();

    // If too long, truncate
    if (simplified.length > 100) {
      simplified = '${simplified.substring(0, 100)}...';
    }

    return simplified.isEmpty ? 'Not available' : simplified;
  }

  /// Simplify example to simple language
  String _simplifyExample(String? example) {
    if (example == null || example.isEmpty) return 'Not available';

    // Remove complex markers and keep only the Tamil and English parts
    String simplified = example
        .replaceAll(RegExp(r'\([^)]*\)'), '') // Remove parentheses
        .trim();

    return simplified.isEmpty ? 'Not available' : simplified;
  }

  /// Batch filter words from API
  Future<List<Map<String, dynamic>>> filterWordsFromAPI(
    List<Map<String, dynamic>> apiWords, {
    int minCommonalityScore = 50,
    bool sortByCommonality = true,
  }) async {
    return await compute(_filterWordsCompute, {
      'words': apiWords,
      'minScore': minCommonalityScore,
      'sortByCommonality': sortByCommonality,
    });
  }

  /// Static method for compute
  static List<Map<String, dynamic>> _filterWordsCompute(
    Map<String, dynamic> params,
  ) {
    final words = params['words'] as List<Map<String, dynamic>>;
    final minScore = params['minScore'] as int;
    final sortByCommonality = params['sortByCommonality'] as bool;

    final service = TamilWordFilterService();
    final filtered = service.filterEverydayWords(words, minCommonalityScore: minScore);

    if (sortByCommonality) {
      filtered.sort((a, b) {
        final scoreA = service.getCommonalityScore(a['word'] as String? ?? '');
        final scoreB = service.getCommonalityScore(b['word'] as String? ?? '');
        return scoreB.compareTo(scoreA);
      });
    }

    return filtered;
  }
}
