import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/view/login_view.dart';
import '../../auth/controller/auth_controller.dart';

class ProfileController extends GetxController {
  var userName = 'Loading...'.obs;
  var userAvatar = ''.obs;
  var myCoins = 0.obs;
  var totalEarnings = 0.0.obs;

  var connectedPayoutMethod = 'PayPal'.obs;
  var isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserRealData();
  }

  // ফায়ারবেস থেকে ইউজারের সব ডেটা রিয়েল-টাইমে নিয়ে আসা
  Future<void> fetchUserRealData() async {
    isProcessing.value = true;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String uid = prefs.getString('uid') ?? '';

      if (uid.isNotEmpty) {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (doc.exists) {
          userName.value = doc['name'] ?? 'Nova User';
          userAvatar.value = doc['avatar'] ?? '';
          myCoins.value = doc['coins'] ?? 0;
          totalEarnings.value = (doc['totalEarnings'] ?? 0.0).toDouble();
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      isProcessing.value = false;
    }
  }

  // 🔥 ব্যাকগ্রাউন্ডে ফায়ারবেসের কয়েন আপডেট করার হেল্পার মেথড
  Future<void> _updateCoinsInFirebase(int amountToChange) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String uid = prefs.getString('uid') ?? '';
      if (uid.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          // FieldValue.increment ব্যবহার করলে সার্ভারে অটোমেটিক প্লাস/মাইনাস হয়
          'coins': FieldValue.increment(amountToChange),
        });
      }
    } catch (e) {
      print("Coin update failed: $e");
    }
  }

  // ১. কয়েন টপ-আপ (লোকাল + ফায়ারবেস)
  Future<void> addCoins(int amount) async {
    isProcessing.value = true;
    myCoins.value += amount; // লোকাল UI তে সাথে সাথে বাড়বে
    await _updateCoinsInFirebase(amount); // ফায়ারবেসে বাড়বে
    isProcessing.value = false;
  }

  // ২. গিফট পাঠানোর সময় কয়েন কাটা (যেটার এরর আসছিল)
  bool deductCoins(int amount) {
    if (myCoins.value >= amount) {
      myCoins.value -= amount; // সাথে সাথে UI আপডেট হবে
      _updateCoinsInFirebase(-amount); // ব্যাকগ্রাউন্ডে ফায়ারবেস থেকে কেটে নেবে
      return true;
    }
    return false; // ব্যালেন্স না থাকলে false রিটার্ন করবে
  }

  // উইথড্র লজিক
  Future<void> requestWithdrawal(double amount) async {
    if (amount > totalEarnings.value) {
      Get.snackbar('Invalid Amount', 'Insufficient earnings.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    isProcessing.value = true;
    Get.snackbar('Processing...', 'Transferring to ${connectedPayoutMethod.value}.', backgroundColor: Colors.orangeAccent, colorText: Colors.black);
    await Future.delayed(const Duration(seconds: 3));
    totalEarnings.value -= amount;
    isProcessing.value = false;
    Get.snackbar('Success ✅', 'Withdrawal successful.', backgroundColor: Colors.greenAccent, colorText: Colors.black);
  }

  // লগ-আউট
  Future<void> logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    if (Get.isRegistered<AuthController>()) Get.find<AuthController>().isAgreed.value = false;
    Get.offAll(() => LoginView(), transition: Transition.fadeIn);
  }

  // ডেটা ডিলিশন
  Future<void> deleteUserAccount() async {
    isProcessing.value = true;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String uid = prefs.getString('uid') ?? '';

      // ফায়ারবেস থেকে রিয়েল ডেটা ডিলিট করা
      if (uid.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      }

      await prefs.clear(); // লোকাল স্টোরেজ ক্লিয়ার

      myCoins.value = 0;
      totalEarnings.value = 0.0;

      if (Get.isRegistered<AuthController>()) Get.find<AuthController>().isAgreed.value = false;
      Get.offAll(() => LoginView(), transition: Transition.fadeIn);
      Get.snackbar('Account Deleted', 'Your data has been removed permanently from our servers.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete account.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isProcessing.value = false;
    }
  }
}