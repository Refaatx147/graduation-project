// ignore_for_file: use_build_context_synchronously, avoid_print, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grade_pro/core/utils/user_auth_service.dart';

class PatientSelectionScreen extends StatefulWidget {
  const PatientSelectionScreen({super.key});

  @override
  _PatientSelectionScreenState createState() => _PatientSelectionScreenState();
}

class _PatientSelectionScreenState extends State<PatientSelectionScreen> {
  final UserAuthService _auth = UserAuthService();
  final String _status = "Welcome! Say 'Register' or 'Login'";
 final  bool _isProcessing = false;
 bool  _isListeningUser=false;

  @override
  void initState() {
    super.initState();
    _startVoiceFlow();
  }
   bool restartListeningUser()
  {
    if(_isListeningUser !=true)
  {
   _startVoiceFlow(); 
  }
  return true;
  }
  
Future<void> _startVoiceFlow() async {
 

    await _auth.speak("Welcome Patient! Please Say Register or Login");
    final choice = await  Future.delayed(const Duration(seconds: 3)).then((value) {
      return _auth.listen();
    });

    if (choice == "register") {
      _isListeningUser=true;
      Navigator.pushReplacementNamed(context,'/patient-register');
    } else if (choice == "login") {
      _isListeningUser=true;
      Navigator.pushReplacementNamed(context, '/patient-login');
    } 
     Future.delayed(const Duration(seconds: 2)).then((value) {

  restartListeningUser();

});
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
    appBar:    AppBar(
        
        centerTitle: true,
        title: Text('Welcome Patient',
                  style: GoogleFonts.poppins(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                                                  color:  const Color.fromARGB(255, 24, 64, 75),

                  ),
                ),
      //  backgroundColor: Color.fromARGB(255, 24, 64, 75),
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