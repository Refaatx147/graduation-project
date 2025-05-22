import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grade_pro/core/utils/user_auth_service.dart';
import 'package:grade_pro/core/utils/voice_patient_helper.dart';
import 'package:grade_pro/features/authentication/presentation/pages/call_screen.dart';
import 'package:grade_pro/features/authentication/presentation/pages/patient/map_patient_screen.dart';
import 'package:grade_pro/features/authentication/presentation/pages/patient/patient_qr_screen.dart';
import 'package:grade_pro/features/authentication/presentation/pages/patient/patient_home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grade_pro/features/authentication/presentation/blocs/navigation_cubit/navigation_cubit.dart';
import 'package:grade_pro/features/authentication/presentation/widgets/patient_navigation_bar.dart';

class PatientNavigationScreen extends StatefulWidget {
  final UserAuthService authService;

  const PatientNavigationScreen({
    super.key,
    required this.authService,
  });

  @override
  State<PatientNavigationScreen> createState() => _PatientNavigationScreenState();
}

class _PatientNavigationScreenState extends State<PatientNavigationScreen> {
  final VoiceHelper _voiceHelper = VoiceHelper();
  OverlayEntry? _overlayEntry;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _startContinuousListening();
  }

  void _startContinuousListening() async {
    if (!_isListening) {
      setState(() => _isListening = true);
      _listenForCommands();
    }
  }

  void _listenForCommands() async {
    while (_isListening) {
      final command = await _voiceHelper.listen();
      if (command != null && command.isNotEmpty) {
        _processVoiceCommand(command);
      }
    }
  }

  void _showNavigationFeedback(String message, bool isError) {
    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 70,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isError ? Colors.red.shade100 : Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isError ? Colors.red.shade300 : Colors.green.shade300,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isError ? Icons.error_outline : Icons.check_circle_outline,
                  color: isError ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isError ? Colors.red.shade900 : Colors.green.shade900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    Future.delayed(const Duration(seconds: 2), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  void _processVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    int? targetIndex;
    String? screenName;

    if (lowerCommand.contains('home') || lowerCommand.contains('main')) {
      targetIndex = 0;
      screenName = 'Home';
    } else if (lowerCommand.contains('qr') || lowerCommand.contains('scan') || lowerCommand.contains('code')) {
      targetIndex = 1;
      screenName = 'QR Code';
    } else if (lowerCommand.contains('map') || lowerCommand.contains('location') || lowerCommand.contains('where')) {
      targetIndex = 2;
      screenName = 'Map';
    } else if (lowerCommand.contains('call') || lowerCommand.contains('phone') || lowerCommand.contains('contact')) {
      targetIndex = 3;
      screenName = 'Call';
    } else if (lowerCommand.contains('logout') || lowerCommand.contains('sign out')) {
      _handleLogout();
      return;
    }

    if (targetIndex != null && screenName != null) {
      final currentIndex = context.read<NavigationCubit>().state.currentIndex;
      if (currentIndex != targetIndex) {
        context.read<NavigationCubit>().navigateToIndex(targetIndex);
        _showNavigationFeedback('Navigating to $screenName', false);
      }
    } else {
      _showNavigationFeedback('Command not recognized. Please try again.', true);
    }
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/user-select',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showNavigationFeedback('Error loggin Please try again.', true);
      }
    }
  }

  @override
  void dispose() {
    _isListening = false;
    _voiceHelper.stopListening();
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(
            index: state.currentIndex,
            children: [
              HomePatient(authService: widget.authService),
              const PatientQrScreen(),
              MapPatientScreen(patientId: FirebaseAuth.instance.currentUser?.uid ?? ''),
              const CallPage(isPatient: true),
            ],
          ),
          bottomNavigationBar: PatientNavigationBar(
            currentIndex: state.currentIndex,
            onTap: (index) {
              final currentIndex = state.currentIndex;
              if (currentIndex != index) {
                context.read<NavigationCubit>().navigateToIndex(index);
                final screenNames = ['Home', 'QR Code', 'Map', 'Call'];
                _showNavigationFeedback('Navigating to ${screenNames[index]}', false);
              }
            },
          ),
        );
      },
    );
  }
}
