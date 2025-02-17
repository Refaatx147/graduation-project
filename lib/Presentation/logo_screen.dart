import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grade_pro/generated/l10n.dart';
import 'package:grade_pro/Presentation/user_screen.dart';

class LogoPage extends StatefulWidget {
      final Function(Locale) changeLanguage;

  const LogoPage({super.key, required this.changeLanguage});

  @override
  State<LogoPage> createState() => _LogoPageState();
}

class _LogoPageState extends State<LogoPage> {


  @override
  void initState()
  {
super.initState();
Timer(
  const Duration(seconds: 2),
    ()=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserPage(changeLanguage:widget.changeLanguage ,),))
);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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