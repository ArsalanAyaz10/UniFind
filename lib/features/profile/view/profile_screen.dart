import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unifind/core/widgets/auth_button.dart';
import 'package:unifind/features/profile/bloc/profile_cubit.dart';
import 'package:unifind/features/profile/bloc/profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<ProfileCubit>().fetchProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFFFF5A5F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
          } else if (state is ProfileSuccess) {
            Navigator.of(
              context,
              rootNavigator: true,
            ).pop(); // Close the loader
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Profile Loaded Successfully")),
            );
          } else if (state is ProfileError) {
            Navigator.of(
              context,
              rootNavigator: true,
            ).pop(); // Close the loader
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: const ProfileBody(),
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
        await context.read<ProfileCubit>().uploadProfilePicture(imageFile);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image upload failed: ${e.toString()}")),
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
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: BlocBuilder<ProfileCubit, ProfileState>(
                      builder: (context, state) {
                        if (state is ProfileLoaded) {
                          _usernameController.text = state.user.name;
                          _programController.text = state.user.program!;
                          _stuIDController.text =
                              state.user.studentId.toString();

                          // If the profile picture URL exists, show the image, otherwise show a default icon
                          return CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[200],
                            backgroundImage:
                                state.user.photoUrl != null
                                    ? NetworkImage(state.user.photoUrl!)
                                    : const AssetImage(
                                          'assets/default_avatar.png',
                                        )
                                        as ImageProvider,
                          );
                        }
                        return const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            const SizedBox(height: 30),
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoaded) {
                  _usernameController.text = state.user.name ?? '';
                  _programController.text = state.user.program ?? '';
                  _stuIDController.text =
                      state.user.studentId?.toString() ?? '';
                }
                return Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: "Enter Your Full Name",
                        prefixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 246, 246, 246),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _programController,
                      decoration: InputDecoration(
                        labelText: "Enter Your Program",
                        prefixIcon: const Icon(Icons.school),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 246, 246, 246),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your program';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _stuIDController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Student ID",
                        prefixIcon: const Icon(Icons.card_membership_sharp),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 246, 246, 246),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
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
                    CustomButton(
                      text: "Save Changes",
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<ProfileCubit>().updateProfile(
                            name: _usernameController.text,
                            program: _programController.text,
                            studentId: int.tryParse(_stuIDController.text) ?? 0,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 15),
                    CustomButton(text: "Cancel", onPressed: () {}),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
