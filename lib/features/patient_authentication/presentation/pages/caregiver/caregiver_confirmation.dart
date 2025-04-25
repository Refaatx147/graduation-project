// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class CaregiverConfirmationScreen extends StatefulWidget {
//   final String email;
//   const CaregiverConfirmationScreen({super.key, required this.email});

//   @override
//   State<CaregiverConfirmationScreen> createState() => _CaregiverConfirmationScreenState();
// }

// class _CaregiverConfirmationScreenState extends State<CaregiverConfirmationScreen> {
//   bool _isResending = false;
//   bool _isVerifying = false;

//   @override
//   void initState() {
//     super.initState();
//     _setupAuthListener();
//   }

//   Future<void> _resendVerification() async {
//     setState(() => _isResending = true);
//     try {
//       await _supabase.auth.resend(
//         type: OtpType.signup, // Changed from email to signup
//         email: widget.email,
//         emailRedirectTo: 'gradepro://auth-callback' // Ensure scheme matches
//       );
      
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('New verification email sent!')),
//         );
//       }
//     } catch (error) {
//       if (mounted) {
//         String message = 'Resend failed: ';
//         if (error is AuthException) {
//           message += error.message.contains('ratelimited') 
//               ? 'Too many attempts. Try again later.' 
//               : 'Failed to send email.';
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(message)),
//         );
//       }
//     }
//     setState(() => _isResending = false);
//   }

//   Future<void> _checkVerification() async {
//     setState(() => _isVerifying = true);
//     try {
//       // Refresh session to get latest confirmation status
//       final session = await _supabase.auth.refreshSession();
      
//       if (session.user?.emailConfirmedAt == null) {
//         throw Exception('Email not verified yet. Check your inbox.');
//       }
      
//       if (mounted) {
//         await _handleSuccessfulVerification(session.user!);
//       }
//     } catch (error) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Verification failed: ${_parseError(error)}')),
//         );
//       }
//     }
//     setState(() => _isVerifying = false);
//   }

//   Future<void> _handleSuccessfulVerification(User user) async {
//     try {
//       final existingProfile = await _supabase
//           .from('caregivers')
//           .select()
//           .eq('user_id', user.id)
//           .maybeSingle();

//       if (existingProfile == null) {
//         await _supabase.from('caregivers').insert({
//           'user_id': user.id,
//           'email': user.email,
//         });
//       }
      
//       if (mounted) {
//         Navigator.pushReplacementNamed(context, '/caregiver-login');
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Profile setup failed: ${_parseError(e)}')),
//         );
//       }
//     }
//   }

//   void _setupAuthListener() {
//     _supabase.auth.onAuthStateChange.listen((AuthState data) async {
//       try {
//         final user = data.session?.user;
//         if (user != null && user.emailConfirmedAt != null && mounted) {
//           await _handleSuccessfulVerification(user);
//         }
//       } catch (error) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Auto-verification failed: ${_parseError(error)}')),
//           );
//         }
//       }
//     });
//   }

//   String _parseError(dynamic error) {
//     if (error is AuthException) {
//       return error.message;
//     }
//     if (error is PostgrestException) {
//       return 'Database error occurred';
//     }
//     return error.toString().replaceAll('Exception:', '');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       backgroundColor: const Color(0xffFFF9ED),
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(
//               horizontal: screenWidth * 0.03, vertical: screenHeight * 0.03),
//           child: Column(
//             children: [
//               // ... (keep your existing UI elements unchanged) ...
              
// SizedBox(height: screenHeight * 0.045),
//               Row(
//                 children: [
//                   Align(
//                     alignment: Alignment.topLeft,
//                     child: IconButton(
//                       icon: const Icon(Icons.arrow_back, color: Color(0xff103944)),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ),
//                   SizedBox(width: screenWidth * 0.09),
//                   ShaderMask(
//                     shaderCallback: (Rect bounds) {
//                       return const LinearGradient(
//                         colors: [Color(0xff1E8E8D), Color(0xff083838)],
//                         begin: Alignment.centerLeft,
//                         end: Alignment.centerRight,
//                       ).createShader(bounds);
//                     },
//                     blendMode: BlendMode.srcIn,
//                     child: Text(
//                       'Verification',
//                       style: GoogleFonts.poppins(
//                         textStyle: const TextStyle(
//                           fontSize: 30,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: screenHeight * 0.04),
//               Image.asset(
//                 'assets/images/uil_comment-verify.png',
//                 width: 200,
//                 height: 170,
//               ),
//               SizedBox(height: screenHeight * 0.03),
//               Text(
//                 'Check Your Email',
//                 style: GoogleFonts.openSans(
//                   textStyle: const TextStyle(
//                     fontSize: 20.0,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF2D3748),
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
//                 child: Text(
//                   'We sent a verification link to\n${widget.email}',
//                   textAlign: TextAlign.center,
//                   style: GoogleFonts.poppins(
//                     textStyle: TextStyle(
//                       fontSize: 16,
//                       color: Colors.black.withAlpha(150),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: screenHeight * 0.05),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'If You didn\'t receive a code? ',
//                     style: GoogleFonts.poppins(
//                       textStyle: TextStyle(
//                           fontSize: 16, color: Colors.black.withAlpha(100)),
//                     ),
//                   ),
//                   InkWell(
//                     onTap: _isResending ? null : _resendVerification,
//                     child: Text(
//                       'Resend',
//                       style: GoogleFonts.poppins(
//                         textStyle: const TextStyle(
//                           color: Color(0xFF0D343F),
//                           fontWeight: FontWeight.w600,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: screenHeight * 0.12),
//               Container(
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xff0D343F), Color(0xff2188A5)],
//                     begin: Alignment.centerLeft,
//                     end: Alignment.centerRight,
//                   ),
//                   borderRadius: BorderRadius.circular(50.0),
//                 ),
//                 child: ElevatedButton(
//                   onPressed: _isVerifying ? null : _checkVerification, // Fixed condition
//                   style: ElevatedButton.styleFrom(
//                     foregroundColor: Colors.white,
//                     backgroundColor: Colors.transparent,
//                     shadowColor: Colors.transparent,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(50.0),
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 80, vertical: 15),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       if (_isVerifying)
//                         const CircularProgressIndicator()
//                       else
//                         Text(
//                           'Verify',
//                           style: GoogleFonts.openSans(
//                             textStyle: const TextStyle(
//                               fontSize: 22,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.white),
//                             ),
//                           ),
//                       const SizedBox(width: 18),
//                       const Icon(Icons.verified, color: Colors.white, size: 30),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

