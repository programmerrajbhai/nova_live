import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🔥 Firebase Auth Import

import '../../auth/view/login_view.dart';
import '../../auth/controller/auth_controller.dart';

class ProfileController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // 🔥 Auth Instance
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
        Get.back();
        Get.snackbar('Success', 'Profile updated successfully!', backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> addCoins(int amount) async {
    isProcessing.value = true;
    myCoins.value += amount;
    if (myUid.value.isNotEmpty) {
      await _db.collection('users').doc(myUid.value).update({'coins': FieldValue.increment(amount)});
    }
    isProcessing.value = false;
  }

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

  Future<void> logOut() async {
    isProcessing.value = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(myUid.value.isNotEmpty) {
      await _db.collection('users').doc(myUid.value).update({'isOnline': false});
    }
    await prefs.clear();
    await _auth.signOut(); // 🔥 Sign out from Firebase Auth

    if (Get.isRegistered<AuthController>()) Get.find<AuthController>().isAgreed.value = false;
    Get.offAll(() => LoginView(), transition: Transition.fadeIn);
    isProcessing.value = false;
  }

  // 🗑️ 100% Perfect Account Deletion (Client Side)
  Future<void> deleteUserAccount() async {
    isProcessing.value = true;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      User? currentUser = _auth.currentUser;

      if (myUid.value.isNotEmpty) {
        // ১. ফায়ারবেস ডাটাবেস থেকে ইউজারের মেইন ডকুমেন্ট ডিলিট করা
        // (এটি ডিলিট হওয়ার সাথে সাথেই আমাদের ব্যাকএন্ড/Cloud Function বাকি সব ডেটা ডিলিট করে দেবে)
        await _db.collection('users').doc(myUid.value).delete();
      }

      // ২. Firebase Auth থেকে ইউজারকে পার্মানেন্টলি ডিলিট করা
      if (currentUser != null) {
        await currentUser.delete();
      }

      // ৩. লোকাল স্টোরেজ ক্লিয়ার করা
      await prefs.clear();
      myCoins.value = 0;

      if (Get.isRegistered<AuthController>()) Get.find<AuthController>().isAgreed.value = false;
      Get.offAll(() => LoginView(), transition: Transition.fadeIn);
      Get.snackbar('Account Deleted', 'Your account and data have been permanently removed.', backgroundColor: Colors.redAccent, colorText: Colors.white);

    } on FirebaseAuthException catch (e) {
      // 🔥 Security Feature: যদি অনেকদিন আগে লগিন করা থাকে, তবে গুগল আবার লগিন করতে বলে অ্যাকাউন্ট ডিলিট করার আগে।
      if (e.code == 'requires-recent-login') {
        Get.snackbar('Security Alert', 'Please log out and log in again to delete your account.', backgroundColor: Colors.orangeAccent, colorText: Colors.white, duration: const Duration(seconds: 5));
      } else {
        Get.snackbar('Error', 'Failed to delete account: ${e.message}', backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isProcessing.value = false;
    }
  }
}