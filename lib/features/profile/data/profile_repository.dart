import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:unifind/core/models/user_model.dart';

class ProfileRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final FirebaseStorage _firebaseStorage;

  ProfileRepository(this.firebaseAuth, this.firestore, this._firebaseStorage);

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
          // Fetch profile picture URL from Firebase Storage
          String? profilePictureUrl;
          try {
            final storageRef = _firebaseStorage.ref().child(
              'profile_pictures/$uid.jpg',
            );
            profilePictureUrl = await storageRef.getDownloadURL();
          } catch (e) {
            profilePictureUrl =
                null; // Handle if the profile picture doesn't exist
          }

          // Add the URL to the user data
          return AppUser.fromMap(uid, data)..photoUrl = profilePictureUrl;
        }
      }
      return null; // User not found
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<AppUser> getUserById(String uid) async {
    try {
      final docSnapshot = await firestore.collection('users').doc(uid).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null) {
          String? profilePictureUrl;

          try {
            final storageRef = _firebaseStorage.ref().child(
              'profile_pictures/$uid.jpg',
            );
            profilePictureUrl = await storageRef.getDownloadURL();
          } catch (_) {
            profilePictureUrl = null;
          }

          return AppUser.fromMap(uid, data)..photoUrl = profilePictureUrl;
        }
      }
      throw Exception('User not found');
    } catch (e) {
      throw Exception('Failed to get user by ID: $e');
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

  Future<String> uploadProfilePicture(String uid, File imageFile) async {
    final storageRef = _firebaseStorage.ref().child(
      'profile_pictures/$uid.jpg',
    );
    final uploadTask = await storageRef.putFile(imageFile);
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    // Update Firestore with the new URL
    await firestore.collection('users').doc(uid).update({
      'profilePicUrl': downloadUrl,
    });

    return downloadUrl;
  }
}
