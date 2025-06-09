// ignore_for_file: use_build_context_synchronously, avoid_print, library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grade_pro/core/utils/user_auth_service.dart';

class VoicePatientLoginScreen extends StatefulWidget {
  const VoicePatientLoginScreen({super.key});

  @override
  _VoicePatientLoginScreenState createState() => _VoicePatientLoginScreenState();
}

class _VoicePatientLoginScreenState extends State<VoicePatientLoginScreen> {
  final UserAuthService _auth = UserAuthService();
  final String _status = "Please say your 4 digit password";
  bool _isProcessing = false;
final bool _isListeningLogin =false;
  @override
  void initState() {
    super.initState();
    _startLogin();
  }


  
bool restartListeningLogin()
  {
    if(_isListeningLogin !=true)
  {
   _startLogin();
  }
  return true;
  }
Future<void> _startLogin() async {
  setState(() => _isProcessing = true);
  await _auth.speak("Please say your 4-digit password clearly");

  String? password;


    password = await Future.delayed(const Duration(seconds: 3)).then((value) {
      return _auth.listen();
    });
    print("Recognized Password Input: $password"); // Debugging log

    if (!await _auth.isValidPassword(password)) {
      await _auth.speak("Invalid password.");
      restartListeningLogin();
    }
  else
  {  await _auth.loginPatient(password!,context);

  }

}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        
        centerTitle: true,
        title: Text('Login As Patient',
                  style: GoogleFonts.poppins(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                                                  color:  const Color.fromARGB(255, 24, 64, 75),

                  ),
                ),
     //   backgroundColor: Color.fromARGB(255, 24, 64, 75),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          
            const Icon(Icons.security, size: 80),
            const SizedBox(height: 20),
            Text(_status, style: const TextStyle(fontSize: 20,color:                  //   //   Color(0xff0D343F),
                                Color.fromARGB(255, 24, 64, 75),
 )),
            if (_isProcessing) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}