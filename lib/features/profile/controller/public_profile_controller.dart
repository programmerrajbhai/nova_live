import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/block_service.dart';

class PublicProfileController extends GetxController {
  final String targetUserId;

  PublicProfileController({required this.targetUserId});

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  var isLoading = true.obs;
  var isProfileUnavailable = false.obs;
  var userData = {}.obs;

  var isFollowing = false.obs;
  var followersCount = 0.obs;
  var followingCount = 0.obs;
  var currentUserId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
  }

  // 🔥 ডেটাবেস ক্র্যাশ ঠেকানোর জন্য সেফ পার্সার
  int _parseCount(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is List) return value.length;
    return 0;
  }

  Future<void> _loadProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      currentUserId.value = prefs.getString('uid') ?? '';

      if (currentUserId.value.isNotEmpty) {
        bool isBlocked = await BlockService.hasBlockBetween(currentUserId.value, targetUserId);
        if (isBlocked) {
          isProfileUnavailable.value = true;
          isLoading.value = false;
          return;
        }
      }

      DocumentSnapshot doc = await _db.collection('users').doc(targetUserId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        userData.value = data;

        // 🔥 BUG FIXED: সেফ কাউন্ট পার্সিং
        followersCount.value = _parseCount(data['followers']);
        followingCount.value = _parseCount(data['following']);
      }

      if (currentUserId.value.isNotEmpty) {
        DocumentSnapshot followDoc = await _db
            .collection('users')
            .doc(targetUserId)
            .collection('followers')
            .doc(currentUserId.value)
            .get();
        isFollowing.value = followDoc.exists;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile data.', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFollow() async {
    if (currentUserId.value.isEmpty) {
      Get.snackbar('Error', 'Please login to follow.', backgroundColor: const Color(0xFFE94560), colorText: Get.theme.colorScheme.onPrimary);
      return;
    }

    bool currentlyFollowing = isFollowing.value;
    isFollowing.value = !currentlyFollowing;

    // UI তে ইনস্ট্যান্ট আপডেটের জন্য
    followersCount.value += currentlyFollowing ? -1 : 1;

    try {
      WriteBatch batch = _db.batch();

      DocumentReference targetFollowersRef = _db.collection('users').doc(targetUserId).collection('followers').doc(currentUserId.value);
      DocumentReference myFollowingRef = _db.collection('users').doc(currentUserId.value).collection('following').doc(targetUserId);
      DocumentReference targetUserRef = _db.collection('users').doc(targetUserId);
      DocumentReference myUserRef = _db.collection('users').doc(currentUserId.value);

      if (currentlyFollowing) {
        batch.delete(targetFollowersRef);
        batch.delete(myFollowingRef);
        batch.update(targetUserRef, {'followers': FieldValue.increment(-1)});
        batch.update(myUserRef, {'following': FieldValue.increment(-1)});
      } else {
        batch.set(targetFollowersRef, {'timestamp': FieldValue.serverTimestamp()});
        batch.set(myFollowingRef, {'timestamp': FieldValue.serverTimestamp()});
        batch.update(targetUserRef, {'followers': FieldValue.increment(1)});
        batch.update(myUserRef, {'following': FieldValue.increment(1)});
      }

      await batch.commit();
    } catch (e) {
      // ফেইল করলে UI আগের অবস্থায় নিয়ে যাবে
      followersCount.value += currentlyFollowing ? 1 : -1;
      isFollowing.value = currentlyFollowing;
      Get.snackbar('Error', 'Failed to update follow status.', backgroundColor: const Color(0xFFE94560), colorText: Get.theme.colorScheme.onPrimary);
    }
  }
}