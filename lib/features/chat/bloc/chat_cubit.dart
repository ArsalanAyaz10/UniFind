import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unifind/features/chat/data/chat_repository.dart';
import 'chat_state.dart';
import 'package:unifind/features/chat/data/model/chat_model.dart';
import 'dart:async';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository chatRepository;
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;

  ChatCubit({required this.chatRepository}) : super(ChatInitial());

  void loadMessages({
    required String currentUserId,
    required String otherUserId,
  }) {
    emit(ChatLoading());
    // Cancel any previous subscription before starting a new one
    _messagesSubscription?.cancel();
    _messagesSubscription = chatRepository
        .getMessages(currentUserId: currentUserId, otherUserId: otherUserId)
        .listen(
          (messages) {
            emit(ChatLoaded(messages));
          },
          onError: (e) {
            emit(ChatError(e.toString()));
          },
        );
  }

  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    try {
      await chatRepository.sendMessage(
        senderId: senderId,
        receiverId: receiverId,
        text: text,
      );
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}