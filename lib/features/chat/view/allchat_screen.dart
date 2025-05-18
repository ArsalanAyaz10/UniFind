import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unifind/features/chat/bloc/chat_list_cubit.dart';
import 'package:unifind/features/chat/bloc/chat_list_state.dart';import 'package:unifind/features/chat/view/chat_screen.dart';

class AllChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chats')),
      body: BlocBuilder<ChatListCubit, ChatListState>(
        builder: (context, state) {
          if (state is ChatListLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ChatListLoaded) {
            final chats = state.chats;
            if (chats.isEmpty) {
              return Center(child: Text('No chats yet.'));
            }
            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(chat.otherUserPhotoUrl ?? ''),
                    child: chat.otherUserPhotoUrl == null ? Icon(Icons.person) : null,
                  ),
                  title: Text(chat.otherUserName ?? 'Unknown'),
                  subtitle: Text(chat.lastMessage ?? ''),
                  trailing: chat.hasUnread ? Icon(Icons.mark_chat_unread, color: Colors.red) : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(otherUserId: chat.otherUserId),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return Center(child: Text('Error loading chats.'));
          }
        },
      ),
    );
  }
}