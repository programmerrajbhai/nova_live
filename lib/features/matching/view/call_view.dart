import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:get/get.dart';

class CallView extends StatelessWidget {
  final String callId;
  final String userId;
  final String userName;

  const CallView({
    Key? key,
    required this.callId,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltCall(
        appID: 358538422,
        appSign: '7e4ad77a5ad88a14bdbfbda739b67e9de336d5c91aa0b00672c22eecd96823fa',
        userID: userId,
        userName: userName,
        callID: callId,

        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),

        // 🔥 লেটেস্ট ZegoCloud প্যাকেজে ইভেন্টগুলো এভাবে হ্যান্ডেল করতে হয়
        events: ZegoUIKitPrebuiltCallEvents(
          onCallEnd: (event, defaultAction) {
            // কেউ কল কেটে দিলে সরাসরি আগের পেজে (Matching View) চলে আসবে
            Get.back();
          },
        ),
      ),
    );
  }
}