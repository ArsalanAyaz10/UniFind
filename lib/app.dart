import 'package:flutter/material.dart';
import 'package:unifind/features/auth/presentation/getstarted_screen.dart';
import 'package:unifind/features/splash/presentation/splash_screen.dart';

class UniFindApp extends StatelessWidget {
  const UniFindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
         '/splash': (context) => SplashScreen(),
         '/started': (context) => GetStartedScreen(),
        // '/login': (context) =>  LoginScreen(),
        // '/signup': (context) =>  SignUpScreen(),
      },
      title: 'UniFind',
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
      ),
      themeMode: ThemeMode.system,
      home: SplashScreen(),
    );
  }
}
