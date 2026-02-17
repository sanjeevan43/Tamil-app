class TamilData {
  static const List<String> uyirEzhuthukkal = [
    'அ', 'ஆ', 'இ', 'ஈ', 'உ', 'ஊ', 'எ', 'ஏ', 'ஐ', 'ஒ', 'ஓ', 'ஔ'
  ];

  static const List<String> meiEzhuthukkal = [
    'க்', 'ங்', 'ச்', 'ஞ்', 'ட்', 'ண்', 'த்', 'ந்', 'ப்', 'ம்', 
    'ய்', 'ர்', 'ல்', 'வ்', 'ழ்', 'ள்', 'ற்', 'ன்'
  ];

  static const Map<String, List<Map<String, String>>> wordCategories = {
    'Animals': [
      {'tamil': 'நாய்', 'english': 'Dog', 'emoji': '🐕'},
      {'tamil': 'பூனை', 'english': 'Cat', 'emoji': '🐈'},
      {'tamil': 'யானை', 'english': 'Elephant', 'emoji': '🐘'},
      {'tamil': 'குதிரை', 'english': 'Horse', 'emoji': '🐴'},
      {'tamil': 'பறவை', 'english': 'Bird', 'emoji': '🐦'},
      {'tamil': 'மீன்', 'english': 'Fish', 'emoji': '🐟'},
      {'tamil': 'சிங்கம்', 'english': 'Lion', 'emoji': '🦁'},
      {'tamil': 'குரங்கு', 'english': 'Monkey', 'emoji': '🐵'},
    ],
    'Fruits': [
      {'tamil': 'ஆப்பிள்', 'english': 'Apple', 'emoji': '🍎'},
      {'tamil': 'வாழை', 'english': 'Banana', 'emoji': '🍌'},
      {'tamil': 'மாம்பழம்', 'english': 'Mango', 'emoji': '🥭'},
      {'tamil': 'ஆரஞ்சு', 'english': 'Orange', 'emoji': '🍊'},
      {'tamil': 'திராட்சை', 'english': 'Grapes', 'emoji': '🍇'},
      {'tamil': 'தர்பூசணி', 'english': 'Watermelon', 'emoji': '🍉'},
    ],
    'Colors': [
      {'tamil': 'சிவப்பு', 'english': 'Red', 'emoji': '🔴'},
      {'tamil': 'நீலம்', 'english': 'Blue', 'emoji': '🔵'},
      {'tamil': 'பச்சை', 'english': 'Green', 'emoji': '🟢'},
      {'tamil': 'மஞ்சள்', 'english': 'Yellow', 'emoji': '🟡'},
      {'tamil': 'வெள்ளை', 'english': 'White', 'emoji': '⚪'},
      {'tamil': 'கருப்பு', 'english': 'Black', 'emoji': '⚫'},
    ],
    'Numbers': [
      {'tamil': 'ஒன்று', 'english': 'One', 'emoji': '1️⃣'},
      {'tamil': 'இரண்டு', 'english': 'Two', 'emoji': '2️⃣'},
      {'tamil': 'மூன்று', 'english': 'Three', 'emoji': '3️⃣'},
      {'tamil': 'நான்கு', 'english': 'Four', 'emoji': '4️⃣'},
      {'tamil': 'ஐந்து', 'english': 'Five', 'emoji': '5️⃣'},
      {'tamil': 'ஆறு', 'english': 'Six', 'emoji': '6️⃣'},
      {'tamil': 'ஏழு', 'english': 'Seven', 'emoji': '7️⃣'},
      {'tamil': 'எட்டு', 'english': 'Eight', 'emoji': '8️⃣'},
      {'tamil': 'ஒன்பது', 'english': 'Nine', 'emoji': '9️⃣'},
      {'tamil': 'பத்து', 'english': 'Ten', 'emoji': '🔟'},
    ],
  };

  static const List<Map<String, dynamic>> lessons = [
    {'id': 1, 'title': 'உயிர் எழுத்துக்கள்', 'level': 'Beginner', 'locked': false},
    {'id': 2, 'title': 'மெய் எழுத்துக்கள்', 'level': 'Beginner', 'locked': false},
    {'id': 3, 'title': 'விலங்குகள்', 'level': 'Beginner', 'locked': false},
    {'id': 4, 'title': 'பழங்கள்', 'level': 'Intermediate', 'locked': true},
    {'id': 5, 'title': 'நிறங்கள்', 'level': 'Intermediate', 'locked': true},
    {'id': 6, 'title': 'எண்கள்', 'level': 'Intermediate', 'locked': true},
    {'id': 7, 'title': 'வாக்கியங்கள்', 'level': 'Advanced', 'locked': true},
  ];

  static const List<Map<String, dynamic>> games = [
    {'id': 1, 'name': 'Letter Hunt', 'icon': '🎯', 'description': 'Find the correct letter'},
    {'id': 2, 'name': 'Word Builder', 'icon': '🔨', 'description': 'Build Tamil words'},
    {'id': 3, 'name': 'Memory Match', 'icon': '🧠', 'description': 'Match Tamil letters'},
    {'id': 4, 'name': 'Quiz Battle', 'icon': '⚔️', 'description': 'Answer questions fast'},
    {'id': 5, 'name': 'Fill Blanks', 'icon': '📝', 'description': 'Complete the word'},
    {'id': 6, 'name': 'Sentence Builder', 'icon': '📚', 'description': 'Form sentences'},
  ];

  static const List<String> achievements = [
    'First Letter', 'Word Master', 'Quiz Champion', 'Writing Expert',
    'Speed Learner', '7 Day Streak', '30 Day Streak', 'Perfect Score',
    'Game Master', 'Tamil Scholar'
  ];

  static const List<String> motivationalQuotes = [
    'நன்றாக படிக்கிறாய்!',
    'சிறப்பாக செய்கிறாய்!',
    'தொடர்ந்து முயற்சி செய்!',
    'நீ சிறந்தவன்!',
    'அருமை!',
    'மிக நன்று!',
  ];

  static List<Map<String, dynamic>> getQuizQuestions() {
    return [
      {
        'question': 'எந்த எழுத்து இது?',
        'letter': 'அ',
        'options': ['அ', 'ஆ', 'இ', 'ஈ'],
        'correct': 0,
      },
      {
        'question': 'நாய் என்பதன் ஆங்கில பொருள்?',
        'letter': 'நாய்',
        'options': ['Cat', 'Dog', 'Bird', 'Horse'],
        'correct': 1,
      },
      {
        'question': 'எந்த எழுத்து இது?',
        'letter': 'இ',
        'options': ['அ', 'ஆ', 'இ', 'ஈ'],
        'correct': 2,
      },
      {
        'question': 'பூனை என்பதன் ஆங்கில பொருள்?',
        'letter': 'பூனை',
        'options': ['Dog', 'Cat', 'Bird', 'Fish'],
        'correct': 1,
      },
    ];
  }

  static final List<Map<String, dynamic>> quizQuestions = getQuizQuestions();
}
