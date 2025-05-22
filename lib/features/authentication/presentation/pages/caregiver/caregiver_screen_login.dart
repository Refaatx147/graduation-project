// ignore_for_file: use_build_context_synchronously, avoid_print, unused_field

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grade_pro/core/utils/user_auth_service.dart';
import 'package:grade_pro/features/authentication/presentation/blocs/auth_cubit/auth_cubit.dart';
import 'package:grade_pro/features/authentication/presentation/blocs/auth_cubit/auth_state.dart';

class CaregiverScreenLogin extends StatefulWidget {
  const CaregiverScreenLogin({super.key});

  @override
  _CaregiverScreenLoginState createState() => _CaregiverScreenLoginState();
}

class _CaregiverScreenLoginState extends State<CaregiverScreenLogin> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final UserAuthService _auth = UserAuthService();
  bool _obscurePassword = true;

  Future<void> loginCaregiver() async {
    if (_email.text.isEmpty || _password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Color(0xff2188A5),
        ),
      );
      return;
    }

    // Register user in Supabase Authentication
    await _auth.loginCaregiver(_email.text, _password.text, context);

    // More specific error handling
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xffFFF9ED),
        body: Padding(
          padding: const EdgeInsets.all(35.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/Access.png',
                color: const Color(0xff2188A5),
                width: 60,
                height: 55,
              ),
              const SizedBox(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 5),
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [Color(0xff169792), Color(0xff2188A5)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcIn,
                    child: Text(
                      'Login to',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Monitor Your Person\'s State',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 19,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 80),

              // Email Input Field
              TextField(
                
                controller: _email,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  hintStyle: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  labelText: 'Email Address',
                  labelStyle: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  suffixIcon: const Padding(
                    padding: EdgeInsets.only(right: 15.0),
                    child: Icon(Icons.email, color: Colors.black, size: 27),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 227, 229, 228),
                ),
              ),
              const SizedBox(height: 50),

              // Password Input Field
              TextField(
                controller: _password,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  labelText: 'Password',
                  labelStyle: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.black,
                        size: 27,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 227, 229, 228),
                ),
              ),
              const SizedBox(height: 60),

              // Login Button
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff0D343F), Color(0xff2188A5)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: context.read<AuthCubit>().isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () {
                              loginCaregiver();
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 85, vertical: 12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Login',
                                  style: GoogleFonts.openSans(
                                    textStyle: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 35),
                                const Icon(Icons.login_outlined,
                                    color: Colors.white, size: 35),
                              ],
                            ),
                          ),
                  );
                },
              ),
              const SizedBox(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.transparent),
                        shadowColor: WidgetStateProperty.all(Colors.transparent),
                        foregroundColor: WidgetStateProperty.all(Colors.black.withAlpha(150)),
                        overlayColor: WidgetStateProperty.all(Colors.transparent),
                      ),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/reset-pass'),
                      child: Text(
                        'Forget Password',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: 15,
                            color: Colors.black.withAlpha(150),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 70),

              // Register Now Link
              Text(
                "Doesn't have an account?",
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(
                    fontSize: 19,
                    color: Colors.black.withAlpha(100),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Register Now Link
              InkWell(
                onTap: () =>
                    Navigator.pushNamed(context, '/caregiver-register'),
                child: Text(
                  "Register Now!",
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
    
    );
  }
}
