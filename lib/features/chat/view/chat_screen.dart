import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unifind/features/chat/bloc/chat_cubit.dart';
import 'package:unifind/features/chat/bloc/chat_state.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;

  const ChatScreen({Key? key, required this.otherUserId}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    if (currentUserId != null) {
      context.read<ChatCubit>().loadMessages(
        currentUserId: currentUserId!,
        otherUserId: widget.otherUserId,
      );
    }
  }

  void _sendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty && currentUserId != null) {
      context.read<ChatCubit>().sendMessage(
        senderId: currentUserId!,
        receiverId: widget.otherUserId,
        text: messageText,
      );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: const Center(child: Text("You must be signed in to chat.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      // This is generally true by default, but explicit for clarity
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ChatLoaded) {
                  final messages = state.messages;
                  if (messages.isEmpty) {
                    return const Center(child: Text('No messages yet.'));
                  }
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == currentUserId;
                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isMe ? Colors.blueAccent : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is ChatError) {
                  return Center(child: Text('Error: ${state.error}'));
                }
                return const SizedBox();
              },
            ),
          ),
          // This SafeArea ensures the input is always visible above navigation bars.
          SafeArea(
            minimum: const EdgeInsets.only(
              left: 8,
              right: 8,
              bottom: 6,
              top: 2,
            ),
            child: Padding(
              // Add this padding to handle the keyboard overlay as well.
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
