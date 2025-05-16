import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unifind/features/auth/bloc/auth_cubit.dart';
import 'package:unifind/features/auth/bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Gradient background
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

          // Main content with BlocListener
          BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthLoading) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder:
                      (_) => Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                );
              } else if (state is AuthSuccess) {
                Navigator.of(context).pop(); // Close loading
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Login Successful",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    backgroundColor: Colors.green.shade700,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.of(context).pushReplacementNamed('/home');
              } else if (state is PasswordResetSuccess) {
                Navigator.of(context).pop(); // Close loading
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Password reset email sent",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    backgroundColor: Colors.blue.shade700,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (state is AuthError) {
                Navigator.of(context).pop(); // Close loading
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    backgroundColor: Colors.red.shade700,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: LoginUI(),
          ),
        ],
      ),
    );
  }
}

class LoginUI extends StatefulWidget {
  const LoginUI({super.key});

  @override
  State<LoginUI> createState() => _LoginUIState();
}

class _LoginUIState extends State<LoginUI> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _viewPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with simplified animation
              Center(
                child: Image(
                  image: AssetImage('assets/animations/Images/logo.png'),
                  filterQuality: FilterQuality.high,
                  height: 140,
                  width: 140,
                ),
              ).animate().fadeIn(duration: 600.ms),

              const SizedBox(height: 30),

              // Welcome text with simplified animation
              Text(
                "Welcome Back to ZabFind!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

              const SizedBox(height: 10),

              // Subtitle with simplified animation
              Text(
                "Login to your account",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

              const SizedBox(height: 40),

              // Form with simplified animation
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email field with simplified styling and yellow error text
                      SizedBox(
                        width: double.infinity,
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "University Email",
                            labelStyle: TextStyle(color: Colors.white),
                            prefixIcon: Icon(
                              Icons.email_sharp,
                              color: Colors.white,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            // Yellow error styling without background
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.yellow,
                                width: 1.5,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.yellow,
                                width: 1.5,
                              ),
                            ),
                            // Yellow error text without background
                            errorStyle: TextStyle(
                              color: Colors.yellow,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                          ),
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.endsWith('@szabist.pk')) {
                              return 'Please use your @szabist.pk email';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Password field with simplified styling and yellow error text
                      SizedBox(
                        width: double.infinity,
                        child: TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: TextStyle(color: Colors.white),
                            prefixIcon: Icon(Icons.lock, color: Colors.white),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _viewPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _viewPassword = !_viewPassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            // Yellow error styling without background
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.yellow,
                                width: 1.5,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.yellow,
                                width: 1.5,
                              ),
                            ),
                            // Yellow error text without background
                            errorStyle: TextStyle(
                              color: Colors.yellow,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                          ),
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          obscureText: !_viewPassword,
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Forgot password with simplified styling
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            context.read<AuthCubit>().resetPassword(
                              email: _emailController.text,
                            );
                          },
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Login button with simplified animation
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthCubit>().login(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(12, 77, 161, 1),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Sign up option with simplified styling
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(
                                context,
                              ).pushReplacementNamed('/signup');
                            },
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.yellow,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
