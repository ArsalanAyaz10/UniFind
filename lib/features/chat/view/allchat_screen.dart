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
  // Define the color scheme
  final Color primaryColor = Color.fromRGBO(12, 77, 161, 1);
  final Color secondaryColor = Color.fromRGBO(28, 93, 177, 1);
  final Color tertiaryColor = Color.fromRGBO(41, 121, 209, 1);
  final Color quaternaryColor = Color.fromRGBO(64, 144, 227, 1);

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
      appBar: AppBar(
        title: Text(
          'Chats',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: BlocBuilder<ChatListCubit, ChatListState>(
          builder: (context, state) {
            if (state is ChatListLoading || state is ChatListInitial) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              );
            } else if (state is ChatListLoaded) {
              final chats = state.chats;
              if (chats.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: tertiaryColor.withOpacity(0.7),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No chats yet.',
                        style: TextStyle(
                          fontSize: 18,
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Start a conversation with someone!',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
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
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: chat.hasUnread 
                            ? quaternaryColor 
                            : Colors.grey.withOpacity(0.2),
                        width: chat.hasUnread ? 1.5 : 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: tertiaryColor.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: quaternaryColor.withOpacity(0.2),
                          backgroundImage:
                              (chat.otherUserPhotoUrl != null &&
                                      chat.otherUserPhotoUrl!.isNotEmpty)
                                  ? NetworkImage(chat.otherUserPhotoUrl!)
                                  : null,
                          child:
                              (chat.otherUserPhotoUrl == null ||
                                      chat.otherUserPhotoUrl!.isEmpty)
                                  ? Icon(Icons.person, size: 28, color: secondaryColor)
                                  : null,
                        ),
                      ),
                      title: Text(
                        chat.otherUserName.isNotEmpty
                            ? chat.otherUserName
                            : 'Unknown',
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 16,
                          color: primaryColor,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          chat.lastMessage ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14, 
                            color: chat.hasUnread 
                                ? Colors.black87 
                                : Colors.grey[600],
                            fontWeight: chat.hasUnread 
                                ? FontWeight.w500 
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (chat.lastMessageTime != null)
                            Text(
                              DateFormat('hh:mm a').format(chat.lastMessageTime!),
                              style: TextStyle(
                                fontSize: 12, 
                                color: Colors.grey[600],
                              ),
                            ),
                          if (chat.hasUnread)
                            Container(
                              margin: EdgeInsets.only(top: 6),
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: quaternaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        if (chat.otherUserId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Chat data is corrupted."),
                              backgroundColor: primaryColor,
                            ),
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
                    ),
                  );
                },
              );
            } else if (state is ChatListError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Error: ${state.error}',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                child: Text(
                  'Unknown state',
                  style: TextStyle(color: primaryColor),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
