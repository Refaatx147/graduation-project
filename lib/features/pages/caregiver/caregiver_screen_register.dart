// ignore_for_file: use_build_context_synchronously, avoid_print, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grade_pro/core/utils/firebase_auth.dart';
import 'package:grade_pro/core/utils/user_auth_service.dart';
import 'package:grade_pro/features/blocs/auth_cubit/auth_cubit.dart';
import 'package:grade_pro/features/blocs/auth_cubit/auth_state.dart';

class CaregiverScreenRegister extends StatefulWidget {
  const CaregiverScreenRegister({super.key});

  @override
  _CaregiverScreenRegisterState createState() =>
      _CaregiverScreenRegisterState();
}

class _CaregiverScreenRegisterState extends State<CaregiverScreenRegister> {
  final UserAuthService _auth = UserAuthService();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final patientName = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> registerCaregiver() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (name.text.isEmpty ||
        email.text.isEmpty ||
        password.text.isEmpty ||
        patientName.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Color(0xff2188A5),
        ),
      );
      return;
    }

    if (!_isValidEmail(email.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters long'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await _auth.registerCaregiver(
          email.text, password.text, context, name.text, patientName.text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(authService: AuthService()),
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: const Color(0xffFFF9ED),
          body: Padding(
            padding: const EdgeInsets.only(top: 60.0, right: 30, left: 30),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title Section
                    SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 50,
                            left: 30,
                            child: Image.asset('assets/images/Create.png',
                                color: const Color(0xff1E8E8D)),
                          ),
                          Positioned(
                            bottom: 115,
                            left: 30,
                            child: ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return const LinearGradient(
                                  colors: [Color(0xff169792), Color(0xff2188A5)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.srcIn,
                              child: Text(
                                'Create',
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontSize: 33,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 45,
                            left: 120,
                            child: ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return const LinearGradient(
                                  colors: [Color(0xff1E8E8D), Color(0xff083838)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.srcIn,
                              child: const Text(
                                'An Account',
                                style: TextStyle(
                                  fontSize: 28,
                                  color: Color(0xFF008577),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 90,
                            left: 120,
                            child: ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return const LinearGradient(
                                  colors: [Color(0xff1E8E8D), Color(0xff083838)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.srcIn,
                              child: Text(
                                'As Caregiver',
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontSize: 28,
                                    color: Color(0xFF008577),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Name Input
                    TextFormField(
                      controller: name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFDAE3E5),
                        suffixIcon: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Email Input
                    TextFormField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!_isValidEmail(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFDAE3E5),
                        suffixIcon: const Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Password Input
                    TextFormField(
                      controller: password,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFDAE3E5),
                        suffixIcon: const Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Patient Name Input
                    TextFormField(
                      controller: patientName,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter patient name';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Patient Name',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFDAE3E5),
                        suffixIcon: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Register Button
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xff0D343F),
                                Color(0xff2188A5),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          child: context.read<AuthCubit>().isLoading
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: registerCaregiver,
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 50, vertical: 10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Register',
                                        style: GoogleFonts.openSans(
                                          textStyle: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(width: 35),
                                      const Icon(
                                        Icons.login_outlined,
                                        color: Colors.white,
                                        size: 35,
                                      ),
                                    ],
                                  ),
                                ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "Already Have An Account?",
                      style: GoogleFonts.openSans(
                        textStyle: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/caregiver-login'),
                      child: Text(
                        'Login Now!',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
