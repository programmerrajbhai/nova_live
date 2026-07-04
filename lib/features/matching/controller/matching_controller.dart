import 'package:get/get.dart';
// import '../view/call_view.dart'; // কল স্ক্রিন ইমপোর্ট (ভবিষ্যতে বানালে)

class MatchingController extends GetxController {
  var selectedFilter = 'Global'.obs;
  var isSearching = false.obs;

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;

    if (isSearching.value) {
      // ৩ সেকেন্ড পর ফেক সার্চিং শেষ করে অন্য পেজে নিয়ে যাওয়ার উদাহরণ
      Future.delayed(const Duration(seconds: 3), () {
        isSearching.value = false;
        // Get.to ব্যবহার করে নতুন পেজে যাওয়ার লজিক:
        // Get.to(() => const CallView(), transition: Transition.zoom);
        Get.snackbar('Success', 'Match Found! (Navigation logic goes here)');
      });
    }
  }
}