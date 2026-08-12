import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../splash/banned_view.dart'; // 🔥 BannedView ইম্পোর্ট করা হলো

class MainNavController extends GetxController {
  var currentIndex = 0.obs;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    _listenForSystemWarnings(); // 🔥 অ্যাপ চালু হলেই ওয়ার্নিং লিসেনার কাজ শুরু করবে
    _listenForBanStatus(); // 🔥 ২৩ নম্বর সমস্যা ফিক্স: রিয়েলটাইম ব্যান লিসেনার যুক্ত করা হলো
  }

  void changePage(int index) {
    currentIndex.value = index;
  }

  // ==========================================
  // 🔥 Realtime Ban Listener (Fixes #23)
  // ==========================================
  void _listenForBanStatus() {
    final user = _auth.currentUser;
    if (user == null) return;

    _db.collection('users').doc(user.uid).snapshots().listen((doc) {
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        bool isBanned = data['isBanned'] == true;

        if (isBanned) {
          Timestamp? bannedUntil = data['bannedUntil'] as Timestamp?;
          String banType = data['banType'] ?? 'permanent';
          String banReason = data['banReason'] ?? 'Violation of policies';

          // যদি পার্মানেন্ট ব্যান হয় অথবা তারিখ না থাকে
          if (banType == 'permanent' || bannedUntil == null) {
            Get.offAll(() => BannedView(banReason: banReason, banType: 'permanent'));
            return;
          }

          // যদি টেম্পোরারি ব্যান হয় এবং সময় পার না হয়ে থাকে
          DateTime unbanDate = bannedUntil.toDate();
          if (unbanDate.isAfter(DateTime.now())) {
            Get.offAll(() => BannedView(
                banReason: banReason,
                banType: 'temporary',
                unbanDate: unbanDate.toString().split('.')[0]
            ));
          }
        }
      }
    });
  }

  // ==========================================
  // 🔥 Official Warning Listener
  // ==========================================
  void _listenForSystemWarnings() {
    final user = _auth.currentUser;
    if (user == null) return;

    _db.collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('type', isEqualTo: 'system_warning')
        .where('isRead', isEqualTo: false) // শুধুমাত্র না-পড়া ওয়ার্নিংগুলো আনবে
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        final data = doc.data();
        _showWarningDialog(doc.id, data['body'] ?? 'You have received an official warning from moderation.');
      }
    });
  }

  void _showWarningDialog(String docId, String message) {
    if (Get.isDialogOpen ?? false) return; // একসাথে অনেকগুলো ডায়ালগ যেন ওপেন না হয়

    Get.defaultDialog(
      title: "⚠️ Official Warning",
      titleStyle: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 20),
      backgroundColor: const Color(0xFF1E1E1E),
      barrierDismissible: false, // বাইরে ক্লিক করে কাটার উপায় নেই
      onWillPop: () async => false, // ব্যাক বাটন দিয়েও কাটা যাবে না
      content: Column(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 50),
          const SizedBox(height: 15),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 20),
          const Text(
            "Please adhere to our Community Guidelines to avoid account suspension or a permanent ban.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      confirm: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orangeAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            // 🔥 'isRead' true করে দেওয়া হলো যেন ডায়ালগটি আর না দেখায়
            _db.collection('notifications').doc(docId).update({'isRead': true});
            Get.back();
          },
          child: const Text("I Understand", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}


