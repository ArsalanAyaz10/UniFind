import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unifind/features/auth/bloc/auth_cubit.dart';
import 'package:unifind/features/auth/data/auth_repository.dart';
import 'package:unifind/features/auth/presentation/getstarted_screen.dart';
import 'package:unifind/features/auth/presentation/login_screen.dart';
import 'package:unifind/features/auth/presentation/signup_screen.dart';
import 'package:unifind/features/home/presentation/home_screen.dart';
import 'package:unifind/features/splash/presentation/splash_screen.dart';

class UniFindApp extends StatelessWidget {
  const UniFindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Provide FirebaseAuth and AuthRepository
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(AuthRepository(FirebaseAuth.instance)),
        ),
      ],
      child: MaterialApp(
        routes: {
          '/splash': (context) => SplashScreen(),
          '/started': (context) => GetStartedScreen(),
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/home': (context) => HomeScreen(),
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
