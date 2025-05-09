// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grade_pro/core/utils/firebase_auth.dart';
import 'package:grade_pro/core/utils/user_auth_service.dart';
import 'package:grade_pro/features/authentication/presentation/blocs/auth_bloc/cubit/auth_cubit.dart';
import 'package:grade_pro/features/authentication/presentation/blocs/auth_bloc/cubit/auth_state.dart';

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

  Future<void> registerCaregiver() async {
    if (name.text.isEmpty ||
        email.text.isEmpty ||
        password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields'),backgroundColor:Color(0xff2188A5),),
      );
      return;
    }

    // Register user in Supabase Authentication
    await _auth.registerCaregiver(
        email.text, password.text, context,name.text);

    // More specific error handling
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(authService: AuthService()),
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Color(0xffFFF9ED),
          body: Padding(
            padding: const EdgeInsets.only(top: 60.0, right: 30, left: 30),
            child: SingleChildScrollView(
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
                              color: Color(0xff1E8E8D)),
                        ),
                        Positioned(
                          bottom: 115,
                          left: 30,
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return LinearGradient(
                                colors: [Color(0xff169792), Color(0xff2188A5)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.srcIn,
                            child: Text(
                              'Create',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
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
                              return LinearGradient(
                                colors: [Color(0xff1E8E8D), Color(0xff083838)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.srcIn,
                            child: Text(
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
                              return LinearGradient(
                                colors: [Color(0xff1E8E8D), Color(0xff083838)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.srcIn,
                            child: Text(
                              'As Caregiver',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
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
                  SizedBox(height: 20),

                  // Name Input
                  TextField(
                    controller: name,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      filled: true,
                      fillColor: Color(0xFFDAE3E5),
                      suffixIcon: Icon(Icons.person),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Email Input
                  TextField(
                    controller: email,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      filled: true,
                      fillColor: Color(0xFFDAE3E5),
                      suffixIcon: Icon(Icons.email),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Password Input
                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      filled: true,
                      fillColor: Color(0xFFDAE3E5),
                      suffixIcon: Icon(Icons.lock),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Register Button
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
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

                            // Show CircularProgressIndicator if loading
                            ? const CircularProgressIndicator()
                            // Show Register button if not loading
                            : ElevatedButton(
                                onPressed: () {
                                  registerCaregiver();
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50.0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 50, vertical: 10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Register',
                                      style: GoogleFonts.openSans(
                                        textStyle: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white),
                                      ),
                                    ), // Text before icon
                                    SizedBox(width: 35),
                                    Icon(
                                      Icons.login_outlined,
                                      color: Colors.white,
                                      size: 35,
                                    ), // Icon
                                  ],
                                ),
                              ),
                      );
                    },
                  ),
                  SizedBox(height: 30),
                  Text(
                    "Already Have An Account?",
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/caregiver-login'),
                    child: Text(
                      'Login Now!',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
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
          )),
    );
  }
}
