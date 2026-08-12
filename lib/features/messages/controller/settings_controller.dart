import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/controllers/safety_controller.dart'; // 🔥 SafetyController ইম্পোর্ট করা হলো

class SettingsController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  var myUid = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUid();
  }

  Future<void> _loadUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    myUid.value = prefs.getString('uid') ?? '';
  }

  // 🚫 Blocked Users Stream
  Stream<QuerySnapshot> getBlockedUsers() {
    return _db.collection('users')
        .doc(myUid.value)
        .collection('blocked_users')
        .snapshots();
  }

  // 🚩 Reported Users Stream (Index Error এড়াতে orderBy বাদ দিয়ে লোকাল সর্ট করা হবে)
  Stream<QuerySnapshot> getReportedUsers() {
    return _db.collection('reports')
        .where('reporterId', isEqualTo: myUid.value)
        .snapshots();
  }

  // ✅ Unblock User Function (Fix: Centralized Unblock)
  Future<void> unblockUser(String blockedUserId, String userName) async {
    Get.back(); // কনফার্মেশন ডায়ালগ ক্লোজ করবে

    // 🔥 নিজের ডিলিট লজিক বাদ দিয়ে সরাসরি SafetyController কল করা হলো (এটি ২ জায়গা থেকেই ডিলিট করবে)
    final SafetyController safetyController = Get.put(SafetyController());
    await safetyController.unblockUser(blockedUserId);
  }

  // ↩️ Undo Report Function (PRO-LEVEL: Audit Trail / Soft Delete)
  Future<void> undoReport(String reportId) async {
    try {
      // ডিলিট না করে আপডেট করা হলো যাতে অ্যাডমিন প্যানেলে অডিট ট্রেইল থাকে
      await _db.collection('reports').doc(reportId).update({
        'status': 'withdrawn',
        'withdrawnAt': FieldValue.serverTimestamp(),
      });

      Get.back(); // কনফার্মেশন ডায়ালগ ক্লোজ করবে
      Get.snackbar(
        'Report Withdrawn ↩️',
        'Your report has been successfully canceled.',
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel report: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}