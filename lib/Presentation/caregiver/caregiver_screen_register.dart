import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


// ignore: use_key_in_widget_constructors
class CaregiverScreenRegister extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor:Color(0xffFFF9ED),
      body: Padding(
        padding: const EdgeInsets.only(top: 60.0,right: 30,left: 30),
        child: Column(

           mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Stack(
              
                children: [
                  Positioned(
                 //   height: 200,
                    //width: 120,
                    top: 50,
                left: 30,
                    child: Image.asset('assets/images/Create.png',color: Color(0xff1E8E8D),)), // Replace with your pencil icon asset
                    SizedBox(width: 10),
                    Positioned(
                    bottom: 115,
                    left: 30,
                      child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                        colors: [Color(0xff169792), Color(0xff2188A5)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                                    
                        ).createShader(bounds);
                                    
                      },
                      blendMode: BlendMode.srcIn,
                      child: Text(
                                    'Create',                  style:GoogleFonts.poppins(textStyle:  TextStyle(
                          fontSize: 33,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                                 ),             ),
                    ),
                Positioned(
                  top: 45,
                  left: 120,
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors: [Color(0xff1E8E8D), Color(0xff083838)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                                
                      ).createShader(bounds);
                                
                    },
                    blendMode: BlendMode.srcIn,
                             child:  Text(
                                'An Account',
                                style: TextStyle(
                  fontSize: 28,
                  color: Color(0xFF008577),
                  fontWeight: FontWeight.w500,
                                ),
                              ),),
                ),
            Positioned(
              top: 90,
              left: 120,
              child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors: [Color(0xff1E8E8D), Color(0xff083838)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                
                      ).createShader(bounds);
                
                    },
                    blendMode: BlendMode.srcIn,
                         child:  Text(
                'As Caregiver',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                  fontSize: 28,
                  color: Color(0xFF008577),
                  fontWeight: FontWeight.w500,
                ),
              ),),
            ),),
                ],
                
              ),
            ),
            
         
            SizedBox(height: 20),

            // Name Input Field
            TextField(
              decoration: InputDecoration(
             labelStyle: TextStyle(color: Colors.black),
            focusColor: Colors.black,
                hoverColor: Colors.black,
                labelText: 'Name',
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right:15.0),
                  child: Icon(Icons.person),
                ),
                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,

                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Color(0xFFDAE3E5),
              ),
            ),
            SizedBox(height: 30),

            // Phone Number Input Field
            TextField(
              decoration: InputDecoration(
                                                labelStyle: TextStyle(color: Colors.black),
focusColor: Colors.black,
                hoverColor: Colors.black,
                
                labelText: 'Phone Number',
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right:15.0),
                  child: Icon(Icons.phone_android),
                ),
                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,

                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Color(0xFFDAE3E5),
              ),
            ),
            SizedBox(height: 30),

            // Patient's Phone Input Field
            TextField(
              decoration: InputDecoration(
                                labelStyle: TextStyle(color: Colors.black),
focusColor: Colors.black,
                hoverColor: Colors.black,
                labelText: "Patient's Phone",
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right:15.0),
                  child: Icon(Icons.phone),
                ),
                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,

                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Color(0xFFDAE3E5),
              ),
            ),
            SizedBox(height: 30),

            // Password Input Field
            TextField(
              obscureText: true,
              decoration: InputDecoration(
               alignLabelWithHint: true,
              //  hintText: 'not',
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.black),
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
            SizedBox(height: 50),

            // Register Button
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
              onPressed: () =>(),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 65, vertical: 12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Register',style:GoogleFonts.openSans(textStyle:  TextStyle(fontSize: 22,fontWeight: FontWeight.w600,color: Colors.white),),
                      ),// Text before icon
                      SizedBox(width: 35),
                      Icon(Icons.person_add_rounded,color: Colors.white,size: 35,), // Icon
                    ],
                  ),
                ),
            ),
            SizedBox(height: 30),

            // Login Now Link
            Text(
              "Already Have An Account?",
              style:GoogleFonts.openSans(textStyle:  TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),),
                        SizedBox(height: 10),

            TextButton(
            onPressed: () =>   Navigator.pushNamed(context,'/caregiver-login')
              ,child: Text(
                'Login Now!',
                style:GoogleFonts.poppins(textStyle:  TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),),
            ),
          ],
        ),
      ),
    );
  }
}