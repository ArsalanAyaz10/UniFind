import 'package:flutter/material.dart';
import 'package:flutter_gradient_button/flutter_gradient_button.dart';
import 'package:unifind/core/widgets/auth_button.dart';
import 'package:unifind/features/splash/presentation/splash_screen.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 247, 248, 250),
      body: const BuildUI(),
    );
  }
}

class BuildUI extends StatelessWidget {
  const BuildUI({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: Image(
                image: NetworkImage(
                  "https://st.depositphotos.com/2274151/3518/i/950/depositphotos_35186549-stock-photo-sample-grunge-red-round-stamp.jpg",
                ),
                filterQuality: FilterQuality.high,
                fit: BoxFit.cover,
                height: 200,
                width: 200,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Welcome to UniFind!",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
            const Text(
              "One Stop Solution To Lost Items!",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            GradientButton(
              colors: [
                Color(0xFFE96443), // reddish pink
                Color(0xFFED6B47), // red-orange
                Color(0xFFF0724B), // soft red-orange
                Color(0xFFF37A4F), // peach-orange
                Color(0xFFF68152), // orange
                Color(0xFFF99856), // light orange
                Color(0xFFF9B456), // yellow-orange
              ],
              width: double.infinity,
              height: 50,
              radius: 25,
              gradientDirection: GradientDirection.leftToRight,
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              text: "Login",
              onPressed: () {
                print("Button clicked");
              },
            ),
            const SizedBox(height: 20),
            GradientButton(
              colors: [
                Color(0xFFE96443), // reddish pink
                Color(0xFFED6B47), // red-orange
                Color(0xFFF0724B), // soft red-orange
                Color(0xFFF37A4F), // peach-orange
                Color(0xFFF68152), // orange
                Color(0xFFF99856), // light orange
                Color(0xFFF9B456), // yellow-orange
              ],
              width: double.infinity,
              height: 50,
              radius: 25,
              gradientDirection: GradientDirection.leftToRight,
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              text: "Sign Up",
              onPressed: () {
                print("Button clicked");
              },
            ),
          ],
        ),
      ),
    );
  }
}
