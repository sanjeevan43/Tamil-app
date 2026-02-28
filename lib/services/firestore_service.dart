import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Users ---
  Future<void> saveUser(User user) async {
    final userRef = _db.collection('users').doc(user.uid);
    await userRef.set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName ?? 'Student',
      'photoURL': user.photoURL ?? '',
      'lastLogin': FieldValue.serverTimestamp(),
      'role': 'student', // Admin can manually update this, or we can add logic
    }, SetOptions(merge: true));
  }

  // --- Daily Tamil Power Word ---
  Future<Map<String, dynamic>?> getDailyWord() async {
    // Get the latest word based on the date
    final today = DateTime.now();
    final dateStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    
    final query = await _db.collection('daily_words')
        .where('date', isEqualTo: dateStr)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.data();
    }
    
    // Fallback to the most recent one if today's is not set
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
}
