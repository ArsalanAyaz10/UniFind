import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:unifind/core/widgets/auth_button.dart';
import 'package:unifind/features/auth/bloc/auth_cubit.dart';
import 'package:unifind/features/item/bloc/item_cubit.dart';
import 'package:unifind/features/item/bloc/item_state.dart';
import 'package:unifind/features/profile/bloc/profile_cubit.dart';
import 'package:unifind/features/profile/bloc/profile_state.dart';

class ReportitemScreen extends StatefulWidget {
  const ReportitemScreen({super.key});

  @override
  State<ReportitemScreen> createState() => _ReportitemScreenState();
}

class _ReportitemScreenState extends State<ReportitemScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Item'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFE96443),
                Color(0xFFED6B47),
                Color(0xFFF0724B),
                Color(0xFFF37A4F),
                Color(0xFFF68152),
                Color(0xFFF99856),
                Color(0xFFF9B456),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                String name = 'Loading...';
                String email = '';
                String? profilePicUrl;

                if (state is ProfileLoaded) {
                  name = state.user.name;
                  email = state.user.email ?? '';
                  profilePicUrl = state.user.photoUrl;
                } else if (state is ProfileError) {
                  name = 'Error';
                  email = '';
                }
                return UserAccountsDrawerHeader(
                  accountName: Text(name),
                  accountEmail: Text(email),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    backgroundImage:
                        profilePicUrl != null
                            ? NetworkImage(profilePicUrl)
                            : const AssetImage('assets/images/profile.jpg')
                                as ImageProvider,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFE96443),
                        Color(0xFFED6B47),
                        Color(0xFFF0724B),
                        Color(0xFFF37A4F),
                        Color(0xFFF68152),
                        Color(0xFFF99856),
                        Color(0xFFF9B456),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                context.read<AuthCubit>().logout();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
      body: BlocListener<ItemCubit, ItemState>(
        listener: (context, state) {
          if (state is ItemLoading) {
            // Show loading indicator
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
          } else if (state is ItemLoaded) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Report submitted successfully!')),
            );
          } else if (state is ItemError) {
            // Show error message
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        child:
            const ReportItemUI(), // This is where ReportItemUI is now inside BlocListener
      ),
    );
  }
}

class ReportItemUI extends StatefulWidget {
  const ReportItemUI({super.key});

  @override
  State<ReportItemUI> createState() => _ReportItemUIState();
}

class _ReportItemUIState extends State<ReportItemUI> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _itemDescriptionController = TextEditingController();
  final _itemLocationController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final ImagePicker _picker = ImagePicker();
  List<XFile> _imageFiles = [];

  String? _selectedCampus;
  final List<String> _toggleOptions = ['Lost', 'Found'];
  int _selectedIndex = 0;
  final List<String> _campuses = [
    '79 Campus',
    '98 Campus',
    '99 Campus',
    '100 Campus',
    '153 Campus',
    '154 Campus',
  ];

  void clearController() {
    _itemNameController.clear();
    _itemDescriptionController.clear();
    _itemLocationController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "Please fill in the details below",
                      style: TextStyle(fontSize: 15, color: Colors.black),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _itemNameController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: "Item Name",
                        prefixIcon: const Icon(Icons.account_circle_sharp),
                        filled: true,
                        fillColor: Color(0xFFF7F8FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter item title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _itemDescriptionController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Enter Description",
                        prefixIcon: const Icon(Icons.description),
                        filled: true,
                        fillColor: Color(0xFFF6F6F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCampus,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      isExpanded: true,
                      hint: const Text('Select Campus'),
                      items:
                          _campuses.map((campus) {
                            return DropdownMenuItem(
                              value: campus,
                              child: Text(campus),
                            );
                          }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCampus = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _itemLocationController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Enter Specific Location",
                        prefixIcon: const Icon(Icons.location_on),
                        filled: true,
                        fillColor: Color(0xFFF6F6F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ToggleButtons(
                      isSelected: List.generate(
                        _toggleOptions.length,
                        (index) => index == _selectedIndex,
                      ),
                      onPressed: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      selectedColor: Colors.white,
                      fillColor: Colors.deepOrange,
                      color: Colors.deepOrange,
                      children:
                          _toggleOptions
                              .map(
                                (option) => SizedBox(
                                  width: 120,
                                  child: Center(child: Text(option)),
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: const BorderSide(color: Colors.deepOrange),
                            ),
                            icon: const Icon(
                              Icons.calendar_today,
                              color: Colors.deepOrange,
                            ),
                            label: Text(
                              _selectedDate == null
                                  ? 'Pick Date'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                              style: const TextStyle(color: Colors.deepOrange),
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() {
                                  _selectedDate = picked;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: const BorderSide(color: Colors.deepOrange),
                            ),
                            icon: const Icon(
                              Icons.access_time,
                              color: Colors.deepOrange,
                            ),
                            label: Text(
                              _selectedTime == null
                                  ? 'Pick Time'
                                  : _selectedTime!.format(context),
                              style: const TextStyle(color: Colors.deepOrange),
                            ),
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (picked != null) {
                                setState(() {
                                  _selectedTime = picked;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: const BorderSide(color: Colors.deepOrange),
                            ),
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.deepOrange,
                            ),
                            label: const Text(
                              'Add Image',
                              style: TextStyle(color: Colors.deepOrange),
                            ),
                            onPressed: () async {
                              final pickedFiles =
                                  await _picker.pickMultiImage();
                              if (pickedFiles != null) {
                                setState(() {
                                  _imageFiles.addAll(pickedFiles);
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16), // Add spacing after the button
                    if (_imageFiles.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _imageFiles.length,
                          itemBuilder: (context, index) {
                            final image = _imageFiles[index];
                            return Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  width: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(File(image.path)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 2,
                                  top: 2,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _imageFiles.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black54,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Submit Report',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (_imageFiles.isNotEmpty) {
                            // Use the first image from the selected list
                            context.read<ItemCubit>().addItem(
                              name: _itemNameController.text.trim(),
                              description:
                                  _itemDescriptionController.text.trim(),
                              campus: _selectedCampus!,
                              specificLocation:
                                  _itemLocationController.text.trim(),
                              category: _toggleOptions[_selectedIndex],
                              date: _selectedDate!,
                              time: _selectedTime!,
                              imageFile: File(
                                _imageFiles.first.path,
                              ), // Use the first image
                            );
                            clearController();
                          } else {
                            // Handle case when no image is selected
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select an image'),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
