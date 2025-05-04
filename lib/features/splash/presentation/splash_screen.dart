import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:unifind/features/auth/presentation/getstarted_screen.dart';

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
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => GetStartedScreen()),
    );
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
