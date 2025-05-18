import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unifind/features/chat/view/chat_screen.dart';

class ChatButton extends StatelessWidget {
  final String userId;

  const ChatButton({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(12, 77, 161, 1),
                Color.fromRGBO(41, 121, 209, 1),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(12, 77, 161, 1).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You must be signed in to chat.'),
                    ),
                  );
                  return;
                }
                final currentUserId = currentUser.uid;
                final otherUserId = userId; // Poster

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(otherUserId: otherUserId),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(28),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_bubble_outline, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Chat with User',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 1500.ms, duration: 800.ms)
        .slideY(begin: 0.5, end: 0, duration: 800.ms);
  }
}
