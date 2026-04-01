class UserProgress {
  final String userId;
  final String userName;
  final int level;
  final int totalCoins;
  final int totalStars;
  final int streakDays;
  final int totalLettersLearned;
  final int quizScore;
  final List<String> achievementBadges;
  final List<String> inventory;
  final List<int> unlockedLessons;
  final Map<int, int> lessonProgress;
  final Map<String, int> storyQuizScores;
  final Map<String, bool> completedTasks;
  final String avatar;
  final String region;
  final bool isTeacherMode;
  final List<String> assignedHomework;
  final List<Map<String, String>> discussions;
  final List<Map<String, dynamic>> assignedQuizzes;
  final String globalNotice;
  final List<Map<String, dynamic>> dailyMissions;
  final List<String> streakHistory;
  final String lastRewardDate;
  final Map<int, int> levelStars;
  final int xpPoints;

  UserProgress({
    required this.userId,
    required this.userName,
    required this.level,
    required this.totalCoins,
    required this.totalStars,
    required this.streakDays,
    required this.totalLettersLearned,
    required this.quizScore,
    required this.achievementBadges,
    required this.inventory,
    required this.unlockedLessons,
    required this.lessonProgress,
    required this.storyQuizScores,
    required this.completedTasks,
    required this.avatar,
    required this.region,
    required this.isTeacherMode,
    required this.assignedHomework,
    required this.discussions,
    required this.assignedQuizzes,
    required this.globalNotice,
    required this.dailyMissions,
    required this.streakHistory,
    required this.lastRewardDate,
    required this.levelStars,
    required this.xpPoints,
  });

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Student',
      level: map['level'] ?? 1,
      totalCoins: map['totalCoins'] ?? 0,
      totalStars: map['totalStars'] ?? 0,
      streakDays: map['streakDays'] ?? 0,
      totalLettersLearned: map['totalLettersLearned'] ?? 0,
      quizScore: map['quizScore'] ?? 0,
      achievementBadges: List<String>.from(map['achievementBadges'] ?? []),
      inventory: List<String>.from(map['inventory'] ?? ['standard']),
      unlockedLessons: List<int>.from(map['unlockedLessons'] ?? [1, 2, 3]),
      lessonProgress: Map<int, int>.from(map['lessonProgress'] ?? {}),
      storyQuizScores: Map<String, int>.from(map['storyQuizScores'] ?? {}),
      completedTasks: Map<String, bool>.from(map['completedTasks'] ?? {}),
      avatar: map['avatar'] ?? '👦',
      region: map['region'] ?? 'India',
      isTeacherMode: map['isTeacherMode'] ?? false,
      assignedHomework: List<String>.from(map['assignedHomework'] ?? []),
      discussions: List<Map<String, String>>.from(map['discussions'] ?? []),
      assignedQuizzes: List<Map<String, dynamic>>.from(map['assignedQuizzes'] ?? []),
      globalNotice: map['globalNotice'] ?? 'Welcome to அகரவளம்!',
      dailyMissions: List<Map<String, dynamic>>.from(map['dailyMissions'] ?? []),
      streakHistory: List<String>.from(map['streakHistory'] ?? []),
      lastRewardDate: map['lastRewardDate'] ?? '',
      levelStars: Map<int, int>.from(map['levelStars'] ?? {}),
      xpPoints: map['xpPoints'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'level': level,
      'totalCoins': totalCoins,
      'totalStars': totalStars,
      'streakDays': streakDays,
      'totalLettersLearned': totalLettersLearned,
      'quizScore': quizScore,
      'achievementBadges': achievementBadges,
      'inventory': inventory,
      'unlockedLessons': unlockedLessons,
      'lessonProgress': lessonProgress,
      'storyQuizScores': storyQuizScores,
      'completedTasks': completedTasks,
      'avatar': avatar,
      'region': region,
      'isTeacherMode': isTeacherMode,
      'assignedHomework': assignedHomework,
      'discussions': discussions,
      'assignedQuizzes': assignedQuizzes,
      'globalNotice': globalNotice,
      'dailyMissions': dailyMissions,
      'streakHistory': streakHistory,
      'lastRewardDate': lastRewardDate,
      'levelStars': levelStars,
      'xpPoints': xpPoints,
    };
  }
}
