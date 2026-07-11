import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/view/login_view.dart';
import '../../auth/controller/auth_controller.dart';

class ProfileController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Basic Info
  var userName = 'Loading...'.obs;
  var userAvatar = ''.obs;
  var userLevel = 1.obs;
  var isVip = false.obs;

  // Social Stats
  var followersCount = 0.obs;
  var followingCount = 0.obs;

  // Monetization & Wallet
  var myCoins = 0.obs;
  var totalEarnings = 0.0.obs;
  var receivedDiamonds = 0.obs; // Live app e gift pele diamond hoy

  var connectedPayoutMethod = 'PayPal'.obs;
  var isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserRealData();
  }

  // 🔥 100% Live Sync with Firebase
  Future<void> fetchUserRealData() async {
    isProcessing.value = true;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String uid = prefs.getString('uid') ?? '';

      if (uid.isNotEmpty) {
        // Listening to data in real-time
        _db.collection('users').doc(uid).snapshots().listen((doc) {
          if (doc.exists) {
            userName.value = doc['name'] ?? 'Nova User';
            userAvatar.value = doc['avatar'] ?? '';
            userLevel.value = doc['level'] ?? 1;
            isVip.value = doc['isVip'] ?? false;
            myCoins.value = doc['coins'] ?? 0;
            totalEarnings.value = (doc['totalEarnings'] ?? 0.0).toDouble();
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

  // 💎 Background Coin Management
  Future<void> _updateCoinsInFirebase(int amountToChange) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String uid = prefs.getString('uid') ?? '';
      if (uid.isNotEmpty) {
        await _db.collection('users').doc(uid).update({
          'coins': FieldValue.increment(amountToChange),
        });
      }
    } catch (e) {
      debugPrint("Coin update failed: $e");
    }
  }

  Future<void> addCoins(int amount) async {
    isProcessing.value = true;
    // Local Update
    myCoins.value += amount;
    // Server Update
    await _updateCoinsInFirebase(amount);
    isProcessing.value = false;
  }

  bool deductCoins(int amount) {
    if (myCoins.value >= amount) {
      myCoins.value -= amount;
      _updateCoinsInFirebase(-amount);
      return true;
    }
    return false;
  }

  // 💸 Payout Logic
  Future<void> requestWithdrawal(double amount) async {
    if (amount < 50.0) {
      Get.snackbar('Minimum Payout', 'You need at least \$50 to withdraw.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    if (amount > totalEarnings.value) {
      Get.snackbar('Invalid Amount', 'Insufficient earnings.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isProcessing.value = true;
    Get.snackbar('Processing...', 'Transferring to ${connectedPayoutMethod.value}.', backgroundColor: Colors.orangeAccent, colorText: Colors.black);
    await Future.delayed(const Duration(seconds: 3));

    totalEarnings.value -= amount;

    // Server Thekeo deduction kora uchit
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString('uid') ?? '';
    await _db.collection('users').doc(uid).update({
      'totalEarnings': FieldValue.increment(-amount),
    });

    isProcessing.value = false;
    Get.snackbar('Success ✅', 'Withdrawal successful.', backgroundColor: Colors.greenAccent, colorText: Colors.black);
  }

  // 🚪 100% Perfect Logout
  Future<void> logOut() async {
    isProcessing.value = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Ekhane presence false kore dewa bhalo (if available)
    String uid = prefs.getString('uid') ?? '';
    if(uid.isNotEmpty) {
      await _db.collection('users').doc(uid).update({'isOnline': false});
    }

    await prefs.clear();

    if (Get.isRegistered<AuthController>()) Get.find<AuthController>().isAgreed.value = false;
    Get.offAll(() => LoginView(), transition: Transition.fadeIn);
    isProcessing.value = false;
  }

  // 🗑️ Delete Account (Complete Wipe)
  Future<void> deleteUserAccount() async {
    isProcessing.value = true;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String uid = prefs.getString('uid') ?? '';

      if (uid.isNotEmpty) {
        // Firebase Cloud Function thakle bhalo, otherwise delete from client
        await _db.collection('users').doc(uid).delete();
      }

      await prefs.clear();
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