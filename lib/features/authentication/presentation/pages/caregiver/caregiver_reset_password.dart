import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grade_pro/features/authentication/presentation/blocs/auth_cubit/auth_cubit.dart';
import 'package:grade_pro/features/authentication/presentation/blocs/auth_cubit/auth_state.dart';

class CaregiverResetPasswordScreen extends StatefulWidget {
  const CaregiverResetPasswordScreen({super.key});

  @override
  State<CaregiverResetPasswordScreen> createState() => _CaregiverResetPasswordScreenState();
}

class _CaregiverResetPasswordScreenState extends State<CaregiverResetPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email'),
          backgroundColor: Color(0xff2188A5),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      await context.read<AuthCubit>().resetPassword(_emailController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent. Please check your inbox.'),
            backgroundColor: Color(0xff2188A5),
          ),
        );
        Navigator.pushNamed(context, '/caregiver-verification');
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
    return  Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFFFF9ED),
        body: Padding(
          padding: const EdgeInsets.only(left: 30.0, top: 50, right: 30),
          child: Column(
            children: [
              // Back Arrow
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xff103944)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Lock Image
              Image.asset('assets/images/key.png', width: 200, height: 170),

              // Title
              SizedBox(
                width: double.infinity,
                height: 100,
                child: Stack(
                  children: [
                    Positioned(
                      child: Center(
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
                            'Reset Password',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
                      right: 20,
                      bottom: 75,
                      child: Icon(Icons.key_off_rounded, color: Color(0xff103944)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Email Input Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
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
                        fontSize: 15,
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
              ),
              Padding(
                padding: const EdgeInsets.only(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.transparent),
                        shadowColor: WidgetStateProperty.all(Colors.transparent),
                        foregroundColor: WidgetStateProperty.all(Colors.black.withAlpha(200)),
                        overlayColor: WidgetStateProperty.all(Colors.transparent),
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/caregiver-login'),
                      child: Text(
                        'or Back to sign in',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.black.withAlpha(200),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Send Button
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff0D343F), Color(0xff2188A5)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child:BlocBuilder<AuthCubit,AuthState>(builder: (context, state) {  
                  return ElevatedButton(
                  onPressed: _isLoading ? null : _handleResetPassword,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 11),
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
                              'Send',
                              style: GoogleFonts.openSans(
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color.fromARGB(255, 238, 237, 237),
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),
                            const Icon(
                              Icons.arrow_circle_right_outlined,
                              color: Colors.white,
                              size: 30,
                            ),
                          ],
                        ),
                );
                }
                )
              ),

              const SizedBox(height: 110),

              // Sign Up Link
              Text(
                "Don't have an account?",
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.black.withAlpha(170),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff2188A5), Color(0xff169792)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/caregiver-register'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 11),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Sign-Up',
                        style: GoogleFonts.openSans(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color.fromARGB(255, 252, 250, 250),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Icon(
                        Icons.app_registration_rounded,
                        color: Colors.white,
                        size: 25,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    
    );
  }
}