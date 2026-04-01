import 'package:cloud_firestore/cloud_firestore.dart';

// MARK: - User Model
class UserProfile {
  final String id;
  final String name;
  final String email;
  final int xp;
  final int streak;
  final String currentLevel;
  final int hearts;
  final DateTime? lastActiveDate;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.xp = 0,
    this.streak = 0,
    this.currentLevel = 'Beginner',
    this.hearts = 5,
    this.lastActiveDate,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return UserProfile(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      xp: data['xp'] ?? 0,
      streak: data['streak'] ?? 0,
      currentLevel: data['currentLevel'] ?? 'Beginner',
      hearts: data['hearts'] ?? 5,
      lastActiveDate: (data['lastActiveDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'xp': xp,
      'streak': streak,
      'currentLevel': currentLevel,
      'hearts': hearts,
      'lastActiveDate': lastActiveDate != null ? Timestamp.fromDate(lastActiveDate!) : null,
    };
  }
}

// MARK: - Question Model
enum QuestionType { mcq, fill, speaking, listening }

class LessonQuestion {
  final String id;
  final String lessonId;
  final QuestionType type;
  final String? tamilText;
  final String? englishText;
  final List<String>? options;
  final String correctAnswer;
  final String? audioURL;

  LessonQuestion({
    required this.id,
    required this.lessonId,
    required this.type,
    this.tamilText,
    this.englishText,
    this.options,
    required this.correctAnswer,
    this.audioURL,
  });

  factory LessonQuestion.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return LessonQuestion(
      id: doc.id,
      lessonId: data['lessonId'] ?? '',
      type: _parseQuestionType(data['type']),
      tamilText: data['tamilText'],
      englishText: data['englishText'],
      options: List<String>.from(data['options'] ?? []),
      correctAnswer: data['correctAnswer'] ?? '',
      audioURL: data['audioURL'],
    );
  }

  static QuestionType _parseQuestionType(String? type) {
    switch (type) {
      case 'mcq': return QuestionType.mcq;
      case 'fill': return QuestionType.fill;
      case 'speaking': return QuestionType.speaking;
      case 'listening': return QuestionType.listening;
      default: return QuestionType.mcq;
    }
  }
}
