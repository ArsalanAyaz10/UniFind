import 'package:flutter/material.dart';

class UniFindApp extends StatelessWidget {
  const UniFindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniFind',
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
      ),
      themeMode: ThemeMode.system,
      home: const Scaffold(
        body: Center(child: Text('Welcome to UniFind')),
      ),
    );
  }
}
