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
    'Body': [
      {'tamil': 'கண்', 'english': 'Eye', 'emoji': '👁️'},
      {'tamil': 'காது', 'english': 'Ear', 'emoji': '👂'},
      {'tamil': 'வாய்', 'english': 'Mouth', 'emoji': '👄'},
      {'tamil': 'மூக்கு', 'english': 'Nose', 'emoji': '👃'},
      {'tamil': 'கை', 'english': 'Hand', 'emoji': '✋'},
      {'tamil': 'கால்', 'english': 'Leg', 'emoji': '🦵'},
    ],
    'Family': [
      {'tamil': 'அம்மா', 'english': 'Mother', 'emoji': '👩'},
      {'tamil': 'அப்பா', 'english': 'Father', 'emoji': '👨'},
      {'tamil': 'அக்கா', 'english': 'Elder Sister', 'emoji': '👧'},
      {'tamil': 'அண்ணா', 'english': 'Elder Brother', 'emoji': '👦'},
      {'tamil': 'தம்பி', 'english': 'Younger Brother', 'emoji': '🧒'},
      {'tamil': 'தங்கை', 'english': 'Younger Sister', 'emoji': '👶'},
    ],
    'Vegetables': [
      {'tamil': 'தக்காளி', 'english': 'Tomato', 'emoji': '🍅'},
      {'tamil': 'வெங்காயம்', 'english': 'Onion', 'emoji': '🧅'},
      {'tamil': 'உருளைக்கிழங்கு', 'english': 'Potato', 'emoji': '🥔'},
      {'tamil': 'கேரட்', 'english': 'Carrot', 'emoji': '🥕'},
      {'tamil': 'கத்தரிக்காய்', 'english': 'Brinjal', 'emoji': '🍆'},
    ],
    'Nature': [
      {'tamil': 'சூரியன்', 'english': 'Sun', 'emoji': '☀️'},
      {'tamil': 'நிலா', 'english': 'Moon', 'emoji': '🌙'},
      {'tamil': 'நட்சத்திரம்', 'english': 'Star', 'emoji': '⭐'},
      {'tamil': 'மேகம்', 'english': 'Cloud', 'emoji': '☁️'},
      {'tamil': 'மழை', 'english': 'Rain', 'emoji': '🌧️'},
      {'tamil': 'மலை', 'english': 'Mountain', 'emoji': '⛰️'},
    ],
  };

  static const List<Map<String, dynamic>> lessons = [
    {'id': 1, 'title': 'உயிர் எழுத்துக்கள்', 'english': 'Vowel Letters', 'level': 'Beginner', 'locked': false},
    {'id': 2, 'title': 'மெய் எழுத்துக்கள்', 'english': 'Consonant Letters', 'level': 'Beginner', 'locked': false},
    {'id': 3, 'title': 'விலங்குகள்', 'english': 'Animals', 'level': 'Beginner', 'locked': false},
    {'id': 4, 'title': 'பழங்கள்', 'english': 'Fruits', 'level': 'Intermediate', 'locked': true},
    {'id': 5, 'title': 'நிறங்கள்', 'english': 'Colors', 'level': 'Intermediate', 'locked': true},
    {'id': 6, 'title': 'எண்கள்', 'english': 'Numbers', 'level': 'Intermediate', 'locked': true},
    {'id': 7, 'title': 'வாக்கியங்கள்', 'english': 'Sentences', 'level': 'Advanced', 'locked': true},
  ];

  static const List<Map<String, dynamic>> games = [
    {'id': 1, 'name': 'Letter Hunt', 'tamilName': 'எழுத்து வேட்டை', 'icon': '🎯', 'description': 'Find the correct letter'},
    {'id': 2, 'name': 'Word Builder', 'tamilName': 'சொல் உருவாக்குதல்', 'icon': '🔨', 'description': 'Build Tamil words'},
    {'id': 3, 'name': 'Memory Match', 'tamilName': 'நினைவகப் போட்டி', 'icon': '🧠', 'description': 'Match Tamil letters'},
    {'id': 4, 'name': 'Quiz Battle', 'tamilName': 'வினாடி வினா போர்', 'icon': '⚔️', 'description': 'Answer questions fast'},
    {'id': 5, 'name': 'Fill Blanks', 'tamilName': 'இடைவெளியை நிரப்பு', 'icon': '📝', 'description': 'Complete the word'},
    {'id': 6, 'name': 'Sentence Builder', 'tamilName': 'வாக்கிய அமைப்பாளர்', 'icon': '📚', 'description': 'Form sentences'},
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
        'question': 'இது எந்த எழுத்து?',
        'letter': 'அ',
        'options': ['அ', 'ஆ', 'இ', 'ஈ'],
        'correct': 0,
      },
      {
        'question': 'நாய் என்பதன் ஆங்கில பொருள்?',
        'letter': '🐕',
        'options': ['Cat', 'Dog', 'Bird', 'Horse'],
        'correct': 1,
      },
      {
        'question': 'இது எந்த எழுத்து?',
        'letter': 'இ',
        'options': ['அ', 'ஆ', 'இ', 'ஈ'],
        'correct': 2,
      },
      {
        'question': 'பூனை என்பதன் ஆங்கில பொருள்?',
        'letter': '🐈',
        'options': ['Dog', 'Cat', 'Bird', 'Fish'],
        'correct': 1,
      },
      {
        'question': 'Apple என்பது தமிழில்?',
        'letter': '🍎',
        'options': ['வாழை', 'ஆப்பிள்', 'ஆரஞ்சு', 'மாம்பழம்'],
        'correct': 1,
      },
      {
        'question': 'Red என்பது தமிழில்?',
        'letter': '🔴',
        'options': ['நீலம்', 'பச்சை', 'சிவப்பு', 'மஞ்சள்'],
        'correct': 2,
      },
      {
        'question': 'யானை என்பதன் ஆங்கில பொருள்?',
        'letter': '🐘',
        'options': ['Lion', 'Horse', 'Cat', 'Elephant'],
        'correct': 3,
      },
      {
        'question': 'ஐந்து என்பது எத்தனை?',
        'letter': '5️⃣',
        'options': ['3', '4', '5', '6'],
        'correct': 2,
      },
      {
        'question': 'அம்மா means?',
        'letter': '👩',
        'options': ['Father', 'Sister', 'Mother', 'Brother'],
        'correct': 2,
      },
      {
        'question': 'இது எந்த எழுத்து?',
        'letter': 'ஓ',
        'options': ['ஒ', 'ஓ', 'ஔ', 'ஐ'],
        'correct': 1,
      },
    ];
  }

  static final List<Map<String, dynamic>> quizQuestions = getQuizQuestions();

  // Sentence data for Sentence Builder game
  static const List<Map<String, dynamic>> sentences = [
    {
      'tamil': ['நான்', 'பள்ளி', 'செல்கிறேன்'],
      'english': 'I go to school',
      'hint': 'நான் + பள்ளி + செல்கிறேன்',
    },
    {
      'tamil': ['இது', 'என்', 'வீடு'],
      'english': 'This is my house',
      'hint': 'இது + என் + வீடு',
    },
    {
      'tamil': ['நாய்', 'ஓடுகிறது'],
      'english': 'Dog is running',
      'hint': 'நாய் + ஓடுகிறது',
    },
    {
      'tamil': ['பூனை', 'பால்', 'குடிக்கிறது'],
      'english': 'Cat drinks milk',
      'hint': 'பூனை + பால் + குடிக்கிறது',
    },
    {
      'tamil': ['மழை', 'வருகிறது'],
      'english': 'Rain is coming',
      'hint': 'மழை + வருகிறது',
    },
    {
      'tamil': ['நான்', 'தமிழ்', 'படிக்கிறேன்'],
      'english': 'I study Tamil',
      'hint': 'நான் + தமிழ் + படிக்கிறேன்',
    },
    {
      'tamil': ['பூ', 'அழகாக', 'இருக்கிறது'],
      'english': 'The flower is beautiful',
      'hint': 'பூ + அழகாக + இருக்கிறது',
    },
    {
      'tamil': ['சூரியன்', 'உதிக்கிறது'],
      'english': 'The sun is rising',
      'hint': 'சூரியன் + உதிக்கிறது',
    },
    {
      'tamil': ['தம்பி', 'விளையாடுகிறான்'],
      'english': 'Younger brother is playing',
      'hint': 'தம்பி + விளையாடுகிறான்',
    },
  ];

  // Fill Blanks Game specific data
  static const List<Map<String, String>> fillBlanksWords = [
    {'word': 'நாய்', 'english': 'Dog', 'emoji': '🐕'},
    {'word': 'பூனை', 'english': 'Cat', 'emoji': '🐈'},
    {'word': 'மீன்', 'english': 'Fish', 'emoji': '🐟'},
    {'word': 'வாழை', 'english': 'Banana', 'emoji': '🍌'},
    {'word': 'நீலம்', 'english': 'Blue', 'emoji': '🔵'},
    {'word': 'பச்சை', 'english': 'Green', 'emoji': '🟢'},
    {'word': 'அம்மா', 'english': 'Mother', 'emoji': '👩'},
    {'word': 'அப்பா', 'english': 'Father', 'emoji': '👨'},
    {'word': 'கண்', 'english': 'Eye', 'emoji': '👁️'},
    {'word': 'காது', 'english': 'Ear', 'emoji': '👂'},
  ];

  static const List<Map<String, String>> globalFacts = [
    {
      'country': 'India',
      'flag': '🇮🇳',
      'fact': 'Tamil is a classical language of India and the official language of Tamil Nadu and Puducherry.'
    },
    {
      'country': 'Sri Lanka',
      'fact': 'Tamil is an official language in Sri Lanka, with a rich history in the North and East.',
      'flag': '🇱🇰'
    },
    {
      'country': 'Singapore',
      'flag': '🇸🇬',
      'fact': 'Tamil is one of the four official languages of Singapore, celebrated during Tamil Language Festival.'
    },
    {
      'country': 'Malaysia',
      'flag': '🇲🇾',
      'fact': 'Malaysia has a large Tamil population with many Tamil-medium primary schools.'
    },
    {
      'country': 'UK & Europe',
      'flag': '🇬🇧',
      'fact': 'London, Paris, and Switzerland have vibrant Tamil communities maintaining language through weekend schools.'
    },
    {
      'country': 'North America',
      'flag': '🇺🇸',
      'fact': 'USA and Canada have many Tamil Sangams and schools teaching the next generation.'
    },
  ];

  static const List<Map<String, dynamic>> tamilRhymes = [
    {
      'title': 'கைவீசம்மா கைவீசு',
      'englishTitle': 'Wave Your Hands',
      'lines': [
        {'content': 'கைவீசம்மா கைவீசு', 'image': 'rhyme_hand_wave'},
        {'content': 'பள்ளிக்குச் செல்லலாம் கைவீசு', 'image': 'rhyme_school'},
        {'content': 'பாடம் படிக்கலாம் கைவீசு', 'image': 'rhyme_study'},
        {'content': 'பழங்கள் வாங்கலாம் கைவீசு', 'image': 'rhyme_fruits'},
      ],
    },
    {
      'title': 'நிலா நிலா ஓடி வா',
      'englishTitle': 'Moon Moon Come Running',
      'lines': [
        {'content': 'நிலா நிலா ஓடி வா', 'image': 'rhyme_moon_1'},
        {'content': 'நில்லாமல் ஓடி வா', 'image': 'rhyme_moon_2'},
        {'content': 'மலை மேலே ஏறி வா', 'image': 'rhyme_moon_3'},
        {'content': 'மல்லிகைப் பூ கொண்டு வா', 'image': 'rhyme_moon_4'},
      ],
    },
    {
      'title': 'ஆத்திச்சூடி',
      'englishTitle': 'Aathichudi (Moral Codes)',
      'lines': [
        {'content': 'அறம் செய விரும்பு', 'image': 'rhyme_aathichudi_1'},
        {'content': 'ஆறுவது சினம்', 'image': 'rhyme_aathichudi_2'},
        {'content': 'இயல்வது கரவேல்', 'image': 'rhyme_aathichudi_3'},
        {'content': 'ஈவது விலக்கேல்', 'image': 'rhyme_aathichudi_4'},
      ],
    },
  ];

  static const List<Map<String, dynamic>> tamilStories = [
    {
      'title': 'சிங்கமும் எலியும்',
      'englishTitle': 'The Lion and the Mouse',
      'moral': 'யாரையும் குறைவாக எடை போடக்கூடாது.',
      'scenes': [
        {'content': 'ஒரு காட்டில் ஒரு சிங்கம் தூங்கிக்கொண்டிருந்தது.', 'englishContent': 'A lion was sleeping in a forest.', 'image': 'story_lion_sleep'},
        {'content': 'அங்கே ஒரு எலி வந்து சிங்கத்தின் மேல் விளையாடியது.', 'englishContent': 'A mouse came there and played on the lion.', 'image': 'story_mouse_play'},
        {'content': 'சிங்கம் கோபத்துடன் எலியைப் பிடித்தது.', 'englishContent': 'The lion caught the mouse angrily.', 'image': 'story_lion_angry'},
        {'content': 'எலி கெஞ்சியது, ஒரு நாள் நான் உனக்கு உதவுவேன் என்றது.', 'englishContent': 'The mouse begged, saying "I will help you one day".', 'image': 'story_mouse_beg'},
        {'content': 'சிங்கம் சிரித்துக்கொண்டே எலியை விட்டுவிட்டது.', 'englishContent': 'The lion laughed and let the mouse go.', 'image': 'story_lion_laugh'},
      ],
      'questions': [
        {'question': 'காட்டில் எது தூங்கிக்கொண்டிருந்தது?', 'options': ['நாய்', 'பூனை', 'சிங்கம்', 'யானை'], 'correct': 2},
        {'question': 'சிங்கத்தின் மேல் எது விளையாடியது?', 'options': ['முயல்', 'எலி', 'மயில்', 'கிளி'], 'correct': 1},
      ],
    },
    {
      'title': 'ஆமையும் முயலும்',
      'englishTitle': 'The Tortoise and the Hare',
      'moral': 'மெதுவாகச் சென்றாலும், நிலையாகச் செல்வது வெற்றி.',
      'scenes': [
        {'content': 'ஒரு நாள் முயல் ஆமையை பார்த்து, நான் மிகவும் வேகமாக ஓடுவேன் என்று கூறியது.', 'englishContent': 'One day a hare saw a tortoise and said "I can run very fast".', 'image': 'story_hare_boast'},
        {'content': 'ஆமை சொன்னது: நாம் ஒரு ஓட்டப்பந்தயம் வைப்போம்!', 'englishContent': 'The tortoise said: "Let\'s have a race!"', 'image': 'story_tortoise_challenge'},
        {'content': 'முயல் வேகமாக ஓடி, நடுவழியில் தூங்கிவிட்டது.', 'englishContent': 'The hare ran fast and fell asleep midway.', 'image': 'story_hare_sleep'},
        {'content': 'ஆமை மெதுவாக, நிலையாக ஓடி, வெற்றி பெற்றது!', 'englishContent': 'The tortoise ran slowly and steadily and won!', 'image': 'story_tortoise_win'},
      ],
      'questions': [
        {'question': 'யார் வேகமாக ஓடுவேன் என்று பெருமை அடித்தது?', 'options': ['ஆமை', 'முயல்', 'நாய்', 'பூனை'], 'correct': 1},
        {'question': 'கடைசியில் யார் வெற்றி பெற்றது?', 'options': ['முயல்', 'நாய்', 'ஆமை', 'யானை'], 'correct': 2},
      ],
    },
    {
      'title': 'தாகமுள்ள காகம்',
      'englishTitle': 'The Thirsty Crow',
      'moral': 'முயற்சி தொடர்ந்தால் வெற்றி நிச்சயம்.',
      'scenes': [
        {'content': 'ஒரு காகத்திற்கு மிகவும் தாகமாக இருந்தது.', 'englishContent': 'A crow was very thirsty.', 'image': 'story_crow_thirsty'},
        {'content': 'ஒரு குடத்தில் கொஞ்சம் தண்ணீர் இருந்தது, ஆனால் அது எட்டவில்லை.', 'englishContent': 'There was a little water in a pot, but it couldn\'t reach it.', 'image': 'story_crow_pot'},
        {'content': 'காகம் சிறிய கற்களை குடத்தில் போட்டது.', 'englishContent': 'The crow put small stones into the pot.', 'image': 'story_crow_stones'},
        {'content': 'தண்ணீர் மேலே வந்தது! காகம் தண்ணீர் குடித்தது.', 'englishContent': 'The water came up! The crow drank the water.', 'image': 'story_crow_drink'},
      ],
      'questions': [
        {'question': 'காகத்திற்கு என்ன பிரச்சனை?', 'options': ['பசி', 'தாகம்', 'தூக்கம்', 'குளிர்'], 'correct': 1},
        {'question': 'காகம் என்ன குடத்தில் போட்டது?', 'options': ['மணல்', 'இலைகள்', 'கற்கள்', 'பூக்கள்'], 'correct': 2},
      ],
    },
  ];
}
