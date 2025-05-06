import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unifind/core/models/user_model.dart';

class ProfileRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  ProfileRepository(this.firebaseAuth, this.firestore);

  Future<void> deleteAccount(String uid) async {
    try {
      await firestore.collection('users').doc(uid).delete();

      final user = firebaseAuth.currentUser;
      if (user != null && user.uid == uid) {
        await user.delete();
      } else {
        throw Exception('No signed-in user or UID mismatch');
      }
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  Future<AppUser?> fetchProfile(String uid) async {
    try {
      final docSnapshot = await firestore.collection('users').doc(uid).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null) {
          return AppUser.fromMap(uid, data);
        }
      }
      return null; // user not found
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<void> updateProfile(
    String uid, {
    String? name,
    String? program,
    int? studentId,
  }) async {
    Map<String, dynamic> updates = {};

    if (name != null) updates['name'] = name;
    if (program != null) updates['program'] = program;
    if (studentId != null) updates['studentId'] = studentId;

    if (updates.isNotEmpty) {
      await firestore.collection('users').doc(uid).update(updates);
    }
  }
}
