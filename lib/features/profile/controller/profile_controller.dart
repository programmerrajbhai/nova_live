import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/view/login_view.dart';
import '../../auth/controller/auth_controller.dart';

class ProfileController extends GetxController {
  var userName = 'Loading...'.obs;
  var userAvatar = ''.obs; // 🔥 অবতার লোড করার ভেরিয়েবল
  var myCoins = 500.obs;
  var totalEarnings = 1250.50.obs;
  var connectedPayoutMethod = 'PayPal'.obs;
  var isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    fetchUserWalletData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName.value = prefs.getString('userName') ?? 'Nova User';
    userAvatar.value = prefs.getString('userAvatar') ?? ''; // স্টোরেজ থেকে অবতার আনা
  }

  Future<void> fetchUserWalletData() async {
    isProcessing.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isProcessing.value = false;
  }

  Future<void> addCoins(int amount) async {
    isProcessing.value = true;
    await Future.delayed(const Duration(seconds: 1));
    myCoins.value += amount;
    isProcessing.value = false;
  }

  bool deductCoins(int amount) {
    if (myCoins.value >= amount) {
      myCoins.value -= amount;
      return true;
    }
    return false;
  }

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

  Future<void> logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    if (Get.isRegistered<AuthController>()) Get.find<AuthController>().isAgreed.value = false;
    Get.offAll(() => LoginView(), transition: Transition.fadeIn);
  }

  Future<void> deleteUserAccount() async {
    isProcessing.value = true;
    await Future.delayed(const Duration(seconds: 2));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    myCoins.value = 0;
    totalEarnings.value = 0.0;
    isProcessing.value = false;
    if (Get.isRegistered<AuthController>()) Get.find<AuthController>().isAgreed.value = false;
    Get.offAll(() => LoginView(), transition: Transition.fadeIn);
  }
}