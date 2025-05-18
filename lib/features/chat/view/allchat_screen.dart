import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:unifind/features/chat/bloc/chat_list_cubit.dart';
import 'package:unifind/features/chat/bloc/chat_list_state.dart';
import 'package:unifind/features/chat/view/chat_screen.dart';

class AllChatsScreen extends StatefulWidget {
  @override
  State<AllChatsScreen> createState() => _AllChatsScreenState();
}

class _AllChatsScreenState extends State<AllChatsScreen> {
  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Prefer real-time updates for a modern chat UI
      context.read<ChatListCubit>().subscribeToChatThreads(currentUser.uid);
    }
  }

  @override
  void dispose() {
    // Clean up the stream subscription if using subscribeToChatThreads
    context.read<ChatListCubit>().close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chats')),
      body: BlocBuilder<ChatListCubit, ChatListState>(
        builder: (context, state) {
          if (state is ChatListLoading || state is ChatListInitial) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ChatListLoaded) {
            final chats = state.chats;
            if (chats.isEmpty) {
              return Center(child: Text('No chats yet.'));
            }
            // DO NOT reverse, show most recent at the bottom (default Firestore order)
            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                if (chat.otherUserId.isEmpty) {
                  // Defensive: skip corrupted threads
                  return SizedBox.shrink();
                }
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundImage:
                        (chat.otherUserPhotoUrl != null &&
                                chat.otherUserPhotoUrl!.isNotEmpty)
                            ? NetworkImage(chat.otherUserPhotoUrl!)
                            : null,
                    child:
                        (chat.otherUserPhotoUrl == null ||
                                chat.otherUserPhotoUrl!.isEmpty)
                            ? Icon(Icons.person, size: 30)
                            : null,
                  ),
                  title: Text(
                    chat.otherUserName.isNotEmpty
                        ? chat.otherUserName
                        : 'Unknown',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    chat.lastMessage ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (chat.lastMessageTime != null)
                        Text(
                          DateFormat('hh:mm a').format(chat.lastMessageTime!),
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      if (chat.hasUnread)
                        Container(
                          margin: EdgeInsets.only(top: 6),
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    if (chat.otherUserId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Chat data is corrupted.")),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => ChatScreen(otherUserId: chat.otherUserId),
                      ),
                    );
                  },
                );
              },
            );
          } else if (state is ChatListError) {
            return Center(child: Text('Error: ${state.error}'));
          } else {
            return Center(child: Text('Unknown state'));
          }
        },
      ),
    );
  }
}
