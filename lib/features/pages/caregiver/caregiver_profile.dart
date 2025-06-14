// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';

class CaregiverProfileScreen extends StatefulWidget {
  const CaregiverProfileScreen({super.key});

  @override
  State<CaregiverProfileScreen> createState() => _CaregiverProfileScreenState();
}

class _CaregiverProfileScreenState extends State<CaregiverProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _patientNameController = TextEditingController();
  File? _patientImageFile;
  String? _localPatientImagePath;
  File? _caregiverImageFile;
  String? _localCaregiverImagePath;
  bool _isLoading = false;
  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userData.exists) {
          setState(() {
            _nameController.text = userData.data()?['name'] ?? '';
            _emailController.text = userData.data()?['email'] ?? '';
            _patientNameController.text = userData.data()?['patientName'] ?? '';
            _localPatientImagePath = userData.data()?['patientImagePath'];
            _localCaregiverImagePath = userData.data()?['caregiverImagePath'];
            
            if (_localPatientImagePath != null) {
              final patientFile = File(_localPatientImagePath!);
              if (patientFile.existsSync()) {
                _patientImageFile = patientFile;
              } else {
                _localPatientImagePath = null;
              }
            }
            if (_localCaregiverImagePath != null) {
              final caregiverFile = File(_localCaregiverImagePath!);
              if (caregiverFile.existsSync()) {
                _caregiverImageFile = caregiverFile;
              } else {
                _localCaregiverImagePath = null;
              }
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading profile data: $e');
      _showSnackBar('Error loading profile data');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source, bool isCaregiver) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1000,
        maxHeight: 1000,
      );
      
      if (pickedFile != null) {
        setState(() {
          if (isCaregiver) {
            _caregiverImageFile = File(pickedFile.path);
          } else {
            _patientImageFile = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      _showSnackBar('Error picking image');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      String? patientImagePath = _localPatientImagePath;
      String? caregiverImagePath = _localCaregiverImagePath;

      if (_patientImageFile != null) {
        patientImagePath = await _saveImageLocally(_patientImageFile!, 'patient');
      }
      if (_caregiverImageFile != null) {
        caregiverImagePath = await _saveImageLocally(_caregiverImageFile!, 'caregiver');
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': _nameController.text,
        'email': _emailController.text,
        'patientName': _patientNameController.text,
        'patientImagePath': patientImagePath,
        'caregiverImagePath': caregiverImagePath,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _showSnackBar('Profile updated successfully');
    } catch (e) {
      _showSnackBar('Error saving profile');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<String> _saveImageLocally(File imageFile, String prefix) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${prefix}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedImage = await imageFile.copy('${directory.path}/$fileName');
    return savedImage.path;
  }

  void _showImageSourceDialog(bool isCaregiver) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Photo',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xff0D343F),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera, isCaregiver);
                  },
                ),
                _buildImageSourceOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery, isCaregiver);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xff0D343F).withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 25,
              color: const Color(0xff0D343F),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: const Color(0xff0D343F),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xff0D343F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xffFFF9ED),
        body: Center(
          child: SpinKitFadingCircle(
            color: Color(0xff0D343F),
            size: 50,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffFFF9ED),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                // padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(

                    color: Color(0xff0D343F),
                    borderRadius: BorderRadius.all(
                      Radius.elliptical(20,20),  
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 7),
                      _buildProfileImagesSection(),
                      const SizedBox(height: 7),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Details',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff0D343F),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildFormFields(),
                    const SizedBox(height: 32),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImagesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                              color: Colors.white.withOpacity(0.1),

              ),
              child: _buildImageSelector(
                title: 'Your Photo',
                imageFile: _caregiverImageFile,
                isCaregiver: true,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withOpacity(0.1),
              ),
              child: _buildImageSelector(
                title: 'Patient Photo',
                imageFile: _patientImageFile,
                isCaregiver: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSelector({
    required String title,
    required File? imageFile,
    required bool isCaregiver,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _showImageSourceDialog(isCaregiver),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: Builder(
                  builder: (context) {
                    if (imageFile != null && imageFile.existsSync()) {
                      try {
                        return Image.file(
                          imageFile,
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/barcelona.png',
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                            );
                          },
                        );
                      } catch (e) {
                        return Image.asset(
                          'assets/images/barcelona.png',
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                        );
                      }
                    }
                    return Image.asset(
                      'assets/images/barcelona.png',
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _showImageSourceDialog(isCaregiver),
            icon: const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 18,
            ),
            label: Text(
              'Change Photo',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              backgroundColor: Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Your Name',
          icon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _patientNameController,
          label: 'Patient Name',
          icon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter patient name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff0D343F).withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: const Color(0xff0D343F),
            ),
          ),
          labelStyle: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: const Color(0xff0D343F).withAlpha(153),
              fontSize: 14,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: const Color(0xff0D343F),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Save Changes',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _patientNameController.dispose();
    super.dispose();
  }
}
