import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:get/get.dart';
import '../../../core/controllers/safety_controller.dart'; // সেফটি কন্ট্রোলার যুক্ত করা হলো

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
    // সেফটি কন্ট্রোলার ইনিশিয়ালাইজ করা হলো
    final SafetyController safetyController = Get.put(SafetyController());

    // কল আইডি থেকে অন্য ইউজারের (Target User) আইডি বের করার লজিক
    // (কারণ MatchingController থেকে callId পাঠানো হয়: targetUid_myUid ফরম্যাটে)
    String targetUserId = callId.split('_').firstWhere((id) => id != userId, orElse: () => 'unknown_user');

    var config = ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall();

    // =======================================================
    // গুগল প্লে পলিসি অনুযায়ী কাস্টম Report ও Block বাটন (Foreground)
    // =======================================================
    config.foreground = SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54, // ভিডিওর উপর যেন স্পষ্ট বোঝা যায়
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.security_rounded, color: Colors.white),
              tooltip: "Safety Options",
              color: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              onSelected: (value) {
                if (value == 'report') {
                  _showReportDialog(context, targetUserId, safetyController);
                } else if (value == 'block') {
                  _showBlockDialog(context, targetUserId, safetyController);
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'report',
                  child: Row(
                    children: [
                      Icon(Icons.report_problem_rounded, color: Colors.orangeAccent, size: 20),
                      SizedBox(width: 10),
                      Text('Report User', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'block',
                  child: Row(
                    children: [
                      Icon(Icons.block_rounded, color: Colors.redAccent, size: 20),
                      SizedBox(width: 10),
                      Text('Block & End Call', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return SafeArea(
      child: ZegoUIKitPrebuiltCall(
        appID: 358538422,
        appSign: '7e4ad77a5ad88a14bdbfbda739b67e9de336d5c91aa0b00672c22eecd96823fa',
        userID: userId,
        userName: userName,
        callID: callId,
        config: config,
        events: ZegoUIKitPrebuiltCallEvents(
          onCallEnd: (event, defaultAction) {
            Get.back();
          },
        ),
      ),
    );
  }

  // ==========================================
  // Report User Dialog
  // ==========================================
  void _showReportDialog(BuildContext context, String targetId, SafetyController safetyController) {
    String selectedReason = 'Nudity or sexual content';
    final TextEditingController detailsController = TextEditingController();

    Get.defaultDialog(
      title: "Report User",
      titleStyle: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
      backgroundColor: const Color(0xFF1E1E1E),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedReason,
                dropdownColor: const Color(0xFF2C2C2C),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
                items: [
                  'Nudity or sexual content',
                  'Violence or dangerous behavior',
                  'Harassment or Bullying',
                  'Spam or Scam'
                ].map((reason) => DropdownMenuItem(value: reason, child: Text(reason))).toList(),
                onChanged: (value) => setState(() => selectedReason = value!),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: detailsController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Additional details...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
            ],
          );
        },
      ),
      textConfirm: "Submit Report",
      textCancel: "Cancel",
      confirmTextColor: Colors.black,
      cancelTextColor: Colors.white,
      buttonColor: Colors.orangeAccent,
      onConfirm: () {
        safetyController.submitReport(
          reportedUserId: targetId,
          reason: selectedReason,
          details: detailsController.text,
          source: 'random_video_call', // সোর্স ট্যাগ করে দেওয়া হলো
        );
        Get.back(); // ডায়ালগ কাটবে
        Get.snackbar('Reported', 'User has been reported to moderation team.', backgroundColor: Colors.green, colorText: Colors.white);
      },
    );
  }

  // ==========================================
  // Block & End Call Dialog
  // ==========================================
  void _showBlockDialog(BuildContext context, String targetId, SafetyController safetyController) {
    Get.defaultDialog(
      title: "Block & End Call?",
      titleStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
      middleText: "Are you sure you want to block this user? The call will end immediately.",
      middleTextStyle: const TextStyle(color: Colors.white70),
      backgroundColor: const Color(0xFF1E1E1E),
      textConfirm: "Block & End",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () async {
        Get.back(); // ডায়ালগ কাটবে
        await safetyController.blockUser(targetId); // ইউজারকে ফায়ারবেসে ব্লক করবে
        Get.back(); // কল থেকে বের করে ম্যাচিং স্ক্রিনে নিয়ে যাবে
        Get.snackbar('Blocked', 'User has been blocked successfully.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      },
    );
  }
}