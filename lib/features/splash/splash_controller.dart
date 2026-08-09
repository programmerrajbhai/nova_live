import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth/view/login_view.dart';
import '../main_nav/view/main_nav_view.dart';
import 'maintenance_view.dart';
import 'banned_view.dart'; // 🔥 এটি যুক্ত করা হয়েছে

class SplashController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
      _checkLoginStatus();
    } catch (e) {
      debugPrint("Splash Config Error: $e");
      _checkLoginStatus();
    }
  }

  bool _isUpdateRequired(String latest, String current) {
    return latest.compareTo(current) > 0;
  }

  // =========================================================
  // প্রফেশনাল লগইন চেক: SharedPreferences + Firebase Auth
  // =========================================================
  void _checkLoginStatus() async {
    await Future.delayed(const Duration(milliseconds: 300));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    User? currentUser = _auth.currentUser;

    if (isLoggedIn && currentUser != null) {
      try {
        DocumentSnapshot doc = await _db.collection('users').doc(currentUser.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data() as Map<String, dynamic>;
          bool isBanned = data['isBanned'] == true;

          if (isBanned) {
            Timestamp? bannedUntil = data['bannedUntil'] as Timestamp?;
            String banType = data['banType'] ?? 'permanent';
            String banReason = data['banReason'] ?? 'Violation of policies';

            // Logic: Permanent Ban
            if (banType == 'permanent' || bannedUntil == null) {
              Get.offAll(() => BannedView(banReason: banReason, banType: 'permanent'));
              return;
            }

            // Logic: Temporary Suspension
            DateTime unbanDate = bannedUntil.toDate();
            if (unbanDate.isAfter(DateTime.now())) {
              Get.offAll(() => BannedView(
                  banReason: banReason,
                  banType: 'temporary',
                  unbanDate: unbanDate.toString().split('.')[0]
              ));
              return;
            } else {
              // Logic: Automatic Unban
              await _db.collection('users').doc(currentUser.uid).update({
                'isBanned': false,
                'bannedUntil': FieldValue.delete(),
                'banType': FieldValue.delete(),
                'banReason': FieldValue.delete(),
              });
            }
          }
        }
      } catch (e) {
        debugPrint("Ban Check Error: $e");
      }
      Get.offAll(() => MainNavView(), transition: Transition.fadeIn);
    } else {
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