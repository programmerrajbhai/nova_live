import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/onboarding_controller.dart';

class OnboardingView extends StatelessWidget {
  // GetX কন্ট্রোলার ইনিশিয়ালাইজ করা হলো
  final OnboardingController controller = Get.put(OnboardingController());

  OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // টপ আইকন / লোগো (সেফটি বোঝানোর জন্য)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.purpleAccent.withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.security_rounded,
                  size: 100,
                  color: Colors.purpleAccent,
                ),
              ),
              const SizedBox(height: 40),

              // ওয়েলকাম টেক্সট
              const Text(
                'Welcome to Nova Live',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // পলিসি ওয়ার্নিং (গুগল প্লে স্টোরের জন্য বাধ্যতামূলক)
              const Text(
                'To ensure a safe and friendly environment, we strictly prohibit nudity, violence, and harassment. Any violations will result in an immediate and permanent ban.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // চেকবক্স (Obx দিয়ে রিয়েক্টিভ করা হয়েছে)
              Obx(() => Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: controller.isAgreed.value ? Colors.purpleAccent : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: CheckboxListTile(
                  title: const Text(
                    "I agree to the Community Guidelines & Terms of Service.",
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  value: controller.isAgreed.value,
                  onChanged: controller.toggleAgreement,
                  activeColor: Colors.purpleAccent,
                  checkColor: Colors.white,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              )),

              const Spacer(),

              // কন্টিনিউ বাটন
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    shadowColor: Colors.purpleAccent.withOpacity(0.5),
                  ),
                  onPressed: controller.continueToApp,
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}