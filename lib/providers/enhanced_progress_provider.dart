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
  List<Map<String, String>> _discussions = [];
  List<Map<String, dynamic>> _assignedQuizzes = [];
  String _globalNotice = 'Welcome to Tamil Master!';
  
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
  bool get isTeacherMode => _isTeacherMode;
  List<String> get assignedHomework => _assignedHomework;
  List<Map<String, String>> get discussions => _discussions;
  List<Map<String, dynamic>> get assignedQuizzes => _assignedQuizzes;
  String get globalNotice => _globalNotice;
  List<Map<String, dynamic>> get dailyMissions => _dailyMissions;

  Future<void> initializeProgress() async {
    try {
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
      _globalNotice = prefs.getString('globalNotice') ?? 'Welcome to Tamil Master!';
      
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
      
      final discList = prefs.getStringList('discussions') ?? [];
      _discussions = discList.map((e) {
        final parts = e.split('|');
        return {'sender': parts[0], 'message': parts[1], 'time': parts[2]};
      }).toList();

      final quizList = prefs.getStringList('assignedQuizzes') ?? [];
      _assignedQuizzes = quizList.map((e) {
        final parts = e.split('|');
        return {'id': parts[0], 'title': parts[1], 'status': parts[2]};
      }).toList();
      
      // Load complex maps
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
      
      await _updateStreak();
      notifyListeners();
    } catch (e) {
      // Ignored
    }
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
    await _addStars(1);
    await _addCoins(5);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalLettersLearned', _totalLettersLearned);
    await _checkLevelUp();
    notifyListeners();
  }

  Future<void> addQuizScore(int score) async {
    _quizScore += score;
    await _addStars(score ~/ 10);
    await _addCoins(score);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quizScore', _quizScore);
    await _checkLevelUp();
    notifyListeners();
  }

  Future<void> addXP(int amount) async {
    await _addStars(amount ~/ 10);
    notifyListeners();
  }

  Future<void> addRewards({int coins = 0, int stars = 0, String? missionId}) async {
    if (coins > 0) await _addCoins(coins);
    if (stars > 0) await _addStars(stars);
    
    if (missionId != null) {
      updateMissionProgress(missionId, 1);
    }
    
    notifyListeners();
  }

  Future<void> updateMissionProgress(String id, int increment) async {
    final index = _dailyMissions.indexWhere((m) => m['id'] == id);
    if (index != -1) {
      _dailyMissions[index]['current'] += increment;
      if (_dailyMissions[index]['current'] >= _dailyMissions[index]['target'] && !_dailyMissions[index]['completed']) {
        _dailyMissions[index]['completed'] = true;
        await _addCoins(50); // Bonus for mission
        await _addStars(10);
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('dailyMissions', 
          _dailyMissions.map((m) => "${m['id']}|${m['title']}|${m['target']}|${m['current']}|${m['completed']}").toList());
      notifyListeners();
    }
  }

  Future<void> addCoins(int amount) async {
    await _addCoins(amount);
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
      await _addCoins(100);
      await _addStars(20);
      if (lessonId < 30) { // Increased range for lessons
        await unlockLesson(lessonId + 1);
      }
    }
    
    final prefs = await SharedPreferences.getInstance();
    List<String> mapList = _lessonProgress.entries.map((e) => '${e.key}:${e.value}').toList();
    await prefs.setStringList('lessonProgressMap', mapList);
    
    notifyListeners();
  }

  Future<void> _checkLevelUp() async {
    int requiredStars = _level * 100;
    if (_totalStars >= requiredStars) {
      _level++;
      await _addCoins(200);
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
    await _addCoins(score * 10);
    await _addStars(score * 5);
    final prefs = await SharedPreferences.getInstance();
    
    List<String> mapList = _storyQuizScores.entries.map((e) => '${e.key}:${e.value}').toList();
    await prefs.setStringList('storyScoresMap', mapList);
    
    notifyListeners();
  }

  Future<void> addMessage(String sender, String message) async {
    final now = DateTime.now();
    final timeStr = "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
    _discussions.add({'sender': sender, 'message': message, 'time': timeStr});
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('discussions', 
        _discussions.map((e) => "${e['sender']}|${e['message']}|${e['time']}").toList());
    notifyListeners();
  }

  Future<void> assignQuiz(String title) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _assignedQuizzes.add({'id': id, 'title': title, 'status': 'Pending'});
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('assignedQuizzes', 
        _assignedQuizzes.map((e) => "${e['id']}|${e['title']}|${e['status']}").toList());
    notifyListeners();
  }

  Future<void> completeQuiz(String id) async {
    final index = _assignedQuizzes.indexWhere((q) => q['id'] == id);
    if (index != -1) {
      _assignedQuizzes[index]['status'] = 'Completed';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('assignedQuizzes', 
          _assignedQuizzes.map((e) => "${e['id']}|${e['title']}|${e['status']}").toList());
      notifyListeners();
    }
  }

  Future<void> setGlobalNotice(String notice) async {
    _globalNotice = notice;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('globalNotice', notice);
    notifyListeners();
  }

  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await initializeProgress();
  }
}
