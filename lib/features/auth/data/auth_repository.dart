import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unifind/core/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository(this.firebaseAuth, this._firestore);

  Future<void> signUp(String email, String password, String name) async {
    await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = firebaseAuth.currentUser;

    final newUser = AppUser(
      name: name,
      email: email,
      program: null,         
      studentId: null,       
    );

    await _firestore.collection("users").doc(user?.uid).set(newUser.toMap());
  }

  Future<AppUser?> login(String email, String password) async {
    await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = firebaseAuth.currentUser;

    if (user != null) {
      final userData = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (userData.exists) {
        final appUser = AppUser.fromMap(user.uid, userData.data()!);
        return appUser;
      }
    }
    return null;
  }

  Future<void> logout() async {
    await firebaseAuth.signOut();
  }


  Future<void> resetPassword(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
