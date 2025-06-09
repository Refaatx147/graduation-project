// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import '../constants/zego_constants.dart';

class CallService {
  static Future<void> initializeCallService() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final userName = userData.data()?['name'] ?? 'Unknown User';

      // Initialize signaling plugin first
      final signalingPlugin = ZegoUIKitSignalingPlugin();
      
      // Initialize ZegoUIKitPrebuiltCallInvitationService with signaling plugin
      await ZegoUIKitPrebuiltCallInvitationService().init(
        appID: ZegoConstants.appID,
        appSign: ZegoConstants.appSign,
        userID: currentUser.uid,
        userName: userName,
        plugins: [signalingPlugin],
        
        config: ZegoCallInvitationConfig(
          endCallWhenInitiatorLeave: true
        )
      );

      print('Call service initialized successfully');
    } catch (e) {
      print('Error initializing call service: $e');
      rethrow;
    }
  }

  static Future<void> disposeCallService() async {
    try {
      await ZegoUIKitPrebuiltCallInvitationService().uninit();
      print('Call service disposed successfully');
    } catch (e) {
      print('Error disposing call service: $e');
      rethrow;
    }
  }
} 