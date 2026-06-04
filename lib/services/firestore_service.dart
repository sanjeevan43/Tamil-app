import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? firestore}) 
      : _db = firestore ?? FirebaseFirestore.instance;

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
  

  Future<void> addStory(Map<String, dynamic> storyData) async {
    await _db.collection('stories').add(storyData);
  }

  // --- Rhymes ---
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
    await _db.collection('users').doc(uid).set({
      'progress': progressData,
      'lastSync': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getProgress(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data()!.containsKey('progress')) {
      return doc.data()!['progress'] as Map<String, dynamic>;
    }
    return null;
  }

  // --- File Storage ---
  Future<String?> uploadFile(String path, File file) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }

  // --- Classrooms (Admin/Student Features) ---
  Stream<QuerySnapshot> getClassroomsStream() {
    return _db.collection('classrooms').orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> createClassroom(String name, String description, String createdBy) async {
    await _db.collection('classrooms').add({
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteClassroom(String classroomId) async {
    await _db.collection('classrooms').doc(classroomId).delete();
  }

  // --- Classroom Posts ---
  Stream<QuerySnapshot> getClassroomPostsStream(String classroomId) {
    return _db
        .collection('classrooms')
        .doc(classroomId)
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> addClassroomPost(
      String classroomId, 
      String title, 
      String content, 
      String? fileUrl, 
      String? fileType) async {
    await _db.collection('classrooms').doc(classroomId).collection('posts').add({
      'title': title,
      'content': content,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteClassroomPost(String classroomId, String postId) async {
    await _db.collection('classrooms').doc(classroomId).collection('posts').doc(postId).delete();
  }

  // --- Classroom Members ---
  Stream<QuerySnapshot> getClassroomMembersStream() {
    return _db.collection('users').snapshots();
  }

  Future<void> addClassroomMember(String email, String name, String role) async {
    await _db.collection('classroom_members').add({
      'email': email,
      'name': name,
      'role': role,
      'joinedAt': FieldValue.serverTimestamp(),
      'isOnline': true,
    });
  }

  Future<void> removeClassroomMember(String memberId) async {
    await _db.collection('classroom_members').doc(memberId).delete();
  }

  // --- Classroom Announcements ---
  Stream<QuerySnapshot> getAnnouncementsStream() {
    return _db.collection('announcements').orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addAnnouncement(String title, String message, String sender) async {
    await _db.collection('announcements').add({
      'title': title,
      'message': message,
      'sender': sender,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteAnnouncement(String id) async {
    await _db.collection('announcements').doc(id).delete();
  }

  // --- Community Forum (Q&A) ---
  Stream<QuerySnapshot> getQuestionsStream() {
    return _db.collection('forum_questions').orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addQuestion(String title, String content, String userId, String userName) async {
    await _db.collection('forum_questions').add({
      'title': title,
      'content': content,
      'userId': userId,
      'userName': userName,
      'createdAt': FieldValue.serverTimestamp(),
      'answersCount': 0,
      'upvotes': 0,
    });
  }

  Stream<QuerySnapshot> getAnswersStream(String questionId) {
    return _db
        .collection('forum_questions')
        .doc(questionId)
        .collection('answers')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Future<void> addAnswer(String questionId, String content, String userId, String userName) async {
    final batch = _db.batch();
    
    final answerRef = _db
        .collection('forum_questions')
        .doc(questionId)
        .collection('answers')
        .doc();
    
    batch.set(answerRef, {
      'content': content,
      'userId': userId,
      'userName': userName,
      'createdAt': FieldValue.serverTimestamp(),
      'upvotes': 0,
    });
    
    final questionRef = _db.collection('forum_questions').doc(questionId);
    batch.update(questionRef, {'answersCount': FieldValue.increment(1)});
    
    await batch.commit();
  }

  // --- Content Streams ---
  Stream<QuerySnapshot> getStoriesStream() {
    return _db.collection('stories').orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot> getRhymesStream() {
    return _db.collection('rhymes').orderBy('createdAt', descending: true).snapshots();
  }
}
// Community methods updated.
