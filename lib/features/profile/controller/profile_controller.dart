import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ProfileController extends GetxController {
  // ইউজারের ডেটা এবং ওয়ালেট স্টেট
  var myCoins = 500.obs; // বর্তমান কয়েন
  var totalEarnings = 1250.50.obs; // হোস্ট হিসেবে মোট ইনকাম (ডলারে)

  // পেআউট মেথড স্টেট
  var connectedPayoutMethod = 'PayPal'.obs; // ডিফল্ট পেআউট মেথড
  var isProcessing = false.obs; // লোডিং স্টেট ট্র্যাক করার জন্য

  @override
  void onInit() {
    super.onInit();
    // অ্যাপ ওপেন হলে সার্ভার থেকে লেটেস্ট ব্যালেন্স ফেচ করার লজিক এখানে কল হবে
    fetchUserWalletData();
  }

  // ১. ডেটাবেস থেকে ইউজারের ব্যালেন্স লোড করা
  Future<void> fetchUserWalletData() async {
    isProcessing.value = true;
    await Future.delayed(const Duration(seconds: 2)); // API কল সিমুলেশন
    // myCoins.value = response.data['coins']; (ভবিষ্যতে API থেকে আসবে)
    isProcessing.value = false;
  }

  // ২. ইন-অ্যাপ পারচেজ (Google Play Billing) থেকে কয়েন টপ-আপ করা
  Future<void> addCoins(int amount) async {
    isProcessing.value = true;

    // গুগল প্লে বিলিং ভেরিফিকেশনের জন্য ডামি ডিলে (Delay)
    await Future.delayed(const Duration(seconds: 1));

    myCoins.value += amount;
    isProcessing.value = false;
  }

  // ৩. গিফট পাঠানোর সময় কয়েন কাটা (ActiveRoomController এটি ব্যবহার করে)
  bool deductCoins(int amount) {
    if (myCoins.value >= amount) {
      myCoins.value -= amount;
      return true; // কয়েন পর্যাপ্ত থাকলে ট্রানজ্যাকশন সাকসেস
    }
    return false; // কয়েন না থাকলে ফেইল
  }

  // ৪. হোস্ট পেআউট / উইথড্র লজিক (ইনকাম তোলা)
  Future<void> requestWithdrawal(double amount) async {
    if (amount > totalEarnings.value) {
      Get.snackbar(
        'Invalid Amount',
        'You cannot withdraw more than your total earnings.',
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    isProcessing.value = true;

    // পেআউট প্রসেসিং সিমুলেশন (যেমন: PayPal API-তে রিকোয়েস্ট পাঠানো)
    Get.snackbar(
      'Processing Payout...',
      'Initiating transfer to ${connectedPayoutMethod.value}. Please wait.',
      backgroundColor: Colors.orangeAccent.withOpacity(0.9),
      colorText: Colors.black,
    );

    await Future.delayed(const Duration(seconds: 3)); // সার্ভার টাইম

    totalEarnings.value -= amount;
    isProcessing.value = false;

    Get.snackbar(
      'Withdrawal Successful ✅',
      '\$$amount has been sent to your ${connectedPayoutMethod.value} account.',
      backgroundColor: Colors.greenAccent.withOpacity(0.9),
      colorText: Colors.black,
      duration: const Duration(seconds: 4),
    );
  }

  // ৫. ডেটা ডিলিশন পলিসি (গুগল প্লে স্টোরের জন্য বাধ্যতামূলক)
  Future<void> deleteUserAccount() async {
    isProcessing.value = true;

    // ইউজারের সমস্ত ডেটা সার্ভার থেকে মুছে ফেলার API কল এখানে হবে
    await Future.delayed(const Duration(seconds: 2));

    // ডামি লগ-আউট এবং ক্লিয়ার ক্যাশ লজিক
    myCoins.value = 0;
    totalEarnings.value = 0.0;
    isProcessing.value = false;

    // ডিলিট হওয়ার পর অনবোর্ডিং বা লগ-ইন পেজে পাঠিয়ে দেওয়া
    // Get.offAll(() => OnboardingView());
  }
}