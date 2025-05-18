import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unifind/features/profile/bloc/current_profile_cubit.dart';
import 'package:unifind/features/profile/bloc/profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<CurrentProfileCubit>().fetchProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromRGBO(12, 77, 161, 1).withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<CurrentProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoading) {
            // Don't show dialog, we'll handle loading in the UI
          } else if (state is ProfileSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Profile Updated Successfully",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is ProfileLoaded) {
            setState(() {
              _isInitialized = true;
            });
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading || !_isInitialized) {
            return buildLoadingScreen();
          }
          return const ProfileBody();
        },
      ),
    );
  }

  Widget buildLoadingScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(12, 77, 161, 1),
            Color.fromRGBO(28, 93, 177, 1),
            Color.fromRGBO(41, 121, 209, 1),
            Color.fromRGBO(64, 144, 227, 1),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              "Loading Profile...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileBody extends StatefulWidget {
  const ProfileBody({Key? key}) : super(key: key);

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _programController = TextEditingController();
  final TextEditingController _stuIDController = TextEditingController();

  String? _profileImageUrl;
  bool _isUploadingImage = false;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _isUploadingImage = true;
      });

      final imageFile = File(pickedFile.path);
      try {
        // Upload and get URL via Cubit
        await context.read<CurrentProfileCubit>().uploadProfilePicture(
          imageFile,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Image upload failed: ${e.toString()}",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _programController.dispose();
    _stuIDController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(12, 77, 161, 1),
            Color.fromRGBO(28, 93, 177, 1),
            Color.fromRGBO(41, 121, 209, 1),
            Color.fromRGBO(64, 144, 227, 1),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Profile Image Section
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      BlocBuilder<CurrentProfileCubit, ProfileState>(
                        builder: (context, state) {
                          if (state is ProfileLoaded) {
                            _usernameController.text = state.user.name ?? '';
                            _programController.text = state.user.program ?? '';
                            _stuIDController.text =
                                state.user.studentId?.toString() ?? '';

                            return Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                backgroundImage:
                                    state.user.photoUrl != null
                                        ? NetworkImage(state.user.photoUrl!)
                                        : const AssetImage(
                                              'assets/default_avatar.png',
                                            )
                                            as ImageProvider,
                              ),
                            ).animate().fadeIn(duration: 600.ms);
                          }
                          return CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                      if (_isUploadingImage)
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickAndUploadImage,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Color.fromRGBO(12, 77, 161, 1),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Form Fields
                BlocBuilder<CurrentProfileCubit, ProfileState>(
                  builder: (context, state) {
                    if (state is ProfileLoaded) {
                      _usernameController.text = state.user.name ?? '';
                      _programController.text = state.user.program ?? '';
                      _stuIDController.text =
                          state.user.studentId?.toString() ?? '';
                    }

                    return Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          buildTextField(
                            controller: _usernameController,
                            label: "Full Name",
                            icon: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          buildTextField(
                            controller: _programController,
                            label: "Program",
                            icon: Icons.school,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your program';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

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

                          const SizedBox(height: 30),

                          // Save Button
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context
                                    .read<CurrentProfileCubit>()
                                    .updateProfile(
                                      name: _usernameController.text,
                                      program: _programController.text,
                                      studentId:
                                          int.tryParse(_stuIDController.text) ??
                                          0,
                                    );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Color.fromRGBO(12, 77, 161, 1),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 4,
                              minimumSize: Size(double.infinity, 50),
                            ),
                            child: Text(
                              "Save Changes",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          // Cancel Button
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(color: Colors.white, width: 1),
                              ),
                              minimumSize: Size(double.infinity, 50),
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 600.ms);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for text fields with yellow error text
  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
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
}
