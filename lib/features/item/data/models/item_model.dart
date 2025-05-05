import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String ItemID;            // Firestore doc ID
  final String title;         // Item name or title
  final String description;   // Description of the item
  final String imageUrl;      // Uploaded image URL
  final String category;      // "Lost" or "Found"
  final String location;      // Where it was lost/found
  final DateTime datePosted;  // When it was posted
  final String userId;        // UID of user who posted

  Item({
    required this.ItemID,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.location,
    required this.datePosted,
    required this.userId,
  });

  // Convert Firestore data to Item object
  factory Item.fromMap(String id, Map<String, dynamic> data) {
    return Item(
      ItemID: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      location: data['location'] ?? '',
      datePosted: (data['datePosted'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
    );
  }

  // Convert Item object to Firestore data
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'location': location,
      'datePosted': Timestamp.fromDate(datePosted),
      'userId': userId,
    };
  }
}
