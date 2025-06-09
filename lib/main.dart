// ignore_for_file: unused_element, non_constant_identifier_names, use_build_context_synchronously, must_be_immutable, no_leading_underscores_for_local_identifiers, unrelated_type_equality_checks, avoid_print, depend_on_referenced_packages, unnecessary_import
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:grade_pro/core/services/push_notifications.dart';
import 'package:grade_pro/core/utils/firebase_auth.dart';
import 'package:grade_pro/features/blocs/auth_cubit/auth_cubit.dart';
import 'package:grade_pro/features/blocs/navigation_cubit/navigation_cubit.dart';
import 'package:grade_pro/features/pages/caregiver/caregiver_new_password.dart';
import 'package:grade_pro/features/pages/caregiver/caregiver_profile.dart';
import 'package:grade_pro/features/pages/caregiver/caregiver_reset_password.dart';
import 'package:grade_pro/features/pages/caregiver/caregiver_scanner_screen.dart';
import 'package:grade_pro/features/pages/caregiver/caregiver_screen_login.dart';
import 'package:grade_pro/features/pages/caregiver/caregiver_screen_register.dart';
import 'package:grade_pro/features/pages/caregiver/caregiver_settings_screen.dart';
import 'package:grade_pro/features/pages/caregiver/caregiver_verification.dart';
import 'package:grade_pro/features/pages/caregiver/map_caregiver_screen.dart';
import 'package:grade_pro/features/pages/patient/map_patient_screen.dart';
import 'package:grade_pro/features/pages/patient/call_feature/patient_call_screen.dart';
import 'package:grade_pro/features/pages/patient/patient_qr_screen.dart';
import 'package:grade_pro/features/pages/patient/voice_patient_login_screen.dart';
import 'package:grade_pro/features/pages/patient/voice_patient_register_screen.dart';
import 'package:grade_pro/features/pages/patient/voice_patient_selection_screen.dart';
import 'package:grade_pro/features/pages/user_screen.dart';
import 'package:grade_pro/features/headset_connection/connected_headset.dart';
import 'package:grade_pro/features/headset_connection/test_screen.dart';
import 'package:grade_pro/generated/l10n.dart';
import 'package:grade_pro/logo_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:grade_pro/core/services/cloudinary_service.dart';
import 'package:permission_handler/permission_handler.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {

  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  await PushNotifications.initialize();


    await CloudinaryService().initialize();
    
     
  }
  catch (e, stackTrace) {
    print('Error initializing Firebase or Cloudinary: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
Future<void> requestOverlayPermission() async {
  if (Platform.isAndroid) {
    
    final status = await Permission.systemAlertWindow.status;
    if (!status.isGranted) {
      await Permission.systemAlertWindow.request();
      // Open settings if not granted
      if (!await Permission.systemAlertWindow.isGranted) {
        await openAppSettings();
      }
    }
  }

}

   runApp(
      MultiProvider(
        providers: [
          Provider<AuthService>(
            create: (_) => AuthService(),
            lazy: false,
          ),
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(
              authService: context.read<AuthService>(),
            ),
          ),
        
           BlocProvider(
            create: (context) => NavigationCubit(),
          ),
        ],
        child: const MyApp(),
      ),
    );
  
}






class MyApp extends StatelessWidget {
  
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
       routes: {
        '/logo': (context) => const LogoPage( ),
        '/patient-login': (context) => const VoicePatientLoginScreen(),
        '/patient-register': (context) => const VoicePatientRegisterScreen(),
        '/patient-select': (context) => const PatientSelectionScreen(),
        '/caregiver-login': (context) => const CaregiverScreenLogin(),
        '/caregiver-register': (context) => const CaregiverScreenRegister(),
        '/reset-pass': (context) => const CaregiverResetPasswordScreen(),
        '/caregiver-verification': (context) => const CaregiverVerificationScreen(),
        '/caregiver-new-password': (context) => const CaregiverNewPassword(),
        '/caregiver-map': (context) => const MapCaregiverScreen(patientId: ''),
        '/patient-map': (context) => const MapPatientScreen(patientId: ''),
        '/caregiver-profile': (context) => const CaregiverProfileScreen(),
        '/patient-QrScreen': (context) => const PatientQrScreen(),
        '/caregiver-scanner': (context) => const CaregiverScannerScreen(),
        '/user-select': (context) => const UserPage(),
        //'/call-screen': (context) => const CallPage(isPatient: false),
      '/settings-caregiver':(context)=> const CaregiverSettingsScreen(),
      '/headset-connected':(context)=>  const ConnectedHeadset(title: '',initialTab: 0,),
      '/test-headset':(context)=>    TestScreen(blinkCount: 0,onContinue: () {},),
      '/patient-call':(context)=>  const PatientCallPage(),
      }
      ,
      navigatorKey: navigatorKey,
      title: 'Grade Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xffFFF9ED),
        appBarTheme: const AppBarTheme(
          color: Color(0xffFFF9ED),
          titleTextStyle: TextStyle(
            color: Color.fromARGB(255, 31, 74, 86),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        useMaterial3: true,
      ),
      home: const LogoPage(),
    );
  }
}








