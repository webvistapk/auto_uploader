import 'package:flutter/material.dart';
import 'package:mobile/screens/messaging/calling/const/const.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

enum CallType { video, audio }

class CallPage extends StatelessWidget {
  final String userID;
  final String userName;
  final String targetUserID;
  final CallType callType;

  const CallPage({
    super.key,
    required this.userID,
    required this.userName,
    required this.targetUserID,
    required this.callType,
  });

  @override
  Widget build(BuildContext context) {
    String callID = generateCallID(userID, targetUserID);
    return ZegoUIKitPrebuiltCall(
      appID: ZegoInfo.zeegoAppID,
      appSign: ZegoInfo.zegoAppSign,
      userID: userID,
      userName: userName,
      callID: callID,
      config: callType == CallType.video
          ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
          : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
    );
  }

  // Ensure both users generate the same room ID
  String generateCallID(String a, String b) {
    List<String> ids = [a, b]..sort();
    return "${ids[0]}_${ids[1]}_call";
  }
}
