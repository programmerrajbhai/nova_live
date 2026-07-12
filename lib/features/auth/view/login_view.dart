import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/gestures.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../controller/auth_controller.dart';
import '../../legal/view/legal_views.dart';
import '../../../core/widgets/premium_background.dart'; // 🔥 Premium Background Import

class LoginView extends StatelessWidget {
  final AuthController controller = Get.put(AuthController());

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 PremiumBackground ব্যবহার করা হয়েছে
    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Scaffold কে ট্রান্সপারেন্ট করতে হবে
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // 🚀 লোগো ও ব্র্যান্ডিং
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.purpleAccent.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(color: Colors.purpleAccent.withOpacity(0.2), blurRadius: 40, spreadRadius: 10)
                    ],
                  ),
                  child: const Icon(FontAwesomeIcons.satelliteDish, size: 80, color: Colors.purpleAccent),
                ),
                const SizedBox(height: 30),

                const Text(
                    'Nova Live',
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.5)
                ),
                const SizedBox(height: 10),
                const Text(
                    'Find matches & make friends instantly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16)
                ),

                const Spacer(),

                // 🔥 100% Policy-Proof: UGC Agreement Checkbox
                Obx(() => Container(
                  decoration: BoxDecoration(
                    color: controller.isAgreed.value ? Colors.purpleAccent.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: controller.isAgreed.value ? Colors.purpleAccent : Colors.grey.withOpacity(0.3)),
                  ),
                  child: CheckboxListTile(
                    value: controller.isAgreed.value,
                    onChanged: controller.toggleAgreement,
                    activeColor: Colors.purpleAccent,
                    checkColor: Colors.white,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    title: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.5),
                        children: [
                          const TextSpan(text: "I am 18+ and I agree to the "),
                          TextSpan(
                            text: "Community Guidelines",
                            style: const TextStyle(color: Colors.purpleAccent, decoration: TextDecoration.underline, fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()..onTap = () => Get.to(() => const PlayPolicyView()),
                          ),
                          const TextSpan(text: ",\n"),
                          TextSpan(
                            text: "UGC Policy",
                            style: const TextStyle(color: Colors.purpleAccent, decoration: TextDecoration.underline, fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()..onTap = () => Get.to(() => const UserAgreementView()),
                          ),
                          const TextSpan(text: ", and "),
                          TextSpan(
                            text: "Terms of Service",
                            style: const TextStyle(color: Colors.purpleAccent, decoration: TextDecoration.underline, fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()..onTap = () => Get.to(() => const TermsConditionsView()),
                          ),
                          const TextSpan(text: "."),
                        ],
                      ),
                    ),
                  ),
                )),
                const SizedBox(height: 25),

                // ⚡ মেইন One Tap Login (Anonymous) বাটন
                Obx(() => GestureDetector(
                  onTap: controller.isLoading.value ? null : controller.onOneTapLoginClicked,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Colors.purpleAccent, Colors.deepPurple]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.purpleAccent.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 5))
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (controller.isLoading.value)
                          const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        else ...[
                          const Icon(Icons.bolt, color: Colors.yellowAccent, size: 28),
                          const SizedBox(width: 10),
                          const Text('One Tap Login', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ]
                      ],
                    ),
                  ),
                )),

                const SizedBox(height: 20),

                // 🌐 সোশ্যাল অপশনস (Google Active, Others Dummy)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 🔥 Working Google Sign-In Button
                    _buildSmallSocialBtn(
                        icon: FontAwesomeIcons.google,
                        color: Colors.redAccent,
                        onTap: () => controller.signInWithGoogle()
                    ),
                    const SizedBox(width: 20),
                    // Apple & Facebook Dummy Buttons
                    _buildSmallSocialBtn(
                        icon: FontAwesomeIcons.apple,
                        color: Colors.white,
                        onTap: () => _showComingSoon('Apple Login')
                    ),
                    const SizedBox(width: 20),
                    _buildSmallSocialBtn(
                        icon: FontAwesomeIcons.facebookF,
                        color: Colors.blueAccent,
                        onTap: () => _showComingSoon('Facebook Login')
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 Social Button Builder (Dynamic OnTap)
  Widget _buildSmallSocialBtn({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.withOpacity(0.2))
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  // 🛑 Dummy Action for Apple/Facebook
  void _showComingSoon(String platform) {
    Get.snackbar(
      'Coming Soon',
      '$platform will be available in the next update!',
      backgroundColor: Colors.white.withOpacity(0.1),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}