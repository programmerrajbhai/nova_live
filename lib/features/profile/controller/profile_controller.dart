import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/view/login_view.dart';
import '../../auth/controller/auth_controller.dart';

class ProfileController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  var myUid = ''.obs;

  // Basic Info
  var userName = 'Loading...'.obs;
  var userAvatar = ''.obs;
  var userBio = 'Hello! I am using Nova Live.'.obs;
  var userLevel = 1.obs;

  // Social Stats
  var followersCount = 0.obs;
  var followingCount = 0.obs;

  // Wallet
  var myCoins = 0.obs;
  var receivedDiamonds = 0.obs;

  var isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUidAndFetchData();
  }

  Future<void> _loadUidAndFetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    myUid.value = prefs.getString('uid') ?? '';
    if (myUid.value.isNotEmpty) {
      fetchUserRealData();
    }
  }

  // 🔥 100% Real-time Sync with Firebase
  void fetchUserRealData() {
    isProcessing.value = true;
    try {
      if (myUid.value.isNotEmpty) {
        _db.collection('users').doc(myUid.value).snapshots().listen((doc) {
          if (doc.exists) {
            userName.value = doc['name'] ?? 'Nova User';
            userAvatar.value = doc['avatar'] ?? '';
            userBio.value = doc['bio'] ?? 'Hello! I am using Nova Live.';
            userLevel.value = doc['level'] ?? 1;
            myCoins.value = doc['coins'] ?? 0;
            receivedDiamonds.value = doc['receivedDiamonds'] ?? 0;
            followersCount.value = doc['followers'] ?? 0;
            followingCount.value = doc['following'] ?? 0;
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    } finally {
      isProcessing.value = false;
    }
  }

  // 📝 Update Profile Data (Name & Bio)
  Future<void> updateProfileDetails(String newName, String newBio) async {
    if (newName.isEmpty) {
      Get.snackbar('Error', 'Name cannot be empty.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isProcessing.value = true;
    try {
      if (myUid.value.isNotEmpty) {
        await _db.collection('users').doc(myUid.value).update({
          'name': newName.trim(),
          'bio': newBio.trim(),
        });
        Get.back(); // Close Edit Screen
        Get.snackbar('Success', 'Profile updated successfully!', backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isProcessing.value = false;
    }
  }

  // Wallet Top-Up
  Future<void> addCoins(int amount) async {
    isProcessing.value = true;
    myCoins.value += amount;
    if (myUid.value.isNotEmpty) {
      await _db.collection('users').doc(myUid.value).update({'coins': FieldValue.increment(amount)});
    }
    isProcessing.value = false;
  }

  // 🔥 Deduct Coins (Restored for Audio/Live Room Gifts)
  bool deductCoins(int amount) {
    if (myCoins.value >= amount) {
      myCoins.value -= amount;
      if (myUid.value.isNotEmpty) {
        _db.collection('users').doc(myUid.value).update({'coins': FieldValue.increment(-amount)});
      }
      return true;
    }
    return false;
  }

  // 🚪 Perfect Logout
  Future<void> logOut() async {
    isProcessing.value = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(myUid.value.isNotEmpty) {
      await _db.collection('users').doc(myUid.value).update({'isOnline': false});
    }
    await prefs.clear();
    if (Get.isRegistered<AuthController>()) Get.find<AuthController>().isAgreed.value = false;
    Get.offAll(() => LoginView(), transition: Transition.fadeIn);
    isProcessing.value = false;
  }

  // 🗑️ Delete Account
  Future<void> deleteUserAccount() async {
    isProcessing.value = true;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (myUid.value.isNotEmpty) {
        await _db.collection('users').doc(myUid.value).delete();
      }
      await prefs.clear();
      if (Get.isRegistered<AuthController>()) Get.find<AuthController>().isAgreed.value = false;
      Get.offAll(() => LoginView(), transition: Transition.fadeIn);
      Get.snackbar('Account Deleted', 'Your data has been removed permanently.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete account.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isProcessing.value = false;
    }
  }
}