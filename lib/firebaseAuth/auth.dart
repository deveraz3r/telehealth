import 'package:firebase_auth/firebase_auth.dart';

class Auth{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  //signIn with firebaseAuth
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
    }) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    }

  //createUser with firebaseAuth
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  //signOut user with firebaseAuth
  Future<void> signOut() async {
      await _firebaseAuth.signOut();
  }
}