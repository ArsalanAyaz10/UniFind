import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:unifind/features/item/data/models/item_model.dart';

class ItemRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  // Replace with your Cloudinary credentials
  static const String cloudName = 'dk49lauij';
  static const String uploadPreset = 'ZabFind_Uploads';

  ItemRepository(this.firebaseAuth, this.firestore);

  Future<void> addItem({
    required String name,
    required String description,
    required String campus,
    required String specificLocation,
    required String category,
    required DateTime date,
    required TimeOfDay time,
    required File? imageFile,
  }) async {
    final userId = firebaseAuth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    String imageUrl = '';
    DocumentReference docRef = firestore.collection('items').doc();

    if (imageFile != null) {
      // Upload image to Cloudinary under 'items/' folder
      imageUrl = await _uploadImageToCloudinary(imageFile, folder: 'items');
    }

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
      status: 'active',
    );

    await docRef.set(item.toMap());
  }

  Future<String> _uploadImageToCloudinary(
    File imageFile, {
    required String folder,
  }) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    var request =
        http.MultipartRequest('POST', url)
          ..fields['upload_preset'] = uploadPreset
          ..fields['folder'] = folder
          ..files.add(
            await http.MultipartFile.fromPath('file', imageFile.path),
          );

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);
      return data['secure_url'];
    } else {
      throw Exception(
        'Failed to upload image to Cloudinary: ${response.statusCode}',
      );
    }
  }

  Future<List<Item>> fetchItems() async {
    try {
      final querySnapshot =
          await firestore
              .collection('items')
              .where('status', isEqualTo: 'active')
              .orderBy('date', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => Item.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch items: $e');
    }
  }

  Future<Item> getItemById(String itemId) async {
    try {
      final docSnapshot = await firestore.collection('items').doc(itemId).get();

      if (!docSnapshot.exists) {
        throw Exception('Item not found');
      }

      return Item.fromMap(docSnapshot.id, docSnapshot.data()!);
    } catch (e) {
      throw Exception('Failed to fetch item by ID: $e');
    }
  }

  Future<void> updateItemStatus(String itemId, String status) async {
    try {
      await firestore.collection('items').doc(itemId).update({
        'status': status,
      });
    } catch (e) {
      throw Exception('Failed to update item status: $e');
    }
  }
}
