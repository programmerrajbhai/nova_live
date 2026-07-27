import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth/view/login_view.dart';
import '../main_nav/view/main_nav_view.dart';
import 'maintenance_view.dart'; // নতুন মেইনটেন্যান্স পেজ

class SplashController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // আপনার অ্যাপের বর্তমান ভার্সন (প্লে স্টোরে আপডেট দিলে এটিও বাড়াবেন)
  final String currentAppVersion = '1.0.0';
  final String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.nova.live'; // আপনার প্লে স্টোর লিংক দিন

  @override
  void onInit() {
    super.onInit();
    _checkAppConfig(); // অ্যাপ ওপেন হলেই আগে কনফিগারেশন চেক করবে
  }

  // ফায়ারবেস থেকে গ্লোবাল সেটিংস চেক করার লজিক
  Future<void> _checkAppConfig() async {
    try {
      DocumentSnapshot doc = await _db.collection('settings').doc('app_config').get();

      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        bool isMaintenanceMode = data['isMaintenanceMode'] ?? false;
        bool forceUpdate = data['forceUpdate'] ?? false;
        String latestVersion = data['appVersion'] ?? '1.0.0';

        // ১. মেইনটেন্যান্স মোড চেক
        if (isMaintenanceMode) {
          Get.offAll(() => const MaintenanceView(), transition: Transition.fadeIn);
          return;
        }

        // ২. ফোর্স আপডেট চেক (যদি ফায়ারবেসের ভার্সন বর্তমান ভার্সনের চেয়ে বড় হয়)
        if (forceUpdate && _isUpdateRequired(latestVersion, currentAppVersion)) {
          _showUpdateDialog();
          return;
        }
      }

      // ৩. সবকিছু ঠিক থাকলে সাধারণ লগইন স্ট্যাটাস চেক করবে
      _checkLoginStatus();

    } catch (e) {
      debugPrint("Splash Config Error: $e");
      // ইন্টারনেট না থাকলে বা এরর হলে স্বাভাবিকভাবে অ্যাপ চালু হবে
      _checkLoginStatus();
    }
  }

  // ভার্সন কম্পেয়ার করার সিম্পল লজিক
  bool _isUpdateRequired(String latest, String current) {
    return latest.compareTo(current) > 0;
  }

  // আপনার আগের লগইন স্ট্যাটাস চেকিং ফাংশন
  void _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      Get.offAll(() => MainNavView(), transition: Transition.fadeIn);
    } else {
      Get.offAll(() => LoginView(), transition: Transition.fadeIn);
    }
  }

  // ফোর্স আপডেট ডায়ালগ (ইউজার এটি স্কিপ করতে পারবে না)
  void _showUpdateDialog() {
    Get.defaultDialog(
      title: "Update Required",
      titleStyle: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 22),
      backgroundColor: const Color(0xFF1E1E1E),
      barrierDismissible: false, // বাইরে ক্লিক করলে কাটবে না
      onWillPop: () async => false, // ব্যাক বাটনে কাজ করবে না
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