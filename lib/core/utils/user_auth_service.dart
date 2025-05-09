// ignore_for_file: unused_field, use_build_context_synchronously, unnecessary_brace_in_string_interps, avoid_print, unused_element


import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:grade_pro/core/utils/firebase_auth.dart';
import 'package:grade_pro/features/authentication/presentation/blocs/auth_bloc/cubit/auth_cubit.dart';
import 'package:grade_pro/features/authentication/presentation/blocs/auth_bloc/cubit/auth_state.dart';
import 'package:grade_pro/features/authentication/presentation/pages/caregiver/caregiver_scanner_screen.dart';
import 'package:grade_pro/features/authentication/presentation/pages/patient/patient_qr_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class UserAuthService {
  User? get currentUser => firebaseAuth.currentUser;

  final AuthCubit authCubit = AuthCubit(authService: AuthService());
  final AuthService authService = AuthService();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  Future<void> speak(String message) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.speak(message);
  }

  Future<String?> listen() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('Speech Status: $val'),
      onError: (val) => print('Speech Error: $val'),
    );

    if (!available) return null;

    String recognizedWords = "";

    Future.delayed(Duration(seconds: 3)).then((value) {
      _speech.listen(
        pauseFor: const Duration(seconds: 7),
        listenFor: const Duration(seconds: 7),
        onResult: (val) {
          if (val.recognizedWords.isNotEmpty) {
            recognizedWords = val.recognizedWords;
          }
        },
      );
    });
    await Future.delayed(const Duration(seconds: 8));
    return recognizedWords.toLowerCase().trim();
  }

  Future<void> stopListening() async {
    if (RouteSettings().name != '/user-select') {
      await _speech.stop();
      await _flutterTts.stop();
    }
  }

  Future<void> registerPatient(String password, BuildContext context) async {
    final encryptedPassword = 'z@#A${password}';

    await authCubit.signUpPatient(
        email: _generateFirebaseEmail(encryptedPassword),
        password: encryptedPassword);
    if (authCubit.state is Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful!'),
          backgroundColor: Colors.green,
        ),
      );
      speak("Registration successful. Navigating to login.");

      Future.delayed(Duration(seconds: 3)).then(
        (value) {
          Navigator.pushReplacementNamed(context, '/patient-login');
        },
      );
    } else if (authCubit.state is Unauthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: Text(
              'register failed: ${(authCubit.state as Unauthenticated).errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
      Future.delayed(Duration(seconds: 2)).then(
        (value) {
          Navigator.pushReplacementNamed(context, '/patient-register');
        },
      ); //  await speak(" failed.please try again.");
    }
  }

  Future<void> loginPatient(String password, BuildContext context) async {
    final encryptedPassword = 'z@#A${password}';

    await authCubit.signInPatient(
      email: _generateFirebaseEmail(encryptedPassword),
      password: encryptedPassword,
    );
    if (authCubit.state is Authenticated) {
      Future.delayed(Duration(seconds: 2)).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
          ),
        );
      });
      await speak("login successful. Navigating to home.");

      Future.delayed(Duration(seconds: 1)).then(
        (value) {
Navigator.of(context).push(MaterialPageRoute(builder: (context) {
  return PatientQrScreen()
;},));  },
      );
    } else if (authCubit.state is Unauthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: Text(
              'Login failed: ${(authCubit.state as Unauthenticated).errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
      await speak("login failed.please try again.");
      Future.delayed(Duration(seconds: 2)).then(
        (value) {
          Navigator.pushReplacementNamed(context, '/patient-login');
        },
      );
    }
  }


  Future<void> registerCaregiver(
      String email, String password, BuildContext context, String name) async {
    await authCubit.signUpCaregiver(
        email: email, password: password, name: name);
    if (authCubit.state is Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          content: Text('Registration successful!'),
          backgroundColor: Colors.green,
        ),
      );
      Future.delayed(Duration(seconds: 2)).then(
        (value) {
          Navigator.pushReplacementNamed(context, '/caregiver-login');
        },
      );
    } else if (authCubit.state is Unauthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: Text(
              'Login failed: ${(authCubit.state as Unauthenticated).errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  Future<void> loginCaregiver(
      String email, String password, BuildContext context) async {
    await authCubit.signInCaregiver(email: email, password: password);
    if (authCubit.state is Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          content: Text('Registration successful!'),
          backgroundColor: Colors.green,
        ),
      );
      Future.delayed(Duration(seconds: 1)).then(
        (value) async {
          // Navigator.push(context, MaterialPageRoute(builder: (context) {
          //   return CaregiverScannerScreen();

        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
  return CaregiverScannerScreen()
;},));
          
          
        },
      );
    } else if (authCubit.state is Unauthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: Text(
              'Login failed:${(authCubit.state as Unauthenticated).errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> isValidPassword(String? input) async {
    if (input == null) return false;

    String cleanedInput = input.replaceAll(RegExp(r'\s+'), '');

    return cleanedInput.length == 4 &&
        RegExp(r'^[0-9]+$').hasMatch(cleanedInput);
  }

  String _generateFirebaseEmail(String password) {
    final hash = password.hashCode.abs().toString();
    return 'user_${hash}@voiceauth.com';
  }

  Future<bool> hasRegisteredUser({required String password}) async {
    final String email = _generateFirebaseEmail(password);

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking user registration: $e');
      return false;
    }
  }
}

  // Future<bool> verifyPassword(String password) async {
  //   final encryptedPassword = 'z@#A${password}';
  //   final response = await _supabase.auth.signInWithPassword(
  //     email: _generateFirebaseEmail(password),
  //     password: encryptedPassword,
  //   );

  //   return response.user != null;
  // }




  
