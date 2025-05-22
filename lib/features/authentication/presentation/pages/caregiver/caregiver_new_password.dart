// ignore_for_file: avoid_print, unused_element

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CaregiverNewPassword extends StatefulWidget {
  const CaregiverNewPassword({super.key});

  @override
  State<CaregiverNewPassword> createState() => _CaregiverNewPasswordState();
}

class _CaregiverNewPasswordState extends State<CaregiverNewPassword> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordReset() async {
    if (_newPasswordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Color(0xff2188A5),
        ),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Color(0xff2188A5),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // Here you would typically update the password with Firebase
      // For now, we'll just navigate back to login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully'),
            backgroundColor: Color(0xff2188A5),
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/caregiver-login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

   return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xffFFF9ED),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenHeight * 0.03),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.045),
                  Row(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Color(0xff103944)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.05),
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return const LinearGradient(
                            colors: [Color(0xff1E8E8D), Color(0xff083838)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.srcIn,
                        child: Text(
                          'New Password',
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Image.asset('assets/images/lock.png', width: 200, height: 190),
                  SizedBox(height: screenHeight * 0.03),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 45.0),
                        child: Text(
                          'Enter New Password',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: TextField(
                          controller: _newPasswordController,
                          obscureText: _obscureNewPassword,
                          decoration: InputDecoration(
                            alignLabelWithHint: true,
                            hintText: '**********',
                            hintStyle: TextStyle(
                              color: Colors.black.withAlpha(150),
                              letterSpacing: 10,
                              fontSize: 15,
                            ),
                            labelStyle: const TextStyle(
                              color: Colors.black,
                              letterSpacing: 10,
                              fontSize: 20,
                            ),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: IconButton(
                                icon: Icon(
                                  _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureNewPassword = !_obscureNewPassword;
                                  });
                                },
                              ),
                            ),
                            focusColor: Colors.black,
                            hoverColor: Colors.black,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFDAE3E5),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      const Padding(
                        padding: EdgeInsets.only(left: 45.0),
                        child: Text(
                          'Confirm Your Password',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: TextField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            alignLabelWithHint: true,
                            hintText: '**********',
                            hintStyle: TextStyle(
                              color: Colors.black.withAlpha(150),
                              letterSpacing: 10,
                              fontSize: 15,
                            ),
                            labelStyle: const TextStyle(
                              color: Colors.black,
                              letterSpacing: 10,
                              fontSize: 20,
                            ),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            focusColor: Colors.black,
                            hoverColor: Colors.black,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFDAE3E5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.09),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff0D343F), Color(0xff2188A5)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handlePasswordReset,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Submit',
                                  style: GoogleFonts.openSans(
                                    textStyle: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 18),
                                const Icon(
                                  Icons.mark_chat_read_sharp,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
   
  }
}

  