import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/widgets/premium_background.dart';
import 'legal_views.dart';

class SafetyCenterView extends StatelessWidget {
  const SafetyCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Safety Center', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(Icons.health_and_safety_rounded, color: Colors.greenAccent, size: 80),
            const SizedBox(height: 20),
            const Text(
              "Nova Safety Center",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "We are committed to providing a safe, respectful, and friendly environment. Please review our guidelines.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 30),
            _buildMenuCard([
              _buildMenuItem(FontAwesomeIcons.users, 'Community Guidelines', Colors.purpleAccent, () => Get.to(() => const PlayPolicyView())),
              _buildMenuItem(FontAwesomeIcons.childReaching, 'Child Safety Standards', Colors.redAccent, () => Get.to(() => const ChildSafetyView())),
              _buildMenuItem(FontAwesomeIcons.fileContract, 'Terms of Service', Colors.cyanAccent, () => Get.to(() => const TermsConditionsView())),
              _buildMenuItem(FontAwesomeIcons.userShield, 'Privacy Policy', Colors.blueAccent, () => Get.to(() => const PrivacyPolicyView())),
              _buildMenuItem(FontAwesomeIcons.commentDots, 'UGC Policy', Colors.orangeAccent, () => Get.to(() => const UserAgreementView())),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Color iconColor, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: iconColor, size: 18)),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
      onTap: onTap,
    );
  }
}