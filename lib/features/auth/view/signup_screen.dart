import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unifind/features/auth/bloc/auth_cubit.dart';
import 'package:unifind/features/auth/bloc/auth_state.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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
                // Simplified loading indicator
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
                Navigator.of(context).pop(); // close loading
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Sign Up Successful",
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
                Navigator.of(context).pushReplacementNamed('/login');
              } else if (state is AuthError) {
                Navigator.of(context).pop(); // close loading
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
            child: const SignUpUI(),
          ),
        ],
      ),
    );
  }
}

class SignUpUI extends StatefulWidget {
  const SignUpUI({super.key});

  @override
  State<SignUpUI> createState() => _SignUpUIState();
}

class _SignUpUIState extends State<SignUpUI> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _stuIDController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _viewPassword = false;
  bool _viewConfirmPassword = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _stuIDController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                  height: 120,
                  width: 120,
                ),
              ).animate().fadeIn(duration: 600.ms),

              const SizedBox(height: 20),

              // Welcome text with simplified animation
              Text(
                "Welcome to ZabFind!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

              const SizedBox(height: 5),

              // Subtitle with simplified animation
              Text(
                "Create your account",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

              const SizedBox(height: 30),

              // Form with simplified animation
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Username field
                      buildTextField(
                        controller: _usernameController,
                        label: "Username",
                        icon: Icons.account_circle_sharp,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      // Student ID field
                      buildTextField(
                        controller: _stuIDController,
                        label: "Student ID",
                        icon: Icons.card_membership_sharp,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your student ID';
                          }
                          if (!RegExp(r'^\d+$').hasMatch(value)) {
                            return 'Student ID must be numeric';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      // Email field
                      buildTextField(
                        controller: _emailController,
                        label: "University Email",
                        icon: Icons.email_sharp,
                        keyboardType: TextInputType.emailAddress,
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

                      const SizedBox(height: 15),

                      // Password field
                      buildPasswordField(
                        controller: _passwordController,
                        label: "Password",
                        isVisible: _viewPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _viewPassword = !_viewPassword;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      // Confirm Password field
                      buildPasswordField(
                        controller: _confirmPasswordController,
                        label: "Confirm Password",
                        isVisible: _viewConfirmPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _viewConfirmPassword = !_viewConfirmPassword;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 25),

                      // Sign Up button with simplified styling
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Perform sign-up auth using firebase auth
                            context.read<AuthCubit>().signUp(
                              name: _usernameController.text,
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
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Back to login option with simplified styling
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(
                                context,
                              ).pushReplacementNamed('/login');
                            },
                            child: Text(
                              "Login",
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

  // Helper widget for text fields with yellow error text
  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
  }) {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          prefixIcon: Icon(icon, color: Colors.white),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.white),
          ),
          // Yellow error styling
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.yellow, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.yellow, width: 1.5),
          ),
          // Yellow error text
          errorStyle: TextStyle(
            color: Colors.yellow,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        style: TextStyle(color: Colors.white, fontSize: 16),
        validator: validator,
      ),
    );
  }

  // Helper widget for password fields with yellow error text
  Widget buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          prefixIcon: Icon(Icons.lock, color: Colors.white),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.white,
            ),
            onPressed: onToggleVisibility,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.white),
          ),
          // Yellow error styling
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.yellow, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.yellow, width: 1.5),
          ),
          // Yellow error text
          errorStyle: TextStyle(
            color: Colors.yellow,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        style: TextStyle(color: Colors.white, fontSize: 16),
        obscureText: !isVisible,
        validator: validator,
      ),
    );
  }
}
