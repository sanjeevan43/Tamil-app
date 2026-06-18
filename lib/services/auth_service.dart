import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'firestore_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirestoreService _firestore = FirestoreService();

  User? _user;
  Map<String, dynamic>? _userProfile;
  
  User? get user => _user;
  Map<String, dynamic>? get userProfile => _userProfile;
  String get userRole => _userProfile?['role'] ?? 'student';

  AuthService() {
    _user = _auth.currentUser;
    if (_user != null) {
      _fetchUserProfile(_user!.uid);
    }
    
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        await _fetchUserProfile(user.uid);
        // Ensure user exists in Firestore
        await _firestore.saveUser(user);
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  Future<void> _fetchUserProfile(String uid) async {
    _userProfile = await _firestore.getUserProfile(uid);
    notifyListeners();
  }

  bool get isAuthenticated => _user != null;

  // Sign in with Username and Password
  Future<String?> signInWithUsername(String username, String password) async {
    try {
      final email = '${username.trim().toLowerCase()}@tamilapp.com';
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        await _fetchUserProfile(credential.user!.uid);
      }
      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'Username not found';
      } else if (e.code == 'wrong-password') {
        return 'Incorrect password';
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Register with Username, Age, and Password
  Future<String?> registerWithUsername(String username, int age, String password) async {
    try {
      final email = '${username.trim().toLowerCase()}@tamilapp.com';
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        await _firestore.saveUser(
          credential.user!, 
          role: 'student', 
          displayName: username.trim(),
          age: age,
        );
        await _fetchUserProfile(credential.user!.uid);
      }
      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Username is already taken';
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Sign in Anonymously
  Future<String?> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      if (credential.user != null) {
        await _firestore.saveUser(
          credential.user!,
          role: 'student',
          displayName: 'Student',
        );
        await _fetchUserProfile(credential.user!.uid);
      }
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
    _user = null;
    _userProfile = null;
    notifyListeners();
  }
}
