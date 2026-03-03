import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Single instance of DatabaseService
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  // --- Users Collection ---
  
  // Create or Update User Profile
  Future<void> saveUserProfile(String userId, String name, String role, String email) async {
    try {
      await _db.collection('users').doc(userId).set({
        'name': name,
        'role': role,
        'email': email,
        'lastActive': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // merge: true updates existing fields without overwriting the whole document
    } catch (e) {
      print('Error saving user profile: $e');
      rethrow;
    }
  }

  // Get User Profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // --- Classrooms Collection ---

  // Create a new classroom
  Future<String?> createClassroom(String teacherId, String className, String description) async {
    try {
      DocumentReference docRef = await _db.collection('classrooms').add({
        'teacherId': teacherId,
        'className': className,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
        'students': [], // array of student UIDs
      });
      return docRef.id;
    } catch (e) {
      print('Error creating classroom: $e');
      return null;
    }
  }
  
  // Join a classroom
  Future<void> joinClassroom(String classroomId, String studentId) async {
    try {
      await _db.collection('classrooms').doc(classroomId).update({
        'students': FieldValue.arrayUnion([studentId])
      });
    } catch (e) {
      print('Error joining classroom: $e');
      rethrow;
    }
  }

  // Stream of classrooms for a teacher
  Stream<QuerySnapshot> getTeacherClassrooms(String teacherId) {
    return _db
        .collection('classrooms')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots();
  }

}
