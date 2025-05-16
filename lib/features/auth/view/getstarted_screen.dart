import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unifind/core/widgets/animated_button.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background with gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromRGBO(12, 77, 161, 1), // Main specified color
                  Color.fromRGBO(28, 93, 177, 1), // Lighter shade
                  Color.fromRGBO(41, 121, 209, 1), // Even lighter
                  Color.fromRGBO(64, 144, 227, 1), // Lightest shade
                ],
              ),
            ),
          ),

          // Decorative circles in background
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -70,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),

          // Main content
          const BuildUI(),
        ],
      ),
    );
  }
}

class BuildUI extends StatelessWidget {
  const BuildUI({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with animation
              Center(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Image(
                        image: AssetImage('assets/animations/Images/logo.png'),
                        filterQuality: FilterQuality.high,
                        height: 150,
                        width: 150,
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 800.ms)
                  .slideY(
                    begin: -0.3,
                    end: 0,
                    curve: Curves.easeOutQuad,
                    duration: 800.ms,
                  ),

              const SizedBox(height: 40),

              // Welcome text with animation
              Column(
                    children: [
                      const Text(
                        "Welcome to ZabFind!",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "One Stop Solution To Lost Items!",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 800.ms)
                  .slideY(
                    begin: 0.3,
                    end: 0,
                    curve: Curves.easeOutQuad,
                    duration: 800.ms,
                    delay: 300.ms,
                  ),

              const SizedBox(height: 60),

              // Buttons with animations
              AnimatedButton(
                text: "Login",
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                delay: 600,
              ),

              const SizedBox(height: 20),

              AnimatedButton(
                text: "Sign Up",
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                isOutlined: true,
                delay: 800,
              ),

              const SizedBox(height: 40),

              // Additional animated element at the bottom
              Text(
                "Find what matters",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ).animate().fadeIn(delay: 1000.ms, duration: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
