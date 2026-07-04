import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../profile/controller/profile_controller.dart';

class ActiveRoomController extends GetxController {
  var isMuted = true.obs;

  // অ্যানিমেশন কন্ট্রোল করার ভেরিয়েবল
  var showGiftAnimation = false.obs;
  var currentGiftIcon = Icons.card_giftcard.obs;
// এখানে Rx<Color> ব্যবহার করে স্পষ্টভাবে টাইপ বলে দেওয়া হলো
  Rx<Color> currentGiftColor = Rx<Color>(Colors.pinkAccent);
  // ProfileController ইনিশিয়ালাইজ করা হলো (ডিপেন্ডেন্সি ইনজেকশন)
  final ProfileController profileController = Get.put(ProfileController());

  void toggleMute() {
    isMuted.value = !isMuted.value;
  }

  void leaveRoom() {
    Get.back();
  }

  // গিফট পাঠানোর মেইন মেথড
  void sendGift(String giftName, int cost, IconData icon, Color color) {
    // আগে চেক করবে প্রোফাইলে পর্যাপ্ত কয়েন আছে কি না
    bool isSuccess = profileController.deductCoins(cost);

    if (isSuccess) {
      // গিফট অ্যানিমেশন চালু করা
      currentGiftIcon.value = icon;
      currentGiftColor.value = color;
      showGiftAnimation.value = true;

      Get.snackbar(
        'Gift Sent! 🎁',
        'You sent $giftName. Remaining coins: ${profileController.myCoins.value}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // ২ সেকেন্ড পর অ্যানিমেশন বন্ধ করে দেওয়া
      Future.delayed(const Duration(seconds: 2), () {
        showGiftAnimation.value = false;
      });
    } else {
      // কয়েন না থাকলে ওয়ার্নিং
      Get.snackbar(
        'Insufficient Coins 🚫',
        'You need $cost coins to send $giftName. Please recharge.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        colorText: Colors.white,
      );
    }
  }
}