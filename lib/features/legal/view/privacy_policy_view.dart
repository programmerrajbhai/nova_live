import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/premium_background.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          title: const Text('Privacy Policy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to Nova Live!',
                style: TextStyle(color: Colors.purpleAccent, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Your privacy is critically important to us. This Privacy Policy explains how we collect, use, and protect your data.',
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 25),

              _buildPolicySection(
                '1. Camera & Gallery',
                'We require camera and gallery access strictly to allow users to upload or update their profile avatars and to participate in live video broadcasting (if applicable). We do not access your photos for any other purpose.',
              ),
              _buildPolicySection(
                '2. Microphone',
                'Microphone access is mandatory for participating in live audio rooms and voice matching calls. Your audio data is transmitted in real-time to facilitate communication and is never recorded or stored on our servers.',
              ),
              _buildPolicySection(
                '3. Firebase Data Usage',
                'We use Google Firebase for secure authentication and database management. Your display name, avatar, level, and chat history are securely stored in Firebase to provide a seamless app experience.',
              ),
              _buildPolicySection(
                '4. Real-time SDKs (Zego/Agora)',
                'To power our live audio and matching features, we integrate third-party SDKs like ZegoCloud or Agora. These services process media streams temporarily and comply with international data privacy standards.',
              ),
              _buildPolicySection(
                '5. Chat & UGC Moderation',
                'Nova Live maintains a zero-tolerance policy against inappropriate User Generated Content (UGC). Users can block offenders or report inappropriate behavior directly from the app. Our team reviews reports within 24 hours and bans violating accounts.',
              ),
              _buildPolicySection(
                '6. Account Deletion',
                'You have full control over your data. You can permanently delete your account and all associated data directly from the App Settings (Profile > Delete Account). Once deleted, this action cannot be undone.',
              ),
              _buildPolicySection(
                '7. Data Retention',
                'We retain your personal data (such as profile info and messages) only for as long as your account is active. Upon account deletion, all your data is instantly and permanently wiped from our active servers.',
              ),

              const SizedBox(height: 30),
              Center(
                child: Text(
                  'Last updated: 11 July, 2026',
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicySection(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}

