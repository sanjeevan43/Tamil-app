import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class EnhancedProgressProvider extends ChangeNotifier {
  final FirestoreService _firestore;
  String? _userId;

  EnhancedProgressProvider({FirestoreService? firestore}) 
      : _firestore = firestore ?? FirestoreService();

  // Student Data
  String _userName = 'Student';
  int _age = 0;
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
  List<String> _favoriteStories = [];
  
  // Teacher Mode
  bool _isTeacherMode = false;
  final List<String> _assignedHomework = [];
  final List<Map<String, String>> _discussions = [];
  final List<Map<String, dynamic>> _assignedQuizzes = [];
  String _globalNotice = 'Welcome to அகரவளம்!';
  List<String> _streakHistory = [];
  String _lastLoginDate = '';
  
  // Daily Missions
  List<Map<String, dynamic>> _dailyMissions = [
    {'id': 'letter_pro', 'title': 'Learn 10 New Letters', 'target': 10, 'current': 0, 'completed': false},
    {'id': 'game_hero', 'title': 'Play any 3 Games', 'target': 3, 'current': 0, 'completed': false},
  ];
  
  // Getters
  String get userName => _userName;
  int get age => _age;
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
  List<String> get favoriteStories => _favoriteStories;
  bool get isTeacherMode => _isTeacherMode;
  List<String> get assignedHomework => _assignedHomework;
  List<Map<String, String>> get discussions => _discussions;
  List<Map<String, dynamic>> get assignedQuizzes => _assignedQuizzes;
  String get globalNotice => _globalNotice;
  List<Map<String, dynamic>> get dailyMissions => _dailyMissions;
  List<String> get streakHistory => _streakHistory;
  String get lastLoginDate => _lastLoginDate;
  String? get userId => _userId;

  Future<void> initializeProgress({String? uid}) async {
    // Reset all in-memory values to defaults first to avoid carrying over state from other users
    _userName = 'Student';
    _age = 0;
    _avatar = '👦';
    _region = 'India';
    _level = 1;
    _totalCoins = 0;
    _totalStars = 0;
    _streakDays = 0;
    _totalLettersLearned = 0;
    _quizScore = 0;
    
    _achievementBadges = [];
    _inventory = ['standard'];
    _unlockedLessons = [1, 2, 3];
    _lessonProgress = {};
    _storyQuizScores = {};
    _completedTasks = {};
    _favoriteStories = [];
    
    _isTeacherMode = false;
    _assignedHomework.clear();
    _discussions.clear();
    _assignedQuizzes.clear();
    _globalNotice = 'Welcome to அகரவளம்!';
    _streakHistory = [];
    _lastLoginDate = '';
    
    _dailyMissions = [
      {'id': 'letter_pro', 'title': 'Learn 10 New Letters', 'target': 10, 'current': 0, 'completed': false},
      {'id': 'game_hero', 'title': 'Play any 3 Games', 'target': 3, 'current': 0, 'completed': false},
    ];

    _userId = uid;
    try {
      // If we have a UID, fetch from Firestore cloud (the single source of truth)
      if (_userId != null) {
        final cloudProgress = await _firestore.getProgress(_userId!);
        if (cloudProgress != null) {
          _loadFromMap(cloudProgress);
        } else {
          final profile = await _firestore.getUserProfile(_userId!);
          if (profile != null) {
            _userName = profile['displayName'] ?? _userName;
            _age = profile['age'] ?? _age;
          }
          await syncToCloud(); // Sync default local values to cloud
        }
        await _updateStreak();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing progress: $e');
    }
  }

  void _loadFromMap(Map<String, dynamic> data) {
    _userName = data['userName'] ?? _userName;
    _age = data['age'] ?? _age;
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
    _lastLoginDate = data['lastLoginDate'] ?? '';
    _isTeacherMode = data['isTeacherMode'] ?? false;
    _streakHistory = List<String>.from(data['streakHistory'] ?? []);
    _favoriteStories = List<String>.from(data['favoriteStories'] ?? []);
    
    if (data['lessonProgress'] != null) {
      _lessonProgress = (data['lessonProgress'] as Map).map((k, v) => MapEntry(int.parse(k.toString()), int.parse(v.toString())));
    }
    if (data['storyQuizScores'] != null) {
      _storyQuizScores = (data['storyQuizScores'] as Map).map((k, v) => MapEntry(k.toString(), int.parse(v.toString())));
    }
    if (data['completedTasks'] != null) {
      _completedTasks = (data['completedTasks'] as Map).map((k, v) => MapEntry(k.toString(), v as bool));
    }
    if (data['dailyMissions'] != null) {
      _dailyMissions = List<Map<String, dynamic>>.from(data['dailyMissions']);
    }
  }

  Future<void> syncToCloud() async {
    if (_userId == null) return;
    
    final progressMap = {
      'userName': _userName,
      'age': _age,
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
      'favoriteStories': _favoriteStories,
      'lastLoginDate': _lastLoginDate,
      'isTeacherMode': _isTeacherMode,
      'dailyMissions': _dailyMissions,
    };
    
    await _firestore.saveProgress(_userId!, progressMap);
  }

  Future<void> _updateStreak() async {
    if (_userId == null) return;
    final now = DateTime.now();
    
    if (_lastLoginDate.isNotEmpty) {
      final lastLogin = DateTime.parse(_lastLoginDate);
      final difference = now.difference(lastLogin).inDays;
      
      if (difference == 1) {
        _streakDays++;
        _totalCoins += 10;
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
    
    _lastLoginDate = now.toIso8601String();
    await syncToCloud();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    await syncToCloud();
    notifyListeners();
  }

  Future<void> setAge(int ageVal) async {
    _age = ageVal;
    await syncToCloud();
    notifyListeners();
  }

  Future<void> updateAvatar(String emoji) async {
    _avatar = emoji;
    await syncToCloud();
    notifyListeners();
  }

  Future<void> setRegion(String region) async {
    _region = region;
    await syncToCloud();
    notifyListeners();
  }

  Future<void> buyItem(String itemId, int price, String emoji) async {
    if (_totalCoins >= price && !_inventory.contains(itemId)) {
      _totalCoins -= price;
      _inventory.add(itemId);
      _avatar = emoji;
      await syncToCloud();
      notifyListeners();
    }
  }

  Future<void> incrementLettersLearned() async {
    _totalLettersLearned++;
    _totalStars += 1;
    _totalCoins += 5;
    await _checkLevelUp();
    await syncToCloud();
    notifyListeners();
  }

  Future<void> addQuizScore(int score) async {
    _quizScore += score;
    _totalStars += score ~/ 10;
    _totalCoins += score;
    await _checkLevelUp();
    await syncToCloud();
    notifyListeners();
  }

  Future<void> addXP(int amount) async {
    _totalStars += amount ~/ 10;
    await syncToCloud();
    notifyListeners();
  }

  Future<void> addRewards({int coins = 0, int stars = 0, String? missionId}) async {
    if (coins > 0) _totalCoins += coins;
    if (stars > 0) _totalStars += stars;
    
    if (missionId != null) {
      await updateMissionProgress(missionId, 1);
    } else {
      await syncToCloud();
      notifyListeners();
    }
  }

  Future<void> updateMissionProgress(String id, int increment) async {
    final index = _dailyMissions.indexWhere((m) => m['id'] == id);
    if (index != -1) {
      _dailyMissions[index]['current'] = (_dailyMissions[index]['current'] as int) + increment;
      if ((_dailyMissions[index]['current'] as int) >= (_dailyMissions[index]['target'] as int) && !(_dailyMissions[index]['completed'] as bool)) {
        _dailyMissions[index]['completed'] = true;
        _totalCoins += 50;
        _totalStars += 10;
      }
      await syncToCloud();
      notifyListeners();
    }
  }

  Future<void> addCoins(int amount) async {
    _totalCoins += amount;
    await syncToCloud();
    notifyListeners();
  }

  Future<void> addStars(int amount) async {
    _totalStars += amount;
    await syncToCloud();
    notifyListeners();
  }

  Future<void> addAchievement(String badge) async {
    if (!_achievementBadges.contains(badge)) {
      _achievementBadges.add(badge);
      _totalCoins += 50;
      _totalStars += 10;
      await syncToCloud();
      notifyListeners();
    }
  }

  Future<void> unlockLesson(int lessonId) async {
    if (!_unlockedLessons.contains(lessonId)) {
      _unlockedLessons.add(lessonId);
      await syncToCloud();
      notifyListeners();
    }
  }

  Future<void> updateLessonProgress(int lessonId, int progress) async {
    _lessonProgress[lessonId] = progress;
    if (progress >= 100) {
      _totalCoins += 100;
      _totalStars += 20;
      if (lessonId < 30) {
        await unlockLesson(lessonId + 1);
      }
    }
    await syncToCloud();
    notifyListeners();
  }

  Future<void> _checkLevelUp() async {
    int requiredStars = _level * 100;
    if (_totalStars >= requiredStars) {
      _level++;
      _totalCoins += 200;
      await syncToCloud();
    }
  }

  Future<void> toggleTeacherMode() async {
    _isTeacherMode = !_isTeacherMode;
    await syncToCloud();
    notifyListeners();
  }

  Future<void> addStoryScore(String title, int score) async {
    _storyQuizScores[title] = score;
    _totalCoins += score * 10;
    _totalStars += score * 5;
    await syncToCloud();
    notifyListeners();
  }

  // --- Favorites ---
  bool isFavoriteStory(String title) {
    return _favoriteStories.contains(title);
  }

  Future<void> toggleFavoriteStory(String title) async {
    if (_favoriteStories.contains(title)) {
      _favoriteStories.remove(title);
    } else {
      _favoriteStories.add(title);
    }
    await syncToCloud();
    notifyListeners();
  }

  // Keep old methods for backward compatibility
  Future<void> completeTask(String taskId, int levelId, int points) async {
    if (_completedTasks[taskId] == true) return;
    _completedTasks[taskId] = true;
    _totalStars += points;
    _totalCoins += points * 2;

    // Auto complete the level if it's the current one
    if (_level == levelId) {
      _level++;
      _totalCoins += 100;
    }

    await syncToCloud();
    notifyListeners();
  }

  double getLevelProgress(int levelId) {
    if (levelId < _level) return 1.0;
    if (levelId > _level) return 0.0;
    return 0.5; // Current level is in progress
  }

  int getCompletedTasksCount(int levelId) {
    return levelId < _level ? 1 : 0;
  }

  Future<void> toggleTeacherModeOnly() async {
    _isTeacherMode = !_isTeacherMode;
    await syncToCloud();
    notifyListeners();
  }

  Future<void> resetProgress() async {
    if (_userId != null) {
      await _firestore.saveProgress(_userId!, {});
    }
    await initializeProgress(uid: _userId);
  }

  void clearProgress() {
    _userId = null;
    _userName = 'Student';
    _avatar = '👦';
    _region = 'India';
    _level = 1;
    _totalCoins = 0;
    _totalStars = 0;
    _streakDays = 0;
    _totalLettersLearned = 0;
    _quizScore = 0;
    
    _achievementBadges = [];
    _inventory = ['standard'];
    _unlockedLessons = [1, 2, 3];
    _lessonProgress = {};
    _storyQuizScores = {};
    _completedTasks = {};
    _favoriteStories = [];
    
    _isTeacherMode = false;
    _assignedHomework.clear();
    _discussions.clear();
    _assignedQuizzes.clear();
    _globalNotice = 'Welcome to அகரவளம்!';
    _streakHistory = [];
    _lastLoginDate = '';
    
    _dailyMissions = [
      {'id': 'letter_pro', 'title': 'Learn 10 New Letters', 'target': 10, 'current': 0, 'completed': false},
      {'id': 'game_hero', 'title': 'Play any 3 Games', 'target': 3, 'current': 0, 'completed': false},
    ];
    
    notifyListeners();
  }
}
