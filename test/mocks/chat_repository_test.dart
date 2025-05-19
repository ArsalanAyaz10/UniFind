import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unifind/features/chat/data/chat_repository.dart';
import 'package:unifind/features/chat/data/model/chat_model.dart';
import 'package:unifind/features/chat/data/model/chat_tread_model.dart';

import 'auth_repository.mocks.mocks.dart';

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockCollectionReference<Map<String, dynamic>> mockChatsCollection;
  late MockDocumentReference<Map<String, dynamic>> mockChatDocRef;
  late MockCollectionReference<Map<String, dynamic>> mockMessagesCollection;
  late MockDocumentReference<Map<String, dynamic>> mockUserDocRef;
  late MockDocumentSnapshot<Map<String, dynamic>> mockUserDocSnap;
  late ChatRepository chatRepository;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockChatsCollection = MockCollectionReference<Map<String, dynamic>>();
    mockChatDocRef = MockDocumentReference<Map<String, dynamic>>();
    mockMessagesCollection = MockCollectionReference<Map<String, dynamic>>();
    mockUserDocRef = MockDocumentReference<Map<String, dynamic>>();
    mockUserDocSnap = MockDocumentSnapshot<Map<String, dynamic>>();

    chatRepository = ChatRepository(firestore: mockFirestore, auth: mockAuth);

    // Default stubs for common Firestore calls
    when(mockFirestore.collection('chats')).thenReturn(mockChatsCollection);
    when(mockChatsCollection.doc(any)).thenReturn(mockChatDocRef);
    when(
      mockChatDocRef.collection('messages'),
    ).thenReturn(mockMessagesCollection);
  });

  group('ChatRepository', () {
    test('getChatId returns sorted id', () {
      final id1 = chatRepository.getChatId('b', 'a');
      final id2 = chatRepository.getChatId('a', 'b');
      expect(id1, equals('a_b'));
      expect(id2, equals('a_b'));
    });

    test('sendMessage sends message and updates metadata', () async {
      // Arrange
      when(
        mockMessagesCollection.add(any),
      ).thenAnswer((_) async => MockDocumentReference<Map<String, dynamic>>());

      // Mock user docs for sender/receiver
      when(mockFirestore.collection('users')).thenReturn(mockChatsCollection);
      when(mockChatsCollection.doc('senderId')).thenReturn(mockUserDocRef);
      when(mockChatsCollection.doc('receiverId')).thenReturn(mockUserDocRef);

      when(mockUserDocRef.get()).thenAnswer((_) async => mockUserDocSnap);
      when(
        mockUserDocSnap.data(),
      ).thenReturn({'name': 'Alice', 'photoUrl': 'alice.png'});

      when(mockChatDocRef.set(any, any)).thenAnswer((_) async => {});

      // Act
      await chatRepository.sendMessage(
        senderId: 'senderId',
        receiverId: 'receiverId',
        text: 'Hello!',
      );

      // Assert
      verify(
        mockMessagesCollection.add(argThat(containsPair('text', 'Hello!'))),
      ).called(1);
      verify(
        mockChatDocRef.set(argThat(isA<Map<String, dynamic>>()), any),
      ).called(1);
    });

    test('markThreadAsRead updates unreadBy', () async {
      when(
        mockChatDocRef.update({
          'unreadBy': FieldValue.arrayRemove(['currentUser']),
        }),
      ).thenAnswer((_) async => {});

      await chatRepository.markThreadAsRead('currentUser', 'otherUser');
      verify(
        mockChatDocRef.update({
          'unreadBy': FieldValue.arrayRemove(['currentUser']),
        }),
      ).called(1);
    });

    // You can add more tests for getMessages, getChatThreadsForUser, chatThreadsStream, etc.
    // For stream methods, you'll want to setup StreamControllers and mock .snapshots()/.listen() if needed.
  });
}
