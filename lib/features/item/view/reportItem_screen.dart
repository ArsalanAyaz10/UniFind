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

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String? _selectedCampus;
  final List<String> _toggleOptions = ['Lost', 'Found'];
  int _selectedIndex = 0; // default to 'Lost'
  final List<String> _campuses = [
    '79 Campus',
    '98 Campus',
    '99 Campus',
    '100 Campus',
    '153 Campus',
    '154 Campus',
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
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _itemController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            labelText: "Item Name",
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
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _typeController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: "Enter Description",
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
                          controller: _typeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Enter Specific Location",
                            prefixIcon: const Icon(Icons.card_membership_sharp),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 246, 246, 246),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Correct Specific Location';
                            }
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
                                      width: 120, // 👈 set fixed width here
                                      child: Center(child: Text(option)),
                                    ),
                                  )
                                  .toList(),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  side: const BorderSide(
                                    color: Colors.deepOrange,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.calendar_today,
                                  color: Colors.deepOrange,
                                ),
                                label: Text(
                                  _selectedDate == null
                                      ? 'Pick Date'
                                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                  style: const TextStyle(
                                    color: Colors.deepOrange,
                                  ),
                                ),
                                onPressed: () async {
                                  final DateTime? picked = await showDatePicker(
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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  side: const BorderSide(
                                    color: Colors.deepOrange,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.access_time,
                                  color: Colors.deepOrange,
                                ),
                                label: Text(
                                  _selectedTime == null
                                      ? 'Pick Time'
                                      : _selectedTime!.format(context),
                                  style: const TextStyle(
                                    color: Colors.deepOrange,
                                  ),
                                ),
                                onPressed: () async {
                                  final TimeOfDay? picked =
                                      await showTimePicker(
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
