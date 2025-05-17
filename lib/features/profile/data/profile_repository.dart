import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unifind/core/models/user_model.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';

class ProfileRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  // Cloudinary Config
  static const String cloudName = 'dk49lauij';
  static const String uploadPreset = 'ZabFind_Uploads';

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
          final profilePictureUrl = data['profilePicUrl'] as String?;
          return AppUser.fromMap(uid, data)..photoUrl = profilePictureUrl;
        }
      }
      return null;
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
          final profilePictureUrl = data['profilePicUrl'] as String?;
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
    final mimeType = lookupMimeType(imageFile.path);
    final uploadUrl = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final fileName = path.basename(imageFile.path);
    final publicId = 'Unifind/UserProfiles/$uid/$fileName'; // Folder structure

    final request = http.MultipartRequest('POST', uploadUrl)
      ..fields['upload_preset'] = uploadPreset
      ..fields['public_id'] = publicId
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: mimeType != null ? MediaType.parse(mimeType) : null,
      ));

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Cloudinary upload failed: ${response.statusCode}');
    }

    final resData = jsonDecode(await response.stream.bytesToString());
    final imageUrl = resData['secure_url'];

    // Save the image URL in Firestore
    await firestore.collection('users').doc(uid).update({
      'profilePicUrl': imageUrl,
    });

    return imageUrl;
  }
}
