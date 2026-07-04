import 'package:get/get.dart';

class MainNavController extends GetxController {
  // বর্তমান সিলেক্টেড পেজের ইনডেক্স
  var currentIndex = 0.obs;

  // পেজ পরিবর্তন করার মেথড
  void changePage(int index) {
    currentIndex.value = index;
  }
}