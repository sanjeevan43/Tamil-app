import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  factory AnalyticsService() {
    return _instance;
  }

  AnalyticsService._internal();

  Future<void> logEvent({
    required String userId,
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _db.collection('analytics').add({
        'userId': userId,
        'eventName': eventName,
        'parameters': parameters ?? {},
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging event: $e');
    }
  }

  Future<void> logGameScore({
    required String userId,
    required String gameName,
    required int score,
    required int timeSpent,
  }) async {
    try {
      await _db.collection('game_scores').add({
        'userId': userId,
        'gameName': gameName,
        'score': score,
        'timeSpent': timeSpent,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging game score: $e');
    }
  }

  Future<void> logLessonCompletion({
    required String userId,
    required int lessonId,
    required String lessonTitle,
    required int timeSpent,
  }) async {
    try {
      await _db.collection('lesson_completions').add({
        'userId': userId,
        'lessonId': lessonId,
        'lessonTitle': lessonTitle,
        'timeSpent': timeSpent,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging lesson completion: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserAnalytics(String userId) async {
    try {
      final gameScores = await _db
          .collection('game_scores')
          .where('userId', isEqualTo: userId)
          .get();

      final lessonCompletions = await _db
          .collection('lesson_completions')
          .where('userId', isEqualTo: userId)
          .get();

      final events = await _db
          .collection('analytics')
          .where('userId', isEqualTo: userId)
          .get();

      return {
        'totalGamesPlayed': gameScores.docs.length,
        'totalLessonsCompleted': lessonCompletions.docs.length,
        'totalEvents': events.docs.length,
        'averageGameScore': _calculateAverageScore(gameScores.docs),
        'totalTimeSpent': _calculateTotalTime(gameScores.docs, lessonCompletions.docs),
      };
    } catch (e) {
      print('Error getting user analytics: $e');
      return null;
    }
  }

  double _calculateAverageScore(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return 0.0;
    int total = 0;
    for (var doc in docs) {
      total += (doc['score'] as num?)?.toInt() ?? 0;
    }
    return total / docs.length;
  }

  int _calculateTotalTime(List<QueryDocumentSnapshot> gameScores, List<QueryDocumentSnapshot> lessons) {
    int total = 0;
    for (var doc in gameScores) {
      total += (doc['timeSpent'] as num?)?.toInt() ?? 0;
    }
    for (var doc in lessons) {
      total += (doc['timeSpent'] as num?)?.toInt() ?? 0;
    }
    return total;
  }

  Future<List<Map<String, dynamic>>> getTopPlayers({int limit = 10}) async {
    try {
      final snapshot = await _db
          .collection('users')
          .orderBy('totalStars', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      print('Error getting top players: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getGameStatistics(String gameName) async {
    try {
      final snapshot = await _db
          .collection('game_scores')
          .where('gameName', isEqualTo: gameName)
          .orderBy('score', descending: true)
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      print('Error getting game statistics: $e');
      return [];
    }
  }

  Future<void> logUserSession({
    required String userId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      await _db.collection('user_sessions').add({
        'userId': userId,
        'startTime': startTime,
        'endTime': endTime,
        'duration': endTime.difference(startTime).inSeconds,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging user session: $e');
    }
  }
}
