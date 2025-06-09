// ignore_for_file: use_build_context_synchronously, unused_field, avoid_print

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grade_pro/core/services/call_service.dart';
import 'package:grade_pro/core/utils/user_auth_service.dart';
import 'package:grade_pro/features/pages/caregiver/caregiver_navigation_screen.dart';
import 'package:grade_pro/features/pages/patient/patient_navigation_screen.dart';
import 'package:grade_pro/generated/l10n.dart';
import 'package:grade_pro/features/pages/user_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grade_pro/features/blocs/navigation_cubit/navigation_cubit.dart';
import 'package:grade_pro/main.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class LogoPage extends StatefulWidget {
  const LogoPage({super.key});

  @override
  State<LogoPage> createState() => _LogoPageState();
}

class _LogoPageState extends State<LogoPage> {
  Widget? _initialScreen;

  @override
  void initState() {
    super.initState();
    _initializeAppAndCheckLogin();
  }

  Future<void> _initializeAppAndCheckLogin() async {
    try {

 
      // Initialize Zego
      ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
      await ZegoUIKit().initLog();
      
      // Configure FCM for Zego
      final signalingPlugin = ZegoUIKitSignalingPlugin();
      ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI([signalingPlugin]);

      // Check login status
      await _checkLoginStatus();

      // Navigate after delay
      if (mounted) {
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => _initialScreen ?? 
                const UserPage(),
            ),
          );
        });
      }
    } catch (e) {
      print('Error during initialization: $e');
    }
  }

  Future<void> _checkLoginStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
            await CallService.initializeCallService();

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final role = userDoc.data()?['role'];

      if (role == 'patient') {
        setState(() {
          _initialScreen = BlocProvider(
            create: (context) => NavigationCubit(),
            child: PatientNavigationScreen(
              authService: UserAuthService(),
            ),
          );
        });
      } else if (role == 'caregiver') {
        setState(() {
          _initialScreen = const CaregiverNavigationScreen();
        });
      } 
    } else {
      setState(() {
        _initialScreen = const UserPage();
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF9ED),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xffFFF9ED),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logoup.png',
                width: 250,
                height: 250,
              ),
              const SizedBox(height: 40),
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [Color(0xff0D343F), Color(0xff169792)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcIn,
                child: Text(
                  S.of(context).logo_title,
                  style: const TextStyle(
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