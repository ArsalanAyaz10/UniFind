import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unifind/features/chat/data/model/chat_model.dart';


class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ChatRepository({required this.firestore, required this.auth});

  String getChatId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Stream<List<ChatMessage>> getMessages(String otherUserId) {
    final currentUserId = auth.currentUser!.uid;
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

  Future<void> sendMessage(String otherUserId, String message) async {
    final currentUserId = auth.currentUser!.uid;
    final chatId = getChatId(currentUserId, otherUserId);
    final chatRef = firestore.collection('chats').doc(chatId);

    final messageData = ChatMessage(
      senderId: currentUserId,
      text: message,
      timestamp: DateTime.now(),
    ).toMap();

    await chatRef.collection('messages').add(messageData);

    // optional metadata
    await chatRef.set({
      'participants': [currentUserId, otherUserId],
      'lastMessage': message,
      'lastTimestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}