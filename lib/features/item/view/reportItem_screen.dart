/*import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
*/
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

// Dummy ProfileCubit and State — replace with your actual implementation
class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());
}

void main() {
  runApp(
    BlocProvider(
      create: (context) => ProfileCubit(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Found Something',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const FoundSomethingScreen(),
    );
  }
}

class FoundSomethingScreen extends StatefulWidget {
  const FoundSomethingScreen({Key? key}) : super(key: key);

  @override
  State<FoundSomethingScreen> createState() => _FoundSomethingScreenState();
}

class _FoundSomethingScreenState extends State<FoundSomethingScreen> {
  final List<File?> _images = [null, null, null];
  bool _hasUploadedFirstImage = true;
  final _itemController = TextEditingController();
  final _typeController = TextEditingController();
  final _markController = TextEditingController();

  String? _selectedCampus;
  String _selectedOption = 'Lost'; // Toggle option

  final List<String> _campuses = [
    'Main Campus',
    'City Campus',
    'North Campus',
    'West Campus'
  ];

  final List<String> _toggleOptions = ['Lost', 'Found'];

  Future<void> _pickImage(int index) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _images[index] = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Gradient App Bar
          Container(
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF5F6D), Color(0xFFFFAA5B)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              children: const [
                Icon(Icons.arrow_back, color: Colors.white),
                SizedBox(width: 16),
                Text(
                  'FOUND SOMETHING',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(label: 'Item Name', controller: _itemController),
                  const SizedBox(height: 16),
                  _buildTextField(label: 'Item Type', controller: _typeController),
                  const SizedBox(height: 16),

                  _buildDropdown(
                    label: 'Select Campus',
                    value: _selectedCampus,
                    items: _campuses,
                    onChanged: (val) => setState(() => _selectedCampus = val),
                  ),

                  const SizedBox(height: 16),

                  _buildDropdown(
                    label: 'Select Type',
                    value: _selectedOption,
                    items: _toggleOptions,
                    onChanged: (val) => setState(() => _selectedOption = val!),
                  ),

                  const SizedBox(height: 16),

                  _buildTextField(label: 'Any mark on object', controller: _markController),
                  const SizedBox(height: 16),

                  const Text('Upload Photo (optional)', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 8),

                  Row(
                    children: List.generate(3, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () => _pickImage(index),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              image: _images[index] != null
                                  ? DecorationImage(
                                image: FileImage(_images[index]!),
                                fit: BoxFit.cover,
                              )
                                  : null,
                            ),
                            child: _images[index] == null
                                ? Icon(Icons.camera_alt, color: Colors.grey[400])
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        // Submit logic
                        print('Item: ${_itemController.text}');
                        print('Type: ${_typeController.text}');
                        print('Campus: $_selectedCampus');
                        print('Option: $_selectedOption');
                        print('Mark: ${_markController.text}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Submit', style: TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(border: InputBorder.none),
            isExpanded: true,
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

