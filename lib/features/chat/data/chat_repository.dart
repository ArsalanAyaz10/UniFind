import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unifind/features/chat/data/model/chat_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send message
  Future<void> sendMessage({
    required String chatId,
    required ChatModel message,
  }) async {
    await _firestore
        .collection('messages')
        .doc(chatId)
        .collection('chats')
        .add(message.toMap());
  }

  // Get all messages for a chat
  Stream<List<ChatModel>> getMessages(String chatId) {
    return _firestore
        .collection('messages')
        .doc(chatId)
        .collection('chats')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatModel.fromMap(doc.data()))
          .toList();
    });
  }

  // Optional: Create or get chatId between two users
  String generateChatId(String userId1, String userId2) {
    return userId1.hashCode <= userId2.hashCode
        ? '$userId1\_$userId2'
        : '$userId2\_$userId1';
  }
}
