import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:characters/characters.dart';
import '../constants/dictionary_data.dart';

class DictionaryDbService {
  static final DictionaryDbService _instance = DictionaryDbService._internal();
  factory DictionaryDbService() => _instance;
  DictionaryDbService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tamil_dictionary.db');

    return await openDatabase(
      path,
      version: 5, // Bumped to 5 to force re-seed with better common words + examples
      onUpgrade: (db, oldVersion, newVersion) async {
        await _dropTables(db);
        await _createTables(db);
        await _seedCommonData(db);
        await _seedHugeData(db);
      },
      onCreate: (Database db, int version) async {
        await _createTables(db);
        await _seedCommonData(db);
        await _seedHugeData(db);
      },
    );
  }

  Future<void> _dropTables(Database db) async {
    await db.execute('DROP TABLE IF EXISTS words');
    await db.execute('DROP TABLE IF EXISTS word_types');
    await db.execute('DROP TABLE IF EXISTS categories');
    await db.execute('DROP TABLE IF EXISTS synonyms');
    await db.execute('DROP TABLE IF EXISTS antonyms');
    await db.execute('DROP TABLE IF EXISTS examples');
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE word_types(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type_name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE words(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL,
        english_meaning TEXT,
        tamil_meaning TEXT,
        pronunciation TEXT,
        type_id INTEGER,
        category_id INTEGER,
        alphabet_start TEXT,
        is_favorite INTEGER DEFAULT 0,
        is_common INTEGER DEFAULT 0,
        FOREIGN KEY(type_id) REFERENCES word_types(id),
        FOREIGN KEY(category_id) REFERENCES categories(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE synonyms(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id INTEGER,
        synonym TEXT NOT NULL,
        FOREIGN KEY(word_id) REFERENCES words(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE antonyms(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id INTEGER,
        antonym TEXT NOT NULL,
        FOREIGN KEY(word_id) REFERENCES words(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE examples(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id INTEGER,
        example_tamil TEXT NOT NULL,
        example_english TEXT NOT NULL,
        FOREIGN KEY(word_id) REFERENCES words(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_word_text ON words(word)');
    await db.execute('CREATE INDEX idx_alphabet ON words(alphabet_start)');
    await db.execute('CREATE INDEX idx_type ON words(type_id)');
    await db.execute('CREATE INDEX idx_category ON words(category_id)');
    await db.execute('CREATE INDEX idx_favorites ON words(is_favorite)');
    await db.execute('CREATE INDEX idx_common ON words(is_common)');
  }

  static Map<String, dynamic> _parseJson(String jsonStr) {
    return json.decode(jsonStr) as Map<String, dynamic>;
  }

  Future<void> _seedCommonData(Database db) async {
    final commonList = DictionaryData.commonWords;
    Batch batch = db.batch();
    
    await db.insert('categories', {'id': 100, 'category_name': 'Common Words'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('word_types', {'id': 100, 'type_name': 'General (பொது)'}, conflictAlgorithm: ConflictAlgorithm.ignore);

    for (var item in commonList) {
      String w = item['word'] ?? '';
      String alphabet = '';
      try { alphabet = Characters(w).first; } catch(_) { alphabet = w.substring(0, 1); }
      
      batch.insert('words', {
        'word': w,
        'english_meaning': item['english_meaning'],
        'tamil_meaning': item['tamil_meaning'],
        'pronunciation': w,
        'type_id': 100,
        'category_id': 100,
        'alphabet_start': alphabet,
        'is_common': 1
      });
    }

    try {
      final jsonStr = await rootBundle.loadString('assets/data/tamil_dictionary.json');
      final List<dynamic> localDict = json.decode(jsonStr);
      for (var item in localDict) {
        String w = item['word'] ?? '';
        String alphabet = '';
        try { alphabet = Characters(w).first; } catch(_) { alphabet = w.substring(0, 1); }

        int wordId = await db.insert('words', {
          'word': w,
          'english_meaning': item['meaning'],
          'tamil_meaning': item['meaning'], 
          'pronunciation': w,
          'type_id': 100,
          'category_id': 100,
          'alphabet_start': alphabet,
          'is_common': 1
        }, conflictAlgorithm: ConflictAlgorithm.ignore);

        if (wordId > 0 && item['example'] != null) {
          batch.insert('examples', {
            'word_id': wordId,
            'example_tamil': item['example'],
            'example_english': 'Verified Example'
          });
        }
      }
    } catch (e) {
      debugPrint("Info: tamil_dictionary.json skipping...");
    }

    await batch.commit(noResult: true);
  }

  Future<void> _seedHugeData(Database db) async {
    String jsonString = '';
    try {
      jsonString = await rootBundle.loadString('assets/data/v_word_list.json');
    } catch (_) {
      debugPrint("Warning: v_word_list.json not found in assets.");
      return; 
    }

    final Map<String, dynamic> parsedJson = await compute(_parseJson, jsonString);
    final List<dynamic> wordList = parsedJson['wordList'];

    int nounId = 1, verbId = 2, adjId = 3, genId = 4;
    
    Batch typeBatch = db.batch();
    typeBatch.insert('word_types', {'id': nounId, 'type_name': 'Noun (பெயர்ச்சொல்)'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    typeBatch.insert('word_types', {'id': verbId, 'type_name': 'Verb (வினைச்சொல்)'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    typeBatch.insert('word_types', {'id': adjId, 'type_name': 'Adjective (உரிச்சொல்)'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    typeBatch.insert('word_types', {'id': genId, 'type_name': 'General (பொது)'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await typeBatch.commit(noResult: true);

    await db.insert('categories', {'id': 1, 'category_name': 'Vocabulary (சொற்களஞ்சியம்)'}, conflictAlgorithm: ConflictAlgorithm.ignore);

    final int chunkSize = 5000;
    Batch batch = db.batch();
    int count = 0;

    for (var item in wordList) {
      String w = item['word']?.toString().trim() ?? '';
      String m = item['meaning']?.toString().trim() ?? '';
      if (w.isEmpty) continue;

      int tId = genId;
      if (m.startsWith('(பெ)')) tId = nounId;
      else if (m.startsWith('(வி)')) tId = verbId;
      else if (m.startsWith('(உ)')) tId = adjId;

      String alphabet = '';
      try { alphabet = Characters(w).first; } catch(_) { alphabet = w.substring(0, 1); }

      batch.insert('words', {
        'word': w,
        'english_meaning': 'Translation Pending',
        'tamil_meaning': m,
        'pronunciation': w,
        'type_id': tId,
        'category_id': 1,
        'alphabet_start': alphabet,
        'is_favorite': 0,
        'is_common': 0
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      count++;
      if (count % chunkSize == 0) {
        await batch.commit(noResult: true);
        batch = db.batch();
      }
    }

    if (count % chunkSize != 0) {
      await batch.commit(noResult: true);
    }
  }

  Future<List<Map<String, dynamic>>> getWords({
    int limit = 20,
    int offset = 0,
    String? searchQuery,
    String? typeFilter,
    String? categoryFilter,
    String? alphabetFilter,
    bool favoritesOnly = false,
  }) async {
    final db = await database;
    
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (searchQuery != null && searchQuery.isNotEmpty) {
      whereClause += ' AND (w.word LIKE ? OR w.tamil_meaning LIKE ? OR w.english_meaning LIKE ?)';
      whereArgs.add('%$searchQuery%');
      whereArgs.add('%$searchQuery%');
      whereArgs.add('%$searchQuery%');
    }

    if (typeFilter != null && typeFilter != 'All') {
      whereClause += ' AND t.type_name = ?';
      whereArgs.add(typeFilter);
    }

    if (categoryFilter != null && categoryFilter != 'All') {
      whereClause += ' AND c.category_name = ?';
      whereArgs.add(categoryFilter);
    }

    if (alphabetFilter != null && alphabetFilter != 'All') {
      whereClause += ' AND w.alphabet_start = ?';
      whereArgs.add(alphabetFilter);
    }

    if (favoritesOnly) {
      whereClause += ' AND w.is_favorite = 1';
    }

    final sql = '''
      SELECT 
        w.id, w.word, w.english_meaning, w.tamil_meaning, w.pronunciation, w.is_favorite, w.is_common,
        t.type_name, c.category_name, w.alphabet_start
      FROM words w
      LEFT JOIN word_types t ON w.type_id = t.id
      LEFT JOIN categories c ON w.category_id = c.id
      WHERE $whereClause
      ORDER BY w.is_common DESC, w.word ASC
      LIMIT $limit OFFSET $offset
    ''';

    return await db.rawQuery(sql, whereArgs);
  }

  Future<Map<String, dynamic>> getWordDetails(int wordId) async {
    final db = await database;
    
    final wordObjList = await db.rawQuery('''
      SELECT w.*, t.type_name, c.category_name 
      FROM words w
      LEFT JOIN word_types t ON w.type_id = t.id
      LEFT JOIN categories c ON w.category_id = c.id
      WHERE w.id = ?
    ''', [wordId]);

    if (wordObjList.isEmpty) return {};
    
    final result = Map<String, dynamic>.from(wordObjList.first);
    
    result['synonyms'] = [];
    result['antonyms'] = [];
    result['examples'] = [];

    final syncList = await db.query('synonyms', where: 'word_id = ?', whereArgs: [wordId]);
    result['synonyms'] = syncList.map((e) => e['synonym']).toList();

    final antList = await db.query('antonyms', where: 'word_id = ?', whereArgs: [wordId]);
    result['antonyms'] = antList.map((e) => e['antonym']).toList();

    final exList = await db.query('examples', where: 'word_id = ?', whereArgs: [wordId]);
    result['examples'] = exList;

    return result;
  }

  Future<void> toggleFavorite(int id, int currentState) async {
    final db = await database;
    await db.update(
      'words',
      {'is_favorite': currentState == 1 ? 0 : 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<String>> getWordTypes() async {
    final db = await database;
    final res = await db.query('word_types', orderBy: 'type_name');
    return res.map((e) => e['type_name'] as String).toList();
  }

  Future<List<String>> getCategories() async {
    final db = await database;
    final res = await db.query('categories', orderBy: 'category_name');
    return res.map((e) => e['category_name'] as String).toList();
  }

  Future<Map<String, dynamic>?> getRandomWordOfDay() async {
    final db = await database;
    final res = await db.rawQuery('''
      SELECT w.id, w.word, w.tamil_meaning, w.english_meaning, t.type_name
      FROM words w
      LEFT JOIN word_types t ON w.type_id = t.id
      ORDER BY RANDOM() LIMIT 1
    ''');
    if (res.isNotEmpty) return res.first;
    return null;
  }
}
