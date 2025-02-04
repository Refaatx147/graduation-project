import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.greenAccent.withAlpha(230), Colors.white],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top : 100.0),
            child: Column(
             // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Combined image using Stack
                SizedBox(
                  width: 300,
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Image.asset(
                              'assets/images/rectangle.png', // Replace with your image path
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Image.asset(
                              'assets/images/footer.png', // Replace with your image path
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 50),
                Text(
                  'Welcome!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,fontFamily: 'Poppins'),
                ),
                Text(
                  'to ThinkStep',
                  style: TextStyle(fontSize: 24, color: Colors.orange,fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  'Choose Your User Type To Get Started',
                  style: TextStyle(fontSize: 18, color: Colors.black,shadows:[Shadow(color: Colors.black.withAlpha(100),blurRadius:5,offset: Offset(0, 1) )]),
                ),
                SizedBox(height: 80),
                ElevatedButton(
                  onPressed: () {
                    // Handle patient button press
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.black, // Text and icon color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal:70 , vertical: 18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Patient',style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold,color: Colors.orangeAccent.withGreen(190)),),
                      // Text before icon
                      SizedBox(width: 80),
                      Icon(Icons.accessibility_new,color: Colors.white,size: 35,), // Icon
                    ],
                  ),
                ),
                SizedBox(height: 60),
                ElevatedButton(
                  onPressed: () {
                    // Handle caregiver button press
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.black, // Text and icon color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 70, vertical: 18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Caregiver',style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold,color: Colors.orangeAccent.withGreen(190)),), // Text before icon
SizedBox(width: 65,),
                      Icon(Icons.handshake_outlined,color: Colors.white,size: 30), // Icon
                    ],
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