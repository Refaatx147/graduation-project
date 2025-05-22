// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grade_pro/features/authentication/presentation/pages/call_screen.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:grade_pro/features/authentication/presentation/blocs/link_users/link_users_cubit.dart';
import 'package:grade_pro/features/authentication/presentation/blocs/link_users/link_users_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grade_pro/features/authentication/presentation/pages/caregiver/caregiver_navigation_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CaregiverScannerScreen extends StatefulWidget {
  final bool isInNavigation;
  
  const CaregiverScannerScreen({
    super.key, 
    this.isInNavigation = false,
  });

  @override
  State<CaregiverScannerScreen> createState() => _CaregiverScannerScreenState();
}

class _CaregiverScannerScreenState extends State<CaregiverScannerScreen> {
  bool initialCheckDone = false;
  String? linkedPatientName;

  @override
  void initState() {
    super.initState();
    if (!widget.isInNavigation) {
    checkIfAlreadyLinked();
    } else {
      checkLinkedPatient();
    }
  }

  Future<void> checkLinkedPatient() async {
    final cubit = CaregiverCubit();
    final linkedPatient = await cubit.checkIfCaregiverLinked();
    
    if (linkedPatient != null) {
      // Get patient name from Firestore
      final patientData = await FirebaseFirestore.instance
          .collection('users')
          .doc(linkedPatient)
          .get();
      
      setState(() {
        linkedPatientName = patientData.data()?['name'] ?? 'Unknown Patient';
        initialCheckDone = true;
      });
    } else {
      setState(() {
        initialCheckDone = true;
      });
    }
  }

  Future<void> checkIfAlreadyLinked() async {
    final cubit = CaregiverCubit();
    final alreadyLinked = await cubit.checkIfCaregiverLinked();

    if (alreadyLinked != null) {
      // Show snackbar with theme styling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You are already linked to a patient!',
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          backgroundColor: const Color(0xff0D343F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      // Navigate to navigation screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CaregiverNavigationScreen(),
        ),
      );
    } else {
      // If not linked, stay on scanner screen
      setState(() {
        initialCheckDone = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CaregiverCubit(),
      child: Scaffold(
        appBar: widget.isInNavigation ? null : AppBar(
          backgroundColor: Color(0xff0D343F),
          title: Text(
            'Scan Patient QR Code',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        body: initialCheckDone
            ? (widget.isInNavigation && linkedPatientName != null
                ? Center(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Color(0xff0D343F),
                            size: 60,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Already Linked',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff0D343F),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'You are linked to:',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            linkedPatientName!,
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff0D343F),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : BlocConsumer<CaregiverCubit, CaregiverState>(
                listener: (context, state) {
                  if (state is CaregiverLinked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Successfully linked to patient!'),
                        backgroundColor: Colors.green,
                      ),
                    );

                        if (widget.isInNavigation) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                              builder: (context) => CaregiverNavigationScreen(),
                            ),
                    );
                        }
                  } else if (state is CaregiverError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is CaregiverLinking) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return MobileScanner(
                    controller: MobileScannerController(
                      detectionSpeed: DetectionSpeed.normal,
                      facing: CameraFacing.back,
                    ),
                    onDetect: (capture) {
                      final String? code = capture.barcodes.first.rawValue;
                      if (code != null &&
                          context.read<CaregiverCubit>().state
                              is! CaregiverLinking) {
                        context
                            .read<CaregiverCubit>()
                            .linkCaregiverToPatient(code);
                      }
                    },
                    errorBuilder: (context, error) {
                      return Center(child: Text('Camera Error: $error'));
                    },
                  );
                },
                  ))
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
