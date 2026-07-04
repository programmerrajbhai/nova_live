import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/view/login_view.dart';
import '../main_nav/view/main_nav_view.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    // অ্যাপ ওপেন হওয়ার পর ২ সেকেন্ড লোগো দেখানোর জন্য
    await Future.delayed(const Duration(seconds: 2));

    // স্টোরেজ চেক করা হচ্ছে
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // আপনার পছন্দ অনুযায়ী সরাসরি ক্লাসভিত্তিক নেভিগেশন (হিস্ট্রি ক্লিয়ার করার জন্য Get.offAll)
    if (isLoggedIn) {
      Get.offAll(() => MainNavView(), transition: Transition.fadeIn);
    } else {
      Get.offAll(() => LoginView(), transition: Transition.fadeIn);
    }
  }
}