import 'package:flutter/material.dart';
import '../../../core/widgets/premium_background.dart';

class MaintenanceView extends StatelessWidget {
  const MaintenanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumBackground( // আপনার কোর প্রজেক্টের প্রিমিয়াম ব্যাকগ্রাউন্ড
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // অ্যানিমেটেড গিয়ার আইকন বা মেইনটেন্যান্স আইকন
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.orangeAccent.withOpacity(0.3), blurRadius: 40, spreadRadius: 10)
                    ],
                  ),
                  child: const Icon(Icons.build_circle_rounded, size: 90, color: Colors.orangeAccent),
                ),
                const SizedBox(height: 40),

                const Text(
                  'Under Maintenance',
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
                const SizedBox(height: 15),

                Text(
                  'We are currently upgrading our servers to provide you with a better experience. Nova Live will be back online shortly. Thank you for your patience!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15, height: 1.6),
                ),
                const SizedBox(height: 50),

                // সিম্পল লোডার
                const CircularProgressIndicator(color: Colors.orangeAccent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}