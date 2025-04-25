import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class CaregiverResetPasswordScreen extends StatelessWidget {
  const CaregiverResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor:Color(0xFFFFF9ED),
      body: Padding(
        padding: const EdgeInsets.only(left: 30.0,top: 50,right: 30),
        child: Column(
        //  mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Back Arrow
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Color(0xff103944)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            // Lock Image
            Image.asset('assets/images/key.png', width: 200, height: 170), // Replace with your lock image asset

            // Title
            SizedBox(
              width: double.infinity,
              height: 100,
              child: Stack(
                children:[ 
                  Positioned(
                  child: Center(
                    child:  ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [Color(0xff1E8E8D), Color(0xff083838)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,

                  ).createShader(bounds);

                },
                blendMode: BlendMode.srcIn,
                child: Text(
'Reset Password',                  style:GoogleFonts.poppins(textStyle:  TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                           ),             ),
                  ),
                ),
                Positioned(right: 20,bottom:75,child: Icon(Icons.key_off_rounded,color: Color(0xff103944),))
                ]),
            ),
            SizedBox(height: 30),

            // Phone Number Input Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: TextField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  focusColor: Colors.black,
              
                  labelText: 'Phone Number',
                  suffixIcon:  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: Icon(Icons.phone,color: Colors.black,size: 27,),
                  ),
                  hintStyle: TextStyle(color: Colors.black),
                  labelStyle: TextStyle(color: Colors.black),
                 // helperStyle: TextStyle(color: Colors.black),
              
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: Color(0xFFE3E3E3),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () =>Navigator.pushNamed(context, '/caregiver-login'),
                    child: Text(
                      'or Back to sign in',
                      style:GoogleFonts.poppins(textStyle:  TextStyle(
                        fontSize: 14,
                        color: Colors.black.withAlpha(220),
                      ),
                    ),
                  ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 25),

            // Send Button
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
              onPressed: () => Navigator.pushNamed(context, '/caregiver-verification'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 11),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Send',style:GoogleFonts.openSans(textStyle:  TextStyle(fontSize: 18,fontWeight: FontWeight.w700,color: Colors.white),),
                      ),// Text before icon
                     SizedBox(width: 18),
                      Icon(Icons.arrow_circle_right_outlined,color: Colors.white,size: 30,), // Icon
                    ],
                  ),
                ),
            ),
            SizedBox(height: 110),

            // Sign Up Link
            Text(
              "Don't have an account?",
              style:GoogleFonts.poppins(textStyle:  TextStyle(
                fontSize: 17,
                color: Colors.black.withAlpha(120),
              ),
            ),),
            SizedBox(height: 30),
             Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff2188A5),
                      Color(0xff169792),

                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: ElevatedButton(
              onPressed: () =>    (),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 11),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Sign-Up',style:GoogleFonts.openSans(textStyle:  TextStyle(fontSize: 18,fontWeight: FontWeight.w700,color: Colors.white),),
                      ),// Text before icon
                     SizedBox(width: 15),
                      Icon(Icons.app_registration_rounded,color: Colors.white,size: 25,), // Icon
                    ],
                  ),
                ),
            ),
          ],
        ),
      ),
    );
  }
}