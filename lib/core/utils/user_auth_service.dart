// ignore_for_file: unused_field, use_build_context_synchronously, unnecessary_brace_in_string_interps, avoid_print, unused_element, use_rethrow_when_possible

import 'package:cloud_firestore/cloud_firestore.dart'
    show FieldValue, FirebaseFirestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:grade_pro/core/utils/firebase_auth.dart';
import 'package:grade_pro/features/blocs/auth_cubit/auth_cubit.dart';
import 'package:grade_pro/features/blocs/auth_cubit/auth_state.dart';
import 'package:grade_pro/features/blocs/navigation_cubit/navigation_cubit.dart';
import 'package:grade_pro/features/pages/caregiver/caregiver_scanner_screen.dart';
import 'package:grade_pro/features/pages/patient/patient_navigation_screen.dart';
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
      finalTimeout: const Duration(seconds: 10),
      onStatus: (val) => print('Speech Status: $val'),
      onError: (val) => print('Speech Error: $val'),
    );

    if (!available) return null;

    String recognizedWords = "";

    Future.delayed(const Duration(seconds: 2)).then((value) {
      _speech.listen(
        pauseFor: const Duration(seconds: 9),
        listenFor: const Duration(seconds: 9),
        onResult: (val) {
          if (val.recognizedWords.isNotEmpty) {
            recognizedWords = val.recognizedWords;
          }
        },
      );
    });
    await Future.delayed(const Duration(seconds: 7));
    return recognizedWords.toLowerCase().trim();
  }

  Future<void> stopListening() async {
    if (const RouteSettings().name != '/user-select') {
      await _speech.stop();
      await _flutterTts.stop();
    }
  }

  Future<void> registerPatient(String password, BuildContext context) async {
    try {
      final encryptedPassword = 'z@#A${password}';

      await authCubit.signUpPatient(
          email: _generateFirebaseEmail(encryptedPassword),
          password: encryptedPassword);

      if (authCubit.state is Authenticated) {
        // Generate a unique share token
        final shareToken = DateTime.now().millisecondsSinceEpoch.toString() +
            (1000 + (DateTime.now().millisecond % 9000)).toString();

        // Create user document with share token
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser?.uid)
            .set({
          'role': 'patient',
          'email': _generateFirebaseEmail(encryptedPassword),
          'shareToken': shareToken,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: Colors.green,
          ),
        );

        await speak("Registration successful. Navigating to login.");
        await Future.delayed(const Duration(seconds: 2));

        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/patient-login');
        }
      } else if (authCubit.state is Unauthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text(
                'Registration failed: ${(authCubit.state as Unauthenticated).errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );

        await speak("Registration failed. Please try again.");
        await Future.delayed(const Duration(seconds: 2));

        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/patient-register');
        }
      }
    } catch (e) {
      print('Error in registerPatient: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      await speak("Registration failed. Please try again.");
      await Future.delayed(const Duration(seconds: 2));

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/patient-register');
      }
    }
  }

  Future<void> loginPatient(String password, BuildContext context) async {
    final encryptedPassword = 'z@#A${password}';

    await authCubit.signInPatient(
      email: _generateFirebaseEmail(encryptedPassword),
      password: encryptedPassword,
    );
    if (authCubit.state is Authenticated) {
      Future.delayed(const Duration(seconds: 2)).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
          ),
        );
      });
      await speak("login successful. Navigating to home.");

      Future.delayed(const Duration(seconds: 1)).then(
        (value) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) {
              return BlocProvider<NavigationCubit>(
                create: (context) => NavigationCubit(),
                child: PatientNavigationScreen(
                  authService: UserAuthService(),
                ),
              );
            },
          ));
        },
      );
    } else if (authCubit.state is Unauthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(
              'Login failed: ${(authCubit.state as Unauthenticated).errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
      await speak("login failed.please try again.");
      Future.delayed(const Duration(seconds: 2)).then(
        (value) {
          Navigator.pushReplacementNamed(context, '/patient-login');
        },
      );
    }
  }

  Future<void> registerCaregiver(String email, String password,
      BuildContext context, String name, String patientName) async {
    try {
      // First create the user in Firebase Auth
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        try {
          // Create the user document in Firestore with the same ID as the auth user
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'name': name,
            'email': email,
            'role': 'caregiver',
            'patientName': patientName,
            'linkedPatient': null,
            'createdAt': FieldValue.serverTimestamp(),
          });

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                duration: Duration(seconds: 2),
                content: Text('Registration successful!'),
                backgroundColor: Colors.green,
              ),
            );

            await Future.delayed(const Duration(seconds: 2));
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, '/caregiver-login');
            }
          }
        } catch (firestoreError) {
          // If Firestore document creation fails, delete the auth user
          await userCredential.user?.delete();
          throw firestoreError;
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed';

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        default:
          errorMessage = e.message ?? 'Registration failed';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> loginCaregiver(
      String email, String password, BuildContext context) async {
    await authCubit.signInCaregiver(email: email, password: password);
    if (authCubit.state is Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          content: Text('Login successful!'),
          backgroundColor: Colors.green,
        ),
      );
      Future.delayed(const Duration(seconds: 1)).then(
        (value) async {
          // Navigator.push(context, MaterialPageRoute(builder: (context) {
          //   return CaregiverScannerScreen();

          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) {
              return const CaregiverScannerScreen();
            },
          ));
        },
      );
    } else if (authCubit.state is Unauthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
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
