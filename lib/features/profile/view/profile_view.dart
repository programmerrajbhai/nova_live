import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../controller/profile_controller.dart';

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
      barrierDismissible: false,
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
      middleText: "This action cannot be undone. All your data, coins, and history will be permanently deleted from our servers.",
      middleTextStyle: const TextStyle(color: Colors.grey),
      backgroundColor: const Color(0xFF1E1E1E),
      barrierDismissible: false,
      textConfirm: "Delete Permanently",
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
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purpleAccent, fontSize: 24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.gear, color: Colors.white, size: 20),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // ১. ইউজার ইনফো সেকশন (ডায়নামিক নামসহ)
            // আপনার ProfileView এর build মেথডের ভেতরের প্রথম Center উইজেটটি নিচের কোড দিয়ে রিপ্লেস করুন:

            // ১. ইউজার ইনফো সেকশন (ডায়নামিক নাম ও অবতারসহ)
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(colors: [Colors.purpleAccent, Colors.cyanAccent]),
                          boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.5), blurRadius: 20)],
                        ),
                        child: Obx(() => CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFF1E1E1E),
                          // 🔥 যদি অবতার সিলেক্ট করে থাকে তবে ছবি দেখাবে, নাহলে ডিফল্ট আইকন
                          backgroundImage: controller.userAvatar.value.isNotEmpty
                              ? NetworkImage(controller.userAvatar.value)
                              : null,
                          child: controller.userAvatar.value.isEmpty
                              ? const Icon(FontAwesomeIcons.userAstronaut, size: 45, color: Colors.white)
                              : null,
                        )),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF121212), width: 3)),
                        child: const Icon(FontAwesomeIcons.camera, size: 14, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // স্টোরেজ থেকে পাওয়া আসল নাম শো করবে
                  Obx(() => Text(
                    controller.userName.value,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  )),

                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                    child: const Text('ID: 8472901 • Level 12', style: TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // ২. ওয়ালেট কার্ড (প্রিমিয়াম গ্রেডিয়েন্ট)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF232526), Color(0xFF141517)], begin: Alignment.topLeft, end: Alignment.bottomRight),
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
                      Obx(() => Row(
                        children: [
                          const Icon(FontAwesomeIcons.coins, color: Colors.orangeAccent, size: 28),
                          const SizedBox(width: 10),
                          Text(
                            '${controller.myCoins.value}',
                            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Colors.orangeAccent, Colors.deepOrangeAccent]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.orangeAccent.withOpacity(0.4), blurRadius: 10)],
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                      ),
                      onPressed: () {
                        controller.addCoins(100);
                        Get.snackbar('Recharge Successful', '100 Coins added to your wallet.', backgroundColor: Colors.green, colorText: Colors.white);
                      },
                      icon: const Icon(FontAwesomeIcons.plus, color: Colors.white, size: 16),
                      label: const Text('Top Up', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 25),

            // ৩. অ্যাপ ফিচারস ও পেআউট
            _buildMenuCard([
              _buildMenuItem(FontAwesomeIcons.moneyCheckDollar, 'Host Payouts & Withdraw', Colors.greenAccent, onTap: () {
                controller.requestWithdrawal(50.0);
              }),
              _buildMenuItem(FontAwesomeIcons.chartLine, 'My Earnings Analytics', Colors.blueAccent, onTap: () {}),
              _buildMenuItem(FontAwesomeIcons.gift, 'Received Gifts History', Colors.pinkAccent, onTap: () {}),
            ]),
            const SizedBox(height: 20),

            // ৪. লিগ্যাল এবং সেফটি
            _buildMenuCard([
              _buildMenuItem(FontAwesomeIcons.shieldHeart, 'Community Guidelines', Colors.cyanAccent, onTap: () {}),
              _buildMenuItem(FontAwesomeIcons.fileContract, 'Terms of Service', Colors.grey, onTap: () {}),
            ]),
            const SizedBox(height: 20),

            // ৫. অ্যাকাউন্ট অ্যাকশনস (লগ-আউট এবং ডিলিট)
            _buildMenuCard([
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(FontAwesomeIcons.rightFromBracket, color: Colors.orangeAccent, size: 18),
                ),
                title: const Text('Log Out', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                onTap: _showLogoutDialog,
              ),
              const Divider(color: Colors.white10, height: 1, indent: 60, endIndent: 20),

              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(FontAwesomeIcons.trash, color: Colors.redAccent, size: 18),
                ),
                title: const Text('Delete Account', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                onTap: _showDeleteAccountDialog,
              ),
            ]),

            const SizedBox(height: 30),
            const Text('Nova Live v1.0.0', style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 1)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Color iconColor, {required VoidCallback onTap}) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
          onTap: onTap,
        ),
        const Divider(color: Colors.white10, height: 1, indent: 65, endIndent: 20),
      ],
    );
  }
}