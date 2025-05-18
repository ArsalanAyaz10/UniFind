import 'package:bloc/bloc.dart';
import 'package:unifind/features/chat/bloc/chat_list_state.dart';
import 'package:unifind/features/chat/data/chat_repository.dart';

class ChatListCubit extends Cubit<ChatListState> {
  final ChatRepository chatRepository;

  ChatListCubit({required this.chatRepository}) : super(ChatListInitial());

  Future<void> loadChatThreads(String currentUserId) async {
    emit(ChatListLoading());
    try {
      final List<ChatThreadModel> chats =
          await chatRepository.getChatThreadsForUser(currentUserId);
      emit(ChatListLoaded(chats));
    } catch (e) {
      emit(ChatListError(e.toString()));
    }
  }

  // Optionally, you can add a stream subscription for real-time updates.
  // Dispose method and subscription logic can be added as needed.
}