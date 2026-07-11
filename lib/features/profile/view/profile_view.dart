import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/widgets/premium_background.dart';
import '../controller/profile_controller.dart';
import '../../messages/view/settings_view.dart';
import 'edit_profile_view.dart';
import '../../legal/view/privacy_policy_view.dart'; // 🔥 Import New Privacy Screen

class ProfileView extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  ProfileView({super.key});

  void _showLogoutDialog() {
    Get.defaultDialog(
      title: "Log Out",
      titleStyle: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
      middleText: "Are you sure you want to log out of your account?",
      middleTextStyle: const TextStyle(color: Colors.grey),
      backgroundColor: const Color(0xFF1E1E1E),
      textConfirm: "Log Out",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.white,
      buttonColor: Colors.orangeAccent,
      onConfirm: () {
        Get.back();
        controller.logOut();
      },
    );
  }

  void _showDeleteAccountDialog() {
    Get.defaultDialog(
      title: "Delete Account?",
      titleStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
      middleText: "This action cannot be undone. All your data will be permanently deleted.",
      middleTextStyle: const TextStyle(color: Colors.grey),
      backgroundColor: const Color(0xFF1E1E1E),
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        Get.back();
        controller.deleteUserAccount();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purpleAccent, fontSize: 24)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(FontAwesomeIcons.gear, color: Colors.white, size: 20),
              onPressed: () => Get.to(() => SettingsView(), transition: Transition.rightToLeftWithFade),
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: Obx(() {
          if (controller.isProcessing.value && controller.userName.value == 'Loading...') {
            return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // ১. User Avatar & Info
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(colors: [Colors.purpleAccent, Colors.cyanAccent]),
                          boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.5), blurRadius: 20)],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFF1E1E1E),
                          backgroundImage: controller.userAvatar.value.isNotEmpty ? NetworkImage(controller.userAvatar.value) : null,
                          child: controller.userAvatar.value.isEmpty ? const Icon(FontAwesomeIcons.userAstronaut, size: 45, color: Colors.white) : null,
                        ),
                      ),
                      const SizedBox(height: 15),

                      Text(controller.userName.value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      const SizedBox(height: 8),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(controller.userBio.value, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ),
                      const SizedBox(height: 15),

                      GestureDetector(
                        onTap: () => Get.to(() => const EditProfileView(), transition: Transition.downToUp),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(FontAwesomeIcons.penToSquare, color: Colors.white, size: 14),
                              SizedBox(width: 8),
                              Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // ২. Social Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn('Followers', controller.followersCount.value.toString()),
                    _buildStatColumn('Following', controller.followingCount.value.toString()),
                    _buildStatColumn('Level', controller.userLevel.value.toString(), icon: FontAwesomeIcons.star),
                  ],
                ),
                const SizedBox(height: 30),

                // ৩. Wallet Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.orangeAccent.withOpacity(0.4), width: 1.5),
                    boxShadow: [BoxShadow(color: Colors.orangeAccent.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 5))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('My Wallet', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(FontAwesomeIcons.coins, color: Colors.orangeAccent, size: 28),
                              const SizedBox(width: 10),
                              Text('${controller.myCoins.value}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.orangeAccent, Colors.deepOrangeAccent]), borderRadius: BorderRadius.circular(20)),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12)),
                          onPressed: () {
                            controller.addCoins(100);
                            Get.snackbar('Recharge Successful', '100 Coins added.', backgroundColor: Colors.green, colorText: Colors.white);
                          },
                          icon: const Icon(FontAwesomeIcons.plus, color: Colors.white, size: 16),
                          label: const Text('Top Up', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // ৪. Core Settings (Privacy Policy Screen Connected)
                _buildMenuCard([
                  _buildMenuItem(FontAwesomeIcons.userShield, 'Privacy & Safety', Colors.indigoAccent, onTap: () => Get.to(() => SettingsView(), transition: Transition.rightToLeftWithFade)),

                  // 🔥 Navigates to App's Internal Privacy Policy Screen
                  _buildMenuItem(FontAwesomeIcons.fileContract, 'Terms & Privacy Policy', Colors.cyanAccent, onTap: () => Get.to(() => const PrivacyPolicyView(), transition: Transition.rightToLeftWithFade)),
                ]),
                const SizedBox(height: 20),

                // ৫. Account Actions
                _buildMenuCard([
                  _buildMenuItem(FontAwesomeIcons.rightFromBracket, 'Log Out', Colors.orangeAccent, onTap: _showLogoutDialog),
                  _buildMenuItem(FontAwesomeIcons.trash, 'Delete Account', Colors.redAccent, onTap: _showDeleteAccountDialog),
                ]),

                const SizedBox(height: 30),
                const Text('Nova Live v1.0.0', style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 1)),
                const SizedBox(height: 30),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, {IconData? icon}) {
    return Column(
      children: [
        Row(
          children: [
            if (icon != null) ...[Icon(icon, color: Colors.cyanAccent, size: 16), const SizedBox(width: 4)],
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
      ],
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Color iconColor, {required VoidCallback onTap}) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: iconColor, size: 18)),
          title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
          onTap: onTap,
        ),
      ],
    );
  }
}