// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grade_pro/core/utils/user_auth_service.dart';
import 'package:grade_pro/features/patient_authentication/presentation/pages/patient/patient_qr_screen.dart';
import 'package:grade_pro/features/patient_authentication/presentation/pages/patient/patient_home_screen.dart';

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
 

    await _auth.speak("Welcome Patient! Please Say   Register or Login");
    final choice = await _auth.listen();

    if (choice == "register") {
      _isListeningUser=true;
      Navigator.pushReplacementNamed(context,'/patient-register');
    } else if (choice == "login") {
      _isListeningUser=true;
      Navigator.pushReplacementNamed(context, '/patient-login');
    } 
  restartListeningUser();

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
                                                  color:  Color.fromARGB(255, 24, 64, 75),

                  ),
                ),
      //  backgroundColor: Color.fromARGB(255, 24, 64, 75),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic, size: 80),
            SizedBox(height: 20),
            Text(_status, style: TextStyle(fontSize: 24,color: Color(0xff0D343F),),textAlign: TextAlign.center,),
            if (_isProcessing) Padding(
              padding: const EdgeInsets.only(top:28.0),
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}