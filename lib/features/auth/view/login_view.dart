import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/gestures.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../controller/auth_controller.dart';
import '../../legal/view/legal_views.dart';
import '../../../core/widgets/premium_background.dart';

class LoginView extends StatelessWidget {
  final AuthController controller = Get.put(AuthController());

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
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

                // ⚡ One Tap Login (Guest/Anonymous)
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

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}