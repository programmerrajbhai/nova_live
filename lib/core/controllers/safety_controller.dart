import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SafetyController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  var isProcessing = false.obs;

  // =========================================
  // 🔥 Universal Block System (Mutual & Unfollow)
  // =========================================
  Future<bool> blockUser(String targetUid) async {
    isProcessing.value = true;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String myUid = prefs.getString('uid') ?? '';

      if (myUid.isEmpty || myUid == targetUid) {
        Get.snackbar('Oops!', 'Action denied.', backgroundColor: Colors.orangeAccent, colorText: Colors.white);
        return false;
      }

      WriteBatch batch = _db.batch();

      // ১. আমার blocked_users লিস্টে অ্যাড করা
      DocumentReference myBlockRef = _db.collection('users').doc(myUid).collection('blocked_users').doc(targetUid);
      batch.set(myBlockRef, {
        'blockedAt': FieldValue.serverTimestamp(),
        'blockedUserId': targetUid,
      });

      // ২. তার blocked_by লিস্টে অ্যাড করা
      DocumentReference theirBlockedByRef = _db.collection('users').doc(targetUid).collection('blocked_by').doc(myUid);
      batch.set(theirBlockedByRef, {
        'blockedAt': FieldValue.serverTimestamp(),
        'blockedByUserId': myUid,
      });

      // ৩. Follower/Following রিলেশন রিমুভ করা (Block = Unfollow)
      DocumentReference myFollowingRef = _db.collection('users').doc(myUid).collection('following').doc(targetUid);
      DocumentReference theirFollowersRef = _db.collection('users').doc(targetUid).collection('followers').doc(myUid);

      DocumentReference theirFollowingRef = _db.collection('users').doc(targetUid).collection('following').doc(myUid);
      DocumentReference myFollowersRef = _db.collection('users').doc(myUid).collection('followers').doc(targetUid);

      DocumentSnapshot myFollowingDoc = await myFollowingRef.get();
      DocumentSnapshot theirFollowingDoc = await theirFollowingRef.get();

      if (myFollowingDoc.exists) {
        batch.delete(myFollowingRef);
        batch.delete(theirFollowersRef);
        batch.update(_db.collection('users').doc(myUid), {'following': FieldValue.increment(-1)});
        batch.update(_db.collection('users').doc(targetUid), {'followers': FieldValue.increment(-1)});
      }

      if (theirFollowingDoc.exists) {
        batch.delete(theirFollowingRef);
        batch.delete(myFollowersRef);
        batch.update(_db.collection('users').doc(targetUid), {'following': FieldValue.increment(-1)});
        batch.update(_db.collection('users').doc(myUid), {'followers': FieldValue.increment(-1)});
      }

      await batch.commit();

      if (Get.isBottomSheetOpen ?? false) Get.back();
      Get.snackbar(
          'Blocked',
          'User has been blocked and unfollowed.',
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
  // 🔥 Universal Report System (Standardized Schema + Cooldown)
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String myUid = prefs.getString('uid') ?? '';

      if (myUid.isEmpty || myUid == reportedUserId) {
        Get.snackbar('Error', 'Action denied.', backgroundColor: Colors.redAccent, colorText: Colors.white);
        return false;
      }

      // 🔥 Cooldown Check (ফলস রিপোর্ট প্রোটেকশন)
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
          } else {
            await _db.collection('users').doc(myUid).update({'reportCooldownUntil': FieldValue.delete()});
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

      Get.snackbar('Report Submitted', 'Our team will review this within 24 hours.', backgroundColor: Colors.orangeAccent, colorText: Colors.black, snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit report.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } finally {
      isProcessing.value = false;
    }
  }
}