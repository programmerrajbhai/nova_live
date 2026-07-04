import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../controller/profile_controller.dart';

class ProfileView extends StatelessWidget {
  // Get.find এর বদলে Get.put ব্যবহার করা হলো এরর ফিক্স করার জন্য
  final ProfileController controller = Get.put(ProfileController());

  ProfileView({super.key});

  // গুগল প্লে ডেটা পলিসির জন্য অ্যাকাউন্ট ডিলিট ডায়ালগ
  void _showDeleteAccountDialog() {
    Get.defaultDialog(
      title: "Delete Account?",
      titleStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
      middleText: "This action cannot be undone. All your data, coins, and history will be permanently deleted from our servers as per Google Play's Data Safety Policy.",
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
        Get.snackbar(
          'Account Deleted',
          'Your data has been successfully removed.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        // অ্যাকাউন্ট ডিলিট করার মেথড কল
        controller.deleteUserAccount();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Profile & Wallet', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purpleAccent)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ১. ইউজার ইনফো সেকশন
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [Colors.purpleAccent, Colors.pinkAccent]),
                      boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.5), blurRadius: 20)],
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFF1E1E1E),
                      child: Icon(FontAwesomeIcons.userAstronaut, size: 50, color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, size: 14, color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            const Text('Super Host VIP', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('ID: 8472901 • Level 12', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 30),

            // ২. ওয়ালেট কার্ড (রিয়েল-টাইম ব্যালেন্স)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF232526), Color(0xFF141517)]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
                boxShadow: [BoxShadow(color: Colors.orangeAccent.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
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
                          const Icon(FontAwesomeIcons.coins, color: Colors.orangeAccent, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            '${controller.myCoins.value}',
                            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    ),
                    onPressed: () {
                      controller.addCoins(100);
                      Get.snackbar('Recharge Successful', '100 Coins added to your wallet.', backgroundColor: Colors.green, colorText: Colors.white);
                    },
                    icon: const Icon(Icons.add, color: Colors.black, size: 18),
                    label: const Text('Top Up', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 25),

            // ৩. অ্যাপ ফিচারস ও পেআউট (মেনু লিস্ট)
            _buildMenuCard([
              _buildMenuItem(FontAwesomeIcons.moneyCheckDollar, 'Host Payouts & Withdraw', Colors.greenAccent, onTap: () {
                // টেস্টিংয়ের জন্য পেআউট মেথড কল করা হলো
                controller.requestWithdrawal(50.0);
              }),
              _buildMenuItem(FontAwesomeIcons.chartLine, 'My Earnings Analytics', Colors.blueAccent, onTap: () {}),
              _buildMenuItem(FontAwesomeIcons.gifts, 'Received Gifts History', Colors.pinkAccent, onTap: () {}),
            ]),

            const SizedBox(height: 20),

            // ৪. লিগ্যাল এবং সেফটি (প্লে স্টোরের জন্য ম্যান্ডেটরি)
            _buildMenuCard([
              _buildMenuItem(FontAwesomeIcons.shieldHalved, 'Community Guidelines', Colors.cyanAccent, onTap: () {}),
              _buildMenuItem(FontAwesomeIcons.fileContract, 'Terms of Service', Colors.grey, onTap: () {}),
              // ডেটা ডিলিট বাটন (রেড অ্যালার্ট)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(FontAwesomeIcons.trashCan, color: Colors.redAccent, size: 20),
                ),
                title: const Text('Delete Account', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                onTap: _showDeleteAccountDialog,
              ),
            ]),

            const SizedBox(height: 30),
            const Text('Nova Live v1.0.0', style: TextStyle(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // রিইউজেবল মেনু কার্ড বিল্ডার
  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }

  // রিইউজেবল মেনু আইটেম বিল্ডার
  Widget _buildMenuItem(IconData icon, String title, Color iconColor, {required VoidCallback onTap}) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          onTap: onTap,
        ),
        const Divider(color: Colors.white10, height: 1, indent: 60, endIndent: 20),
      ],
    );
  }
}