import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // 🔥 AdMob Import

import '../../auth/view/login_view.dart';
import '../../auth/controller/auth_controller.dart';

class ProfileController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var myUid = ''.obs;

  // Basic Info
  var userName = 'Loading...'.obs;
  var userAvatar = ''.obs;
  var userBio = 'Hello! I am using Nova Live.'.obs;
  var userLevel = 1.obs;

  // Social Stats
  var followersCount = 0.obs;
  var followingCount = 0.obs;

  // Wallet & Earnings
  var myCoins = 0.obs;
  var receivedDiamonds = 0.obs;

  var isProcessing = false.obs;

  // 🔥 AdMob & Daily Check-in Variables
  RewardedAd? _rewardedAd;
  var isAdLoaded = false.obs;
  var isAdLoading = false.obs;
  var canClaimDaily = false.obs;

  // গুগলের Test Ad ID (পাবলিশ করার আগে আপনার আসল ID বসাবেন)
  final String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  @override
  void onInit() {
    super.onInit();
    _loadUidAndFetchData();
    _checkDailyRewardStatus();
    loadRewardedAd();
  }

  Future<void> _loadUidAndFetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    myUid.value = prefs.getString('uid') ?? '';
    if (myUid.value.isNotEmpty) {
      fetchUserRealData();
    }
  }

  void fetchUserRealData() {
    isProcessing.value = true;
    try {
      if (myUid.value.isNotEmpty) {
        _db.collection('users').doc(myUid.value).snapshots().listen((doc) {
          if (doc.exists) {
            userName.value = doc['name'] ?? 'Nova User';
            userAvatar.value = doc['avatar'] ?? '';
            userBio.value = doc['bio'] ?? 'Hello! I am using Nova Live.';
            userLevel.value = doc['level'] ?? 1;
            myCoins.value = doc['coins'] ?? 0;
            receivedDiamonds.value = doc['receivedDiamonds'] ?? 0;
            followersCount.value = doc['followers'] ?? 0;
            followingCount.value = doc['following'] ?? 0;
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    } finally {
      isProcessing.value = false;
    }
  }

  // =========================================
  // 🎁 1. Daily Check-in Logic
  // =========================================
  Future<void> _checkDailyRewardStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lastClaimDate = prefs.getString('last_daily_claim') ?? '';
    String todayDate = DateTime.now().toIso8601String().substring(0, 10); // Format: YYYY-MM-DD

    if (lastClaimDate != todayDate) {
      canClaimDaily.value = true;
    } else {
      canClaimDaily.value = false;
    }
  }

  Future<void> claimDailyReward() async {
    if (!canClaimDaily.value) return;

    isProcessing.value = true;
    try {
      await addCoins(30); // ডেইলি বোনাস ৩০ কয়েন

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String todayDate = DateTime.now().toIso8601String().substring(0, 10);
      await prefs.setString('last_daily_claim', todayDate);

      canClaimDaily.value = false;
      Get.back(); // Bottom Sheet বন্ধ করবে
      Get.snackbar('Awesome! 🎁', 'You received 30 Daily Bonus Coins!', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to claim reward.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isProcessing.value = false;
    }
  }

  // =========================================
  // 🎮 2. AdMob Rewarded Video Logic
  // =========================================
  void loadRewardedAd() {
    isAdLoading.value = true;
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          isAdLoaded.value = true;
          isAdLoading.value = false;
          debugPrint("Ad Loaded successfully!");
        },
        onAdFailedToLoad: (error) {
          isAdLoaded.value = false;
          isAdLoading.value = false;
          debugPrint("Ad Failed to load: $error");
          // ১০ সেকেন্ড পর আবার ট্রাই করবে
          Future.delayed(const Duration(seconds: 10), () => loadRewardedAd());
        },
      ),
    );
  }

  void showRewardedAd() {
    if (_rewardedAd == null || !isAdLoaded.value) {
      Get.snackbar('Not Ready', 'Ad is still loading. Please try again in a few seconds.', backgroundColor: Colors.orangeAccent, colorText: Colors.white);
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => debugPrint('Ad showed fullscreen.'),
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        isAdLoaded.value = false;
        loadRewardedAd(); // পরবর্তী অ্যাড লোড করে রাখা
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        isAdLoaded.value = false;
        loadRewardedAd();
      },
    );

    _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) async {
      // 🚀 অ্যাড দেখা শেষ হলে ইউজারকে ৫০ কয়েন দেওয়া হবে
      await addCoins(50);
      Get.back(); // Bottom Sheet বন্ধ করবে
      Get.snackbar('Congratulations! 🎉', 'You earned 50 Free Coins for watching the video!', backgroundColor: Colors.purpleAccent, colorText: Colors.white, duration: const Duration(seconds: 4));
    });
  }

  // =========================================
  // ⚙️ Core Profile Operations
  // =========================================
// =========================================
  // ⚙️ Core Profile Operations
  // =========================================
  Future<void> addCoins(int amount) async {
    myCoins.value += amount;
    if (myUid.value.isNotEmpty) {
      await _db.collection('users').doc(myUid.value).update({'coins': FieldValue.increment(amount)});
    }
  }

  // 🔥 এই ফাংশনটি বসিয়ে দিন (যেটি মিসিং ছিল)
  bool deductCoins(int amount) {
    if (myCoins.value >= amount) {
      myCoins.value -= amount;
      if (myUid.value.isNotEmpty) {
        _db.collection('users').doc(myUid.value).update({'coins': FieldValue.increment(-amount)});
      }
      return true;
    }
    return false;
  }

  Future<void> updateProfileDetails(String newName, String newBio) async {
    if (newName.isEmpty) {
      Get.snackbar('Error', 'Name cannot be empty.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    isProcessing.value = true;
    try {
      if (myUid.value.isNotEmpty) {
        await _db.collection('users').doc(myUid.value).update({
          'name': newName.trim(),
          'bio': newBio.trim(),
        });
        Get.back();
        Get.snackbar('Success', 'Profile updated successfully!', backgroundColor: Colors.green, colorText: Colors.white);
      }
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> logOut() async {
    isProcessing.value = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(myUid.value.isNotEmpty) {
      await _db.collection('users').doc(myUid.value).update({'isOnline': false});
    }
    await prefs.clear();
    await _auth.signOut();
    if (Get.isRegistered<AuthController>()) Get.find<AuthController>().isAgreed.value = false;
    Get.offAll(() => LoginView(), transition: Transition.fadeIn);
    isProcessing.value = false;
  }

  Future<void> deleteUserAccount() async {
    isProcessing.value = true;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      User? currentUser = _auth.currentUser;
      if (myUid.value.isNotEmpty) {
        await _db.collection('users').doc(myUid.value).delete();
      }
      if (currentUser != null) await currentUser.delete();
      await prefs.clear();
      myCoins.value = 0;
      if (Get.isRegistered<AuthController>()) Get.find<AuthController>().isAgreed.value = false;
      Get.offAll(() => LoginView(), transition: Transition.fadeIn);
      Get.snackbar('Account Deleted', 'Your account has been permanently removed.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete account.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isProcessing.value = false;
    }
  }

  @override
  void onClose() {
    _rewardedAd?.dispose();
    super.onClose();
  }


}
