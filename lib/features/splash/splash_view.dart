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
            // 🔥 Glowing Logo
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.35),
                    blurRadius: 45,
                    spreadRadius: 8,
                  ),
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.25),
                    blurRadius: 35,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Image.asset(
                    "assets/images/app_icon.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 35),

            const Text(
              "Nova Live",
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.3,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Connect • Stream • Enjoy",
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 15,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 45),

            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.purpleAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}