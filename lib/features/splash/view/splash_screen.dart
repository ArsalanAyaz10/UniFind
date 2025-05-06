import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadBackend();
  }

  Future<void> _loadBackend() async {
    await Future.delayed(Duration(seconds: 5));
    // Simulate a network call or any other initialization logic here
    if (!mounted) return;
    Navigator.pushNamed(context, '/started');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          'assets/animations/splash.json',
          width: 100,
          height: 100,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
