import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:unifind/features/chat/bloc/chat_cubit.dart';
import 'package:unifind/features/chat/bloc/chat_state.dart';
import 'package:unifind/features/chat/data/chat_repository.dart';
import 'package:unifind/features/chat/data/model/chat_model.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository mockChatRepository;
  late ChatCubit chatCubit;

  setUp(() {
    mockChatRepository = MockChatRepository();
    chatCubit = ChatCubit(chatRepository: mockChatRepository);
  });

  tearDown(() async {
    await chatCubit.close();
  });

  group('ChatCubit', () {
    const currentUserId = 'user1';
    const otherUserId = 'user2';
    final messages = [
      ChatMessage(
        senderId: currentUserId,
        text: 'Hello',
        timestamp: DateTime(2023, 1, 1, 12, 0, 0),
      ),
      ChatMessage(
        senderId: otherUserId,
        text: 'Hey!',
        timestamp: DateTime(2023, 1, 1, 12, 1, 0),
      ),
    ];

    blocTest<ChatCubit, ChatState>(
      'emits [ChatLoading, ChatLoaded] when loadMessages succeeds',
      build: () {
        when(mockChatRepository.getMessages(
          currentUserId: currentUserId,
          otherUserId: otherUserId,
        )).thenAnswer((_) => Stream.value(messages));
        return chatCubit;
      },
      act: (cubit) =>
          cubit.loadMessages(currentUserId: currentUserId, otherUserId: otherUserId),
      expect: () => [isA<ChatLoading>(), isA<ChatLoaded>().having((l) => l.messages, 'messages', messages)],
    );

    blocTest<ChatCubit, ChatState>(
      'emits [ChatLoading, ChatError] when loadMessages emits error',
      build: () {
        when(mockChatRepository.getMessages(
          currentUserId: currentUserId,
          otherUserId: otherUserId,
        )).thenAnswer((_) => Stream<List<ChatMessage>>.error(Exception('stream error')));
        return chatCubit;
      },
      act: (cubit) =>
          cubit.loadMessages(currentUserId: currentUserId, otherUserId: otherUserId),
      expect: () => [
        isA<ChatLoading>(),
        isA<ChatError>().having((e) => e.error, 'error', contains('stream error')),
      ],
    );

    blocTest<ChatCubit, ChatState>(
      'calls sendMessage on repository when sendMessage is called successfully',
      build: () {
        when(mockChatRepository.sendMessage(
          senderId: currentUserId,
          receiverId: otherUserId,
          text: 'test message',
        )).thenAnswer((_) async {});
        return chatCubit;
      },
      act: (cubit) => cubit.sendMessage(
        senderId: currentUserId,
        receiverId: otherUserId,
        text: 'test message',
      ),
      expect: () => [],
      verify: (_) {
        verify(mockChatRepository.sendMessage(
          senderId: currentUserId,
          receiverId: otherUserId,
          text: 'test message',
        )).called(1);
      },
    );

    blocTest<ChatCubit, ChatState>(
      'emits ChatError when sendMessage throws',
      build: () {
        when(mockChatRepository.sendMessage(
          senderId: currentUserId,
          receiverId: otherUserId,
          text: 'fail message',
        )).thenThrow(Exception('send error'));
        return chatCubit;
      },
      act: (cubit) => cubit.sendMessage(
        senderId: currentUserId,
        receiverId: otherUserId,
        text: 'fail message',
      ),
      expect: () => [
        isA<ChatError>().having((e) => e.error, 'error', contains('send error')),
      ],
    );
  });
}