import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Item {
  final String itemId; // Firestore doc ID
  final String userId; // UID of user who posted
  final String name; // Item name
  final String description; // Item description
  final String campus; // Campus name
  final String specificLocation; // Exact spot/location
  final String category; // "Lost" or "Found"
  final String imageUrl; // Image URL
  final String status;
  final DateTime date; // Date when it was lost/found
  final TimeOfDay time; // Time when it was lost/found

  Item({
    required this.itemId,
    required this.userId,
    required this.name,
    required this.description,
    required this.campus,
    required this.specificLocation,
    required this.category,
    required this.imageUrl,
    required this.date,
    required this.time,
    required this.status,
  });

  // Convert Firestore data to Item object
  factory Item.fromMap(String id, Map<String, dynamic> data) {
    return Item(
      itemId: id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      campus: data['campus'] ?? '',
      specificLocation: data['specificLocation'] ?? '',
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: TimeOfDay.fromDateTime((data['time'] as Timestamp).toDate()),
      status: data['status'] ?? 'active',
    );
  }

  // Convert Item object to Firestore data
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'campus': campus,
      'specificLocation': specificLocation,
      'category': category,
      'imageUrl': imageUrl,
      'date': Timestamp.fromDate(date),
      'time': Timestamp.fromDate(
        DateTime(date.year, date.month, date.day, time.hour, time.minute),
      ),

      'status': status,
    };
  }
}
