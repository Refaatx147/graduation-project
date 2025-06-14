// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:grade_pro/features/blocs/link_users/link_users_cubit.dart';
import 'package:grade_pro/features/blocs/link_users/link_users_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grade_pro/features/pages/caregiver/caregiver_navigation_screen.dart';
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
  bool isScanning = false;
  late MobileScannerController _controller;
  bool _isDisposed = false;
  bool _justLinked = false; // Track if just linked via scan

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
    checkIfAlreadyLinked();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }

  Future<void> checkIfAlreadyLinked() async {
    if (_isDisposed) return;
    final cubit = CaregiverCubit();
    final alreadyLinked = await cubit.checkIfCaregiverLinked();
    if (_isDisposed) return;
    if (alreadyLinked != null) {
      // Show the 'Already Linked' box, do not navigate away or show snackbar
      try {
        final patientData = await FirebaseFirestore.instance
            .collection('users')
            .doc(alreadyLinked)
            .get();
        if (!_isDisposed) {
          setState(() {
            linkedPatientName = patientData.data()?['name'] ?? 'Unknown Patient';
            initialCheckDone = true;
          });
        }
      } catch (e) {
        if (!_isDisposed) {
          setState(() {
            linkedPatientName = 'Unknown Patient';
            initialCheckDone = true;
          });
        }
      }
    } else {
      if (!_isDisposed) {
        setState(() {
          initialCheckDone = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CaregiverCubit(),
      child: Scaffold(
        appBar: null,
        body: initialCheckDone
            ? (linkedPatientName != null
                ? _buildLinkedPatientView()
                : _buildScannerView())
            : const Center(
                child: CircularProgressIndicator(
                  color: Color(0xff0D343F),
                ),
              ),
      ),
    );
  }

  Widget _buildLinkedPatientView() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xff0D343F).withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xff0D343F),
                size: 60,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Already Linked',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
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
              linkedPatientName ?? 'Unknown Patient',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff0D343F),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CaregiverNavigationScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.visibility, color: Color.fromARGB(255, 45, 248, 173)),
              label: Text(
                'Go to Dashboard',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0D343F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerView() {
    return BlocConsumer<CaregiverCubit, CaregiverState>(
      listener: (context, state) async {
        if (state is CaregiverLinked && !_justLinked) {
          _justLinked = true;
          _controller.stop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully linked to patient!'),
              backgroundColor: Colors.green,
            ),
          );
          // After linking, redirect to navigation screen
          await Future.delayed(const Duration(milliseconds: 500));
          if (!_isDisposed) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const CaregiverNavigationScreen(),
              ),
            );
          }
        } else if (state is CaregiverError) {
          if (!_isDisposed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        if (state is CaregiverLinking) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xff0D343F),
            ),
          );
        }

        return Stack(
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                if (_isDisposed) return;
                final String? code = capture.barcodes.first.rawValue;
                if (code != null &&
                    context.read<CaregiverCubit>().state is! CaregiverLinking) {
                  context.read<CaregiverCubit>().linkCaregiverToPatient(code);
                }
              },
              errorBuilder: (context, error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Color(0xff0D343F),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Camera Error: $error',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            color: Color(0xff0D343F),
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (!_isDisposed) {
                            setState(() {
                              _controller.stop();
                              _controller.start();
                            });
                          }
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff0D343F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Scanner overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xff0D343F),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      margin: const EdgeInsets.only(bottom: 40),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(230),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Scan Patient QR Code',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff0D343F),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Position the QR code within the frame',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
