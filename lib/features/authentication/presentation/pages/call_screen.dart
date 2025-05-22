// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grade_pro/features/authentication/presentation/pages/caregiver/caregiver_call_screen.dart';
import 'package:grade_pro/features/authentication/presentation/pages/patient/patient_call_screen.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:grade_pro/core/constants/zego_constants.dart';

// Unique call ID
String generateRoomId(String user1, String user2) {
  final sorted = [user1, user2]..sort();
  return '${sorted[0]}_${sorted[1]}';
}

class CallPage extends StatefulWidget {
  final bool isPatient;

  const CallPage({super.key, required this.isPatient});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _initializeZegoCall();
  }

  void _initializeZegoCall() {
    if (currentUserId != null) {
      ZegoUIKitPrebuiltCallInvitationService().init(
        notificationConfig: ZegoCallInvitationNotificationConfig(
          androidNotificationConfig: ZegoCallAndroidNotificationConfig(
            callIDVisibility: true,
            showFullScreen: true,
            callChannel: ZegoCallAndroidNotificationChannelConfig(
              channelID: ZegoConstants.callChannel,
              channelName: ZegoConstants.callTitle,
              vibrate: true,
            ),
          ),
        ),
        appID: ZegoConstants.appID,
        appSign: ZegoConstants.appSign,
        userID: currentUserId!,
        userName: widget.isPatient ? 'Patient' : 'Caregiver',
        plugins: [ZegoUIKitSignalingPlugin()],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF9ED),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 33, 95, 112),
        leading: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(
              Icons.people,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 8),
              Text(
              widget.isPatient ? 'My Caregivers' : 'My Patients',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        leadingWidth: 200,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: widget.isPatient 
          ?  PatientCallPage() 
          : CaregiverCallPage(),
    );
  }
}