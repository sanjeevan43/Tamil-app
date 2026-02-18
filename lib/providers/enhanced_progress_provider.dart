import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnhancedProgressProvider extends ChangeNotifier {
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
  
  // Teacher Mode
  bool _isTeacherMode = false;
  List<String> _assignedHomework = [];
  
  // Getters
  String get userName => _userName;
  String get avatar => _avatar;
  String get region => _region;
  int get level => _level;
  int get totalCoins => _totalCoins;
  int get coins => _totalCoins; // Alias for backward compatibility
  int get totalStars => _totalStars;
  int get stars => _totalStars;
  int get xp => _totalStars * 10;
  String get currentEquipped => _avatar;
  int get streakDays => _streakDays;
  int get totalLettersLearned => _totalLettersLearned;
  int get quizScore => _quizScore;
  List<String> get achievementBadges => _achievementBadges;
  List<String> get inventory => _inventory;
  List<int> get unlockedLessons => _unlockedLessons;
  Map<int, int> get lessonProgress => _lessonProgress;
  Map<String, int> get storyQuizScores => _storyQuizScores;
  bool get isTeacherMode => _isTeacherMode;
  List<String> get assignedHomework => _assignedHomework;

  Future<void> initializeProgress() async {
    final prefs = await SharedPreferences.getInstance();
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
    _assignedHomework = prefs.getStringList('assignedHomework') ?? [];
    
    // Load complex maps
    final lessonProgList = prefs.getStringList('lessonProgressMap') ?? [];
    _lessonProgress = {
      for (var e in lessonProgList) 
        int.parse(e.split(':')[0]): int.parse(e.split(':')[1])
    };

    final storyScoreList = prefs.getStringList('storyScoresMap') ?? [];
    _storyQuizScores = {
      for (var e in storyScoreList) 
        e.split(':')[0]: int.parse(e.split(':')[1])
    };
    
    _updateStreak();
    notifyListeners();
  }

  void _updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final lastLoginStr = prefs.getString('lastLoginDate');
    
    if (lastLoginStr != null) {
      final lastLogin = DateTime.parse(lastLoginStr);
      final difference = now.difference(lastLogin).inDays;
      
      if (difference == 1) {
        _streakDays++;
        _addCoins(10);
      } else if (difference > 1) {
        _streakDays = 1;
      }
    }
    
    
    await prefs.setString('lastLoginDate', now.toIso8601String());
    await prefs.setInt('streakDays', _streakDays);
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    notifyListeners();
  }

  Future<void> updateAvatar(String emoji) async {
    _avatar = emoji;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar', emoji);
    notifyListeners();
  }

  Future<void> setRegion(String region) async {
    _region = region;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('region', region);
    notifyListeners();
  }

  Future<void> buyItem(String itemId, int price, String emoji) async {
    if (_totalCoins >= price && !_inventory.contains(itemId)) {
      _totalCoins -= price;
      _inventory.add(itemId);
      _avatar = emoji;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('totalCoins', _totalCoins);
      await prefs.setStringList('inventory', _inventory);
      await prefs.setString('avatar', emoji);
      notifyListeners();
    }
  }

  Future<void> incrementLettersLearned() async {
    _totalLettersLearned++;
    _addStars(1);
    _addCoins(5);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalLettersLearned', _totalLettersLearned);
    _checkLevelUp();
    notifyListeners();
  }

  Future<void> addQuizScore(int score) async {
    _quizScore += score;
    _addStars(score ~/ 10);
    _addCoins(score);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quizScore', _quizScore);
    _checkLevelUp();
    notifyListeners();
  }

  void addXP(int amount) {
    _addStars(amount ~/ 10); // Normalizing XP to Stars
    notifyListeners();
  }

  void addCoins(int amount) {
    _addCoins(amount);
    notifyListeners();
  }

  void _addStars(int amount) async {
    _totalStars += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalStars', _totalStars);
  }

  void _addCoins(int amount) async {
    _totalCoins += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalCoins', _totalCoins);
  }

  Future<void> addAchievement(String badge) async {
    if (!_achievementBadges.contains(badge)) {
      _achievementBadges.add(badge);
      _addCoins(50);
      _addStars(10);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('achievementBadges', _achievementBadges);
      notifyListeners();
    }
  }

  Future<void> unlockLesson(int lessonId) async {
    if (!_unlockedLessons.contains(lessonId)) {
      _unlockedLessons.add(lessonId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('unlockedLessons', 
          _unlockedLessons.map((e) => e.toString()).toList());
      notifyListeners();
    }
  }

  Future<void> updateLessonProgress(int lessonId, int progress) async {
    _lessonProgress[lessonId] = progress;
    if (progress >= 100) {
      _addCoins(100);
      _addStars(20);
      if (lessonId < 7) {
        await unlockLesson(lessonId + 1);
      }
    }
    
    // Save map
    final prefs = await SharedPreferences.getInstance();
    List<String> mapList = _lessonProgress.entries.map((e) => '${e.key}:${e.value}').toList();
    await prefs.setStringList('lessonProgressMap', mapList);
    
    notifyListeners();
  }

  void _checkLevelUp() async {
    int requiredStars = _level * 100;
    if (_totalStars >= requiredStars) {
      _level++;
      _addCoins(200);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('level', _level);
    }
  }

  Future<void> toggleTeacherMode() async {
    _isTeacherMode = !_isTeacherMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isTeacherMode', _isTeacherMode);
    notifyListeners();
  }

  Future<void> assignHomework(String homework) async {
    _assignedHomework.add(homework);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('assignedHomework', _assignedHomework);
    notifyListeners();
  }

  Future<void> addStoryScore(String title, int score) async {
    _storyQuizScores[title] = score;
    _addCoins(score * 10);
    _addStars(score * 5);
    final prefs = await SharedPreferences.getInstance();
    
    // Save map properly
    List<String> mapList = _storyQuizScores.entries.map((e) => '${e.key}:${e.value}').toList();
    await prefs.setStringList('storyScoresMap', mapList);
    
    notifyListeners();
  }

  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await initializeProgress();
  }
}
