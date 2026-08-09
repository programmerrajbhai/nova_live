import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/block_service.dart'; // 🔥 BlockService ইমপোর্ট করা হলো

class PublicProfileController extends GetxController {
  final String targetUserId;

  PublicProfileController({required this.targetUserId});

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  var isLoading = true.obs;
  var isProfileUnavailable = false.obs; // 🔥 ব্লকড প্রোফাইলের জন্য নতুন ভেরিয়েবল
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

  Future<void> _loadProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      currentUserId.value = prefs.getString('uid') ?? '';

      if (currentUserId.value.isNotEmpty) {
        // 🔥 প্রোফাইল লোড করার আগেই মিউচুয়াল ব্লক চেক
        bool isBlocked = await BlockService.hasBlockBetween(currentUserId.value, targetUserId);
        if (isBlocked) {
          isProfileUnavailable.value = true;
          isLoading.value = false;
          return; // ব্লক থাকলে আর ডেটা লোড করবে না
        }
      }

      DocumentSnapshot doc = await _db.collection('users').doc(targetUserId).get();

      if (doc.exists) {
        userData.value = doc.data() as Map<String, dynamic>;
        followersCount.value = userData['followers'] ?? 0;
        followingCount.value = userData['following'] ?? 0;
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
      followersCount.value += currentlyFollowing ? 1 : -1;
      Get.snackbar('Error', 'Failed to update follow status.', backgroundColor: const Color(0xFFE94560), colorText: Get.theme.colorScheme.onPrimary);
    }
  }
}