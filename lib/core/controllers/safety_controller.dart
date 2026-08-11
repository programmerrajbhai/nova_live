import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SafetyController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var isProcessing = false.obs;

  // =========================================
  // 🔥 Universal Block System (Name Saved + Mutual Block)
  // =========================================
  // 🔥 Fixes #27: targetName প্যারামিটার যুক্ত করা হলো যাতে নাম সেভ হয়
  Future<bool> blockUser(String targetUid, {String targetName = 'User'}) async {
    isProcessing.value = true;
    try {
      String myUid = _auth.currentUser?.uid ?? '';

      if (myUid.isEmpty) {
        Get.snackbar('Error', 'User authentication failed.', backgroundColor: Colors.redAccent, colorText: Colors.white);
        return false;
      }

      if (targetUid.isEmpty || myUid == targetUid) {
        Get.snackbar('Oops!', 'You cannot block yourself.', backgroundColor: Colors.orangeAccent, colorText: Colors.black);
        return false;
      }

      WriteBatch batch = _db.batch();

      // ১. আমার blocked_users লিস্টে অ্যাড করা এবং নাম সেভ করা (Fixes #27)
      DocumentReference myBlockRef = _db.collection('users').doc(myUid).collection('blocked_users').doc(targetUid);
      batch.set(myBlockRef, {
        'blockedAt': FieldValue.serverTimestamp(),
        'blockedUserId': targetUid,
        'name': targetName, // 🔥 নাম ডেটাবেসে সেভ হচ্ছে
      });

      // ২. তার blocked_by লিস্টে অ্যাড করা (যাতে সে আমাকে আর না দেখতে পায়)
      DocumentReference theirBlockedByRef = _db.collection('users').doc(targetUid).collection('blocked_by').doc(myUid);
      batch.set(theirBlockedByRef, {
        'blockedAt': FieldValue.serverTimestamp(),
        'blockedByUserId': myUid,
      });

      // ৩. Forward Unfollow
      DocumentReference myFollowingRef = _db.collection('users').doc(myUid).collection('following').doc(targetUid);
      DocumentReference theirFollowersRef = _db.collection('users').doc(targetUid).collection('followers').doc(myUid);

      DocumentSnapshot myFollowingDoc = await myFollowingRef.get();

      if (myFollowingDoc.exists) {
        batch.delete(myFollowingRef);
        batch.delete(theirFollowersRef);
        batch.update(_db.collection('users').doc(myUid), {'following': FieldValue.increment(-1)});
        batch.update(_db.collection('users').doc(targetUid), {'followers': FieldValue.increment(-1)});
      }

      await batch.commit();

      if (Get.isBottomSheetOpen ?? false) Get.back();
      Get.snackbar(
          'Blocked',
          '$targetName has been blocked.', // 🔥 স্ন্যাকেবারে নাম দেখাবে
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM
      );
      return true;
    } catch (e) {
      debugPrint('Block Error: $e');
      Get.snackbar('Error', 'Failed to block user. Try again later.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  // =========================================
  // 🔥 Unblock User (Fixes #22 - Removes from both lists)
  // =========================================
  Future<bool> unblockUser(String targetUid) async {
    isProcessing.value = true;
    try {
      String myUid = _auth.currentUser?.uid ?? '';
      if (myUid.isEmpty || targetUid.isEmpty) return false;

      WriteBatch batch = _db.batch();

      // আমার blocked_users থেকে রিমুভ
      DocumentReference myBlockRef = _db.collection('users').doc(myUid).collection('blocked_users').doc(targetUid);
      batch.delete(myBlockRef);

      // অন্যের blocked_by থেকেও রিমুভ (Fixes #22)
      DocumentReference theirBlockedByRef = _db.collection('users').doc(targetUid).collection('blocked_by').doc(myUid);
      batch.delete(theirBlockedByRef);

      await batch.commit();

      Get.snackbar('Unblocked', 'User unblocked successfully.', backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to unblock user.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  // =========================================
  // 🔥 Universal Report System (Standardized Schema + Cooldown Fix)
  // =========================================
  Future<bool> submitReport({
    required String reportedUserId,
    String? roomId,
    String? messageId,
    required String reason,
    required String details,
    required String source,
  }) async {
    isProcessing.value = true;
    try {
      String myUid = _auth.currentUser?.uid ?? '';

      if (myUid.isEmpty || myUid == reportedUserId) {
        Get.snackbar('Error', 'Action denied.', backgroundColor: Colors.redAccent, colorText: Colors.white);
        return false;
      }

      // 🔥 Cooldown Check
      final userDoc = await _db.collection('users').doc(myUid).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>? ?? {};
        final dynamic cooldownData = userData['reportCooldownUntil'];

        if (cooldownData is Timestamp) {
          final cooldownUntil = cooldownData.toDate();
          if (cooldownUntil.isAfter(DateTime.now())) {
            final remaining = cooldownUntil.difference(DateTime.now());
            String remainingText = remaining.inDays >= 1 ? '${remaining.inDays} day(s)'
                : remaining.inHours >= 1 ? '${remaining.inHours} hour(s)'
                : '${remaining.inMinutes} minute(s)';

            Get.snackbar(
                'Reporting Temporarily Limited',
                'You can submit another report after $remainingText.',
                backgroundColor: Colors.orangeAccent,
                colorText: Colors.black,
                snackPosition: SnackPosition.BOTTOM
            );
            return false;
          }
        }
      }

      // 🔥 Standardized Schema
      await _db.collection('reports').add({
        'reporterId': myUid,
        'reportedUserId': reportedUserId,
        'roomId': roomId ?? '',
        'messageId': messageId ?? '',
        'reason': reason,
        'details': details,
        'source': source,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'reviewedAt': null,
        'reviewedBy': null,
        'actionTaken': null,
      });

      if (Get.isBottomSheetOpen ?? false) Get.back();
      if (Get.isDialogOpen ?? false) Get.back();

      Get.snackbar('Report Submitted', 'Our team will review this within 24 hours.', backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit report.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } finally {
      isProcessing.value = false;
    }
  }
}