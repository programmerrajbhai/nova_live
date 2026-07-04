import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'splash_controller.dart';

class SplashView extends StatelessWidget {
  // কন্ট্রোলার কল করার সাথে সাথেই লগিন চেকিং শুরু হয়ে যাবে
  final SplashController controller = Get.put(SplashController());

  SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // গ্লোয়িং লোগো
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purpleAccent.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(color: Colors.purpleAccent.withOpacity(0.5), blurRadius: 40, spreadRadius: 10)
                ],
              ),
              child: const Icon(FontAwesomeIcons.satelliteDish, size: 80, color: Colors.purpleAccent),
            ),
            const SizedBox(height: 30),

            // অ্যাপের নাম
            const Text(
                'Nova Live',
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.5)
            ),
            const SizedBox(height: 40),

            // ছোট্ট লোডিং এনিমেশন
            const CircularProgressIndicator(color: Colors.purpleAccent),
          ],
        ),
      ),
    );
  }
}