import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit/zego_uikit.dart';

class ActiveRoomController extends GetxController {
  var isMuted = true.obs;
  var showGiftAnimation = false.obs;
  var currentGiftIcon = Icons.card_giftcard.obs;
  Rx<Color> currentGiftColor = Rx<Color>(Colors.pinkAccent);

  void toggleMute() {
    isMuted.value = !isMuted.value;
    ZegoUIKit().turnMicrophoneOn(!isMuted.value);
  }

  void leaveRoom() {
    Get.back();
  }

  // 🔥 Coin deduction removed. Gift will be sent directly.
  void sendGift(String giftName, int cost, IconData icon, Color color) {
    currentGiftIcon.value = icon;
    currentGiftColor.value = color;
    showGiftAnimation.value = true;

    Get.snackbar(
      'Gift Sent! 🎁',
      'You sent a $giftName.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black87.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    Future.delayed(const Duration(seconds: 2), () {
      showGiftAnimation.value = false;
    });
  }
}