import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grade_pro/core/utils/voice_patient_helper.dart';
import 'package:grade_pro/features/patient_authentication/presentation/pages/patient/patient_navigation_screen.dart';

class SplashVoicePage extends StatefulWidget {
  @override
  _SplashVoicePageState createState() => _SplashVoicePageState();
}

class _SplashVoicePageState extends State<SplashVoicePage> {
  final VoiceHelper _voiceHelper = VoiceHelper();
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    _startVoiceGuidance();
  }




bool _isListening = false;

void _startVoiceGuidance() async {
  await _voiceHelper.speak("Welcome. Please choose a page to navigate to ");
  await Future.delayed(Duration(seconds: 3));
  _listenOnce();

  _retryTimer = Timer.periodic(Duration(seconds: 6), (_) {
    if (!_isListening) {
      _listenOnce();
    }
  });
}

void _listenOnce() async {
  _isListening = true;
  await _voiceHelper.speak("I didn't understand. Please choose a page to go to.");
  await Future.delayed(Duration(seconds: 2));
 final result = await _voiceHelper.listen();
 _handleCommand (result!);
  _isListening = false;
}
  
  void _handleCommand(String command) {
    final cmd = command.toLowerCase();
    int? pageIndex;

    if (cmd.contains("qr") || cmd.contains("code")) {
  pageIndex = 0;
   Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VoiceNavigationPage(initialPageIndex: pageIndex!),
      ),
    );
} else if (cmd.contains("home")) {
  pageIndex = 1;
  Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VoiceNavigationPage(initialPageIndex: pageIndex!),
      ),
    );
} else if (cmd.contains("call")) {
  pageIndex = 2;
  Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VoiceNavigationPage(initialPageIndex: pageIndex!),
      ),
    );
} else if (cmd.contains("con") || cmd.contains("connect")) {
  pageIndex = 3;
  Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VoiceNavigationPage(initialPageIndex: pageIndex!),
      ),
    );
}


    _retryTimer?.cancel();
    
  }

  

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: CircularProgressIndicator(),),
          SizedBox(height: 40,),

        Text('Qr,Home, call or Con',style:  GoogleFonts.poppins(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                                                  color:  Color.fromARGB(255, 24, 64, 75),

                  ),)
        ],
      ),
    );
  }
}
