import 'package:unifind/features/chat/data/model/chat_model.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;

  ChatLoaded(this.messages);
}

class ChatError extends ChatState {
  final String error;

  ChatError(this.error);
}
