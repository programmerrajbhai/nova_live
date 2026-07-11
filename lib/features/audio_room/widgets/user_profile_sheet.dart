import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔥 Safety Controller ইমপোর্ট করা হলো
import '../../../core/controllers/safety_controller.dart';
// 🔥 UserProfileView ইমপোর্ট করা হলো
import '../../profile/view/user_profile_view.dart';

class UserProfileSheet {
  static void show({
    required BuildContext context,
    required ZegoUIKitUser clickedUser,
    required bool isHost,
    required String roomId,
    required String currentUserId,
  }) {
    // 🔥 Safety Controller ইনিশিয়ালাইজ করা হলো
    final SafetyController safetyController = Get.put(SafetyController());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF141E30), Color(0xFF243B55)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
            border: Border.all(
              color: Colors.purpleAccent.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 25),

              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF1A1A2E),
                child: Text(
                  clickedUser.name.isNotEmpty
                      ? clickedUser.name.substring(0, 1).toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    fontSize: 40,
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                clickedUser.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'ID: ${clickedUser.id}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 20),

              // 🔥 View Full Profile Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Get.back();
                  Get.to(() => UserProfileView(
                    userId: clickedUser.id,
                    userName: clickedUser.name,
                  ));
                },
                child: const Text(
                  'View Full Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // 🔥 Host Actions (Kick/Ban)
              if (isHost) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      'Kick',
                      Icons.output,
                      Colors.orangeAccent,
                          () {
                        ZegoUIKit().removeUserFromRoom([clickedUser.id]);
                        Get.back();
                        Get.snackbar(
                          'Kicked',
                          '${clickedUser.name} has been kicked.',
                          backgroundColor: Colors.orangeAccent,
                          colorText: Colors.white,
                        );
                      },
                    ),
                    _buildActionButton(
                      'Ban',
                      Icons.block,
                      Colors.redAccent,
                          () async {
                        await FirebaseFirestore.instance
                            .collection('banned_users')
                            .doc(roomId)
                            .collection('users')
                            .doc(clickedUser.id)
                            .set({
                          'banned_at': FieldValue.serverTimestamp(),
                          'banned_by': currentUserId,
                        });

                        ZegoUIKit().removeUserFromRoom([clickedUser.id]);
                        Get.back();
                        Get.snackbar(
                          'Banned 🚫',
                          '${clickedUser.name} is permanently banned.',
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                      },
                    ),
                  ],
                ),
              ] else ...[
                // 🔥 Standard User Actions (Block/Report via SafetyController)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      'Block User',
                      Icons.person_off,
                      Colors.grey,
                          () {
                        // গ্লোবাল স্কিমা ব্যবহার করে ব্লক
                        safetyController.blockUser(clickedUser.id);
                      },
                    ),
                    _buildActionButton(
                      'Report User',
                      Icons.report_problem,
                      Colors.orangeAccent,
                          () {
                        // স্ট্যান্ডার্ড স্কিমার জন্য প্রপার রিপোর্ট ডায়ালগ কল
                        _showReportDialog(context, clickedUser, roomId, safetyController);
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  static Widget _buildActionButton(
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // 📝 Standard Schema Report Dialog
  static void _showReportDialog(BuildContext context, ZegoUIKitUser clickedUser, String roomId, SafetyController safetyController) {
    String selectedReason = 'Spam or Scam';
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
                items: ['Spam or Scam', 'Harassment or Bullying', 'Nudity or Sexual Content', 'Hate Speech']
                    .map((reason) => DropdownMenuItem(value: reason, child: Text(reason)))
                    .toList(),
                onChanged: (value) => setState(() => selectedReason = value!),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: detailsController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Additional details (optional)...',
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
          reportedUserId: clickedUser.id,
          roomId: roomId,
          reason: selectedReason,
          details: detailsController.text,
          source: 'audio_room', // 🔥 Source explicitly tagged
        );
      },
    );
  }
}