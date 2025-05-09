// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grade_pro/features/authentication/presentation/pages/call_screen.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:grade_pro/features/authentication/presentation/blocs/auth_bloc/link_users/link_users_cubit.dart';
import 'package:grade_pro/features/authentication/presentation/blocs/auth_bloc/link_users/link_users_state.dart';

class CaregiverScannerScreen extends StatefulWidget {
  const CaregiverScannerScreen({super.key});

  @override
  State<CaregiverScannerScreen> createState() => _CaregiverScannerScreenState();
}

class _CaregiverScannerScreenState extends State<CaregiverScannerScreen> {
  bool initialCheckDone = false;

  @override
  void initState() {
    super.initState();
    checkIfAlreadyLinked();
  }

  void checkIfAlreadyLinked() async {
    final cubit = CaregiverCubit();
    final alreadyLinked = await cubit.checkIfCaregiverLinked();

    if (alreadyLinked != null) {
      // مربوطة بالفعل
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are already linked to a patient!'),
          backgroundColor: Colors.blueAccent,
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CallPage(isPatient: false)),
      );
    } else {
      // غير مربوط → لازم نسكان
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
        appBar: AppBar(title: const Text('Scan Patient QR Code')),
        body: initialCheckDone
            ? BlocConsumer<CaregiverCubit, CaregiverState>(
                listener: (context, state) {
                  if (state is CaregiverLinked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Successfully linked to patient!'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const CallPage(isPatient: false)),
                    );
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
                    errorBuilder: (context, error, child) {
                      return Center(child: Text('Camera Error: $error'));
                    },
                  );
                },
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
