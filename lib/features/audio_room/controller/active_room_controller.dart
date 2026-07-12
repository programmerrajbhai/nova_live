import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit/zego_uikit.dart';

import '../../profile/controller/profile_controller.dart';
import '../../wallet/controller/wallet_controller.dart'; // 🔥 Wallet Controller অ্যাড করা হলো

class ActiveRoomController extends GetxController {
  var isMuted = true.obs;
  var showGiftAnimation = false.obs;
  var currentGiftIcon = Icons.card_giftcard.obs;
  Rx<Color> currentGiftColor = Rx<Color>(Colors.pinkAccent);

  final ProfileController profileController = Get.put(ProfileController());
  final WalletController walletController = Get.put(WalletController()); // 🔥 Wallet Controller ইনিশিয়ালাইজ করা হলো

  void toggleMute() {
    isMuted.value = !isMuted.value;
    ZegoUIKit().turnMicrophoneOn(!isMuted.value);
  }

  void leaveRoom() {
    Get.back();
  }

  // 🔥 ফাংশনটি async করা হলো কারণ deductCoins এখন ডাটাবেসে রিয়েলটাইম আপডেট করে
  Future<void> sendGift(String giftName, int cost, IconData icon, Color color) async {
    // 🔥 profileController এর বদলে walletController ব্যবহার করা হলো
    bool isSuccess = await walletController.deductCoins(cost);

    if (isSuccess) {
      currentGiftIcon.value = icon;
      currentGiftColor.value = color;
      showGiftAnimation.value = true;

      Get.snackbar(
        'Gift Sent! 🎁',
        'Remaining coins: ${walletController.myCoins.value}', // 🔥 walletController থেকে কয়েন দেখানো হলো
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black87.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      Future.delayed(const Duration(seconds: 2), () {
        showGiftAnimation.value = false;
      });
    } else {
      // WalletController থেকেও একটি Error Snackbar আসবে, তাই এটি চাইলে মুছেও দিতে পারেন।
      // তবে নির্দিষ্ট গিফটের নাম দেখানোর জন্য এটি রাখা হলো।
      Get.snackbar(
        'Insufficient Coins 🚫',
        'Need $cost coins for $giftName.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}