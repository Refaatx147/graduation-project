// // ignore_for_file: unused_field, avoid_print

// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:grade_pro/generated/l10n.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;

// class UserPage extends StatefulWidget {
//     final Function(Locale) changeLanguage;

//   const UserPage({super.key, required this.changeLanguage});

//   @override
//   State<UserPage> createState() => _UserPageState();
// }

// class _UserPageState extends State<UserPage> {
//   final FlutterTts flutterTts = FlutterTts();
//   final stt.SpeechToText _speech = stt.SpeechToText();
//   bool _isListening = false;
//   String _text = 'Welcome!';
//     BuildContext? _navigatorContext;


//   @override
//   void initState() {
//     super.initState();
//     _initSpeech();
// // _testNavigation();
//   }

 

//   @override
//   Widget build(BuildContext context) {
//     _navigatorContext=context;
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//         //  color: Color(0xffFFF9ED),
//           color: Color(0xffFFF9ED)


//         ),
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.only(top : 100.0),
//             child: Column(
//              // mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Combined image using Stack
//                 SizedBox(
//                   //width: 300,
//                   //height: 180,
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(16.0),
//                     child: Image.asset(
//                       width: 220,
//                       height: 220,
//                       'assets/images/introimage.png', // Replace with your image path
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 25),
                
//                   Text(S.of(context).text3,
//                   style: GoogleFonts.poppins(textStyle: const TextStyle( fontSize: 30, fontWeight: FontWeight.bold,color: Color.fromARGB(255, 0, 0, 0),),
//             ),),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       S.of(context).text4,
//                       style:GoogleFonts.roboto(textStyle:  const TextStyle(fontSize: 28, color: Color.fromARGB(255, 0, 0, 0),fontWeight: FontWeight.bold),
//                     ),),
//                     const SizedBox(width: 10,),
//                     Text(
//                       S.of(context).text8,
                      
//                       style:GoogleFonts.roboto(textStyle:  const TextStyle(fontSize: 28, color: Color(0xff2188A5),fontWeight: FontWeight.bold),
//                     ),),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   S.of(context).text5,
//                   style:GoogleFonts.readexPro(textStyle:  const TextStyle(fontSize: 17, color: Color(0xff363D5F),shadows:[Shadow(color: Color(0xff363D5F),blurRadius:5,offset: Offset(0, 1) )]),
//                 ),),
//                 const SizedBox(height: 80),

//             Container(
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [
//                       Color(0xff0D343F),
//                       Color(0xff2188A5),

//                     ],
//                     begin: Alignment.centerLeft,
//                     end: Alignment.centerRight,
//                   ),
//                   borderRadius: BorderRadius.circular(50.0),
//                 ),
//                 child: ElevatedButton(
//               onPressed: () =>    Navigator.pushNamed(_navigatorContext!, '/patient-login'),
//                   style: ElevatedButton.styleFrom(
//                     foregroundColor: Colors.white, backgroundColor: Colors.transparent,
//                     shadowColor: Colors.transparent,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(50.0),
//                     ),
//                     padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(S.of(context).text6,style:GoogleFonts.robotoSlab(textStyle:  const TextStyle(fontSize: 22,fontWeight: FontWeight.bold,color: Colors.white),),
//                       ),// Text before icon
//                       const SizedBox(width: 70),
//                       const Icon(Icons.accessibility_new,color: Colors.white,size: 35,), // Icon
//                     ],
//                   ),
//                 ),
//             ),
//                 const SizedBox(height: 55),
//                 Container(
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [
//                        Color(0xff0D343F),
//                       Color(0xff2188A5),

//                       ],
//                       begin: Alignment.centerLeft,
//                       end: Alignment.centerRight,
//                     ),
//                     borderRadius: BorderRadius.circular(50.0),
//                   ),
//                   child: ElevatedButton(
//               onPressed: () =>    Navigator.pushNamed(_navigatorContext!, '/caregiver-login'),
//                     style: ElevatedButton.styleFrom(
//                       foregroundColor: Colors.white, backgroundColor: Colors.transparent,
//                       shadowColor: Colors.transparent,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(50.0),
//                       ),
//                       padding: const EdgeInsets.symmetric(horizontal: 75, vertical: 15),
//                     ),
//                     child:  Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(S.of(context).text7,style:GoogleFonts.robotoSlab(textStyle:  const TextStyle(fontSize: 22,fontWeight: FontWeight.bold,color: Colors.white),),), // Text before icon
//                         const SizedBox(width: 50,),
//                         const Icon(Icons.handshake_outlined,color: Colors.white,size: 30), // Icon
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20,),

//           ],
//         ),
              
//             ),
//           ),
//         ),
      
//     );
//   }

// void _initSpeech() async {
//   print('Initializing speech recognition...'); // Debug log

//   // Request microphone permission
//   var status = await Permission.microphone.request();
//   if (status.isGranted) {
//     bool available = await _speech.initialize(
//       onStatus: (val) => print('Speech Status: $val'), // Log status updates
//       onError: (val) => print('Speech Error: $val'),   // Log errors
//     );

//     if (available) {
//       print('Speech recognition initialized successfully.'); // Debug log
//       await flutterTts.setLanguage("en-US");
//       await flutterTts.speak("Patient or Caregiver.");
//       _listen();
//     } else {
//       print('Speech recognition initialization failed.'); // Debug log
//     }
//   } else {
//     print('Microphone permission denied.'); // Debug log
//     await flutterTts.speak("Microphone permission is required to proceed.");
//   }
// }

//   void _listen() async {
//   if (!_isListening) {
//     bool available = await _speech.initialize(
//       onStatus: (val) => print('onStatus: $val'),
//       onError: (val) => print('onError: $val'),
//     );
//     if (available) {
//       setState(() => _isListening = true);
//       _speech.listen(
//         pauseFor: const Duration(seconds: 5),
//         listenFor: const Duration(seconds: 4),
//         onResult: (val) => setState(() {
//           _text = val.recognizedWords;
//           _processVoiceInput(val.recognizedWords); // Process the recognized input
//         }),
//       );
//     }
//   } else {
//     setState(() => _isListening = false);
//     _speech.stop();
//   }
// }

// void _processVoiceInput(String input) async {
//   print('Recognized Input: $input'); // Debug log

// if ((!input.toLowerCase().contains('patient')|| (!input.toLowerCase().contains('patient'))))
// {

// }
//   if (input.toLowerCase().contains('patient')) {
//     print('Navigating to Patient Page'); // Debug log
//     await Future.delayed(const Duration(milliseconds: 500)); // Add a short delay
//     Navigator.pushNamed(_navigatorContext!, '/patient-login');
//   } else if (input.toLowerCase().contains('caregiver')) {
//     print('Navigating to Caregiver Page'); // Debug log
//     await Future.delayed(const Duration(milliseconds: 500)); // Add a short delay
//     Navigator.pushNamed(_navigatorContext!, '/caregiver-login');
//   } 
// }
// }
