import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unifind/features/auth/bloc/auth_cubit.dart';
import 'package:unifind/features/auth/data/auth_repository.dart';
import 'package:unifind/features/auth/view/getstarted_screen.dart';
import 'package:unifind/features/auth/view/login_screen.dart';
import 'package:unifind/features/auth/view/signup_screen.dart';
import 'package:unifind/features/chat/bloc/chat_cubit.dart';
import 'package:unifind/features/chat/bloc/chat_list_cubit.dart'; // <-- Add this import
import 'package:unifind/features/chat/data/chat_repository.dart';
import 'package:unifind/features/chat/view/allchat_screen.dart';
import 'package:unifind/features/home/view/home_screen.dart';
import 'package:unifind/features/item/bloc/item_cubit.dart';
import 'package:unifind/features/item/data/item_repository.dart';
import 'package:unifind/features/item/view/itemDisplay_screen.dart';
import 'package:unifind/features/item/view/myItem_screen.dart';
import 'package:unifind/features/item/view/reportItem_screen.dart';
import 'package:unifind/features/profile/bloc/current_profile_cubit.dart';
import 'package:unifind/features/profile/bloc/other_profile_cubit.dart';
import 'package:unifind/features/profile/data/profile_repository.dart';
import 'package:unifind/features/profile/view/profile_screen.dart';
import 'package:unifind/features/splash/view/splash_screen.dart';

class UniFindApp extends StatelessWidget {
  const UniFindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create:
              (_) => AuthCubit(
                AuthRepository(
                  FirebaseAuth.instance,
                  FirebaseFirestore.instance,
                ),
              ),
        ),
        BlocProvider<CurrentProfileCubit>(
          create:
              (_) => CurrentProfileCubit(
                ProfileRepository(
                  FirebaseAuth.instance,
                  FirebaseFirestore.instance,
                ),
              ),
        ),
        BlocProvider<OtherProfileCubit>(
          create:
              (_) => OtherProfileCubit(
                ProfileRepository(
                  FirebaseAuth.instance,
                  FirebaseFirestore.instance,
                ),
              ),
        ),
        BlocProvider<ItemCubit>(
          create:
              (_) => ItemCubit(
                ItemRepository(
                  FirebaseAuth.instance,
                  FirebaseFirestore.instance,
                ),
              ),
        ),
        BlocProvider<ChatCubit>(
          create:
              (_) => ChatCubit(
                chatRepository: ChatRepository(
                  auth: FirebaseAuth.instance,
                  firestore: FirebaseFirestore.instance,
                ),
              ),
        ),
        BlocProvider<ChatListCubit>(
          // <-- Add this provider
          create:
              (_) => ChatListCubit(
                chatRepository: ChatRepository(
                  auth: FirebaseAuth.instance,
                  firestore: FirebaseFirestore.instance,
                ),
              ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          '/splash': (context) => SplashScreen(),
          '/started': (context) => GetStartedScreen(),
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/home': (context) => HomeScreen(),
          '/profile': (context) => ProfileScreen(),
          '/report': (context) => ReportitemScreen(),
          '/display': (context) => ItemdisplayScreen(),
          '/my-items': (context) => MyItemsScreen(),
          '/chats': (context) => AllChatsScreen(),
          //'/displaydetail': (context) => ItemdetailScreen(itemId: ''),
        },
        title: 'UniFind',
        theme: ThemeData.light().copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        darkTheme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
        ),
        themeMode: ThemeMode.light,
        home: SplashScreen(),
      ),
    );
  }
}
