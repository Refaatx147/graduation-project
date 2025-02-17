import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CaregiverScreenLogin extends StatelessWidget {
  const CaregiverScreenLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
          backgroundColor: Color(0xffFFF9ED)
      ,body: Padding(
        padding: const EdgeInsets.all(35.0),
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: [
                          Image.asset(color: Color(0xff2188A5),'assets/images/Access.png' ,width: 60, height: 55), // Replace with your key icon asset
              // SizedBox(height: 1),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 SizedBox(height: 5),

              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [Color(0xff169792), Color(0xff2188A5)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,

                  ).createShader(bounds);

                },
                blendMode: BlendMode.srcIn,
                child: Text(
'Login to',                  style:GoogleFonts.poppins(textStyle:  TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                           ),             ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Monitor Your Person’s State',
              style:GoogleFonts.poppins(textStyle:  TextStyle(
                fontSize: 19,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),),
            SizedBox(height: 80),

            // Phone Number Input Field
            TextField(
              decoration: InputDecoration(
                focusColor: Colors.black,

                labelText: 'Phone Number',
                suffixIcon:  Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: Icon(Icons.phone,color: Colors.black,size: 27,),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Color(0xFFDAE3E5),
              ),
            ),
            SizedBox(height: 50),

            // Password Input Field
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: Icon(Icons.visibility_off,color: Colors.black,size: 27,),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(30),
                
                ),
                filled: true,
                fillColor: Color(0xFFDAE3E5),
              ),
            ),
            SizedBox(height: 60),

            // Login Button
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
              onPressed: () =>    (),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 85, vertical: 12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Login',style:GoogleFonts.openSans(textStyle:  TextStyle(fontSize: 22,fontWeight: FontWeight.w700,color: Colors.white),),
                      ),// Text before icon
                      SizedBox(width: 35),
                      Icon(Icons.login_outlined,color: Colors.white,size: 35,), // Icon
                    ],
                  ),
                ),
            ),
            SizedBox(height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: TextButton(
                    onPressed: () =>    Navigator.pushNamed(context,'/reset-pass'),

                    child: Text(
                      'Forget Password',
                      style:GoogleFonts.poppins(textStyle:  TextStyle(
                        fontSize: 15,
                        color: Colors.black.withAlpha(150),
                      
                      ),
                    ),)
                  ),
                ),
              ],
            ),
            SizedBox(height: 70),

            // Register Now Link
            Text(
              "Doesn't have an account?",
              style:GoogleFonts.openSans(textStyle:  TextStyle(
                fontSize: 19,
                color: Colors.black.withAlpha(100),
              ),
            ),),
            SizedBox(height: 20),

            // Register Now Link
            InkWell(
              onTap: () => Navigator.pushNamed(context,'/caregiver-register'),
              child: Text(
                "Register Now!",
                style:GoogleFonts.poppins(textStyle:  TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w800
                ),
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}