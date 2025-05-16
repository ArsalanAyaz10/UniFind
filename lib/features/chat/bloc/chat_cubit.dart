import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unifind/features/chat/data/chat_repository.dart';
import 'package:unifind/features/chat/data/model/chat_model.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository chatRepository;
  StreamSubscription<List<ChatModel>>? _messagesSubscription;

  ChatCubit({required this.chatRepository}) : super(ChatInitial());

  void loadMessages(String chatId) {
    emit(ChatLoading());

    _messagesSubscription?.cancel();
    _messagesSubscription = chatRepository.getMessages(chatId).listen(
      (messages) {
        emit(ChatLoaded(messages));
      },
      onError: (error) {
        emit(ChatError(error.toString()));
      },
    );
  }

  Future<void> sendMessage({
    required String chatId,
    required ChatModel message,
  }) async {
    try {
      await chatRepository.sendMessage(chatId: chatId, message: message);
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
