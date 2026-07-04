import 'package:get/get.dart';
import '../../main_nav/view/main_nav_view.dart'; // মেইন নেভ ভিউ ইমপোর্ট

class OnboardingController extends GetxController {
  var isAgreed = false.obs;

  void toggleAgreement(bool? value) {
    isAgreed.value = value ?? false;
  }

  void continueToApp() {
    if (isAgreed.value) {
      // Get.to এর বদলে Get.offAll, যাতে ব্যাক হিস্ট্রি ক্লিয়ার হয়ে যায়
      Get.offAll(() => MainNavView(), transition: Transition.fadeIn);
    } else {
      Get.snackbar(
        'Alert',
        'You must agree to the Terms & Safety Policy.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }
}