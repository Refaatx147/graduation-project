import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grade_pro/core/utils/user_auth_service.dart';
import 'package:grade_pro/core/utils/voice_patient_helper.dart';
import 'package:grade_pro/features/patient_authentication/presentation/pages/call_screen.dart';
import 'package:grade_pro/features/patient_authentication/presentation/pages/caregiver/map_caregiver.dart';
import 'package:grade_pro/features/patient_authentication/presentation/pages/patient/patient_qr_screen.dart';
import 'package:grade_pro/features/patient_authentication/presentation/pages/patient/patient_home_screen.dart';

class VoiceNavigationPage extends StatefulWidget {
  final int initialPageIndex;

  VoiceNavigationPage({required this.initialPageIndex});

  @override
  _VoiceNavigationPageState createState() => _VoiceNavigationPageState();
}

class _VoiceNavigationPageState extends State<VoiceNavigationPage> {
  final VoiceHelper _voiceHelper = VoiceHelper();
   int _currentPageIndex=1;
  late Timer _reminderTimer;
   final bool  _isListeningRegister=false;


  final List<Widget> _pages = [
    PatientQrScreen(),
    HomePatient(authService: UserAuthService()),
        CallPage(isPatient: true),
    MapScreen()
  ];

  @override
  void initState() {
    super.initState();
    _startReminderTimer();
  }




bool restartListeningRegister()
  {
    if(_isListeningRegister !=true)
  {
   _registerUser();
  }
  return true;
  }

  Future<void> _registerUser() async {
  await VoiceHelper().speak("Please navigate to any page");

  String? result;


  // while (password == null || !_isValidPassword(password)) {
  //   }

    result = await VoiceHelper().listen();
    print("Recognized  Input: $result");  // Debugging log


}










  void _startReminderTimer() {
  _reminderTimer = Timer.periodic(Duration(seconds: 15), (_) async {
    await _voiceHelper.speak("You can choose any page");
 String? result;


  // while (password == null || !_isValidPassword(password)) {
  //   }

    result = await VoiceHelper().listen();
  String res =   cleanCommand(result!);
   _handleVoiceCommand(res);
    // استمع للصوت ومرر النتيجة لفنكشن التنفيذ
    
  });
}

String cleanCommand(String command) {
  return command.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
}

void  _handleVoiceCommand(String command) {
  String cleaned = cleanCommand(command);
  print("Cleaned command: $cleaned");

 if (cleaned=='qr') {
 setState(() {
   _currentPageIndex=0;
           print(_currentPageIndex);

 });}    
    else if(cleaned== 'home')
    {
      setState(() => _currentPageIndex = 1);
             print(_currentPageIndex);

     
    }
    else if (cleaned== 'call')
       {setState(() {
         _currentPageIndex=2;
                 print(_currentPageIndex);

       });
       }
    else if (cleaned=='map')
    {
      setState(() {
        _currentPageIndex=3;
        print(_currentPageIndex);
      });
    }
     else {
 _voiceHelper.speak("Sorry, I didn't understand that.");
     }  
 
  
}


  @override
  void dispose() {
    _reminderTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _pages[_currentPageIndex]);
  
  }
}
