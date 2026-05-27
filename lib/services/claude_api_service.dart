import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ClaudeApiService {
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-sonnet-4-20250514';
  static const int _maxTokens = 1500;

  static String get _apiKey => dotenv.env['CLAUDE_API_KEY'] ?? '';

  static bool get _useMockFallback {
    final key = _apiKey.trim();
    return key.isEmpty || key == 'YOUR_CLAUDE_API_KEY' || key.startsWith('sk-ant-xxx') || key.length < 10;
  }

  static Future<Map<String, dynamic>> _callClaude({
    required String systemPrompt,
    required String userMessage,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': _maxTokens,
          'system': systemPrompt,
          'messages': [
            {'role': 'user', 'content': userMessage}
          ],
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Claude API error: ${response.statusCode} - ${response.body}');
      }

      final data = jsonDecode(response.body);
      final jsonText = data['content'][0]['text'];
      return jsonDecode(jsonText);
    } catch (e) {
      throw Exception('Failed to call Claude API: $e');
    }
  }

  static Future<String> _callClaudeChat({
    required String systemPrompt,
    required List<Map<String, String>> messages,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': _maxTokens,
          'system': systemPrompt,
          'messages': messages,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Claude API error: ${response.statusCode} - ${response.body}');
      }

      final data = jsonDecode(response.body);
      return data['content'][0]['text'] as String;
    } catch (e) {
      throw Exception('Failed to call Claude API chat: $e');
    }
  }

  // ─── FEATURE 1: Family Tamil Tree ───────────────────────────────────
  static Future<Map<String, dynamic>> getKinshipWord({
    required String relation,
    required int childAge,
  }) async {
    if (_useMockFallback) {
      debugPrint('ClaudeApiService: Using fallback mock data for getKinshipWord (Relation: $relation)');
      return _mockKinshipWord(relation);
    }

    const systemPrompt = '''
You are a Tamil kinship language expert for children.
When given a family relation, return ONLY this JSON:

{
  "tamil_word": "சித்தி",
  "transliteration": "Chitti",
  "meaning_english": "Mother's younger sister",
  "meaning_tamil": "அம்மாவின் தங்கை",
  "fun_fact": "சித்தி உன்னை அம்மாவைப் போலவே நேசிப்பாள்!",
  "example_sentence": "சித்தி என்னிடம் மிட்டாய் தந்தாள்.",
  "quiz": [
    {
      "question": "அம்மாவின் தங்கையை என்ன சொல்வோம்?",
      "correct": "சித்தி",
      "options": ["சித்தி", "அத்தை", "பெரியம்மா", "பாட்டி"]
    }
  ]
}

Tamil kinship reference:
அப்பா=Father, அம்மா=Mother, அண்ணன்=Older brother, தம்பி=Younger brother,
அக்கா=Older sister, தங்கை=Younger sister, தாத்தா=Grandfather, பாட்டி=Grandmother,
பெரியப்பா=Father's older brother, சித்தப்பா=Father's younger brother,
மாமா=Mother's brother, அத்தை=Father's sister,
பெரியம்மா=Mother's older sister, சித்தி=Mother's younger sister,
மைத்துனன்=Sister's husband, நாத்தனார்=Brother's wife

No extra text. JSON only.
''';

    try {
      return await _callClaude(
        systemPrompt: systemPrompt,
        userMessage: 'Relation: $relation\nChild age: $childAge',
      );
    } catch (e) {
      debugPrint('ClaudeApiService: Live API call failed ($e). Falling back to mock data for getKinshipWord.');
      return _mockKinshipWord(relation);
    }
  }

  // ─── FEATURE 2: Scan & Learn Camera ─────────────────────────────────
  static Future<Map<String, dynamic>> explainScannedText({
    required String scannedText,
    required int childAge,
  }) async {
    if (_useMockFallback) {
      debugPrint('ClaudeApiService: Using fallback mock data for explainScannedText (Text: $scannedText)');
      return _mockExplainScannedText(scannedText);
    }

    const systemPrompt = '''
You are a Tamil language teacher for children aged 5–12.
The child has scanned a Tamil text using their phone camera.
Your job is to explain every Tamil word in that text in a simple, fun way.

Return ONLY this JSON:

{
  "full_text": "வணக்கம் தமிழ் நாடு",
  "words": [
    {
      "word": "வணக்கம்",
      "transliteration": "Vanakkam",
      "meaning": "Hello / Greetings",
      "example": "நான் உங்களை பார்க்கும்போது வணக்கம் சொல்வேன்.",
      "fun_fact": "வணக்கம் என்பது தமிழரின் பாரம்பரிய வாழ்த்து!"
    }
  ],
  "full_meaning": "Hello Tamil Nadu",
  "quiz": [
    {
      "question": "வணக்கம் என்றால் என்ன?",
      "correct": "Hello",
      "options": ["Hello", "Goodbye", "Thank you", "Sorry"]
    }
  ]
}

Rules:
- Always explain every single word separately
- Keep meanings simple for children
- fun_fact must be interesting and age-appropriate
- No extra text. JSON only.
''';

    try {
      return await _callClaude(
        systemPrompt: systemPrompt,
        userMessage: 'Tamil text from camera: $scannedText\nChild age: $childAge',
      );
    } catch (e) {
      debugPrint('ClaudeApiService: Live API call failed ($e). Falling back to mock data for explainScannedText.');
      return _mockExplainScannedText(scannedText);
    }
  }

  // ─── FEATURE 3: Spoken vs Written Tamil ──────────────────────────────
  static Future<Map<String, dynamic>> convertTamil({
    required String sentence,
    required String mode,
    required String topic,
    required int childAge,
  }) async {
    if (_useMockFallback) {
      debugPrint('ClaudeApiService: Using fallback mock data for convertTamil (Sentence: $sentence)');
      return _mockConvertTamil(sentence);
    }

    const systemPrompt = '''
You are a Tamil language expert who teaches the difference between
formal written Tamil (எழுத்து தமிழ்) and spoken colloquial Tamil (பேச்சு தமிழ்).

Many children learn formal Tamil but cannot have real conversations.
Your job is to show both forms and explain the difference simply.

Return ONLY this JSON:

{
  "written_tamil": "நான் பள்ளிக்கூடம் போகிறேன்.",
  "spoken_tamil": "நான் இஸ்கூலுக்கு போறேன்.",
  "written_transliteration": "Naan pallikkoodam pogireen",
  "spoken_transliteration": "Naan iskoolukkup pooreen",
  "english": "I am going to school.",
  "difference_explained": "எழுத்தில் 'போகிறேன்' என்று எழுதுவோம், ஆனால் பேசும்போது 'போறேன்' என்று சொல்வோம்!",
  "key_changes": [
    { "formal": "போகிறேன்", "spoken": "போறேன்", "rule": "கிற → ற" }
  ],
  "practice_tip": "உன் நண்பனிடம் பேசும்போது பேச்சு தமிழ் பயன்படுத்து!",
  "quiz": [
    {
      "question": "பேச்சு தமிழில் 'போகிறேன்' என்பதை எப்படி சொல்வோம்?",
      "correct": "போறேன்",
      "options": ["போகிறேன்", "போறேன்", "போனேன்", "போவேன்"]
    }
  ]
}

No extra text. JSON only.
''';

    try {
      return await _callClaude(
        systemPrompt: systemPrompt,
        userMessage: 'Sentence: $sentence\nMode: $mode\nTopic: $topic\nChild age: $childAge',
      );
    } catch (e) {
      debugPrint('ClaudeApiService: Live API call failed ($e). Falling back to mock data for convertTamil.');
      return _mockConvertTamil(sentence);
    }
  }

  // ─── FEATURE 3.5: Akaran Interactive Mentor ────────────────────────────
  static Future<String> chatWithAkaran({
    required List<Map<String, String>> messages,
    required int childAge,
    required bool regionalMode,
  }) async {
    if (_useMockFallback) {
      debugPrint('ClaudeApiService: Using mock fallback for Akaran chat.');
      return _mockAkaranChat();
    }

    final systemPrompt = '''
You are அகர்ன் (Akaran), an interactive Tamil communication mentor inside the Akaravalam learning platform for children aged $childAge.

Your mission is to help students master both forms of Tamil:
- Written Tamil (எழுத்து தமிழ்)
- Spoken Tamil (பேச்சு தமிழ்)

Teach students how Tamil is naturally used in:
- schools,
- homes,
- friendships,
- texting,
- public conversations,
- and regional communication.

━━━━━━━━━━━━━━━━━━
CORE OBJECTIVE
━━━━━━━━━━━━━━━━━━
Every lesson must include:
- Written Tamil
- Spoken Tamil
- Transliteration
- English meaning
- Real-world usage explanation

Never teach only one form.

━━━━━━━━━━━━━━━━━━
IMPORTANT LANGUAGE PRINCIPLE
━━━━━━━━━━━━━━━━━━
Never describe spoken Tamil as:
- wrong,
- broken,
- lazy,
- or incorrect.

Instead explain:
Written Tamil is used in: essays, books, exams, formal speeches.
Spoken Tamil is used in: daily conversations, homes, friendships, and natural communication.

Teach students that fluent Tamil speakers switch naturally between both styles depending on the situation.

━━━━━━━━━━━━━━━━━━
LESSON STRUCTURE
━━━━━━━━━━━━━━━━━━
STEP 1 — INTRODUCTION
Start with curiosity.

STEP 2 — SIDE-BY-SIDE FORMAT
Always display:
Written Tamil (எழுத்து தமிழ்): sentence, transliteration, formal usage context
Spoken Tamil (பேச்சு தமிழ்): sentence, transliteration, conversational usage context
English Meaning: natural translation

STEP 3 — PATTERN EXPLANATION
Teach language transformation patterns clearly (e.g. கிற → ற, கள் → ங்க).

STEP 4 — REAL-LIFE CONTEXT
Always connect lessons to practical situations.

STEP 5 — SPEAKING PRACTICE
Encourage learners to repeat both versions aloud.

━━━━━━━━━━━━━━━━━━
TEACHING STYLE
━━━━━━━━━━━━━━━━━━
The assistant should sound: friendly, supportive, interactive, modern, encouraging, easy to understand.
Avoid: robotic explanations, overly academic teaching, harsh corrections, or language shaming.
Output in natural conversational Markdown.

━━━━━━━━━━━━━━━━━━
REGIONAL TAMIL MODE: ${regionalMode ? 'ENABLED' : 'DISABLED'}
━━━━━━━━━━━━━━━━━━
When Regional Mode is enabled, teach regional spoken styles respectfully (Chennai Tamil, Madurai Tamil, Coimbatore Tamil, Sri Lankan Tamil).

━━━━━━━━━━━━━━━━━━
GAME MODES
━━━━━━━━━━━━━━━━━━
1. Spot the Spoken: Identify whether a sentence is written or spoken Tamil.
2. Fix It!: Convert written Tamil into spoken Tamil.
3. Flip It!: Convert spoken Tamil into written Tamil.
4. Street Scene: Choose the correct Tamil style for real-world situations.
5. Voice Comparison: Compare formal pronunciation and conversational pronunciation.

━━━━━━━━━━━━━━━━━━
RESPONSE FORMAT
━━━━━━━━━━━━━━━━━━
Use clear Markdown with formatting like:
**Written Tamil (எழுத்து தமிழ்):** ...
**Spoken Tamil (பேச்சு தமிழ்):** ...
**Rule:** ...
**Practice Challenge:** ...
Always end positively!
''';

    try {
      return await _callClaudeChat(
        systemPrompt: systemPrompt,
        messages: messages,
      );
    } catch (e) {
      debugPrint('ClaudeApiService: Live API call failed ($e). Falling back to mock data for Akaran chat.');
      return _mockAkaranChat();
    }
  }

  // ─── FEATURE 4: Tamil Riddle Game ────────────────────────────────────
  static Future<Map<String, dynamic>> generateRiddle({
    required String category,
    required String difficulty,
    required int childAge,
    List<String> shownRiddles = const [],
  }) async {
    if (_useMockFallback) {
      debugPrint('ClaudeApiService: Using fallback mock data for generateRiddle (Category: $category)');
      return _mockGenerateRiddle(category, difficulty);
    }

    const systemPrompt = '''
You are a Tamil riddle (விடுகதை) master for children.
Tamil riddles are a 2000-year-old oral tradition. You know hundreds of them.

Generate age-appropriate Tamil riddles with hints and fun explanations.

Return ONLY this JSON:

{
  "riddle_tamil": "காலில்லாமல் ஓடும், கையில்லாமல் பிடிக்கும் — அது என்ன?",
  "riddle_transliteration": "Kaalillamal odum, kaiyillamal pidikkum — adhu enna?",
  "riddle_english": "It runs without legs, it holds without hands — what is it?",
  "answer_tamil": "நதி",
  "answer_english": "River",
  "answer_transliteration": "Nathi",
  "hint_1": "இது இயற்கையில் காணப்படும்",
  "hint_2": "மழை பெய்தால் இது பெரிதாகும்",
  "explanation": "நதிக்கு கால் இல்லாமலே ஓடும் சக்தி உண்டு! அது பாறைகளை பிடிக்கும் வலிமையும் உண்டு.",
  "fun_fact": "தமிழ்நாட்டின் பெரிய நதி காவிரி ஆறு!",
  "category": "nature",
  "difficulty": "easy",
  "age_group": "6-10"
}

Riddle categories: nature, animals, body_parts, food, home_objects, sky, school
Difficulty levels: easy (age 5-7), medium (age 8-10), hard (age 11-14)

Never repeat the same riddle twice in a conversation.
No extra text. JSON only.
''';

    try {
      return await _callClaude(
        systemPrompt: systemPrompt,
        userMessage: '''
Category: $category
Difficulty: $difficulty
Child age: $childAge
Already shown riddles: ${shownRiddles.join(', ')}
''',
      );
    } catch (e) {
      debugPrint('ClaudeApiService: Live API call failed ($e). Falling back to mock data for generateRiddle.');
      return _mockGenerateRiddle(category, difficulty);
    }
  }

  // ─── FEATURE 5: Child Creates Tamil Story ───────────────────────────
  static Future<Map<String, dynamic>> generateStory({
    required String hero,
    required String place,
    required String problem,
    required String childName,
    required int childAge,
  }) async {
    if (_useMockFallback) {
      debugPrint('ClaudeApiService: Using fallback mock data for generateStory (Hero: $hero, Place: $place)');
      return _mockGenerateStory(hero, place, problem, childName, childAge);
    }

    const systemPrompt = '''
You are a Tamil children's story writer. You create short, fun, illustrated
Tamil stories based on what the child chooses.

The story must:
- Be written in simple Tamil (suitable for age 6-12)
- Have exactly 6 scenes (each scene = 2-3 sentences)
- Teach a small moral at the end
- Include 3 comprehension quiz questions

Return ONLY this JSON:

{
  "story_title_tamil": "விண்வெளி குரங்கின் சாகசம்",
  "story_title_english": "The Space Monkey's Adventure",
  "hero": "குரங்கு",
  "place": "விண்வெளி",
  "moral_tamil": "தைரியமாக முயன்றால் எதையும் சாதிக்கலாம்.",
  "moral_english": "If you try bravely, you can achieve anything.",
  "scenes": [
    {
      "scene_number": 1,
      "text_tamil": "ஒரு சின்னக் குரங்கு விண்வெளிக்கு போக வேண்டும் என்று கனவு கண்டது.",
      "text_english": "A little monkey dreamed of going to space.",
      "image_prompt": "cute cartoon monkey looking at stars through window at night, Tamil children's book style"
    }
  ],
  "quiz": [
    {
      "question": "குரங்கு எங்கே போக வேண்டும் என்று கனவு கண்டது?",
      "correct": "விண்வெளி",
      "options": ["கடல்", "விண்வெளி", "காடு", "மலை"]
    }
  ],
  "new_words_learned": [
    { "tamil": "விண்வெளி", "english": "Space", "transliteration": "Vinveli" }
  ]
}

Rules:
- Tamil must be simple, no complex grammar
- Every scene must be exciting and move the story forward
- image_prompt must be in English (for image generation API)
- moral must connect to the story's problem
- No extra text. JSON only.
''';

    try {
      return await _callClaude(
        systemPrompt: systemPrompt,
        userMessage: '''
Hero: $hero
Place: $place
Problem: $problem
Child name: $childName
Child age: $childAge
''',
      );
    } catch (e) {
      debugPrint('ClaudeApiService: Live API call failed ($e). Falling back to mock data for generateStory.');
      return _mockGenerateStory(hero, place, problem, childName, childAge);
    }
  }

  // ─── MOCK RESPONSERS (FALLBACK FOR LOCAL TESTING) ───────────────────────

  static Map<String, dynamic> _mockKinshipWord(String relation) {
    final lowerRelation = relation.toLowerCase();
    
    if (lowerRelation.contains('sister') && lowerRelation.contains('younger')) {
      return {
        'tamil_word': 'தங்கை',
        'transliteration': 'Thangai',
        'meaning_english': 'Younger Sister',
        'meaning_tamil': 'உடன் பிறந்த இளைய பெண்',
        'fun_fact': 'தங்கை உனது சிறந்த தோழியாகவும் அன்பானவளாகவும் இருப்பாள்!',
        'example_sentence': 'எனது தங்கை அழகாக ஓவியம் வரைந்தாள்.',
        'quiz': [
          {
            'question': 'உடன் பிறந்த இளைய பெண்ணை எப்படி அழைப்போம்?',
            'correct': 'தங்கை',
            'options': ['தங்கை', 'அக்கா', 'அத்தை', 'பாட்டி']
          }
        ]
      };
    } else if (lowerRelation.contains('mother') && lowerRelation.contains('younger') && lowerRelation.contains('sister')) {
      return {
        'tamil_word': 'சித்தி',
        'transliteration': 'Chitti',
        'meaning_english': "Mother's younger sister",
        'meaning_tamil': 'அம்மாவின் தங்கை',
        'fun_fact': 'சித்தி உன்னை அம்மாவைப் போலவே நேசிப்பாள்!',
        'example_sentence': 'சித்தி என்னிடம் சுவையான மிட்டாய் தந்தாள்.',
        'quiz': [
          {
            'question': 'அம்மாவின் தங்கையை என்ன சொல்வோம்?',
            'correct': 'சித்தி',
            'options': ['சித்தி', 'அத்தை', 'பெரியம்மா', 'பாட்டி']
          }
        ]
      };
    } else if (lowerRelation.contains('father') && lowerRelation.contains('brother')) {
      return {
        'tamil_word': 'சித்தப்பா',
        'transliteration': 'Chithappa',
        'meaning_english': "Father's younger brother",
        'meaning_tamil': 'அப்பாவின் தம்பி',
        'fun_fact': 'சித்தப்பா உனது இரண்டாவது தந்தை போன்றவர்!',
        'example_sentence': 'சித்தப்பா எனக்கு ஒரு புதிய மிதிவண்டி வாங்கித் தந்தார்.',
        'quiz': [
          {
            'question': 'அப்பாவின் தம்பியை எவ்வாறு அழைப்போம்?',
            'correct': 'சித்தப்பா',
            'options': ['சித்தப்பா', 'பெரியப்பா', 'மாமா', 'தாத்தா']
          }
        ]
      };
    } else {
      return {
        'tamil_word': 'உறவினர்',
        'transliteration': 'Uravinar',
        'meaning_english': 'Relative / Family member',
        'meaning_tamil': 'குழுமத்தின் உறவு உறுப்பினர்',
        'fun_fact': 'தமிழ் உறவுமுறை உலகிலேயே மிக அழகானது மற்றும் ஒழுங்குடையது!',
        'example_sentence': 'அன்பான உறவினர்கள் நமது மகிழ்ச்சிக்கு காரணமாவர்.',
        'quiz': [
          {
            'question': 'குடும்ப உறவுகளைக் குறிக்கும் பொதுவான தமிழ்ச் சொல் எது?',
            'correct': 'உறவினர்',
            'options': ['உறவினர்', 'நண்பர்கள்', 'ஆசிரியர்கள்', 'அயலவர்கள்']
          }
        ]
      };
    }
  }

  static Map<String, dynamic> _mockExplainScannedText(String scannedText) {
    final cleanText = scannedText.trim();
    if (cleanText.contains('வணிகம்')) {
      return {
        'full_text': 'வணிகம்',
        'words': [
          {
            'word': 'வணிகம்',
            'transliteration': 'Vanigam',
            'meaning': 'Commerce / Business / Trade',
            'example': 'பண்டைய காலத்திலிருந்தே தமிழர்கள் கடல் கடந்து வணிகம் செய்தனர்.',
            'fun_fact': 'தமிழ்நாடு நீண்ட கடல் எல்லையைக் கொண்டிருப்பதால் உலக நாடுகளுடன் கப்பல் வணிகத்தில் சிறந்து விளங்கியது!'
          }
        ],
        'full_meaning': 'Commerce and business trade.',
        'quiz': [
          {
            'question': 'வணிகம் என்ற சொல்லின் பொருள் என்ன?',
            'correct': 'வியாபாரம் / Trade',
            'options': ['விளையாட்டு', 'வியாபாரம் / Trade', 'பாட்டு', 'காடு']
          }
        ]
      };
    } else if (cleanText.contains('வணக்கம்')) {
      return {
        'full_text': 'வணக்கம் தமிழ் நாடு',
        'words': [
          {
            'word': 'வணக்கம்',
            'transliteration': 'Vanakkam',
            'meaning': 'Hello / Respectful greetings',
            'example': 'பெரியவர்களைக் காணும்போது வணக்கம் கூற வேண்டும்.',
            'fun_fact': 'வணக்கம் என்பது இரு கைகளைக் கூப்பி தமிழர்கள் தெரிவிக்கும் மிக உயர்ந்த பண்பாட்டு வாழ்த்து!'
          },
          {
            'word': 'தமிழ்நாடு',
            'transliteration': 'Tamil Nadu',
            'meaning': 'The land of Tamil',
            'example': 'எனது தாய்நாடு தமிழ்நாடு ஆகும்.',
            'fun_fact': 'தமிழ்நாடு கலை, இலக்கியம், கோவில்கள் மற்றும் கலாச்சாரத்தில் உலகப் புகழ் பெற்றது!'
          }
        ],
        'full_meaning': 'Greetings to Tamil Nadu',
        'quiz': [
          {
            'question': 'தமிழர்களின் பாரம்பரிய வாழ்த்துச் சொல் எது?',
            'correct': 'வணக்கம்',
            'options': ['வணக்கம்', 'நன்றி', 'வாழ்க', 'வரவேற்பு']
          }
        ]
      };
    } else {
      return {
        'full_text': cleanText,
        'words': [
          {
            'word': cleanText,
            'transliteration': 'Tamil vaarthai',
            'meaning': 'Delightful word or phrase',
            'example': 'அகர முதல எழுத்தெல்லாம் ஆதி பகவன் முதற்றே உலகு.',
            'fun_fact': 'தமிழ் மொழி உலகின் மிகத் தொன்மையான இலக்கண, இலக்கிய வளங்களைக் கொண்ட உயர்தனிச் செம்மொழியாகும்!'
          }
        ],
        'full_meaning': 'Exploring beautiful Tamil language concepts',
        'quiz': [
          {
            'question': 'The scanned word represents:',
            'correct': 'A beautiful Tamil concept',
            'options': ['A beautiful Tamil concept', 'An English word', 'A number', 'A shape']
          }
        ]
      };
    }
  }

  static Map<String, dynamic> _mockConvertTamil(String sentence) {
    return {
      'written_tamil': sentence.isNotEmpty ? sentence : 'நான் பள்ளிக்கூடம் போகிறேன்.',
      'spoken_tamil': 'நான் இஸ்கூலுக்கு போறேன்.',
      'written_transliteration': 'Naan pallikkoodam pogireen',
      'spoken_transliteration': 'Naan iskoolukkup pooreen',
      'english': 'I am going to school.',
      'difference_explained': 'எழுத்துத் தமிழில் \'பள்ளிக்கூடம் போகிறேன்\' என்று முறைப்படி எழுதுவோம். ஆனால் பேசும்போது எளிமையாக \'இஸ்கூலுக்கு போறேன்\' என்று பேச்சுத் வழக்கில் பேசுவோம்!',
      'key_changes': [
        { 'formal': 'பள்ளிக்கூடம்', 'spoken': 'இஸ்கூலுக்கு', 'rule': 'ஆங்கிலக் கலப்பு வழக்கு' },
        { 'formal': 'போகிறேன்', 'spoken': 'போறேன்', 'rule': 'நடு எழுத்து குறைதல் (கிற -> ற)' }
      ],
      'practice_tip': 'நண்பர்களிடம் பேசும்போது இந்த எளிய பேச்சுத் தமிழ் வடிவங்களைப் பயன்படுத்தி பழகு!',
      'quiz': [
        {
          'question': 'பேச்சு தமிழில் \'போகிறேன்\' என்பதை எப்படி எளிய வழக்கில் கூறுவோம்?',
          'correct': 'போறேன்',
          'options': ['போகிறேன்', 'போறேன்', 'போனேன்', 'போவேன்']
        }
      ]
    };
  }

  static String _mockAkaranChat() {
    return '''வணக்கம்! நான் அகர்ன் (Akaran), உனது தமிழ் வழிகாட்டி! 

இன்று நாம் எப்படி இயற்கையாக பேசுவது என்று கற்றுக்கொள்ளலாம்.

**Written Tamil (எழுத்து தமிழ்):**
நான் பள்ளிக்கூடம் போகிறேன்
(Naan pallikkoodam pōgiṟēn)
*Used in: essays, exams, formal writing.*

**Spoken Tamil (பேச்சு தமிழ்):**
நான் school-ku போறேன்
(Naan school-ku pōrēn)
*Used in: daily conversations, talking with friends and family.*

**Pattern Notice:**
"போகிறேன்" becomes "போறேன்"

**Rule:**
- "கிற" → "ற"

**Practice Challenge:**
Say the written version first. Now say the spoken version. Notice how spoken Tamil flows more naturally in conversation.

இப்போ நீ இரண்டும் தெரிஞ்ச ஆளு!
''';
  }

  static Map<String, dynamic> _mockGenerateRiddle(String category, String difficulty) {
    if (category == 'nature') {
      return {
        'riddle_tamil': 'காலில்லாமல் ஓடும், கையில்லாமல் பிடிக்கும் — அது என்ன?',
        'riddle_transliteration': 'Kaalillamal odum, kaiyillamal pidikkum — adhu enna?',
        'riddle_english': 'It runs without legs, it holds without hands — what is it?',
        'answer_tamil': 'நதி',
        'answer_english': 'River',
        'answer_transliteration': 'Nathi',
        'hint_1': 'இது மலைகளில் தொடங்கி கடலை நோக்கி பாயும்.',
        'hint_2': 'மீன்கள் இதில் நீந்தி விளையாடும்.',
        'explanation': 'நதிக்கு கால்கள் இல்லையென்றாலும் தொடர்ந்து ஓடிக்கொண்டே இருக்கும். அது எதையும் பிடிக்கும் ஆற்றல் கொண்டது.',
        'fun_fact': 'தமிழ்நாட்டின் மிக நீண்ட மற்றும் புனிதமான ஆறு காவிரி ஆறு ஆகும்!',
        'category': category,
        'difficulty': difficulty,
        'age_group': '6-12'
      };
    } else if (category == 'animals') {
      return {
        'riddle_tamil': 'நான்கு கால்கள் உண்டு, ஆனால் நடக்க முடியாது, உணவு உண்ண உதவும் — அது என்ன?',
        'riddle_transliteration': 'Naangu kaalgal undu, aanaal nadakka mudiyaadhu, unavu unna uthavum — adhu enna?',
        'riddle_english': 'Has four legs but cannot walk, helps you eat food — what is it?',
        'answer_tamil': 'மேஜை',
        'answer_english': 'Table',
        'answer_transliteration': 'Mejai',
        'hint_1': 'இது மரத்தினால் செய்யப்பட்டிருக்கலாம்.',
        'hint_2': 'இதன் மேல் புத்தகங்களை வைத்து படிப்பாய்.',
        'explanation': 'மேஜைக்கு நான்கு கால்கள் வடிவத்தில் இருந்தாலும் அதற்கு உயிர் இல்லாததால் நடக்க முடியாது. ஆனால் நாம் உட்காரவும் படிக்கவும் பயன்படும்.',
        'fun_fact': 'பண்டைய காலத்தில் மக்கள் தரையிலேயே அமர்ந்து சாப்பிட்டு வந்தனர்!',
        'category': category,
        'difficulty': difficulty,
        'age_group': '6-12'
      };
    } else {
      return {
        'riddle_tamil': 'உடம்பெல்லாம் கண், ஆனால் பார்வை இல்லை — அது என்ன?',
        'riddle_transliteration': 'Udambellaam kan, aanaal paarvai illai — adhu enna?',
        'riddle_english': 'Eyes all over the body, but has no sight — what is it?',
        'answer_tamil': 'அன்னாசி பழம்',
        'answer_english': 'Pineapple',
        'answer_transliteration': 'Annaasi pazham',
        'hint_1': 'இது ஒரு சுவையான இனிப்பு மற்றும் புளிப்பு பழம்.',
        'hint_2': 'அதன் மேல் பகுதியில் ஒரு பச்சை கிரீடம் போன்ற இலைகள் இருக்கும்.',
        'explanation': 'அன்னாசி பழத்தின் தோலில் இருக்கும் புள்ளிகளை நாம் \'கண்\' என்று அழைப்போம். ஆனால் அதற்கு பார்வை கிடையாது.',
        'fun_fact': 'அன்னாசி பழத்தில் வைட்டமின் சி சத்து மிக அதிக அளவில் நிறைந்துள்ளது!',
        'category': category,
        'difficulty': difficulty,
        'age_group': '6-12'
      };
    }
  }

  static Map<String, dynamic> _mockGenerateStory(
    String hero,
    String place,
    String problem,
    String childName,
    int childAge,
  ) {
    return {
      'story_title_tamil': 'சின்னஞ்சிறு முயலும் தங்கக் கேரட்டும்',
      'story_title_english': 'The Little Rabbit and the Golden Carrot',
      'hero': hero,
      'place': place,
      'moral_tamil': 'விடாமுயற்சியே எந்தவொரு கடினமான சூழ்நிலையிலும் வெற்றிக்கு வழிவகுக்கும்.',
      'moral_english': 'Perseverance and brave efforts always lead to beautiful victory.',
      'scenes': [
        {
          'scene_number': 1,
          'text_tamil': 'ஒரு அழகிய அடர்ந்த காட்டில், $childName என்ற ஒரு சுட்டி முயல் மிகவும் மகிழ்ச்சியாக வாழ்ந்து வந்தது.',
          'text_english': 'In a beautiful dense forest, a playful rabbit named $childName lived very happily.',
          'image_prompt': 'cute cartoon rabbit playing in green lush forest, children book illustration style'
        },
        {
          'scene_number': 2,
          'text_tamil': 'ஒரு நாள், அந்த முயல் காட்டின் நடுவே இருக்கும் ஒரு ரகசிய தங்கக் கேரட்டைப் பற்றி கேள்விப்பட்டது.',
          'text_english': 'One day, the rabbit heard about a secret golden carrot in the middle of the forest.',
          'image_prompt': 'cute cartoon rabbit thinking of a glowing golden carrot, children book illustration style'
        },
        {
          'scene_number': 3,
          'text_tamil': '$childName அந்தத் தங்கக் கேரட்டைத் தேடி தனது சாகசப் பயணத்தை உடனே தொடங்கியது.',
          'text_english': '$childName immediately started its adventurous journey in search of the golden carrot.',
          'image_prompt': 'cute cartoon rabbit walking on a sunny path, children book illustration style'
        },
        {
          'scene_number': 4,
          'text_tamil': 'வழியில் ஒரு ஆழமான மற்றும் வேகமாக ஓடும் ஆறு அதன் பாதையை முழுமையாக மறித்தது.',
          'text_english': 'On the way, a deep and fast-flowing river completely blocked its path.',
          'image_prompt': 'cute cartoon rabbit looking at a flowing river, children book illustration style'
        },
        {
          'scene_number': 5,
          'text_tamil': 'அப்போது அங்கே வந்த ஒரு அன்பான பெரிய ஆமை, முயலைத் தனது முதுகில் ஏற்றி ஆற்றைக் கடக்க உதவியது.',
          'text_english': 'A kind big turtle arrived there and helped the rabbit cross the river on its back.',
          'image_prompt': 'cute cartoon rabbit riding on a big friendly turtle crossing river, children book illustration style'
        },
        {
          'scene_number': 6,
          'text_tamil': 'ஆற்றைக் கடந்த முயல், இறுதியில் பிரகாசமான தங்கக் கேரட்டைக் கண்டுபிடித்துப் பெருமகிழ்ச்சி அடைந்தது.',
          'text_english': 'Crossing the river, the rabbit finally found the glowing golden carrot and was extremely happy.',
          'image_prompt': 'cute cartoon rabbit hugging a glowing golden carrot happily, children book illustration style'
        }
      ],
      'quiz': [
        {
          'question': 'முயல் காட்டில் எதைத் தேடிப் பயணம் செய்தது?',
          'correct': 'தங்கக் கேரட்',
          'options': ['ஆப்பிள்', 'தங்கக் கேரட்', 'முட்டைக்கோஸ்', 'தக்காளி']
        },
        {
          'question': 'முயலுக்கு ஆற்றைக் கடக்க உதவிய விலங்கு எது?',
          'correct': 'ஆமை',
          'options': ['மீன்', 'ஆமை', 'தவளை', 'நண்டு']
        }
      ],
      'new_words_learned': [
        { 'tamil': 'முயல்', 'english': 'Rabbit', 'transliteration': 'Muyal' },
        { 'tamil': 'ஆமை', 'english': 'Turtle', 'transliteration': 'Aamai' },
        { 'tamil': 'காடு', 'english': 'Forest', 'transliteration': 'Kaadu' }
      ]
    };
  }
}
