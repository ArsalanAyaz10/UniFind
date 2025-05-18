import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unifind/core/widgets/custom_drawer.dart';
import 'package:unifind/features/auth/bloc/auth_cubit.dart';
import 'package:unifind/features/item/bloc/item_cubit.dart';
import 'package:unifind/features/item/bloc/item_state.dart';
import 'package:unifind/features/profile/bloc/current_profile_cubit.dart';
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Report Item',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromRGBO(12, 77, 161, 1).withOpacity(0.8),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: ModernDrawer(context),
      body: Stack(
        children: [
          // Background gradient
          Container(
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
          ),

          // Main content
          BlocConsumer<ItemCubit, ItemState>(
            listener: (context, state) {
              if (state is ItemLoaded) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Report submitted successfully!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.green.shade700,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (state is ItemError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Error: ${state.message}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.red.shade700,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              return Stack(
                children: [
                  // Report form
                  const ReportItemUI(),

                  // Loading overlay - only show when ItemLoading state is active
                  if (state is ItemLoading)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Uploading report...",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
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
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _imageFiles = [];
      _selectedCampus = null;
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header
              Text(
                "Report Lost or Found Item",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate().fadeIn(duration: 600.ms),

              SizedBox(height: 10),

              Text(
                "Please fill in the details below",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

              SizedBox(height: 20),

              // Form Container
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item Type Toggle
                      Text(
                        "Item Status",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: 10),

                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ToggleButtons(
                          isSelected: List.generate(
                            _toggleOptions.length,
                            (index) => index == _selectedIndex,
                          ),
                          onPressed: (index) {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          selectedColor: Colors.white,
                          fillColor: Color.fromRGBO(12, 77, 161, 1),
                          color: Colors.white,
                          constraints: BoxConstraints.expand(
                            width: (MediaQuery.of(context).size.width - 80) / 2,
                            height: 45,
                          ),
                          renderBorder: false,
                          children:
                              _toggleOptions
                                  .map(
                                    (option) => Text(
                                      option,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Item Name
                      buildTextField(
                        controller: _itemNameController,
                        label: "Item Name",
                        icon: Icons.inventory,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter item title';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16),

                      // Item Description
                      buildTextField(
                        controller: _itemDescriptionController,
                        label: "Item Description",
                        icon: Icons.description,
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16),

                      // Campus Selection
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedCampus,
                          decoration: InputDecoration(
                            labelText: "Select Campus",
                            labelStyle: TextStyle(color: Colors.white),
                            prefixIcon: Icon(
                              Icons.location_city,
                              color: Colors.white,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            errorStyle: TextStyle(
                              color: Colors.yellow,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          dropdownColor: Color.fromRGBO(28, 93, 177, 1),
                          style: TextStyle(color: Colors.white),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          ),
                          isExpanded: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a campus';
                            }
                            return null;
                          },
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
                      ),

                      SizedBox(height: 16),

                      // Specific Location
                      buildTextField(
                        controller: _itemLocationController,
                        label: "Specific Location",
                        icon: Icons.location_on,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the location';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 20),

                      // Date and Time
                      Text(
                        "When was it ${_toggleOptions[_selectedIndex].toLowerCase()}?",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: 10),

                      // Date and Time Pickers
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: Color.fromRGBO(
                                            12,
                                            77,
                                            161,
                                            1,
                                          ),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setState(() {
                                    _selectedDate = picked;
                                  });
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      _selectedDate == null
                                          ? 'Select Date'
                                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: Color.fromRGBO(
                                            12,
                                            77,
                                            161,
                                            1,
                                          ),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setState(() {
                                    _selectedTime = picked;
                                  });
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      _selectedTime == null
                                          ? 'Select Time'
                                          : _selectedTime!.format(context),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Image Upload
                      Text(
                        "Upload Images",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: 10),

                      GestureDetector(
                        onTap: () async {
                          final pickedFiles = await _picker.pickMultiImage();
                          if (pickedFiles != null) {
                            setState(() {
                              _imageFiles.addAll(pickedFiles);
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                'Add Images',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Image Preview
                      if (_imageFiles.isNotEmpty)
                        Container(
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
                                    margin: const EdgeInsets.only(right: 10),
                                    width: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: FileImage(File(image.path)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 5,
                                    top: 5,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _imageFiles.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black.withOpacity(0.7),
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                      SizedBox(height: 30),

                      // Submit Button
                      BlocBuilder<ItemCubit, ItemState>(
                        builder: (context, state) {
                          // Disable button during loading
                          bool isLoading = state is ItemLoading;

                          return ElevatedButton(
                            onPressed:
                                isLoading
                                    ? null // Disable button when loading
                                    : () {
                                      if (_formKey.currentState!.validate()) {
                                        if (_selectedDate == null) {
                                          showErrorSnackbar(
                                            'Please select a date',
                                          );
                                          return;
                                        }

                                        if (_selectedTime == null) {
                                          showErrorSnackbar(
                                            'Please select a time',
                                          );
                                          return;
                                        }

                                        if (_imageFiles.isEmpty) {
                                          showErrorSnackbar(
                                            'Please select at least one image',
                                          );
                                          return;
                                        }

                                        // Submit the report
                                        context.read<ItemCubit>().addItem(
                                          name: _itemNameController.text.trim(),
                                          description:
                                              _itemDescriptionController.text
                                                  .trim(),
                                          campus: _selectedCampus!,
                                          specificLocation:
                                              _itemLocationController.text
                                                  .trim(),
                                          category:
                                              _toggleOptions[_selectedIndex],
                                          date: _selectedDate!,
                                          time: _selectedTime!,
                                          imageFile: File(
                                            _imageFiles.first.path,
                                          ),
                                        );

                                        clearController();
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
                              // Dim the button when disabled
                              disabledBackgroundColor: Colors.grey.shade300,
                              disabledForegroundColor: Colors.grey.shade700,
                            ),
                            child: Text(
                              isLoading ? "Submitting..." : "Submit Report",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
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

  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Helper method for text fields with yellow error text
  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required String? Function(String?) validator,
  }) {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
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
