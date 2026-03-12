class ReadingJourneyData {
  // Stage definitions
  static const List<Map<String, dynamic>> stages = [
    {
      'id': 1,
      'name': 'Tamil Letters',
      'tamilName': 'தமிழ் எழுத்துக்கள்',
      'color': 0xFFFF7043, // Deep Orange
      'levels': [1, 2, 3, 4],
    },
    {
      'id': 2,
      'name': 'Simple Words',
      'tamilName': 'எளிய சொற்கள்',
      'color': 0xFF42A5F5, // Blue
      'levels': [5, 6, 7, 8],
    },
    {
      'id': 3,
      'name': 'Bigger Words',
      'tamilName': 'பெரிய சொற்கள்',
      'color': 0xFF66BB6A, // Green
      'levels': [9, 10, 11, 12],
    },
    {
      'id': 4,
      'name': 'Simple Sentences',
      'tamilName': 'எளிய வாக்கியங்கள்',
      'color': 0xFFAB47BC, // Purple
      'levels': [13, 14, 15, 16],
    },
    {
      'id': 5,
      'name': 'Reading Practice',
      'tamilName': 'வாசிப்புப் பயிற்சி',
      'color': 0xFFEF5350, // Red
      'levels': [17, 18, 19, 20],
    },
  ];

  // All 20 levels
  static const List<Map<String, dynamic>> levels = [
    // Stage 1 – Tamil Letters
    {
      'id': 1,
      'stageId': 1,
      'title': 'Identify Letter',
      'tamilTitle': 'எழுத்தை அடையாளம் காண்',
      'gameType': 'tap_correct',
      'description': 'Tap the correct Tamil letter',
      'xp': 10,
      'maxStars': 3,
    },
    {
      'id': 2,
      'stageId': 1,
      'title': 'Letter Sound',
      'tamilTitle': 'எழுத்து ஒலி',
      'gameType': 'listen_choose',
      'description': 'Listen and choose the letter',
      'xp': 10,
      'maxStars': 3,
    },
    {
      'id': 3,
      'stageId': 1,
      'title': 'Match Letters',
      'tamilTitle': 'எழுத்துக்களை பொருத்து',
      'gameType': 'match_pairs',
      'description': 'Match same Tamil letters',
      'xp': 15,
      'maxStars': 3,
    },
    {
      'id': 4,
      'stageId': 1,
      'title': 'Letter to Image',
      'tamilTitle': 'எழுத்தை படத்துக்கு இழு',
      'gameType': 'drag_drop',
      'description': 'Drag letter to its matching image',
      'xp': 15,
      'maxStars': 3,
    },

    // Stage 2 – Simple Words
    {
      'id': 5,
      'stageId': 2,
      'title': 'Build Word',
      'tamilTitle': 'சொல்லை உருவாக்கு',
      'gameType': 'arrange_letters',
      'description': 'Arrange letters to form a word',
      'xp': 20,
      'maxStars': 3,
    },
    {
      'id': 6,
      'stageId': 2,
      'title': 'Word & Picture',
      'tamilTitle': 'சொல்லும் படமும்',
      'gameType': 'match_word_picture',
      'description': 'Match word with its picture',
      'xp': 20,
      'maxStars': 3,
    },
    {
      'id': 7,
      'stageId': 2,
      'title': 'Find Word',
      'tamilTitle': 'சரியான சொல்லை தேர்ந்தெடு',
      'gameType': 'find_correct',
      'description': 'Find the correct Tamil word',
      'xp': 20,
      'maxStars': 3,
    },
    {
      'id': 8,
      'stageId': 2,
      'title': 'Pronounce Word',
      'tamilTitle': 'சொல்லை உச்சரி',
      'gameType': 'pronounce',
      'description': 'Pronounce the Tamil word correctly',
      'xp': 25,
      'maxStars': 3,
    },

    // Stage 3 – Bigger Words
    {
      'id': 9,
      'stageId': 3,
      'title': 'Missing Letter',
      'tamilTitle': 'விடுபட்ட எழுத்து',
      'gameType': 'fill_blank',
      'description': 'Complete the missing letter in a word',
      'xp': 25,
      'maxStars': 3,
    },
    {
      'id': 10,
      'stageId': 3,
      'title': 'Word Puzzle',
      'tamilTitle': 'சொல் புதிர்',
      'gameType': 'puzzle',
      'description': 'Solve the word puzzle',
      'xp': 30,
      'maxStars': 3,
    },
    {
      'id': 11,
      'stageId': 3,
      'title': 'Listen & Write',
      'tamilTitle': 'கேட்டு எழுது',
      'gameType': 'listen_write',
      'description': 'Listen to the word and write it',
      'xp': 30,
      'maxStars': 3,
    },
    {
      'id': 12,
      'stageId': 3,
      'title': 'Memory Match',
      'tamilTitle': 'நினைவு விளையாட்டு',
      'gameType': 'memory_match',
      'description': 'Match words from memory',
      'xp': 30,
      'maxStars': 3,
    },

    // Stage 4 – Simple Sentences
    {
      'id': 13,
      'stageId': 4,
      'title': 'Build Sentence',
      'tamilTitle': 'வாக்கியத்தை உருவாக்கு',
      'gameType': 'arrange_words',
      'description': 'Arrange words into a sentence',
      'xp': 35,
      'maxStars': 3,
    },
    {
      'id': 14,
      'stageId': 4,
      'title': 'Choose Sentence',
      'tamilTitle': 'சரியான வாக்கியம்',
      'gameType': 'choose_correct',
      'description': 'Choose the correct sentence',
      'xp': 35,
      'maxStars': 3,
    },
    {
      'id': 15,
      'stageId': 4,
      'title': 'Fill Missing Word',
      'tamilTitle': 'விடுபட்ட சொல்',
      'gameType': 'fill_word',
      'description': 'Fill in the missing word',
      'xp': 35,
      'maxStars': 3,
    },
    {
      'id': 16,
      'stageId': 4,
      'title': 'Read Sentence',
      'tamilTitle': 'வாக்கியம் வாசி',
      'gameType': 'read_aloud',
      'description': 'Read the sentence aloud',
      'xp': 40,
      'maxStars': 3,
    },

    // Stage 5 – Reading Practice
    {
      'id': 17,
      'stageId': 5,
      'title': 'Short Paragraph',
      'tamilTitle': 'சிறு பத்தி',
      'gameType': 'read_paragraph',
      'description': 'Read a short Tamil paragraph',
      'xp': 40,
      'maxStars': 3,
    },
    {
      'id': 18,
      'stageId': 5,
      'title': 'Answer Questions',
      'tamilTitle': 'கேள்விகளுக்கு பதில்',
      'gameType': 'comprehension',
      'description': 'Answer questions about the reading',
      'xp': 45,
      'maxStars': 3,
    },
    {
      'id': 19,
      'stageId': 5,
      'title': 'Listen & Understand',
      'tamilTitle': 'கேட்டு புரிந்துகொள்',
      'gameType': 'listening',
      'description': 'Listen to Tamil and answer',
      'xp': 45,
      'maxStars': 3,
    },
    {
      'id': 20,
      'stageId': 5,
      'title': 'Story Reading',
      'tamilTitle': 'கதை வாசிப்பு',
      'gameType': 'story_read',
      'description': 'Read a full Tamil story',
      'xp': 50,
      'maxStars': 3,
    },
  ];

  // Get stage for a level
  static Map<String, dynamic> getStageForLevel(int levelId) {
    final level = levels.firstWhere((l) => l['id'] == levelId, orElse: () => levels.first);
    return stages.firstWhere((s) => s['id'] == level['stageId'], orElse: () => stages.first);
  }

  // Get all levels for a stage
  static List<Map<String, dynamic>> getLevelsForStage(int stageId) {
    return levels.where((l) => l['stageId'] == stageId).toList();
  }
}
