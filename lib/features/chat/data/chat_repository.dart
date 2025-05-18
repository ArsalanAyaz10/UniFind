import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unifind/features/chat/data/model/chat_model.dart';

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ChatRepository({required this.firestore, required this.auth});

  // Returns a deterministic chat ID based on two user IDs
  String getChatId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  // Stream of messages between two users (in order)
  Stream<List<ChatMessage>> getMessages({
    required String currentUserId,
    required String otherUserId,
  }) {
    final chatId = getChatId(currentUserId, otherUserId);
    return firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.data()))
            .toList());
  }

  // Send a message from sender to receiver
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    final chatId = getChatId(senderId, receiverId);
    final chatRef = firestore.collection('chats').doc(chatId);

    final messageData = ChatMessage(
      senderId: senderId,
      text: text,
      timestamp: DateTime.now(),
    ).toMap();

    await chatRef.collection('messages').add(messageData);

    // Optionally update chat metadata for inbox view
    await chatRef.set({
      'participants': [senderId, receiverId],
      'lastMessage': text,
      'lastTimestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}