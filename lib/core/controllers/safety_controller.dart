import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SafetyController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  var isProcessing = false.obs;

  // 🔥 Universal Block System
  Future<void> blockUser(String targetUid) async {
    isProcessing.value = true;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String myUid = prefs.getString('uid') ?? '';

      if (myUid.isNotEmpty && targetUid.isNotEmpty) {
        // স্ট্যান্ডার্ড স্কিমা: users/{myUid}/blocked_users/{targetUid}
        await _db
            .collection('users')
            .doc(myUid)
            .collection('blocked_users')
            .doc(targetUid)
            .set({
          'blockedAt': FieldValue.serverTimestamp(),
        });

        Get.back(); // Close the BottomSheet or Dialog
        Get.snackbar('Blocked 🚫', 'User has been blocked and removed from your view.',
            backgroundColor: Colors.redAccent, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to block user.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isProcessing.value = false;
    }
  }

  // 🔥 Universal Report System
  Future<void> submitReport({
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

      if (myUid.isNotEmpty) {
        // স্ট্যান্ডার্ড স্কিমা: reports/{reportId}
        await _db.collection('reports').add({
          'reporterId': myUid,
          'reportedUserId': reportedUserId,
          'roomId': roomId ?? '',
          'reason': reason,
          'details': details,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
          'source': source,
        });

        Get.back(); // Close Report Dialog
        Get.back(); // Close Profile Sheet
        Get.snackbar('Report Submitted ✅', 'Our team will review this within 24 hours.',
            backgroundColor: Colors.orangeAccent, colorText: Colors.black, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit report.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isProcessing.value = false;
    }
  }
}