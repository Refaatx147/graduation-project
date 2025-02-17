// ignore_for_file: avoid_print, unused_element

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CaregiverNewPassword extends StatefulWidget {
  const CaregiverNewPassword({super.key});

  @override
  State<CaregiverNewPassword> createState() => _CaregiverNewPasswordState();
}

class _CaregiverNewPasswordState extends State<CaregiverNewPassword> {
  

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xffFFF9ED),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03,vertical: screenHeight*0.03),
            child: Column(
             // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight*0.045,),
                 Row(
                   children: [
                     Align(
                                   alignment: Alignment.topLeft,
                                   child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Color(0xff103944)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                                   ),
                                 ),
                                 SizedBox(width: screenWidth*0.05,),
                   
               ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [Color(0xff1E8E8D), Color(0xff083838)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
              
                    ).createShader(bounds);
              
                  },
                  blendMode: BlendMode.srcIn,
                  child: Text(
              'New Password',                  style:GoogleFonts.poppins(textStyle:  TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                             ),             ),
                             ],
                 ),
                 SizedBox(height: screenHeight*0.04,),
              // Lock Image
              Image.asset('assets/images/lock.png', width: 200, height: 190), // Replace with your lock image asset
               
                              SizedBox(height: screenHeight*0.03,),
               // Title
                 Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                    Padding(
                      padding: const EdgeInsets.only(left:45.0),
                      child: Text('Enter New Password',style: GoogleFonts.openSans(textStyle:TextStyle(fontSize: 13,fontWeight: FontWeight.bold)),),
                    ),
                    SizedBox(height: 10,),
                     Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 30.0),
                       child: TextField(
                                     obscureText: true,
                                     decoration: InputDecoration(
                       alignLabelWithHint: true,
                                     //  hintText: 'not',
                       // labelText: '********',
              hintText: '**********',
              hintStyle: TextStyle(color: Colors.black.withAlpha(150),letterSpacing: 10,fontSize: 15),
                        labelStyle: TextStyle(color: Colors.black,letterSpacing:10,fontSize: 20 ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right:15.0),
                          child: Icon(Icons.visibility_off),
                        ),
                        focusColor: Colors.black,
                        hoverColor: Colors.black,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        filled: true,
                        fillColor: Color(0xFFDAE3E5),
                                     ),
                                   ),
                     ),
              
                                                      SizedBox(height: screenHeight*0.03,),
              
                     
                      Padding(
                      padding: const EdgeInsets.only(left:45.0),
                      child: Text('Confirm Your Password',style: GoogleFonts.openSans(textStyle:TextStyle(fontSize: 13,fontWeight: FontWeight.bold)),),
                    ),
                    SizedBox(height: 10,),
                     Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 30.0),
                       child: TextField(
                                     obscureText: true,
                                     decoration: InputDecoration(
                       alignLabelWithHint: true,
                                     //  hintText: 'not',
                       // labelText: '********',
              hintText: '**********',
              hintStyle: TextStyle(color: Colors.black.withAlpha(150),letterSpacing: 10,fontSize: 15),
                        labelStyle: TextStyle(color: Colors.black,letterSpacing:10,fontSize: 20 ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right:15.0),
                          child: Icon(Icons.visibility_off),
                        ),
                        focusColor: Colors.black,
                        hoverColor: Colors.black,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        filled: true,
                        fillColor: Color(0xFFDAE3E5),
                                     ),
                                   ),
                     ),
                   ],
                 ),
          
            SizedBox(height: screenHeight*0.09,),
              
              
              
                // Verify Button
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
                onPressed: (){},
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Submit',style:GoogleFonts.openSans(textStyle:  TextStyle(fontSize: 22,fontWeight: FontWeight.w600,color: Colors.white),),
                        ),// Text before icon
                       SizedBox(width: 18),
                        Icon(Icons.mark_chat_read_sharp,color: Colors.white,size: 28,), // Icon
                      ],
                    ),
                  ),
              ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}

  