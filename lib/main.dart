// ignore_for_file: unused_element, non_constant_identifier_names, use_build_context_synchronously, must_be_immutable, no_leading_underscores_for_local_identifiers, unrelated_type_equality_checks


import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:grade_pro/features/authentication/presentation/pages/call_screen.dart';
import 'package:grade_pro/features/authentication/presentation/pages/caregiver/caregiver_new_password.dart';
import 'package:grade_pro/features/authentication/presentation/pages/caregiver/caregiver_profile.dart';
import 'package:grade_pro/features/authentication/presentation/pages/caregiver/caregiver_reset_password.dart';
import 'package:grade_pro/features/authentication/presentation/pages/caregiver/caregiver_scanner_screen.dart';
import 'package:grade_pro/features/authentication/presentation/pages/caregiver/caregiver_screen_login.dart';
import 'package:grade_pro/features/authentication/presentation/pages/caregiver/caregiver_screen_register.dart';
import 'package:grade_pro/features/authentication/presentation/pages/caregiver/caregiver_verification.dart';
import 'package:grade_pro/features/authentication/presentation/pages/caregiver/map_caregiver.dart';
import 'package:grade_pro/features/authentication/presentation/pages/patient/patient_qr_screen.dart';
import 'package:grade_pro/features/authentication/presentation/pages/patient/voice_patient_login_screen.dart';
import 'package:grade_pro/features/authentication/presentation/pages/patient/voice_patient_register_screen.dart';
import 'package:grade_pro/features/authentication/presentation/pages/patient/voice_patient_selection_screen.dart';
import 'package:grade_pro/features/authentication/presentation/pages/user_screen.dart';
import 'package:grade_pro/generated/l10n.dart';
import 'package:grade_pro/login_patient.dart';
import 'package:grade_pro/logo_screen.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {

WidgetsFlutterBinding.ensureInitialized();

  /// 1.1.2: set navigator key to ZegoUIKitPrebuiltCallInvitationService
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

  // call the useSystemCallingUI
  ZegoUIKit().initLog().then((value) {
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
      [ZegoUIKitSignalingPlugin()],
    );
  });


    
// await ZIMKit().init(appID: 1417893468,appSign: '24422e49f6e8d6e106f5d840f96b247dee62e5832d54d462e568075c4ef4b3e4');
  
 late  String password;
  WidgetsFlutterBinding.ensureInitialized();


  password = 'default_password'; // Initialize password with a default value

  WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(MyApp(password: password,));
}




class MyApp extends StatelessWidget {

  final String password;
  // ignore: unused_field
 
 const  MyApp({super.key,required this.password,});

  @override
  Widget build(BuildContext context) {

return LanguageSwitcher(password: password,);  }
    
  }



class LanguageSwitcher extends StatefulWidget {
  final String password;
   final Map<String, WidgetBuilder> _routes = {

    // ignore: avoid_types_as_parameter_names
    '/logo': (context) => LogoPage(changeLanguage:(p0) {
    },),
    '/dashboard': (context) => HomeScreen(),
        '/patient-login': (context) => VoicePatientLoginScreen(),
        '/patient-register': (context) => VoicePatientRegisterScreen(),
'/patient-select':(context)=>PatientSelectionScreen(),
    '/caregiver-login': (context) => CaregiverScreenLogin(),
    '/caregiver-register':(context)=>CaregiverScreenRegister(),
    '/reset-pass':(context)=>CaregiverResetPasswordScreen(),
    '/caregiver-verification':(context)=>CaregiverVerificationScreen(),
    '/caregiver-new-password':(context)=>CaregiverNewPassword(),
    '/caregiver-confirmation':(context)=>CaregiverNewPassword(),
    '/map':(context)=>MapScreen(),
    '/caregiver-profile':(context)=>CaregiverProfileScreen(),
    '/patient-QrScreen':(context)=>PatientQrScreen(),
    '/caregiver-scanner':(context)=>CaregiverScannerScreen(),
    '/user-select':(context)=>UserPage(changeLanguage: (p0) {
    },),
    '/call-screen':(context)=>CallPage(isPatient: false),
  };
   LanguageSwitcher( {super.key,required this.password});

  @override
  State<LanguageSwitcher> createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends State<LanguageSwitcher> {
  Locale currentLocale = Locale('en');

  @override
  void initState() {
    super.initState();
  }

  void _changeLanguage(Locale newLocale) {
    setState(() {
      currentLocale = newLocale;
    });
  }

 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      locale: currentLocale,
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      title: 'Default App Title',
      routes: widget._routes,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xffFFF9ED),
        appBarTheme: const AppBarTheme(
          color: Color(0xffFFF9ED),
          titleTextStyle: TextStyle(
            color: Color.fromARGB(255, 31, 74, 86),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        primarySwatch: Colors.blue,
      ),
      home:  LogoPage(changeLanguage: _changeLanguage),
    );
  }
}
