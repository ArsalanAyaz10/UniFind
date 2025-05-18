import 'package:equatable/equatable.dart';
import 'package:unifind/features/chat/data/models/chat_thread_model.dart';

abstract class ChatListState extends Equatable {
  const ChatListState();

  @override
  List<Object?> get props => [];
}

class ChatListInitial extends ChatListState {}

class ChatListLoading extends ChatListState {}

class ChatListLoaded extends ChatListState {
  final List<ChatThreadModel> chats;

  const ChatListLoaded(this.chats);

  @override
  List<Object?> get props => [chats];
}

class ChatListError extends ChatListState {
  final String error;

  const ChatListError(this.error);

  @override
  List<Object?> get props => [error];
}