import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit/zego_uikit.dart';
import '../../profile/controller/profile_controller.dart';

class ActiveRoomController extends GetxController {
  var isMuted = true.obs;
  var showGiftAnimation = false.obs;
  var currentGiftIcon = Icons.card_giftcard.obs;
  Rx<Color> currentGiftColor = Rx<Color>(Colors.pinkAccent);

  final ProfileController profileController = Get.put(ProfileController());

  void toggleMute() {
    isMuted.value = !isMuted.value;
    ZegoUIKit().turnMicrophoneOn(!isMuted.value);
  }

  void leaveRoom() {
    Get.back();
  }

  void sendGift(String giftName, int cost, IconData icon, Color color) {
    bool isSuccess = profileController.deductCoins(cost);

    if (isSuccess) {
      currentGiftIcon.value = icon;
      currentGiftColor.value = color;
      showGiftAnimation.value = true;

      Get.snackbar(
        'Gift Sent! 🎁',
        'Remaining coins: ${profileController.myCoins.value}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black87.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      Future.delayed(const Duration(seconds: 2), () {
        showGiftAnimation.value = false;
      });
    } else {
      Get.snackbar(
        'Insufficient Coins 🚫',
        'Need $cost coins for $giftName.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}