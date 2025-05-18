import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:unifind/features/chat/bloc/chat_list_state.dart';
import 'package:unifind/features/chat/data/chat_repository.dart';
import 'package:unifind/features/chat/data/model/chat_tread_model.dart';

class ChatListCubit extends Cubit<ChatListState> {
  final ChatRepository chatRepository;
  StreamSubscription<List<ChatThreadModel>>? _subscription;

  ChatListCubit({required this.chatRepository}) : super(ChatListInitial());

  /// Loads chat threads once (non-streaming, one-time fetch)
  Future<void> loadChatThreads(String currentUserId) async {
    emit(ChatListLoading());
    try {
      final List<ChatThreadModel> chats = await chatRepository
          .getChatThreadsForUser(currentUserId);
      emit(ChatListLoaded(chats));
    } catch (e) {
      emit(ChatListError(e.toString()));
    }
  }

  /// Start a real-time chat threads listener (streaming)
  void subscribeToChatThreads(String currentUserId) {
    emit(ChatListLoading());
    _subscription?.cancel();
    _subscription = chatRepository
        .chatThreadsStream(currentUserId)
        .listen(
          (chats) {
            emit(ChatListLoaded(chats));
          },
          onError: (error) {
            emit(ChatListError(error.toString()));
          },
        );
  }

  /// Cancel the real-time subscription when no longer needed
  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
