import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:unifind/core/widgets/auth_button.dart';

class ReportitemScreen extends StatelessWidget {
  const ReportitemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFE96443), // reddish pink
                Color(0xFFED6B47), // red-orange
                Color(0xFFF0724B), // soft red-orange
                Color(0xFFF37A4F), // peach-orange
                Color(0xFFF68152), // orange
                Color(0xFFF99856), // light orange
                Color(0xFFF9B456), // lightest orange
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: const ReportItemUI(),
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
  final _itemController = TextEditingController();
  final _typeController = TextEditingController();
  final _markController = TextEditingController();

  String? _selectedCampus;
  final List<String> _toggleOptions = ['Lost', 'Found'];
  int _selectedIndex = 0; // default to 'Lost'
  final List<String> _campuses = [
    'Main Campus',
    'City Campus',
    'North Campus',
    'West Campus',
  ];
  @override
  void dispose() {
    _itemController.dispose();
    _typeController.dispose();
    _markController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0, left: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          "Report Item",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Please fill in the details below",
                          style: TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _itemController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            labelText: "Item Title",
                            prefixIcon: const Icon(Icons.account_circle_sharp),
                            filled: true,
                            fillColor: Color.fromARGB(255, 247, 248, 250),
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
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _typeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Enter type of item",
                            prefixIcon: const Icon(Icons.card_membership_sharp),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 246, 246, 246),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select valid type';
                            }
                          },
                        ),
                        const SizedBox(height: 20),
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
                        const SizedBox(height: 20),
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
                                      width: 120, // 👈 set fixed width here
                                      child: Center(child: Text(option)),
                                    ),
                                  )
                                  .toList(),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _typeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Enter item Description",
                            prefixIcon: const Icon(Icons.card_membership_sharp),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 246, 246, 246),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter item description';
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          text: "Submit",
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {}
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
