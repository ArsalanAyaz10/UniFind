import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unifind/features/chat/data/model/chat_model.dart';
import 'package:unifind/features/chat/data/model/chat_tread_model.dart';

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
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ChatMessage.fromMap(doc.data()))
                  .toList(),
        );
  }

  // Send a message from sender to receiver
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    final chatId = getChatId(senderId, receiverId);
    final chatRef = firestore.collection('chats').doc(chatId);

    final messageData =
        ChatMessage(
          senderId: senderId,
          text: text,
          timestamp: DateTime.now(),
        ).toMap();

    await chatRef.collection('messages').add(messageData);

    // Fetch both users' info for better chat metadata
    final senderSnapshot =
        await firestore.collection('users').doc(senderId).get();
    final receiverSnapshot =
        await firestore.collection('users').doc(receiverId).get();

    final senderName = senderSnapshot.data()?['name'] ?? '';
    final senderPhoto = senderSnapshot.data()?['photoUrl'];
    final receiverName = receiverSnapshot.data()?['name'] ?? '';
    final receiverPhoto = receiverSnapshot.data()?['photoUrl'];

    // Store both users' info for easy access in chat thread
    await chatRef.set({
      'participants': [senderId, receiverId],
      'lastMessage': text,
      'lastMessageTime':
          FieldValue.serverTimestamp(), // Use 'lastMessageTime' for consistency
      'lastTimestamp': FieldValue.serverTimestamp(), // For legacy compatibility
      'unreadBy': [receiverId],
      'userInfo': {
        senderId: {'name': senderName, 'photoUrl': senderPhoto},
        receiverId: {'name': receiverName, 'photoUrl': receiverPhoto},
      },
    }, SetOptions(merge: true));
  }

  // Mark all messages as read for current user in a thread
  Future<void> markThreadAsRead(
    String currentUserId,
    String otherUserId,
  ) async {
    final chatId = getChatId(currentUserId, otherUserId);
    final chatRef = firestore.collection('chats').doc(chatId);

    await chatRef.update({
      'unreadBy': FieldValue.arrayRemove([currentUserId]),
    });
  }

  // Get all chat threads for the current user (for AllChatsScreen)
  Future<List<ChatThreadModel>> getChatThreadsForUser(
    String currentUserId,
  ) async {
    final threadsQuery =
        await firestore
            .collection('chats')
            .where('participants', arrayContains: currentUserId)
            .orderBy('lastTimestamp', descending: true)
            .get();

    return (await Future.wait(
      threadsQuery.docs.map((doc) async {
        final data = doc.data();
        final participants = List<String>.from(data['participants'] ?? []);
        final otherUserId = participants.firstWhere(
          (uid) => uid != currentUserId,
          orElse: () => '',
        );
        if (otherUserId.isEmpty) return null;

        Map<String, dynamic> userInfo = Map<String, dynamic>.from(
          data['userInfo'] ?? {},
        );
        if (userInfo[otherUserId] == null) {
          final otherUserSnapshot =
              await firestore.collection('users').doc(otherUserId).get();
          final name = otherUserSnapshot.data()?['name'] ?? '';
          final photoUrl = otherUserSnapshot.data()?['photoUrl'];
          userInfo[otherUserId] = {'name': name, 'photoUrl': photoUrl};
          await firestore.collection('chats').doc(doc.id).set({
            'userInfo': userInfo,
          }, SetOptions(merge: true));
          data['userInfo'] = userInfo;
        }

        return ChatThreadModel.fromMap(doc.id, data, currentUserId);
      }).toList(),
    )).whereType<ChatThreadModel>().toList();
  }

  // Provide a stream for real-time chat thread updates
  Stream<List<ChatThreadModel>> chatThreadsStream(String currentUserId) {
    return firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastTimestamp', descending: true)
        .snapshots()
        .asyncMap((querySnapshot) async {
          return (await Future.wait(
            querySnapshot.docs.map((doc) async {
              final data = doc.data();
              final participants = List<String>.from(
                data['participants'] ?? [],
              );
              final otherUserId = participants.firstWhere(
                (uid) => uid != currentUserId,
                orElse: () => '',
              );
              if (otherUserId.isEmpty) return null;

              Map<String, dynamic> userInfo = Map<String, dynamic>.from(
                data['userInfo'] ?? {},
              );
              if (userInfo[otherUserId] == null) {
                final otherUserSnapshot =
                    await firestore.collection('users').doc(otherUserId).get();
                final name = otherUserSnapshot.data()?['name'] ?? '';
                final photoUrl = otherUserSnapshot.data()?['photoUrl'];
                userInfo[otherUserId] = {'name': name, 'photoUrl': photoUrl};
                await firestore.collection('chats').doc(doc.id).set({
                  'userInfo': userInfo,
                }, SetOptions(merge: true));
                data['userInfo'] = userInfo;
              }

              return ChatThreadModel.fromMap(doc.id, data, currentUserId);
            }).toList(),
          )).whereType<ChatThreadModel>().toList();
        });
  }
}
