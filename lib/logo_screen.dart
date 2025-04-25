// ignore_for_file: use_build_context_synchronously, unused_field

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grade_pro/features/patient_authentication/presentation/pages/caregiver/caregiver_naigation_screen.dart';
import 'package:grade_pro/features/patient_authentication/presentation/pages/patient/patient_navigation_screen.dart';
import 'package:grade_pro/generated/l10n.dart';
import 'package:grade_pro/features/patient_authentication/presentation/pages/user_screen.dart';

class LogoPage extends StatefulWidget {
      final Function(Locale) changeLanguage;

  const LogoPage({super.key, required this.changeLanguage});

  @override
  State<LogoPage> createState() => _LogoPageState();
}

class _LogoPageState extends State<LogoPage> {
  Widget? _initialScreen;


  @override
  void initState()
  {
super.initState();
    _checkLoginStatus();

Future.delayed(Duration(seconds: 3),() {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) {
      return _initialScreen ?? UserPage(changeLanguage: widget.changeLanguage); // Default screen if no user is logged in
    },)
  );
},);
  }



  Future<void> _checkLoginStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final role = userDoc.data()?['role'];

      if (role == 'patient') {
        setState(() {
          _initialScreen = VoiceNavigationPage(initialPageIndex: 0,);
        });
      } else if (role == 'caregiver') {
        setState(() {
          _initialScreen = CaregiverNavigationScreen(); // أو أي شاشة خاصة بالمرافق
        });
      } 
    } else {
      setState(() {
        _initialScreen = UserPage(changeLanguage: widget.changeLanguage);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
                backgroundColor: Color(0xffFFF9ED)
,
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xffFFF9ED)
          ),
        
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             Image.asset('assets/images/logoup.png', width: 250, height: 250),
              // Replace with your logo asset path
              SizedBox(height: 40),

              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [Color(0xff0D343F), Color(0xff169792)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,

                  ).createShader(bounds);

                },
                blendMode: BlendMode.srcIn,
                child: Text(
                  S.of(context).logo_title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}