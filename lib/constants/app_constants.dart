class AppConstants {
  // App Info
  static const String appName = 'Tamil Kids Park';
  static const String appVersion = '2.0.0';
  static const String appBuild = '2';

  // API Endpoints
  static const String baseUrl = 'https://api.tamilmaster.com';
  static const String apiVersion = '/v1';

  // Timeouts
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;

  // Cache Duration
  static const Duration cacheDuration = Duration(hours: 24);
  static const Duration shortCacheDuration = Duration(minutes: 5);

  // Game Settings
  static const int maxGameScore = 100;
  static const int minGameScore = 0;
  static const int defaultGameTime = 60;

  // Level Settings
  static const int maxLevel = 100;
  static const int minLevel = 1;
  static const int starsPerLevel = 100;

  // Rewards
  static const int coinsPerCorrectAnswer = 10;
  static const int starsPerCorrectAnswer = 1;
  static const int bonusCoinsForStreak = 50;
  static const int bonusStarsForStreak = 10;

  // Streak Settings
  static const int streakBonusThreshold = 3;
  static const int maxStreakDays = 365;

  // Classroom Settings
  static const int maxStudentsPerClassroom = 50;
  static const int maxClassroomsPerTeacher = 10;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int minClassroomNameLength = 3;
  static const int maxClassroomNameLength = 50;

  // Tamil Language
  static const String tamilLanguageCode = 'ta';
  static const String tamilLocale = 'ta-IN';
  static const String englishLanguageCode = 'en';
  static const String englishLocale = 'en-US';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 300);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);

  // Notification Duration
  static const Duration notificationDuration = Duration(seconds: 3);
  static const Duration errorNotificationDuration = Duration(seconds: 5);

  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10 MB
  static const List<String> allowedFileTypes = ['pdf', 'doc', 'docx', 'jpg', 'png'];

  // Daily Missions
  static const int dailyMissionResetHour = 0; // Midnight
  static const int maxDailyMissions = 3;

  // Achievement Thresholds
  static const int firstLetterThreshold = 1;
  static const int wordMasterThreshold = 50;
  static const int quizChampionThreshold = 100;
  static const int speedLearnerThreshold = 7;
  static const int streakThreshold = 7;

  // Speech Recognition
  static const double pronunciationThreshold = 0.7;
  static const int maxListeningDuration = 10;

  // Database Collections
  static const String usersCollection = 'users';
  static const String classroomsCollection = 'classrooms';
  static const String lessonsCollection = 'lessons';
  static const String gamesCollection = 'games';
  static const String storiesCollection = 'stories';
  static const String rhymesCollection = 'rhymes';
  static const String analyticsCollection = 'analytics';
  static const String gameScoresCollection = 'game_scores';
  static const String lessonCompletionsCollection = 'lesson_completions';

  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError = 'An unknown error occurred.';
  static const String invalidInput = 'Invalid input. Please check your data.';
  static const String authenticationError = 'Authentication failed. Please login again.';
  static const String authorizationError = 'You do not have permission to perform this action.';

  // Success Messages
  static const String operationSuccess = 'Operation completed successfully.';
  static const String loginSuccess = 'Login successful.';
  static const String logoutSuccess = 'Logout successful.';
  static const String registrationSuccess = 'Registration successful.';
  static const String updateSuccess = 'Update successful.';
  static const String deleteSuccess = 'Delete successful.';

  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = true;
  static const bool enableNotifications = true;
  static const bool enableSocialFeatures = true;
  static const bool enableTeacherMode = true;
  static const bool enableParentDashboard = true;

  // Debug Settings
  static const bool debugMode = false;
  static const bool enableLogging = true;
  static const bool enableCrashReporting = true;
}
