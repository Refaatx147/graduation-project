// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grade_pro/core/utils/firebase_auth.dart';
import 'package:grade_pro/core/utils/user_auth_service.dart';
import 'package:grade_pro/features/blocs/auth_cubit/auth_cubit.dart';

class VoicePatientRegisterScreen extends StatefulWidget {
  const VoicePatientRegisterScreen({super.key});

  @override
  State<VoicePatientRegisterScreen> createState() => _VoicePatientRegisterScreenState();
}

class _VoicePatientRegisterScreenState extends State<VoicePatientRegisterScreen> {
   bool _isProcessing = false;
  final UserAuthService _auth = UserAuthService();
  final String _status = " Please Say your four digit password";
final AuthCubit authCubit = AuthCubit(authService: AuthService());
   final bool  _isListeningRegister=false;

@override

  void initState() {
    super.initState();
_registerUser();  }

bool restartListeningRegister()
  {
    if(_isListeningRegister !=true)
  {
   _registerUser();
  }
  return true;
  }
  Future<void> _registerUser() async {
    setState(() => _isProcessing = true);
    try {
      await _auth.speak("Please say your 4-digit password");
      String? password = await _auth.listen();
      print("Recognized Password Input: $password");  // Debugging log
      if (!await _auth.isValidPassword(password)) {
        await _auth.speak("Invalid password. Please try again.");
        setState(() => _isProcessing = false);
        // Retry after a short delay
        await Future.delayed(const Duration(seconds: 4));
        if (mounted) {
          _registerUser(); // Retry registration
        }
        return;
      }

      await _auth.registerPatient(password!, context);
    } catch (e) {
      print('Error in _registerUser: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      await _auth.speak("Registration failed. Please try again.");
      // Retry after error
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        _registerUser(); // Retry registration
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

 
  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
    appBar:   AppBar(
        
        centerTitle: true,
        title: Text('Register As Patient',
                  style: GoogleFonts.poppins(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                                                  color:  const Color.fromARGB(255, 24, 64, 75),

                  ),
                ),
    //    backgroundColor: Color.fromARGB(255, 24, 64, 75),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mic, size: 80),
            const SizedBox(height: 20),
            Text(_status, style: const TextStyle(fontSize: 24,color: Color(0xff0D343F),),textAlign: TextAlign.center,),
            if (_isProcessing) const Padding(
              padding: EdgeInsets.only(top:28.0),
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  
  }
}