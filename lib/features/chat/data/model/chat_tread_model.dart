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

  /// Creates a ChatThreadModel from Firestore data.
  /// [data] is a chat thread document.
  /// [currentUserId] is used to determine the "other" user and unread status.
  factory ChatThreadModel.fromMap(
    String id,
    Map<String, dynamic> data,
    String currentUserId,
  ) {
    final participants = List<String>.from(data['participants'] ?? []);
    final otherUserId = participants.firstWhere(
      (uid) => uid != currentUserId,
      orElse: () => '',
    );

    // Extract userInfo for the other user if available
    String otherUserName = '';
    String? otherUserPhotoUrl;
    final userInfo = data['userInfo'] as Map<String, dynamic>? ?? {};
    if (userInfo.isNotEmpty && userInfo[otherUserId] != null) {
      final otherUserInfo = userInfo[otherUserId] as Map<String, dynamic>? ?? {};
      otherUserName = (otherUserInfo['name'] ?? '') as String;
      otherUserPhotoUrl = otherUserInfo['photoUrl'] as String?;
    } else {
      // fallback to any old field if present, for backward compatibility
      otherUserName = data['otherUserName'] ?? '';
      otherUserPhotoUrl = data['otherUserPhotoUrl'];
    }

    // Support both 'lastMessageTime' and 'lastTimestamp' for compatibility
    final Timestamp? timestamp =
        data['lastMessageTime'] ??
        data['lastTimestamp']; // 'lastTimestamp' fallback (legacy field)
    return ChatThreadModel(
      threadId: id,
      otherUserId: otherUserId,
      otherUserName: otherUserName,
      otherUserPhotoUrl: otherUserPhotoUrl,
      lastMessage: data['lastMessage'],
      lastMessageTime: timestamp != null ? timestamp.toDate() : null,
      hasUnread:
          (data['unreadBy'] != null &&
              List<String>.from(data['unreadBy']).contains(currentUserId)),
    );
  }

  /// Converts this thread back to a map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'participants': [
        otherUserId,
      ], // You should include both user IDs when saving
      'otherUserName': otherUserName,
      'otherUserPhotoUrl': otherUserPhotoUrl,
      'lastMessage': lastMessage,
      'lastMessageTime':
          lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
      // 'unreadBy': ... -- manage this in your repository/cubit logic
    };
  }
}