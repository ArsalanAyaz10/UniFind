import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unifind/features/chat/data/chat_repository.dart';
import 'package:unifind/features/chat/data/model/chat_model.dart';
import 'package:unifind/features/chat/data/model/chat_tread_model.dart';
import 'package:mockito/mockito.dart';

// Manual mocks
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockCollectionReference<T> extends Mock implements CollectionReference<T> {}
class MockDocumentReference<T> extends Mock implements DocumentReference<T> {}
class MockQuerySnapshot<T> extends Mock implements QuerySnapshot<T> {}
class MockQueryDocumentSnapshot<T> extends Mock implements QueryDocumentSnapshot<T> {}
class MockDocumentSnapshot<T> extends Mock implements DocumentSnapshot<T> {}
class MockFieldValue extends Mock implements FieldValue {}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late ChatRepository chatRepository;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    chatRepository = ChatRepository(firestore: mockFirestore, auth: mockAuth);
  });

  group('ChatRepository', () {
    const userId1 = 'user1';
    const userId2 = 'user2';

    test('getChatId returns sorted id', () {
      expect(chatRepository.getChatId('b', 'a'), 'a_b');
    });

    test('getMessages returns a stream of ChatMessage', () async {
      final mockChats = MockCollectionReference<Map<String, dynamic>>();
      final mockChatDoc = MockDocumentReference<Map<String, dynamic>>();
      final mockMessages = MockCollectionReference<Map<String, dynamic>>();
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      final mockQueryDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();

      when(mockFirestore.collection('chats')).thenReturn(mockChats);
      when(mockChats.doc(any)).thenReturn(mockChatDoc);
      when(mockChatDoc.collection('messages')).thenReturn(mockMessages);
      when(mockMessages.orderBy('timestamp')).thenReturn(mockMessages);
      when(mockMessages.snapshots()).thenAnswer((_) => Stream.value(mockQuerySnapshot));
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDoc]);
      when(mockQueryDoc.data()).thenReturn({
        'senderId': userId1,
        'text': 'hi',
        'timestamp': Timestamp.fromDate(DateTime(2024, 1, 1, 12)),
      });

      final result = await chatRepository.getMessages(
        currentUserId: userId1,
        otherUserId: userId2,
      ).first;

      expect(result, isA<List<ChatMessage>>());
      expect(result.length, 1);
      expect(result.first.senderId, userId1);
      expect(result.first.text, 'hi');
    });

    test('sendMessage stores message and updates chat meta', () async {
      final mockChats = MockCollectionReference<Map<String, dynamic>>();
      final mockChatDoc = MockDocumentReference<Map<String, dynamic>>();
      final mockMessages = MockCollectionReference<Map<String, dynamic>>();
      final mockUsers = MockCollectionReference<Map<String, dynamic>>();
      final mockSenderDoc = MockDocumentReference<Map<String, dynamic>>();
      final mockReceiverDoc = MockDocumentReference<Map<String, dynamic>>();
      final mockSenderSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      final mockReceiverSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

      when(mockFirestore.collection('chats')).thenReturn(mockChats);
      when(mockChats.doc(any)).thenReturn(mockChatDoc);
      when(mockChatDoc.collection('messages')).thenReturn(mockMessages);
      when(mockMessages.add(any)).thenAnswer((_) async => MockDocumentReference<Map<String, dynamic>>());

      when(mockFirestore.collection('users')).thenReturn(mockUsers);
      when(mockUsers.doc(userId1)).thenReturn(mockSenderDoc);
      when(mockUsers.doc(userId2)).thenReturn(mockReceiverDoc);
      when(mockSenderDoc.get()).thenAnswer((_) async => mockSenderSnapshot);
      when(mockReceiverDoc.get()).thenAnswer((_) async => mockReceiverSnapshot);
      when(mockSenderSnapshot.data()).thenReturn({'name': 'Alice', 'photoUrl': 'alice.jpg'});
      when(mockReceiverSnapshot.data()).thenReturn({'name': 'Bob', 'photoUrl': 'bob.jpg'});
      when(mockChatDoc.set(any, any)).thenAnswer((_) async {});

      await chatRepository.sendMessage(
        senderId: userId1,
        receiverId: userId2,
        text: 'hello world',
      );

      verify(mockMessages.add(any)).called(1);
      verify(mockChatDoc.set(argThat(isA<Map<String, dynamic>>()), any)).called(1);
    });

    test('markThreadAsRead updates unreadBy array', () async {
      final mockChats = MockCollectionReference<Map<String, dynamic>>();
      final mockChatDoc = MockDocumentReference<Map<String, dynamic>>();

      when(mockFirestore.collection('chats')).thenReturn(mockChats);
      when(mockChats.doc(any)).thenReturn(mockChatDoc);
      when(mockChatDoc.update(any)).thenAnswer((_) async {});

      await chatRepository.markThreadAsRead(userId1, userId2);

      verify(mockChatDoc.update({'unreadBy': FieldValue.arrayRemove([userId1])})).called(1);
    });

    test('getChatThreadsForUser returns ChatThreadModel list', () async {
      final mockChats = MockCollectionReference<Map<String, dynamic>>();
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      final mockQueryDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      final mockUsers = MockCollectionReference<Map<String, dynamic>>();
      final mockUserDoc = MockDocumentReference<Map<String, dynamic>>();
      final mockUserSnap = MockDocumentSnapshot<Map<String, dynamic>>();

      when(mockFirestore.collection('chats')).thenReturn(mockChats);
      when(mockChats.where('participants', arrayContains: userId1)).thenReturn(mockChats);
      when(mockChats.orderBy('lastTimestamp', descending: true)).thenReturn(mockChats);
      when(mockChats.get()).thenAnswer((_) async => mockQuerySnapshot);

      final testMap = {
        'participants': [userId1, userId2],
        'lastMessage': 'yo',
        'lastMessageTime': Timestamp.fromDate(DateTime.now()),
        'unreadBy': [userId1],
        'userInfo': {
          userId1: {'name': 'Alice', 'photoUrl': 'alice.jpg'},
          userId2: {'name': 'Bob', 'photoUrl': 'bob.jpg'},
        },
      };

      when(mockQuerySnapshot.docs).thenReturn([mockQueryDoc]);
      when(mockQueryDoc.id).thenReturn('threadId');
      when(mockQueryDoc.data()).thenReturn(testMap);

      when(mockFirestore.collection('users')).thenReturn(mockUsers);
      when(mockUsers.doc(userId2)).thenReturn(mockUserDoc);
      when(mockUserDoc.get()).thenAnswer((_) async => mockUserSnap);
      when(mockUserSnap.data()).thenReturn({'name': 'Bob', 'photoUrl': 'bob.jpg'});

      final threads = await chatRepository.getChatThreadsForUser(userId1);
      expect(threads, isA<List<ChatThreadModel>>());
      expect(threads.first.otherUserId, userId2);
      expect(threads.first.otherUserName, 'Bob');
    });
  });
}