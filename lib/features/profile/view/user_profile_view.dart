import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/public_profile_controller.dart';

class UserProfileView extends StatelessWidget {
  final String userId;
  final String userName;

  const UserProfileView({Key? key, required this.userId, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // কন্ট্রোলার ইনিশিয়ালাইজ করা হলো
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
              // Report or Block BottomSheet
            },
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));
        }

        var user = controller.userData;
        String avatarUrl = user['avatar'] ?? '';
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

                    // 📊 Stats Row (Followers / Following / Level)
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
                            // TODO: Message page routing
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
}