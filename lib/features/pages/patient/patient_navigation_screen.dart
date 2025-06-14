// ignore_for_file: unused_field, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grade_pro/core/services/push_notifications.dart';
import 'package:grade_pro/core/utils/user_auth_service.dart';
import 'package:grade_pro/core/utils/voice_patient_helper.dart';
import 'package:grade_pro/features/pages/patient/command_control.dart';
import 'package:grade_pro/features/pages/patient/map_patient_screen.dart';
import 'package:grade_pro/features/pages/patient/call_feature/patient_call_screen.dart';
import 'package:grade_pro/features/pages/patient/patient_appointments_screen.dart';
import 'package:grade_pro/features/pages/patient/patient_medications_screen.dart';
import 'package:grade_pro/features/pages/patient/patient_qr_screen.dart';
import 'package:grade_pro/features/pages/patient/patient_home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grade_pro/features/blocs/navigation_cubit/navigation_cubit.dart';
import 'package:grade_pro/features/widgets/patient_navigation_bar.dart';
import 'package:grade_pro/features/headset_connection/connected_headset.dart';
import 'package:grade_pro/features/headset_connection/connected_headset.dart' as headset;
import 'package:grade_pro/features/chat/presentation/pages/patient_chat_screen.dart';

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
    late NavigationCubit _navigationCubit;

  final VoiceHelper _voiceHelper = VoiceHelper();
  final RobotFunctions _robotFunctions = RobotFunctions();
  OverlayEntry? _overlayEntry;
  bool _isListening = false;
  String _activeDirection = '';
  final String _lastWords = '';

  int _selectedTab = 0;
  final GlobalKey<headset.ConnectedHeadsetState> _headsetKey = GlobalKey<headset.ConnectedHeadsetState>();
  PatientChatScreen? _chatScreen;
  bool _isInChatScreen = false;
  final GlobalKey<PatientChatScreenState> _chatKey = GlobalKey<PatientChatScreenState>();

 void _updateDeviceTab(int newTab) {
    setState(() {
      _selectedTab = newTab;
    });
  }
  @override
  void initState() {
    super.initState();
    _navigationCubit = BlocProvider.of<NavigationCubit>(context);
    _startContinuousListening();
    _navigationCubit.navigateToIndex(0);
    PushNotifications.getAndSaveFcmTokenToFirestore();
  }

  void _startContinuousListening() async {
    if (!_isListening) {
      setState(() => _isListening = true);
      _listenForCommands();
    }
  }

  void _listenForCommands() async {
    while (_isListening) {
      final command = await  _voiceHelper.listen();
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

  Future<void> _processVoiceCommand(String command) async {
    final lowerCommand = command.toLowerCase();
    int? targetIndex;
    String? screenName;

    if (lowerCommand.contains('connection lost with the headset') ||
        lowerCommand.contains("can't connect to the headset")) {
      return;
    }

    // Handle chat-specific commands when in chat screen
    if (_isInChatScreen && _chatKey.currentState != null) {
      if (lowerCommand.contains('record') || lowerCommand.contains('start recording')) {
        await _voiceHelper.speak('Starting voice recording');
        _chatKey.currentState?.startRecording();
        _showNavigationFeedback('Starting voice recording', false);
        return;
      } else if (lowerCommand.contains('send') || lowerCommand.contains('stop recording')) {
        await _voiceHelper.speak('Sending voice message');
        _chatKey.currentState?.stopRecording();
        _showNavigationFeedback('Sending voice message', false);
        return;
      }
    }

    // Handle navigation to chat
    if (lowerCommand.contains('chat') || lowerCommand.contains('message')) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _showNavigationFeedback('Not authenticated', true);
        return;
      }

      try {
        final patientDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        final linkedCaregivers = patientDoc.data()?['linkedCaregivers'] as List<dynamic>?;
        if (linkedCaregivers == null || linkedCaregivers.isEmpty) {
          _showNavigationFeedback('No caregiver linked', true);
          return;
        }

        // Get caregiver name
        final caregiverDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(linkedCaregivers[0].toString())
            .get();
        
        final caregiverName = caregiverDoc.data()?['name'] ?? 'Caregiver';

        setState(() {
          _isInChatScreen = true;
          _chatScreen = PatientChatScreen(
            key: _chatKey,
            caregiverId: linkedCaregivers[0].toString(),
            caregiverName: caregiverName,
          );
        });

        await _voiceHelper.speak('Opening chat with ${caregiverName}');
        
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _chatScreen!,
          ),
        );

        setState(() {
          _isInChatScreen = false;
          _chatScreen = null;
        });

        return;
      } catch (e) {
        debugPrint('Error opening chat: $e');
        _showNavigationFeedback('Error opening chat', true);
        return;
      }
    }

    else if (lowerCommand.contains('medicine') || lowerCommand.contains('medications')) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const PatientMedicationsScreen(),
        ),
      );
      _showNavigationFeedback('Opening Medications', false);
      return;
    } else if (lowerCommand.contains('appointment') || lowerCommand.contains('schedule')) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const PatientAppointmentsScreen(),
        ),
      );
      _showNavigationFeedback('Opening Appointments', false);
      return;
    }
    else if (lowerCommand.contains('back')|| (lowerCommand.contains('return'))) {
      Navigator.of(context).pop();
      _showNavigationFeedback('Going back', false);
      return;
    }

   else  if (lowerCommand.contains('home') || lowerCommand.contains('main')) {
      targetIndex = 0;
      screenName = 'Home';
    } else if (lowerCommand.contains('qr') || lowerCommand.contains('scan')) {
      targetIndex = 1;
      screenName = 'QR Code';
    } else if (lowerCommand.contains('map') || lowerCommand.contains('location')) {
      targetIndex = 2;
      screenName = 'Map';
    } else if (lowerCommand.contains('call') || lowerCommand.contains('phone')) {
      targetIndex = 3;
      screenName = 'Call';
    }
     else if (lowerCommand.contains('headset') || lowerCommand.contains('device')) {
      targetIndex = 4;
      screenName = 'headset';
      _updateDeviceTab(0);

      print(_selectedTab);

    } 
    else if (lowerCommand.contains('robot') || lowerCommand.contains('connect robot')) {
      targetIndex = 4;
      screenName = 'robot';
      _updateDeviceTab  (1);
      print(_selectedTab);

    }
    else if (lowerCommand.contains('start server')) {
      targetIndex = 4;
      _updateDeviceTab(0);
      screenName = 'Headset';
      Future.microtask(() {
        _headsetKey.currentState?.startServerExternal();
      });
    } else if (lowerCommand.contains('stop server')) {
      targetIndex = 4;
      _updateDeviceTab(0);
      screenName = 'Headset';
      Future.microtask(() {
        _headsetKey.currentState?.stopServerExternal();
      });
    } else if (lowerCommand.contains('start test')) {
      targetIndex = 4;
      _updateDeviceTab(0);
      screenName = 'Headset';
      Future.microtask(() {
        _headsetKey.currentState?.startTestExternal();
      });
    } else if (lowerCommand.contains('stop test')) {
      targetIndex = 4;
      _updateDeviceTab(0);
      screenName = 'Headset';
      Future.microtask(() {
        _headsetKey.currentState?.stopTestExternal();
      });
    }
    else if (command.toLowerCase().contains('help') || 
            command.toLowerCase().contains('emergency')) {
    {
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          _showNavigationFeedback('Not authenticated', true);
          return;
        }

        final patientDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        final linkedCaregivers = patientDoc.data()?['linkedCaregivers'] as List<dynamic>?;
        if (linkedCaregivers == null || linkedCaregivers.isEmpty) {
          _showNavigationFeedback('No caregiver linked', true);
          return;
        }

        // Send to first caregiver
        final success = await PushNotifications.sendHelpNotificationsToCaregiver(
          linkedCaregivers[0].toString(),
          context,
        );

        if (success) {
          _showNavigationFeedback('Emergency alert sent', false);
          await _voiceHelper.speak('Help is on the way');
        } else {
          _showNavigationFeedback('Failed to send alert', true);
        }
      } catch (e) {
        print('Error sending emergency: $e');
        _showNavigationFeedback('Emergency failed', true);
      }
    }
}
    // Handle robot control commands
    else if (lowerCommand.contains('forward')) {
      _handleRobotDirection('forward');
    } else if (lowerCommand.contains('backward')) {
      _handleRobotDirection('backward');
    } else if (lowerCommand.contains('left')) {
      _handleRobotDirection('left');
    } else if (lowerCommand.contains('right')) {
      _handleRobotDirection('right');
    } else if (lowerCommand.contains('stop')) {
      _handleRobotDirection('stop');
    } else if (lowerCommand.contains('logout')) {
      _handleLogout();
      return;
    }
   else if ((lowerCommand.contains('disconnect') || lowerCommand.contains('disconnect robot')) ) {
      targetIndex = 4;
      _updateDeviceTab(1);
      screenName = 'Robot';
      _isListening = false;
      await _voiceHelper.stopListening();
      Future.microtask(() {
        _headsetKey.currentState?.disconnectRobotExternal();
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (!_isListening) {
          _startContinuousListening();
        }
      });
    }
    // Handle navigation if a valid target was found
    if (targetIndex != null ) {
      final currentIndex = context.read<NavigationCubit>().state.currentIndex;
      if (currentIndex != targetIndex) {
        context.read<NavigationCubit>().navigateToIndex(targetIndex);
        _showNavigationFeedback('Navigating to $screenName', false);
      }
    } 
    // else {
    //   _showNavigationFeedback('Command not recognized. Please try again.', true);
    // }

    // Ignore system TTS phrases that might be captured by the mic
    
  }

  void _handleRobotDirection(String direction) {
    setState(() {
      _activeDirection = direction;
    });
    
    switch (direction) {
      case 'forward':
        _robotFunctions.moveForward();
        print( 'Robot moving forward');
        break;
      case 'backward':
        _robotFunctions.moveBackward();
        break;
      case 'left':
        _robotFunctions.turnLeft();
        break;
      case 'right':
        _robotFunctions.turnRight();
        break;
      case 'stop':
        _robotFunctions.stop();
        break;
    }

    _showNavigationFeedback('Robot moving $direction', false);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _activeDirection = '';
        });
      }
    });
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        await _voiceHelper.speak('Logging out successfully');
      
      // Wait for 2 seconds
      await Future.delayed(const Duration(seconds: 4));
      
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/user-select',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showNavigationFeedback('Error logging out Please try again.', true);
      }
    }
  }



  // Add this helper method if not already present

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
              const PatientCallPage(),
              ConnectedHeadset(
                key: _headsetKey,
                title: _selectedTab == 0 ? 'Headset Connection' : 'Chair Connection',
                initialTab: _selectedTab,
              ),
            ],
          ),
          bottomNavigationBar: PatientNavigationBar(
            currentIndex: state.currentIndex,
            onTap: (index) {
              final currentIndex = state.currentIndex;
              if (currentIndex != index) {
                context.read<NavigationCubit>().navigateToIndex(index);
                final screenNames = ['Home', 'QR Code', 'Map', 'Call','Device'];
                _showNavigationFeedback('Navigating to ${screenNames[index]}', false);
              }
            },
          ),
        );
      },
    );
  }
}
