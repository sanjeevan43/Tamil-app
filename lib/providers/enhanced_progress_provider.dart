import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firestore_service.dart';
import '../data/reading_journey_data.dart';

class EnhancedProgressProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  String? _userId;

  // Student Data
  String _userName = 'Student';
  String _avatar = '👦';
  String _region = 'India';
  int _level = 1;
  int _totalCoins = 0;
  int _totalStars = 0;
  int _streakDays = 0;
  int _totalLettersLearned = 0;
  int _quizScore = 0;
  
  // Engagement
  List<String> _achievementBadges = [];
  List<String> _inventory = ['standard'];
  List<int> _unlockedLessons = [1, 2, 3];
  Map<int, int> _lessonProgress = {};
  Map<String, int> _storyQuizScores = {};
  Map<String, bool> _completedTasks = {};
  
  // Teacher Mode
  bool _isTeacherMode = false;
  List<String> _assignedHomework = [];
  List<Map<String, String>> _discussions = [];
  List<Map<String, dynamic>> _assignedQuizzes = [];
  String _globalNotice = 'Welcome to அகரவளம்!';
  List<String> _streakHistory = [];
  String _lastRewardDate = '';
  
  // Daily Missions
  List<Map<String, dynamic>> _dailyMissions = [
    {'id': 'quiz_master', 'title': 'Complete 5 Quiz Rounds', 'target': 5, 'current': 0, 'completed': false},
    {'id': 'letter_pro', 'title': 'Learn 10 New Letters', 'target': 10, 'current': 0, 'completed': false},
    {'id': 'game_hero', 'title': 'Play any 3 Games', 'target': 3, 'current': 0, 'completed': false},
  ];
  
  // Getters
  String get userName => _userName;
  String get avatar => _avatar;
  String get region => _region;
  int get level => _level;
  int get totalCoins => _totalCoins;
  int get totalStars => _totalStars;
  int get streakDays => _streakDays;
  int get totalLettersLearned => _totalLettersLearned;
  int get quizScore => _quizScore;
  List<String> get achievementBadges => _achievementBadges;
  List<String> get inventory => _inventory;
  List<int> get unlockedLessons => _unlockedLessons;
  Map<int, int> get lessonProgress => _lessonProgress;
  Map<String, int> get storyQuizScores => _storyQuizScores;
  Map<String, bool> get completedTasks => _completedTasks;
  bool get isTeacherMode => _isTeacherMode;
  List<String> get assignedHomework => _assignedHomework;
  List<Map<String, String>> get discussions => _discussions;
  List<Map<String, dynamic>> get assignedQuizzes => _assignedQuizzes;
  String get globalNotice => _globalNotice;
  List<Map<String, dynamic>> get dailyMissions => _dailyMissions;
  List<String> get streakHistory => _streakHistory;
  String get lastRewardDate => _lastRewardDate;
  String? get userId => _userId;

  Future<void> initializeProgress({String? uid}) async {
    _userId = uid;
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // If we have a UID, try to fetch from cloud first
      if (_userId != null) {
        final cloudProgress = await _firestore.getProgress(_userId!);
        if (cloudProgress != null) {
          _loadFromMap(cloudProgress);
          await _saveToLocal(); // Sync cloud to local
        } else {
          await _loadFromLocal(prefs);
          await syncToCloud(); // Sync local to cloud if cloud is empty
        }
      } else {
        await _loadFromLocal(prefs);
      }
      
      await _updateStreak();
      await _loadLevelStars();
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing progress: $e');
    }
  }

  Future<void> _loadFromLocal(SharedPreferences prefs) async {
    _userName = prefs.getString('userName') ?? 'Student';
    _avatar = prefs.getString('avatar') ?? '👦';
    _region = prefs.getString('region') ?? 'India';
    _level = prefs.getInt('level') ?? 1;
    _totalCoins = prefs.getInt('totalCoins') ?? 0;
    _totalStars = prefs.getInt('totalStars') ?? 0;
    _streakDays = prefs.getInt('streakDays') ?? 0;
    _totalLettersLearned = prefs.getInt('totalLettersLearned') ?? 0;
    _quizScore = prefs.getInt('quizScore') ?? 0;
    _achievementBadges = prefs.getStringList('achievementBadges') ?? [];
    _inventory = prefs.getStringList('inventory') ?? ['standard'];
    _unlockedLessons = (prefs.getStringList('unlockedLessons') ?? ['1', '2', '3'])
        .map((e) => int.parse(e)).toList();
    _isTeacherMode = prefs.getBool('isTeacherMode') ?? false;
    _globalNotice = prefs.getString('globalNotice') ?? 'Welcome to அகரவளம்!';
    
    final missionsJson = prefs.getStringList('dailyMissions') ?? [];
    if (missionsJson.isNotEmpty) {
      _dailyMissions = missionsJson.map((e) {
        final parts = e.split('|');
        return {
          'id': parts[0],
          'title': parts[1],
          'target': int.parse(parts[2]),
          'current': int.parse(parts[3]),
          'completed': parts[4] == 'true'
        };
      }).toList();
    }
    
    final lessonProgList = prefs.getStringList('lessonProgressMap') ?? [];
    _lessonProgress = {
      for (var e in lessonProgList) 
        if (e.contains(':'))
          int.parse(e.split(':')[0]): int.parse(e.split(':')[1])
    };

    final storyScoreList = prefs.getStringList('storyScoresMap') ?? [];
    _storyQuizScores = {
      for (var e in storyScoreList) 
        if (e.contains(':'))
          e.split(':')[0]: int.parse(e.split(':')[1])
    };

    final taskCompList = prefs.getStringList('completedTasksMap') ?? [];
    _completedTasks = {
      for (var e in taskCompList)
        if (e.contains(':'))
          e.split(':')[0]: e.split(':')[1] == 'true'
    };
    _streakHistory = prefs.getStringList('streakHistory') ?? [];
  }

  void _loadFromMap(Map<String, dynamic> data) {
    _userName = data['userName'] ?? _userName;
    _avatar = data['avatar'] ?? _avatar;
    _region = data['region'] ?? _region;
    _level = data['level'] ?? _level;
    _totalCoins = data['totalCoins'] ?? _totalCoins;
    _totalStars = data['totalStars'] ?? _totalStars;
    _streakDays = data['streakDays'] ?? _streakDays;
    _totalLettersLearned = data['totalLettersLearned'] ?? _totalLettersLearned;
    _quizScore = data['quizScore'] ?? _quizScore;
    _achievementBadges = List<String>.from(data['achievementBadges'] ?? []);
    _inventory = List<String>.from(data['inventory'] ?? ['standard']);
    _unlockedLessons = List<int>.from(data['unlockedLessons'] ?? [1, 2, 3]);
    
    if (data['lessonProgress'] != null) {
      _lessonProgress = (data['lessonProgress'] as Map).map((k, v) => MapEntry(int.parse(k.toString()), int.parse(v.toString())));
    }
    if (data['storyQuizScores'] != null) {
      _storyQuizScores = (data['storyQuizScores'] as Map).map((k, v) => MapEntry(k.toString(), int.parse(v.toString())));
    }
    if (data['completedTasks'] != null) {
      _completedTasks = (data['completedTasks'] as Map).map((k, v) => MapEntry(k.toString(), v as bool));
    }
  }

  Future<void> _saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _userName);
    await prefs.setString('avatar', _avatar);
    await prefs.setString('region', _region);
    await prefs.setInt('level', _level);
    await prefs.setInt('totalCoins', _totalCoins);
    await prefs.setInt('totalStars', _totalStars);
    await prefs.setInt('streakDays', _streakDays);
    await prefs.setInt('totalLettersLearned', _totalLettersLearned);
    await prefs.setInt('quizScore', _quizScore);
    await prefs.setStringList('achievementBadges', _achievementBadges);
    await prefs.setStringList('inventory', _inventory);
    await prefs.setStringList('unlockedLessons', _unlockedLessons.map((e) => e.toString()).toList());
    
    List<String> lessonProgList = _lessonProgress.entries.map((e) => '${e.key}:${e.value}').toList();
    await prefs.setStringList('lessonProgressMap', lessonProgList);
    
    List<String> storyScoreList = _storyQuizScores.entries.map((e) => '${e.key}:${e.value}').toList();
    await prefs.setStringList('storyScoresMap', storyScoreList);

    List<String> taskCompList = _completedTasks.entries.map((e) => '${e.key}:${e.value}').toList();
    await prefs.setStringList('completedTasksMap', taskCompList);
    await prefs.setStringList('streakHistory', _streakHistory);
  }

  Future<void> syncToCloud() async {
    if (_userId == null) return;
    
    final progressMap = {
      'userName': _userName,
      'avatar': _avatar,
      'region': _region,
      'level': _level,
      'totalCoins': _totalCoins,
      'totalStars': _totalStars,
      'streakDays': _streakDays,
      'totalLettersLearned': _totalLettersLearned,
      'quizScore': _quizScore,
      'achievementBadges': _achievementBadges,
      'inventory': _inventory,
      'unlockedLessons': _unlockedLessons,
      'lessonProgress': _lessonProgress.map((k, v) => MapEntry(k.toString(), v)),
      'storyQuizScores': _storyQuizScores,
      'completedTasks': _completedTasks,
      'streakHistory': _streakHistory,
    };
    
    await _firestore.saveProgress(_userId!, progressMap);
  }

  Future<void> _updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final lastLoginStr = prefs.getString('lastLoginDate');
    
    if (lastLoginStr != null) {
      final lastLogin = DateTime.parse(lastLoginStr);
      final difference = now.difference(lastLogin).inDays;
      
      if (difference == 1) {
        _streakDays++;
        await _addCoins(10);
      } else if (difference > 1) {
        _streakDays = 1;
      }
    } else {
      _streakDays = 1;
    }
    
    final todayStr = now.toIso8601String().split('T').first;
    if (!_streakHistory.contains(todayStr)) {
      _streakHistory.add(todayStr);
      if (_streakHistory.length > 7) _streakHistory.removeAt(0);
    }
    
    await prefs.setStringList('streakHistory', _streakHistory);
    await prefs.setString('lastLoginDate', now.toIso8601String());
    await prefs.setInt('streakDays', _streakDays);
    await syncToCloud();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    await _saveToLocal();
    await syncToCloud();
    notifyListeners();
  }

  Future<void> updateAvatar(String emoji) async {
    _avatar = emoji;
    await _saveToLocal();
    await syncToCloud();
    notifyListeners();
  }

  Future<void> setRegion(String region) async {
    _region = region;
    await _saveToLocal();
    await syncToCloud();
    notifyListeners();
  }

  Future<void> buyItem(String itemId, int price, String emoji) async {
    if (_totalCoins >= price && !_inventory.contains(itemId)) {
      _totalCoins -= price;
      _inventory.add(itemId);
      _avatar = emoji;
      await _saveToLocal();
      await syncToCloud();
      notifyListeners();
    }
  }

  Future<void> incrementLettersLearned() async {
    _totalLettersLearned++;
    await _addStars(1);
    await _addCoins(5);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalLettersLearned', _totalLettersLearned);
    await _checkLevelUp();
    await syncToCloud();
    notifyListeners();
  }

  Future<void> addQuizScore(int score) async {
    _quizScore += score;
    await _addStars(score ~/ 10);
    await _addCoins(score);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quizScore', _quizScore);
    await _checkLevelUp();
    await syncToCloud();
    notifyListeners();
  }

  Future<void> addXP(int amount) async {
    await _addStars(amount ~/ 10);
    await syncToCloud();
    notifyListeners();
  }

  Future<void> addRewards({int coins = 0, int stars = 0, String? missionId}) async {
    if (coins > 0) await _addCoins(coins);
    if (stars > 0) await _addStars(stars);
    
    if (missionId != null) {
      updateMissionProgress(missionId, 1);
    }
    
    await syncToCloud();
    notifyListeners();
  }

  Future<void> updateMissionProgress(String id, int increment) async {
    final index = _dailyMissions.indexWhere((m) => m['id'] == id);
    if (index != -1) {
      _dailyMissions[index]['current'] += increment;
      if (_dailyMissions[index]['current'] >= _dailyMissions[index]['target'] && !_dailyMissions[index]['completed']) {
        _dailyMissions[index]['completed'] = true;
        await _addCoins(50);
        await _addStars(10);
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('dailyMissions', 
          _dailyMissions.map((m) => "${m['id']}|${m['title']}|${m['target']}|${m['current']}|${m['completed']}").toList());
      await syncToCloud();
      notifyListeners();
    }
  }

  Future<void> addCoins(int amount) async {
    await _addCoins(amount);
    await syncToCloud();
    notifyListeners();
  }

  Future<void> addStars(int amount) async {
    await _addStars(amount);
    await syncToCloud();
    notifyListeners();
  }

  Future<void> _addStars(int amount) async {
    _totalStars += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalStars', _totalStars);
  }

  Future<void> _addCoins(int amount) async {
    _totalCoins += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalCoins', _totalCoins);
  }

  Future<void> addAchievement(String badge) async {
    if (!_achievementBadges.contains(badge)) {
      _achievementBadges.add(badge);
      await _addCoins(50);
      await _addStars(10);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('achievementBadges', _achievementBadges);
      await syncToCloud();
      notifyListeners();
    }
  }

  Future<void> unlockLesson(int lessonId) async {
    if (!_unlockedLessons.contains(lessonId)) {
      _unlockedLessons.add(lessonId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('unlockedLessons', 
          _unlockedLessons.map((e) => e.toString()).toList());
      await syncToCloud();
      notifyListeners();
    }
  }

  Future<void> updateLessonProgress(int lessonId, int progress) async {
    _lessonProgress[lessonId] = progress;
    if (progress >= 100) {
      await _addCoins(100);
      await _addStars(20);
      if (lessonId < 30) {
        await unlockLesson(lessonId + 1);
      }
    }
    
    final prefs = await SharedPreferences.getInstance();
    List<String> mapList = _lessonProgress.entries.map((e) => '${e.key}:${e.value}').toList();
    await prefs.setStringList('lessonProgressMap', mapList);
    
    await syncToCloud();
    notifyListeners();
  }

  Future<void> _checkLevelUp() async {
    int requiredStars = _level * 100;
    if (_totalStars >= requiredStars) {
      _level++;
      await _addCoins(200);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('level', _level);
      await syncToCloud();
    }
  }

  Future<void> toggleTeacherMode() async {
    _isTeacherMode = !_isTeacherMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isTeacherMode', _isTeacherMode);
    notifyListeners();
  }

  Future<void> addStoryScore(String title, int score) async {
    _storyQuizScores[title] = score;
    await _addCoins(score * 10);
    await _addStars(score * 5);
    final prefs = await SharedPreferences.getInstance();
    
    List<String> mapList = _storyQuizScores.entries.map((e) => '${e.key}:${e.value}').toList();
    await prefs.setStringList('storyScoresMap', mapList);
    
    await syncToCloud();
    notifyListeners();
  }

  // --- Candy Crush Level Map Methods ---
  // Map of levelId -> stars earned (0 = not completed, 1-3 = star rating)
  Map<int, int> _levelStars = {};
  Map<int, int> get levelStars => _levelStars;
  int _xpPoints = 0;
  int get xpPoints => _xpPoints;

  /// Complete a level with a star rating (1-3)
  Future<void> completeLevel(int levelId, int starsEarned) async {
    // Only update if new stars are higher
    final currentStars = _levelStars[levelId] ?? 0;
    if (starsEarned <= currentStars) return;

    _levelStars[levelId] = starsEarned;

    // Award rewards
    final levelData = ReadingJourneyData.levels.firstWhere((l) => l['id'] == levelId, orElse: () => {});
    final xp = (levelData['xp'] ?? 10) as int;
    _xpPoints += xp;
    await _addStars(starsEarned);
    await _addCoins(starsEarned * 10);

    // Unlock next level
    if (_level == levelId && levelId < ReadingJourneyData.levels.length) {
      _level = levelId + 1;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('level', _level);
    }

    await _saveLevelStars();
    await _saveToLocal();
    await syncToCloud();
    notifyListeners();
  }

  /// Get star rating for a level (0 if not completed)
  int getLevelStarRating(int levelId) {
    return _levelStars[levelId] ?? 0;
  }

  /// Check if a level is unlocked
  bool isLevelUnlocked(int levelId) {
    return levelId <= _level;
  }

  /// Check if a level is completed
  bool isLevelCompleted(int levelId) {
    return (_levelStars[levelId] ?? 0) > 0;
  }

  /// Get total stars earned across all levels
  int get totalLevelStars {
    int total = 0;
    for (var stars in _levelStars.values) {
      total += stars;
    }
    return total;
  }

  /// Get stage progress (0.0 to 1.0) based on completed levels in that stage
  double getStageProgress(int stageId) {
    final stageLevels = ReadingJourneyData.getLevelsForStage(stageId);
    if (stageLevels.isEmpty) return 0.0;
    int completed = 0;
    for (var level in stageLevels) {
      if (isLevelCompleted(level['id'])) completed++;
    }
    return completed / stageLevels.length;
  }

  Future<void> _saveLevelStars() async {
    final prefs = await SharedPreferences.getInstance();
    final entries = _levelStars.entries.map((e) => '${e.key}:${e.value}').toList();
    await prefs.setStringList('levelStars', entries);
    await prefs.setInt('xpPoints', _xpPoints);
  }

  Future<void> _loadLevelStars() async {
    final prefs = await SharedPreferences.getInstance();
    final entries = prefs.getStringList('levelStars') ?? [];
    _levelStars = {};
    for (var entry in entries) {
      final parts = entry.split(':');
      if (parts.length == 2) {
        _levelStars[int.parse(parts[0])] = int.parse(parts[1]);
      }
    }
    _xpPoints = prefs.getInt('xpPoints') ?? 0;
  }

  // Keep old methods for backward compatibility
  Future<void> completeTask(String taskId, int levelId, int points) async {
    if (_completedTasks[taskId] == true) return;
    _completedTasks[taskId] = true;
    await _addStars(points);
    await _addCoins(points * 2);

    // Auto complete the level if it's the current one
    if (_level == levelId) {
      _level++;
      await _addCoins(100);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('level', _level);
    }

    await _saveToLocal();
    await syncToCloud();
    notifyListeners();
  }

  double getLevelProgress(int levelId) {
    if (levelId < _level) return 1.0;
    if (levelId > _level) return 0.0;
    return 0.5; // Current level is in progress
  }

  int getCompletedTasksCount(int levelId) {
    return isLevelCompleted(levelId) ? 1 : 0;
  }

  Future<void> toggleTeacherModeOnly() async {
    _isTeacherMode = !_isTeacherMode;
    notifyListeners();
  }

  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (_userId != null) {
      await _firestore.saveProgress(_userId!, {});
    }
    await initializeProgress(uid: _userId);
  }
}
