// ignore_for_file: avoid_print, unused_element

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CaregiverVerificationScreen extends StatefulWidget {
  const CaregiverVerificationScreen({super.key});

  @override
  State<CaregiverVerificationScreen> createState() => _CaregiverVerificationScreenState();
}

class _CaregiverVerificationScreenState extends State<CaregiverVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xffFFF9ED),
      body: SafeArea(
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
                               SizedBox(width: screenWidth*0.09,),
                 
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
'Verification',                  style:GoogleFonts.poppins(textStyle:  TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                           ),             ),
                           ],
               ),
               SizedBox(height: screenHeight*0.04,),
            // Lock Image
            Image.asset('assets/images/uil_comment-verify.png', width: 200, height: 170), // Replace with your lock image asset
             
                            SizedBox(height: screenHeight*0.03,),
 // Title
              Text(
                'Enter Verification Code',
                style:GoogleFonts.openSans(textStyle:  TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3748),
                  letterSpacing: 0.5,
                ),
              ),),
              SizedBox(height: screenHeight * 0.05),

              // Code Input Fields
              Padding(
                padding:  EdgeInsets.symmetric(horizontal:screenWidth*0.08),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (index) => _buildCodeField(index)),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),

              // Resend Text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                                           Text( 'If You didn\'t receive a code? ',style:GoogleFonts.poppins(textStyle:  TextStyle(fontSize: 16,color: Colors.black.withAlpha(100))),),

                  InkWell(
                    onTap: () {
                      
                    },
                    child: Text(
                         'Resend',
                        style:GoogleFonts.poppins(textStyle:  TextStyle(
                          color: const Color(0xFF0D343F),
                          fontWeight: FontWeight.w600,
                          fontSize: 16
                        ),),
                      ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.12),

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
              onPressed: ()=>Navigator.pushNamed(context,'/caregiver-new-password'),
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
                      Text('Verify',style:GoogleFonts.openSans(textStyle:  TextStyle(fontSize: 22,fontWeight: FontWeight.w600,color: Colors.white),),
                      ),// Text before icon
                     SizedBox(width: 18),
                      Icon(Icons.verified,color: Colors.white,size: 30,), // Icon
                    ],
                  ),
                ),
            ),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeField(int index) {
    return SizedBox(
      width: 60.0,
      height: 60.0,
      child: TextField(
        
        showCursor: true,
        cursorHeight: 25,
        cursorColor: Colors.black,
      //  scrollPadding: EdgeInsets.only(bottom: 5),
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D3748)),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: const Color(0xFFDAE3E5),
          
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 204, 207, 209),
              width: 2.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(
              color: Color(0xFF2188A5),
              width: 2.0,
              
            ),
          ),
        ),
        onChanged: (value) {
          if (value.length == 1 && index < 3) {
            _focusNodes[index + 1].requestFocus();
          }
        },
      ),
    );
  }

  void _verifyCode() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length == 4) {
      // Handle verification logic
      print('Verification code: $code');
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}