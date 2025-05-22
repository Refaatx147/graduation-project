import 'package:grade_pro/core/constants/zego_constants.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class CallService {
  static Future<void> initializeCallService() async {
    // Initialize ZegoUIKitSignalingPlugin
    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: ZegoConstants.appID, // Replace with your Zego app ID
      appSign: ZegoConstants.appSign, // Replace with your Zego app sign
      userID: 'user_id', // This will be set when user logs in
      userName: 'user_name', // This will be set when user logs in
      plugins: [ZegoUIKitSignalingPlugin()],
    );
  }

  static void disposeCallService() {
    ZegoUIKitPrebuiltCallInvitationService().uninit();
  }
} 