import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/public_profile_controller.dart';

class UserProfileView extends StatelessWidget {
  final String userId;
  final String userName;
  final String? userAvatar; // ঐচ্ছিক প্যারামিটার হিসেবে রাখলাম যাতে এরর না আসে

  const UserProfileView({
    super.key,
    required this.userId,
    required this.userName,
    this.userAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final PublicProfileController controller = Get.put(PublicProfileController(targetUserId: userId));

    return Scaffold(
      backgroundColor: const Color(0xFF0F0518),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {
              // 🔥 Play Store Policy: Report & Block Options
              _showOptionsBottomSheet(context, userId, userName);
            },
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));
        }

        var user = controller.userData;
        String avatarUrl = user['avatar'] ?? userAvatar ?? '';
        String bio = user['bio'] ?? 'Hello! I am using Nova Live.';
        String name = user['name'] ?? userName;

        return Stack(
          children: [
            // 🎨 Premium Gradient Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F0518), Color(0xFF1A0B2E), Color(0xFF0F0518)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.pinkAccent.withOpacity(0.1)),
                child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50), child: Container(color: Colors.transparent)),
              ),
            ),

            // 👤 Profile Content
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Avatar setup with glowing effect
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.pinkAccent, width: 2),
                        boxShadow: [BoxShadow(color: Colors.pinkAccent.withOpacity(0.4), blurRadius: 20)],
                      ),
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: const Color(0xFF1A1A2E),
                        backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                        child: avatarUrl.isEmpty
                            ? Text(name.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold))
                            : null,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // User Name & ID
                    Text(name, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text("ID: $userId", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ),
                    const SizedBox(height: 15),

                    // Bio
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(bio, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 14)),
                    ),
                    const SizedBox(height: 30),

                    // 📊 Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatColumn("Followers", controller.followersCount.value.toString()),
                        _buildStatColumn("Following", controller.followingCount.value.toString()),
                        _buildStatColumn("Level", (user['level'] ?? '1').toString()),
                      ],
                    ),
                    const SizedBox(height: 35),

                    // 🔘 Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Follow / Unfollow Button
                        GestureDetector(
                          onTap: () => controller.toggleFollow(),
                          child: Container(
                            width: 140,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: controller.isFollowing.value
                                    ? [Colors.grey[800]!, Colors.grey[700]!]
                                    : [Colors.pinkAccent, Colors.deepPurpleAccent],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: controller.isFollowing.value ? [] : [BoxShadow(color: Colors.pinkAccent.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Center(
                              child: Text(
                                controller.isFollowing.value ? "Following" : "Follow",
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        // Message Button
                        GestureDetector(
                          onTap: () {
                            Get.snackbar('Message', 'Opening chat with $name...', backgroundColor: Colors.cyan, colorText: Colors.white);
                          },
                          child: Container(
                            width: 60,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: const Center(
                              child: Icon(Icons.chat_bubble_outline, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
      ],
    );
  }

  // =======================================================
  // 🔥 Google Play UGC Policy Implementation (Block & Report)
  // =======================================================

  void _showOptionsBottomSheet(BuildContext context, String targetId, String targetName) {
    showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1A0B2E),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 20),
                  width: 40, height: 5,
                  decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(10)),
                ),
                ListTile(
                  leading: const Icon(Icons.report_problem_rounded, color: Colors.orangeAccent),
                  title: const Text('Report User', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Report inappropriate content or behavior', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  onTap: () {
                    Get.back();
                    _showReportDialog(context, targetId, targetName);
                  },
                ),
                const Divider(color: Colors.white10),
                ListTile(
                  leading: const Icon(Icons.block_rounded, color: Colors.redAccent),
                  title: const Text('Block User', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  subtitle: const Text('You will no longer see this user', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  onTap: () {
                    Get.back();
                    _showBlockDialog(context, targetId, targetName);
                  },
                ),
                const SizedBox(height: 15),
              ],
            ),
          );
        }
    );
  }

  // 🚩 Report System (Required by Play Store)
  void _showReportDialog(BuildContext context, String targetId, String targetName) {
    final List<String> reportReasons = [
      'Nudity or sexually explicit content',
      'Hate speech or symbols',
      'Violence or dangerous behavior',
      'Bullying or harassment',
      'Scam or fraud',
      'Spam'
    ];
    String selectedReason = reportReasons[0];

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  backgroundColor: const Color(0xFF1A0B2E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.white.withOpacity(0.1))),
                  title: const Text('Report User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: reportReasons.map((reason) {
                        return RadioListTile<String>(
                          activeColor: Colors.pinkAccent,
                          title: Text(reason, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                          value: reason,
                          groupValue: selectedReason,
                          onChanged: (value) {
                            setState(() { selectedReason = value!; });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                      // 🔥 Fix: Removed onButtonTap
                      onPressed: () => Get.back(),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text('Submit Report', style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        Get.back(); // Close Dialog

                        // ফায়ারবেসে রিপোর্ট সেভ করা
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String myUid = prefs.getString('uid') ?? '';

                        if (myUid.isNotEmpty) {
                          await FirebaseFirestore.instance.collection('reports').add({
                            'reporterId': myUid,
                            'reportedUserId': targetId,
                            'reason': selectedReason,
                            'timestamp': FieldValue.serverTimestamp(),
                            'status': 'pending'
                          });

                          // Play Store Requirement: Show confirmation that report is received
                          Get.snackbar(
                            'Report Submitted',
                            'Thank you for reporting. Our team will review this user within 24 hours.',
                            backgroundColor: Colors.black87,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            duration: const Duration(seconds: 4),
                            icon: const Icon(Icons.check_circle, color: Colors.greenAccent),
                          );
                        }
                      },
                    ),
                  ],
                );
              }
          );
        }
    );
  }

  // 🚫 Block System (Required by Play Store)
  void _showBlockDialog(BuildContext context, String targetId, String targetName) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A0B2E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.redAccent.withOpacity(0.5))),
            title: const Text('Block User?', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            content: Text('Are you sure you want to block $targetName? You will not receive their messages or see them in live rooms.', style: const TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                // 🔥 Fix: Removed onButtonTap
                onPressed: () => Get.back(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text('Block', style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  Get.back();

                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String myUid = prefs.getString('uid') ?? '';

                  if (myUid.isNotEmpty) {
                    // ইউজারের ব্লক লিস্টে অ্যাড করা
                    await FirebaseFirestore.instance.collection('users').doc(myUid).collection('blocked_users').doc(targetId).set({
                      'blockedAt': FieldValue.serverTimestamp(),
                      'blockedUserId': targetId,
                      'blockedUserName': targetName,
                    });

                    Get.snackbar(
                      'User Blocked',
                      '$targetName has been blocked.',
                      backgroundColor: Colors.redAccent.withOpacity(0.9),
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );

                    // প্রোফাইল থেকে বের করে দেওয়া
                    Future.delayed(const Duration(seconds: 1), () => Get.back());
                  }
                },
              ),
            ],
          );
        }
    );
  }
}