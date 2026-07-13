import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/safety_controller.dart';
import '../controller/public_profile_controller.dart';

class UserProfileView extends StatelessWidget {
  final String userId;
  final String userName;
  final String? userAvatar;

  const UserProfileView({
    super.key,
    required this.userId,
    required this.userName,
    this.userAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final PublicProfileController controller = Get.put(PublicProfileController(targetUserId: userId));
    // 🔥 SafetyController ইনিশিয়ালাইজ করা হলো
    final SafetyController safetyController = Get.put(SafetyController());

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
              _showOptionsBottomSheet(context, userId, userName, safetyController);
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

                    Text(name, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text("ID: $userId", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ),
                    const SizedBox(height: 15),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(bio, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 14)),
                    ),
                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatColumn("Followers", controller.followersCount.value.toString()),
                        _buildStatColumn("Following", controller.followingCount.value.toString()),
                        _buildStatColumn("Level", (user['level'] ?? '1').toString()),
                      ],
                    ),
                    const SizedBox(height: 35),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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

  void _showOptionsBottomSheet(BuildContext context, String targetId, String targetName, SafetyController safetyController) {
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
                    Get.back(); // Close BottomSheet
                    _showReportDialog(context, targetId, targetName, safetyController);
                  },
                ),
                const Divider(color: Colors.white10),
                ListTile(
                  leading: const Icon(Icons.block_rounded, color: Colors.redAccent),
                  title: const Text('Block User', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  subtitle: const Text('You will no longer see this user', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  onTap: () {
                    Get.back(); // Close BottomSheet
                    _showBlockDialog(context, targetId, targetName, safetyController);
                  },
                ),
                const SizedBox(height: 15),
              ],
            ),
          );
        }
    );
  }

  // 🚩 Report System via SafetyController
  void _showReportDialog(BuildContext context, String targetId, String targetName, SafetyController safetyController) {
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
                      onPressed: () => Get.back(),
                    ),
                    Obx(() => ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: safetyController.isProcessing.value ? null : () {
                        // 🔥 Direct Firebase কল মুছে SafetyController ব্যবহার করা হলো
                        safetyController.submitReport(
                          reportedUserId: targetId,
                          reason: selectedReason,
                          details: 'Reported from User Profile View',
                          source: 'user_profile',
                        );
                      },
                      child: safetyController.isProcessing.value
                          ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Submit Report', style: TextStyle(color: Colors.white)),
                    )),
                  ],
                );
              }
          );
        }
    );
  }

  // 🚫 Block System via SafetyController
  void _showBlockDialog(BuildContext context, String targetId, String targetName, SafetyController safetyController) {
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
                onPressed: () => Get.back(),
              ),
              Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: safetyController.isProcessing.value ? null : () async {

                  // 🔥 Direct Firebase কল মুছে SafetyController ব্যবহার করা হলো
                  await safetyController.blockUser(targetId);

                  // ব্লক করার পর ইউজার প্রোফাইল পেজ থেকে বের করে দেওয়া
                  Future.delayed(const Duration(milliseconds: 500), () {
                    Get.back();
                  });
                },
                child: safetyController.isProcessing.value
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Block', style: TextStyle(color: Colors.white)),
              )),
            ],
          );
        }
    );
  }
}