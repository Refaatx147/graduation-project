// ignore_for_file: unused_element, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:grade_pro/Presentation/caregiver/caregiver_new_password.dart';
import 'package:grade_pro/Presentation/caregiver/caregiver_reset_password.dart';
import 'package:grade_pro/Presentation/caregiver/caregiver_screen_login.dart';
import 'package:grade_pro/Presentation/caregiver/caregiver_screen_register.dart';
import 'package:grade_pro/Presentation/caregiver/caregiver_verification.dart';
import 'package:grade_pro/generated/l10n.dart';
import 'package:grade_pro/Presentation/logo_screen.dart';
import 'package:grade_pro/Presentation/patient/patient_screen.dart';

void main() {
  runApp(MyApp());
}




class MyApp extends StatelessWidget {
  
  // ignore: unused_field
 
 const  MyApp({super.key});

  @override
  Widget build(BuildContext context) {

return LanguageSwitcher();  }
    
  }



class LanguageSwitcher extends StatefulWidget {
   final Map<String, WidgetBuilder> _routes = {
    // ignore: avoid_types_as_parameter_names
    '/logo': (context) => LogoPage(changeLanguage:(p0) {
      
    },),
    '/patient-login': (context) => PatientScreen(),
    '/caregiver-login': (context) => CaregiverScreenLogin(),
    '/caregiver-register':(context)=>CaregiverScreenRegister(),
    '/reset-pass':(context)=>CaregiverResetPasswordScreen(),
    '/caregiver-verification':(context)=>CaregiverVerificationScreen(),
    '/caregiver-new-password':(context)=>CaregiverNewPassword(),
  };
   LanguageSwitcher( {super.key});

  @override
  State<LanguageSwitcher> createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends State<LanguageSwitcher> {
      Locale currentLocale  =Locale('en');
 void _changeLanguage(Locale newLocale) {
    setState(() {
      currentLocale = newLocale; // Update the locale
    });
  }
  @override
  
  Widget build(BuildContext context) {
        return MaterialApp(
          locale: currentLocale,
          
          localizationsDelegates: [
            
                    S.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: S.delegate.supportedLocales,
          title: 'Default App Title',
          initialRoute: '/',
      routes: widget._routes,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: LogoPage(changeLanguage: _changeLanguage,),
        );
      }
  } 


