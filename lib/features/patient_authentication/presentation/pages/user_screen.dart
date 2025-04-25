// ignore_for_file: unused_field, avoid_print, use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grade_pro/core/utils/user_auth_service.dart';
import 'package:grade_pro/generated/l10n.dart';

class UserPage extends StatefulWidget {
    final Function(Locale) changeLanguage;

  const UserPage({super.key, required this.changeLanguage});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
 final UserAuthService _auth = UserAuthService();
  final String _status = " Welcome! Say 'Register' or 'Login ";
  bool _isListening = false;


  @override
  void initState() {
    super.initState();
    //_initSpeech();
    _startVoiceFlow();
// _testNavigation();
  }
   bool restartListening()
  {
    if(_isListening !=true)
  {
   _startVoiceFlow(); 
  }
  return true;
  }
  Future<void> _startVoiceFlow() async {
    await _auth.speak(" Patient or Caregiver");
    final choice = await _auth.listen();
    
    if (choice?.toLowerCase() == 'patient') {
      _isListening=true;
      Navigator.pushReplacementNamed(context, '/patient-select');
    } else if (choice?.toLowerCase() == 'caregiver') {
            _isListening=true;
      Navigator.pushReplacementNamed(context, '/caregiver-login');
    } 
  //  else if (choice?.toLowerCase() != 'caregiver' ||choice?.toLowerCase() == 'patient' && RouteSettings().name == '/user-select' ) {
 
// else if (RouteSettings().name != '/user-select') {
//             _isListening=true;

//       await _auth.stopListening();
//     }
 Future.delayed(Duration(seconds: 1)).then((value) {
    restartListening();
 });
    
  
 
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:      Color(0xffFFF9ED)
,
      body: Container(
        decoration: BoxDecoration(
        //  color: Color(0xffFFF9ED),
          color: Color(0xffFFF9ED)


        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top : 100.0),
            child: Column(
             // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Combined image using Stack
                SizedBox(
                  //width: 300,
                  //height: 180,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.asset(
                      width: 220,
                      height: 220,
                      'assets/images/introimage.png', // Replace with your image path
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 25),
                
                  Text(S.of(context).text3,
                  style: GoogleFonts.poppins(textStyle: TextStyle( fontSize: 30, fontWeight: FontWeight.bold,color: Color.fromARGB(255, 0, 0, 0),),
            ),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      S.of(context).text4,
                      style:GoogleFonts.roboto(textStyle:  TextStyle(fontSize: 28, color: Color.fromARGB(255, 0, 0, 0),fontWeight: FontWeight.bold),
                    ),),
                    SizedBox(width: 10,),
                    Text(
                      S.of(context).text8,
                      
                      style:GoogleFonts.roboto(textStyle:  TextStyle(fontSize: 28, color: Color(0xff2188A5),fontWeight: FontWeight.bold),
                    ),),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  S.of(context).text5,
                  style:GoogleFonts.readexPro(textStyle:  TextStyle(fontSize: 17, color: Color(0xff363D5F),shadows:[Shadow(color: Color(0xff363D5F),blurRadius:5,offset: Offset(0, 1) )]),
                ),),
                SizedBox(height: 80),
Text('${RouteSettings().name}'),
            Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff0D343F),
                      Color(0xff2188A5),

                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: ElevatedButton(
              onPressed: (){
                _isListening=true;  
                  _auth.stopListening();
                Navigator.pushReplacementNamed(context, '/patient-login')
                  ;},    style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(S.of(context).text6,style:GoogleFonts.robotoSlab(textStyle:  TextStyle(fontSize: 22,fontWeight: FontWeight.bold,color: Colors.white),),
                      ),// Text before icon
                      SizedBox(width: 70),
                      Icon(Icons.accessibility_new,color: Colors.white,size: 35,), // Icon
                    ],
                  ),
                ),
            ),
                SizedBox(height: 55),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                       Color(0xff0D343F),
                      Color(0xff2188A5),

                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  child: ElevatedButton(
              onPressed: () { 
                                _isListening=true;  
                  _auth.stopListening();
                 Navigator.pushReplacementNamed(context, '/caregiver-login');
              },
              style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 75, vertical: 15),
                    ),
                    child:  Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(S.of(context).text7,style:GoogleFonts.robotoSlab(textStyle:  TextStyle(fontSize: 22,fontWeight: FontWeight.bold,color: Colors.white),),), // Text before icon
                        SizedBox(width: 50,),
                        Icon(Icons.handshake_outlined,color: Colors.white,size: 30), // Icon
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20,),

          ],
        ),
              
            ),
          ),
        ),
      
    );
  }

}