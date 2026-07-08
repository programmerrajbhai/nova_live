import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileSheet {
  static void show({
    required BuildContext context,
    required ZegoUIKitUser clickedUser,
    required bool isHost,
    required String roomId,
    required String currentUserId,
  }) {
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
            border: Border.all(color: Colors.purpleAccent.withOpacity(0.3), width: 1.5),
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.white38, borderRadius: BorderRadius.circular(10))
              ),
              const SizedBox(height: 25),

              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF1A1A2E),
                child: Text(
                  clickedUser.name.isNotEmpty ? clickedUser.name.substring(0, 1).toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 40, color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                  clickedUser.name,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
              ),
              Text(
                  'ID: ${clickedUser.id}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12)
              ),
              const SizedBox(height: 25),

              // 🔥 রিয়েল এডমিন অ্যাকশন
              if (isHost) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton('Kick', Icons.output, Colors.orangeAccent, () {
                      ZegoUIKit().removeUserFromRoom([clickedUser.id]);
                      Get.back();
                      Get.snackbar('Kicked', '${clickedUser.name} has been kicked.', backgroundColor: Colors.orangeAccent, colorText: Colors.white);
                    }),
                    _buildActionButton('Ban', Icons.block, Colors.redAccent, () async {
                      // ১. ডেটাবেসে ব্যান লিস্টে এড করা
                      await FirebaseFirestore.instance
                          .collection('banned_users')
                          .doc(roomId)
                          .collection('users')
                          .doc(clickedUser.id)
                          .set({
                        'banned_at': FieldValue.serverTimestamp(),
                        'banned_by': currentUserId,
                      });
                      // ২. রুম থেকে রিয়েল টাইমে বের করে দেওয়া
                      ZegoUIKit().removeUserFromRoom([clickedUser.id]);
                      Get.back();
                      Get.snackbar(
                          'Banned 🚫',
                          '${clickedUser.name} is permanently banned.',
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white
                      );
                    }),
                  ],
                )
              ] else ...[
                // সাধারণ ইউজারদের জন্য Block এবং Report
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton('Block User', Icons.person_off, Colors.grey, () async {
                      await FirebaseFirestore.instance
                          .collection('blocked_users')
                          .doc(currentUserId)
                          .collection('blocked')
                          .doc(clickedUser.id)
                          .set({'blocked_at': FieldValue.serverTimestamp()});
                      Get.back();
                      Get.snackbar('Blocked', 'You will no longer see interactions from this user.', backgroundColor: Colors.grey[800], colorText: Colors.white);
                    }),
                    _buildActionButton('Report User', Icons.report_problem, Colors.orangeAccent, () async {
                      await FirebaseFirestore.instance.collection('reports_users').add({
                        'reported_user_id': clickedUser.id,
                        'reported_by': currentUserId,
                        'room_id': roomId,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      Get.back();
                      Get.snackbar('Reported', 'User reported successfully.', backgroundColor: Colors.orangeAccent, colorText: Colors.white);
                    }),
                  ],
                )
              ]
            ],
          ),
        );
      },
    );
  }

  static Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(0.5))
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}