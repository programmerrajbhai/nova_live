import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SafetyController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  var isProcessing = false.obs;

  // =========================================
  // 🔥 Universal Block System
  // =========================================
  Future<bool> blockUser(String targetUid) async {
    isProcessing.value = true;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String myUid = prefs.getString('uid') ?? '';

      // ১. ইউজার লগিন করা আছে কি না চেক
      if (myUid.isEmpty) {
        Get.snackbar('Error', 'Authentication error. Please re-login.', backgroundColor: Colors.redAccent, colorText: Colors.white);
        return false;
      }

      // ২. নিজেকে ব্লক করার চেষ্টা করছে কি না চেক
      if (myUid == targetUid) {
        Get.snackbar('Oops!', 'You cannot block yourself.', backgroundColor: Colors.orangeAccent, colorText: Colors.white);
        return false;
      }

      // ৩. ফায়ারবেসে ব্লক লিস্টে অ্যাড করা
      await _db
          .collection('users')
          .doc(myUid)
          .collection('blocked_users')
          .doc(targetUid)
          .set({
        'blockedAt': FieldValue.serverTimestamp(),
        'blockedUserId': targetUid,
      });

      // ৪. সেফ নেভিগেশন (ডায়ালগ বা বটম শিট ওপেন থাকলে শুধু সেটা কাটবে)
      if (Get.isDialogOpen ?? false) Get.back();
      if (Get.isBottomSheetOpen ?? false) Get.back();

      Get.snackbar(
          'Blocked 🚫',
          'User has been blocked and removed from your view.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM
      );

      return true; // সাকসেস

    } catch (e) {
      debugPrint('Block Error: $e');
      Get.snackbar('Error', 'Failed to block user. Try again later.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  // =========================================
  // 🔥 Universal Report System
  // =========================================
  Future<bool> submitReport({
    required String reportedUserId,
    String? roomId,
    required String reason,
    required String details,
    required String source,
  }) async {
    isProcessing.value = true;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String myUid = prefs.getString('uid') ?? '';

      // ১. অথেনটিকেশন চেক
      if (myUid.isEmpty) {
        Get.snackbar('Error', 'Authentication error. Please re-login.', backgroundColor: Colors.redAccent, colorText: Colors.white);
        return false;
      }

      // ২. নিজেকে রিপোর্ট করছে কি না চেক
      if (myUid == reportedUserId) {
        Get.snackbar('Oops!', 'You cannot report yourself.', backgroundColor: Colors.orangeAccent, colorText: Colors.white);
        return false;
      }

      // ৩. ফায়ারবেসে রিপোর্ট সেভ করা
      await _db.collection('reports').add({
        'reporterId': myUid,
        'reportedUserId': reportedUserId,
        'roomId': roomId ?? '',
        'reason': reason,
        'details': details,
        'status': 'pending', // pending, reviewed, resolved
        'createdAt': FieldValue.serverTimestamp(),
        'source': source,
      });

      // ৪. সেফ নেভিগেশন
      if (Get.isDialogOpen ?? false) Get.back();
      if (Get.isBottomSheetOpen ?? false) Get.back();

      Get.snackbar(
        'Report Submitted ✅',
        'Our team will review this within 24 hours.',
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );

      return true; // সাকসেস

    } catch (e) {
      debugPrint('Report Error: $e');
      Get.snackbar('Error', 'Failed to submit report. Try again later.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } finally {
      isProcessing.value = false;
    }
  }
}