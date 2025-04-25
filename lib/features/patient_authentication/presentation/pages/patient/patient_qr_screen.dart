// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grade_pro/features/patient_authentication/presentation/blocs/auth_bloc/link_users/link_users_cubit.dart';
import 'package:grade_pro/features/patient_authentication/presentation/blocs/auth_bloc/link_users/link_users_state.dart';
import 'package:grade_pro/features/patient_authentication/presentation/pages/call_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientQrScreen extends StatelessWidget {
  const PatientQrScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PatientCubit()..loadShareToken(),
      child: Scaffold(
       // backgroundColor: const Color(0xffFFF9ED),
        resizeToAvoidBottomInset: false,
        appBar:  AppBar(
        
        centerTitle: true,
        title: Text('Patient QR Code',
                  style: GoogleFonts.poppins(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                                                  color:  Color.fromARGB(255, 24, 64, 75),

                  ),
                ),
       // backgroundColor: Color.fromARGB(255, 24, 64, 75),
      ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                BlocBuilder<PatientCubit, PatientState>(
                  builder: (context, state) {
                    if (state is PatientLoaded) {
                      final sharedToken = state.shareToken;
                      return QrImageView(
                       data: sharedToken,
                                  version: QrVersions.auto,
                                  size: 200.0,
                                  foregroundColor: const Color.fromARGB(255, 2, 52, 92),
                      );
                    }
                     else if (state is PatientError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text('Error: ${state.message}',textAlign: TextAlign.center,style:  TextStyle(
                        
                                      color: const Color.fromARGB(255, 16, 35, 51), fontSize: 14)),
                      );
                    } else if(state is PatientLoading) {
                      return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(child: CircularProgressIndicator()),
                        ],
                      );
                    } 
                 return Text('No QR code available',style:   TextStyle(
              color: const Color.fromARGB(255, 16, 35, 51), fontSize: 18),);
                  },
                ),
              SizedBox(height: 60),
              Text('Share this QR code with caregiver',
                  style: TextStyle(
                      color: const Color.fromARGB(255, 4, 59, 104),
                      fontSize: 18)),
              SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CallPage(isPatient: true,)));
                  },
                  child: Text('Call page'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
