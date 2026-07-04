import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ১. User Agreement (UGC Policy) Screen
class UserAgreementView extends StatelessWidget {
  const UserAgreementView({super.key});
  @override
  Widget build(BuildContext context) {
    return _buildLegalScreen('UGC Policy & Agreement', 'User Generated Content (UGC) Policy\n\n1. No Nudity or Sexual Content.\n2. No Hate Speech or Bullying.\n3. Respect all users in the live stream.\n4. Violating these rules will lead to a permanent device ban.\n\nBy using Nova Live, you agree to these terms completely.');
  }
}

// ২. Terms and Conditions Screen
class TermsConditionsView extends StatelessWidget {
  const TermsConditionsView({super.key});
  @override
  Widget build(BuildContext context) {
    return _buildLegalScreen('Terms & Conditions', 'Terms of Service\n\n1. Acceptance of Terms: You must be 18+ to use this app.\n2. Account Security: You are responsible for your account.\n3. Virtual Items: Coins and gifts hold no real-world value outside the platform.\n4. Termination: We reserve the right to suspend accounts without notice.');
  }
}

// ৩. Play Policy (Community Guidelines) Screen
class PlayPolicyView extends StatelessWidget {
  const PlayPolicyView({super.key});
  @override
  Widget build(BuildContext context) {
    return _buildLegalScreen('Community Guidelines', 'Community Guidelines\n\n1. Keep it safe and friendly.\n2. Do not share personal information.\n3. Report abusive behavior using the in-app reporting tool.\n4. We strictly follow Google Play Data Safety policies. You can request data deletion at any time from your profile.');
  }
}

// রিইউজেবল লিগ্যাল স্ক্রিন ডিজাইন
Widget _buildLegalScreen(String title, String content) {
  return Scaffold(
    backgroundColor: const Color(0xFF121212),
    appBar: AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.purpleAccent)),
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Get.back()),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Text(
        content,
        style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.6),
      ),
    ),
  );
}