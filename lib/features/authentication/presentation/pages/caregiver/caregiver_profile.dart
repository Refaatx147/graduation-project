import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class CaregiverProfileScreen extends StatefulWidget {
  const CaregiverProfileScreen({super.key});

  @override
  State<CaregiverProfileScreen> createState() => _CaregiverProfileScreenState();
}

class _CaregiverProfileScreenState extends State<CaregiverProfileScreen> {
  final _nameController = TextEditingController(text: 'Ahmed Refaat');
  final _emailController = TextEditingController(text: 'ahmed22@gmail.com');
  final _phoneController = TextEditingController(text: '+201153881930');
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take Photo'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 252, 247),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
             Text(
              'Edit Profile',
              style:GoogleFonts.poppins(textStyle:  TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 25, 63, 80),
              ),
            ),),
            const SizedBox(height: 50),
            Center(child: _buildProfileImageSection()),
            const SizedBox(height: 60),
            _buildFormFields(),
            const SizedBox(height: 70),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Stack(
        children: [
          CircleAvatar(
            backgroundColor: const Color.fromARGB(255, 47, 101, 122),
            radius: 60,
            backgroundImage: _imageFile != null
                ? FileImage(_imageFile!)
                : const AssetImage('assets/default_avatar.png') as ImageProvider,
          ),
          Positioned(
            bottom: 5,
            right: 5,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(80),
                    blurRadius: 3,
                  )
                ],
              ),
              child: const Icon(Icons.camera_alt, size: 18, color: Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildTextField(_nameController, 'Name'),
        const SizedBox(height: 50),
        _buildTextField(_emailController, 'Email'),
        const SizedBox(height: 50),
        _buildTextField(_phoneController, 'Phone'),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        
        labelText: label,
        labelStyle: const TextStyle(color: Color.fromARGB(255, 8, 52, 72)),
        filled: true,
        fillColor: const Color.fromARGB(255, 233, 237, 240),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return  
    Padding(padding: EdgeInsets.symmetric(horizontal: 50) ,child:  SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color.fromARGB(255, 13, 49, 57), Color.fromARGB(255, 94, 184, 204)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Text(
              'Save',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
