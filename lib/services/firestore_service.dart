import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Users ---
  Future<void> saveUser(User user, {String role = 'student'}) async {
    final userRef = _db.collection('users').doc(user.uid);
    
    final doc = await userRef.get();
    if (doc.exists) {
      await userRef.update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } else {
      await userRef.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? 'Student',
        'photoURL': user.photoURL ?? '',
        'lastLogin': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'role': role,
      });
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  // --- Daily Tamil Power Word ---
  Future<Map<String, dynamic>?> getDailyWord() async {
    final today = DateTime.now();
    final dateStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    
    final query = await _db.collection('daily_words')
        .where('date', isEqualTo: dateStr)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.data();
    }
    
    final fallbackQuery = await _db.collection('daily_words')
        .orderBy('date', descending: true)
        .limit(1)
        .get();
        
    if (fallbackQuery.docs.isNotEmpty) {
      return fallbackQuery.docs.first.data();
    }
    
    return null;
  }
  
  // --- Admin Control: Topics ---
  Stream<QuerySnapshot> getTopicsStream() {
    return _db.collection('topics').orderBy('order', descending: false).snapshots();
  }

  Future<void> addTopic(Map<String, dynamic> topicData) async {
    await _db.collection('topics').add(topicData);
  }

  Future<void> updateTopic(String docId, Map<String, dynamic> data) async {
    await _db.collection('topics').doc(docId).update(data);
  }

  Future<void> deleteTopic(String docId) async {
    await _db.collection('topics').doc(docId).delete();
  }
  
  // --- Admin Control: Daily Words ---
  Future<void> addDailyWord(Map<String, dynamic> wordData) async {
    await _db.collection('daily_words').add(wordData);
  }

  // --- Stories ---
  Stream<QuerySnapshot> getStoriesStream() {
    return _db.collection('stories').snapshots();
  }

  Future<void> addStory(Map<String, dynamic> storyData) async {
    await _db.collection('stories').add(storyData);
  }

  // --- Rhymes ---
  Stream<QuerySnapshot> getRhymesStream() {
    return _db.collection('rhymes').snapshots();
  }

  Future<void> addRhyme(Map<String, dynamic> rhymeData) async {
    await _db.collection('rhymes').add(rhymeData);
  }

  // --- Classrooms & Notice ---
  Stream<DocumentSnapshot> getNoticeStream() {
    return _db.collection('settings').doc('global_notice').snapshots();
  }

  Future<void> updateNotice(String notice) async {
    await _db.collection('settings').doc('global_notice').set({
      'message': notice,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // --- Discussions / Chat ---
  Stream<QuerySnapshot> getDiscussionsStream() {
    return _db.collection('discussions').orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> addMessage(String sender, String message) async {
    await _db.collection('discussions').add({
      'sender': sender,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // --- Tasks (Homework & Quizzes) ---
  Stream<QuerySnapshot> getTasksStream() {
    return _db.collection('tasks').orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addTask(Map<String, dynamic> taskData) async {
    await _db.collection('tasks').add({
      ...taskData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // --- User Progress Sync ---
  Future<void> saveProgress(String uid, Map<String, dynamic> progressData) async {
    await _db.collection('users').doc(uid).update({
      'progress': progressData,
      'lastSync': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getProgress(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data()!.containsKey('progress')) {
      return doc.data()!['progress'] as Map<String, dynamic>;
    }
    return null;
  }
}
