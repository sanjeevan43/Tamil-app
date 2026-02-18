class ReadingJourneyData {
  static const List<Map<String, dynamic>> levels = [
    {
      'id': 1,
      'title': 'உயிர் எழுத்துக்கள்',
      'subtitle': 'Vowels',
      'description': 'Master the soul letters of Tamil',
      'isLocked': false,
      'stars': 3,
      'words': [
        {'tamil': 'அ', 'pronunciation': 'A', 'meaning': 'Short A'},
        {'tamil': 'ஆ', 'pronunciation': 'Aa', 'meaning': 'Long A'},
        {'tamil': 'இ', 'pronunciation': 'E', 'meaning': 'Short E'},
        {'tamil': 'ஈ', 'pronunciation': 'Ee', 'meaning': 'Long E'},
        {'tamil': 'உ', 'pronunciation': 'U', 'meaning': 'Short U'},
      ],
    },
    {
      'id': 2,
      'title': 'மெய் எழுத்துக்கள்',
      'subtitle': 'Consonants',
      'description': 'Learn the body letters',
      'isLocked': false,
      'stars': 2,
      'words': [
        {'tamil': 'க்', 'pronunciation': 'Ik', 'meaning': 'k'},
        {'tamil': 'ங்', 'pronunciation': 'Ing', 'meaning': 'ng'},
        {'tamil': 'ச்', 'pronunciation': 'Ich', 'meaning': 'ch'},
      ],
    },
    {
      'id': 3,
      'title': 'ஈரெழுத்துச் சொற்கள்',
      'subtitle': 'Two Letter Words',
      'description': 'Simple words to start reading',
      'isLocked': false, // Current level in HTML
      'stars': 0,
      'words': [
        {'tamil': 'அம்மா', 'pronunciation': 'Am-ma', 'meaning': 'Mother'},
        {'tamil': 'ஆடு', 'pronunciation': 'Aa-du', 'meaning': 'Goat'},
        {'tamil': 'இலை', 'pronunciation': 'I-lai', 'meaning': 'Leaf'},
        {'tamil': 'ஈட்டி', 'pronunciation': 'Ee-tti', 'meaning': 'Spear'},
        {'tamil': 'உடை', 'pronunciation': 'U-dai', 'meaning': 'Dress'},
      ],
    },
    {
      'id': 4,
      'title': 'மூன்றெழுத்துச் சொற்கள்',
      'subtitle': 'Three Letter Words',
      'description': 'Expand your vocabulary',
      'isLocked': true,
      'stars': 0,
      'words': [],
    },
    {
      'id': 5,
      'title': 'சொற்றொடர்கள்',
      'subtitle': 'Sentences',
      'description': 'Read full sentences',
      'isLocked': true,
      'stars': 0,
      'words': [],
    },
  ];
}
