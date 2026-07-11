import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SafetyController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  var isProcessing = false.obs;

  // 🔥 ১. Universal Block System
  Future<void> blockUser(String targetUid) async {
    isProcessing.value = true;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String myUid = prefs.getString('uid') ?? '';

      if (myUid.isNotEmpty && targetUid.isNotEmpty) {
        // সবসময় এই একটাই স্কিমা ব্যবহার হবে পুরো অ্যাপে
        await _db
            .collection('users')
            .doc(myUid)
            .collection('blocked_users')
            .doc(targetUid)
            .set({
          'blockedAt': FieldValue.serverTimestamp(),
        });

        Get.snackbar('Blocked', 'User has been blocked successfully.', backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to block user.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isProcessing.value = false;
    }
  }

  // 🔥 ২. Universal Report System
  Future<void> submitReport({
    required String reportedUserId,
    String? roomId,
    required String reason,
    required String details,
    required String source, // 'profile', 'audio_room', or 'chat'
  }) async {
    isProcessing.value = true;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String myUid = prefs.getString('uid') ?? '';

      if (myUid.isNotEmpty) {
        // সব রিপোর্ট একটাই reports কালেকশনে যাবে
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

        Get.snackbar('Report Submitted', 'We will review this within 24 hours.', backgroundColor: Colors.orangeAccent, colorText: Colors.black);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit report.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isProcessing.value = false;
    }
  }
}