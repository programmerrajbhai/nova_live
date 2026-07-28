import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // প্রফেশনাল অথ চেকের জন্য যুক্ত করা হলো
import 'package:url_launcher/url_launcher.dart';

import '../auth/view/login_view.dart';
import '../main_nav/view/main_nav_view.dart';
import 'maintenance_view.dart';

class SplashController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // অথ ইনিশিয়ালাইজেশন

  final String currentAppVersion = '1.0.0';
  final String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.nova.live';

  @override
  void onInit() {
    super.onInit();
    _checkAppConfig();
  }

  Future<void> _checkAppConfig() async {
    try {
      DocumentSnapshot doc = await _db.collection('settings').doc('app_config').get();
      if (doc.exists && doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;
        bool isMaintenanceMode = data['isMaintenanceMode'] ?? false;
        bool forceUpdate = data['forceUpdate'] ?? false;
        String latestVersion = data['appVersion'] ?? '1.0.0';

        if (isMaintenanceMode) {
          Get.offAll(() => const MaintenanceView(), transition: Transition.fadeIn);
          return;
        }

        if (forceUpdate && _isUpdateRequired(latestVersion, currentAppVersion)) {
          _showUpdateDialog();
          return;
        }
      }
      // কনফিগ চেক শেষ, এবার লগইন স্ট্যাটাস চেক করবে (আপনার কোডে এটি কমেন্ট করা ছিল)
      _checkLoginStatus();
    } catch (e) {
      debugPrint("Splash Config Error: $e");
      // কোনো কারণে ফায়ারবেস এরর দিলেও অ্যাপ যেন আটকে না থাকে
      _checkLoginStatus();
    }
  }

  bool _isUpdateRequired(String latest, String current) {
    return latest.compareTo(current) > 0;
  }

  // =========================================================
  // প্রফেশনাল লগইন চেক: SharedPreferences + Firebase Auth (100% Policy Proof)
  // =========================================================
  void _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // স্প্ল্যাশ স্ক্রিন অ্যানিমেশন ডিলে

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    User? currentUser = _auth.currentUser; // ফায়ারবেস সেশন চেক

    // যদি লোকাল স্টোরেজ এবং ফায়ারবেস সেশন—উভয় জায়গাতেই ইউজার লগইন থাকে
    if (isLoggedIn && currentUser != null) {
      Get.offAll(() => MainNavView(), transition: Transition.fadeIn);
    } else {
      // সেশন এক্সপায়ার হলে বা নতুন ইউজার হলে লগইন পেজে যাবে
      Get.offAll(() => LoginView(), transition: Transition.fadeIn);
    }
  }

  void _showUpdateDialog() {
    Get.defaultDialog(
      title: "Update Required",
      titleStyle: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 22),
      backgroundColor: const Color(0xFF1E1E1E),
      barrierDismissible: false,
      onWillPop: () async => false,
      content: const Padding(
        padding: EdgeInsets.all(15.0),
        child: Text(
          "A new version of Nova Live is available. Please update the app to continue using it and enjoy new features.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 14),
        ),
      ),
      confirm: SizedBox(
        width: double.infinity,
        height: 45,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyanAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () async {
            if (await canLaunchUrl(Uri.parse(playStoreUrl))) {
              await launchUrl(Uri.parse(playStoreUrl), mode: LaunchMode.externalApplication);
            }
          },
          child: const Text("Update Now", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }
}