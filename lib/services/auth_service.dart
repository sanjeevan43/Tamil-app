import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'firestore_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
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

  // Sign in with Email and Password
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        await _fetchUserProfile(credential.user!.uid);
      }
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Register with Email and Password
  Future<String?> registerWithEmail(String email, String password, {String role = 'student'}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        await _firestore.saveUser(credential.user!, role: role);
        await _fetchUserProfile(credential.user!.uid);
      }
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Sign in with Google
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return "Sign in cancelled";

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        await _firestore.saveUser(userCredential.user!);
        await _fetchUserProfile(userCredential.user!.uid);
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
    await _googleSignIn.signOut();
    await _auth.signOut();
    _user = null;
    _userProfile = null;
    notifyListeners();
  }

  // Password Reset
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
}
