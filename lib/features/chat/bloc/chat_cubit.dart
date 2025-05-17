import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unifind/features/chat/data/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository chatRepository;

  ChatCubit({required this.chatRepository}) : super(ChatInitial());

  void loadMessages(String otherUserId) {
    emit(ChatLoading());
    chatRepository.getMessages(otherUserId).listen((messages) {
      emit(ChatLoaded(messages));
    }, onError: (e) {
      emit(ChatError(e.toString()));
    });
  }

  void sendMessage(String otherUserId, String message) async {
    try {
      await chatRepository.sendMessage(otherUserId, message);
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}