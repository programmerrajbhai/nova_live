import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class WalletController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var myUid = ''.obs;
  var myCoins = 0.obs;
  var isProcessing = false.obs;

  // 🎁 Daily Reward Variables
  var canClaimDaily = false.obs;

  // 🎮 AdMob Variables
  RewardedAd? _rewardedAd;
  var isAdLoaded = false.obs;
  var isAdLoading = false.obs;

  // 🔥 AdMob Test ID (পাবলিশ করার আগে আসল ID দেবেন)
  final String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  @override
  void onInit() {
    super.onInit();
    _initWallet();
  }

  Future<void> _initWallet() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      myUid.value = currentUser.uid;
      _listenToWalletUpdates();
      _checkDailyRewardStatus();
      loadRewardedAd();
    }
  }

  // 🔄 Firebase থেকে রিয়েলটাইম কয়েন আপডেট
  void _listenToWalletUpdates() {
    _db.collection('users').doc(myUid.value).snapshots().listen((doc) {
      if (doc.exists && doc.data() != null) {
        myCoins.value = doc.data()!['coins'] ?? 0;
      }
    });
  }

  // =========================================
  // 🎁 Daily Check-in Logic
  // =========================================
  Future<void> _checkDailyRewardStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lastClaimDate = prefs.getString('last_daily_claim_${myUid.value}') ?? '';
    String todayDate = DateTime.now().toIso8601String().substring(0, 10);

    canClaimDaily.value = (lastClaimDate != todayDate);
  }

  Future<void> claimDailyReward() async {
    if (!canClaimDaily.value) return;

    isProcessing.value = true;
    try {
      await _db.collection('users').doc(myUid.value).update({
        'coins': FieldValue.increment(30)
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String todayDate = DateTime.now().toIso8601String().substring(0, 10);
      await prefs.setString('last_daily_claim_${myUid.value}', todayDate);

      canClaimDaily.value = false;
      Get.snackbar('Awesome! 🎁', 'You received 30 Daily Bonus Coins!', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to claim reward.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isProcessing.value = false;
    }
  }

  // =========================================
  // 🎮 AdMob Rewarded Video Logic
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
        },
        onAdFailedToLoad: (error) {
          isAdLoaded.value = false;
          isAdLoading.value = false;
          Future.delayed(const Duration(seconds: 15), () => loadRewardedAd());
        },
      ),
    );
  }

  void showRewardedAd() {
    if (_rewardedAd == null || !isAdLoaded.value) {
      Get.snackbar('Loading...', 'Video ad is still loading. Please wait.', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        isAdLoaded.value = false;
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        isAdLoaded.value = false;
        loadRewardedAd();
      },
    );

    _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) async {
      isProcessing.value = true;
      try {
        await _db.collection('users').doc(myUid.value).update({
          'coins': FieldValue.increment(50)
        });
        Get.snackbar('Congratulations! 🎉', 'You earned 50 Free Coins!', backgroundColor: Colors.purpleAccent, colorText: Colors.white);
      } finally {
        isProcessing.value = false;
      }
    });
  }

  // =========================================
  // ⚙️ Deduct Coins (For Gifts/Live Rooms)
  // =========================================
  Future<bool> deductCoins(int amount) async {
    if (myCoins.value >= amount) {
      await _db.collection('users').doc(myUid.value).update({'coins': FieldValue.increment(-amount)});
      return true;
    }
    Get.snackbar('Insufficient Coins', 'You do not have enough coins.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    return false;
  }

  @override
  void onClose() {
    _rewardedAd?.dispose();
    super.onClose();
  }
}