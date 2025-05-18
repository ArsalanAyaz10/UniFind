import 'package:cloud_firestore/cloud_firestore.dart';

class ChatThreadModel {
  final String threadId; // Unique thread/document ID
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhotoUrl;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final bool hasUnread;

  ChatThreadModel({
    required this.threadId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhotoUrl,
    this.lastMessage,
    this.lastMessageTime,
    this.hasUnread = false,
  });

  factory ChatThreadModel.fromMap(String id, Map<String, dynamic> data, String currentUserId) {
    // Assumes Firestore doc structure with participants, lastMessage, etc.
    final participants = List<String>.from(data['participants'] ?? []);
    // Find the other user (not the current user)
    final otherUserId = participants.firstWhere((id) => id != currentUserId, orElse: () => '');

    return ChatThreadModel(
      threadId: id,
      otherUserId: otherUserId,
      otherUserName: data['otherUserName'] ?? '',
      otherUserPhotoUrl: data['otherUserPhotoUrl'],
      lastMessage: data['lastMessage'],
      lastMessageTime: data['lastMessageTime'] != null
          ? (data['lastMessageTime'] as Timestamp).toDate()
          : null,
      hasUnread: data['unreadBy'] != null && List<String>.from(data['unreadBy']).contains(currentUserId),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'otherUserId': otherUserId,
      'otherUserName': otherUserName,
      'otherUserPhotoUrl': otherUserPhotoUrl,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'hasUnread': hasUnread,
    };
  }
}