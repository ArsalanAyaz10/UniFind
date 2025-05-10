import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:unifind/features/item/data/models/item_model.dart';

class DataRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final FirebaseStorage _firebaseStorage;

  DataRepository(this.firebaseAuth, this.firestore, this._firebaseStorage);

  Future<void> addItem({
    required String name,
    required String description,
    required String campus,
    required String specificLocation,
    required String category,
    required DateTime date,
    required DateTime time,
    required File? imageFile,
  }) async {
    // Get current user ID
    final userId = firebaseAuth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    String imageUrl = '';
    DocumentReference docRef = firestore.collection('items').doc();

    if (imageFile != null) {
      // Upload the image to Firebase Storage
      final storageRef = _firebaseStorage
          .ref()
          .child('item_images')
          .child('${docRef.id}.jpg');

      final uploadTask = await storageRef.putFile(imageFile);
      imageUrl = await uploadTask.ref.getDownloadURL();
    }

    // Create the item object with status as 'active' by default
    final item = Item(
      itemId: docRef.id,
      userId: userId,
      name: name,
      description: description,
      campus: campus,
      specificLocation: specificLocation,
      category: category,
      imageUrl: imageUrl,
      date: date,
      time: time,
      status: 'active', // default status
    );

    // Set the document with generated ID
    await docRef.set(item.toMap());
  }
}
