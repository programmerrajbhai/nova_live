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
  var isProcessing = false.obs; // 🔥 এই লক ভেরিয়েবলটি হ্যাকারদের আটকাবে

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

  // 🔄 Firebase থেকে রিয়েলটাইম কয়েন আপডেট
  void _listenToWalletUpdates() {
    if (myUid.value.isNotEmpty) {
      _db.collection('users').doc(myUid.value).snapshots().listen((doc) {
        if (doc.exists && doc.data() != null) {
          myCoins.value = doc.data()!['coins'] ?? 0;
        }
      });
    }
  }

  // =========================================
  // 🎁 Daily Check-in Logic (HACKER PROOF)
  // =========================================
  Future<void> _checkDailyRewardStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lastClaimDate = prefs.getString('last_daily_claim_${myUid.value}') ?? '';
    String todayDate = DateTime.now().toIso8601String().substring(0, 10);

    // যদি আজকের ডেট আর লাস্ট ক্লেইম ডেট না মেলে, তবেই বাটন অন হবে
    canClaimDaily.value = (lastClaimDate != todayDate);
  }

  Future<void> claimDailyReward() async {
    // 🔥 ১. Instant Lock: যদি অলরেডি প্রসেসিং চলে বা ক্লেইম করা থাকে, তবে সাথে সাথে রিটার্ন করবে!
    if (!canClaimDaily.value || myUid.value.isEmpty || isProcessing.value) return;

    // 🔥 ২. ক্লিক করার মিলি-সেকেন্ডের মধ্যে বাটন লক করে দেওয়া হলো!
    isProcessing.value = true;
    canClaimDaily.value = false;

    try {
      WriteBatch batch = _db.batch();
      DocumentReference userRef = _db.collection('users').doc(myUid.value);
      DocumentReference transactionRef = userRef.collection('coin_transactions').doc();

      // কয়েন যোগ করা
      batch.update(userRef, {'coins': FieldValue.increment(30)});

      // হিস্ট্রি লগ সেভ করা
      batch.set(transactionRef, {
        'type': 'daily_reward',
        'amount': 30,
        'createdAt': FieldValue.serverTimestamp(),
        'source': 'daily_check_in',
      });

      await batch.commit();

      // লোকাল স্টোরেজে আজকের ডেট সেভ করা
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String todayDate = DateTime.now().toIso8601String().substring(0, 10);
      await prefs.setString('last_daily_claim_${myUid.value}', todayDate);

      Get.snackbar('Awesome! 🎁', 'You received 30 Daily Bonus Coins!', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      // 🔥 ৩. যদি ইন্টারনেট না থাকার কারণে ফেইল হয়, তবে আবার ক্লেইম করার সুযোগ দেবে
      canClaimDaily.value = true;
      Get.snackbar('Error', 'Failed to claim reward. Try again.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      // প্রসেসিং শেষ
      isProcessing.value = false;
    }
  }

  // =========================================
  // 🎮 AdMob Rewarded Video Logic (HACKER PROOF)
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
    // 🔥 অ্যাড লোড না হলে বা প্রসেসিং চললে স্প্যাম ক্লিক আটকাবে
    if (_rewardedAd == null || !isAdLoaded.value || isProcessing.value) {
      Get.snackbar('Wait...', 'Video ad is not ready yet.', backgroundColor: Colors.orange, colorText: Colors.white);
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
      if (myUid.value.isEmpty || isProcessing.value) return; // ডাবল রিওয়ার্ড আটকানো

      isProcessing.value = true; // বাটন লক
      try {
        WriteBatch batch = _db.batch();
        DocumentReference userRef = _db.collection('users').doc(myUid.value);
        DocumentReference transactionRef = userRef.collection('coin_transactions').doc();

        batch.update(userRef, {'coins': FieldValue.increment(50)});
        batch.set(transactionRef, {
          'type': 'rewarded_ad',
          'amount': 50,
          'createdAt': FieldValue.serverTimestamp(),
          'source': 'admob',
        });

        await batch.commit();

        Get.snackbar('Congratulations! 🎉', 'You earned 50 Free Coins!', backgroundColor: Colors.purpleAccent, colorText: Colors.white);
      } finally {
        isProcessing.value = false; // বাটন আনলক
      }
    });
  }

  // =========================================
  // ⚙️ Deduct Coins (Transaction-Safe 100%)
  // =========================================
  Future<bool> deductCoins(int amount, {String purpose = 'gift_spend', String source = 'audio_room'}) async {
    // 🔥 ডাবল ট্যাপ বা স্প্যাম সেন্ড আটকানোর জন্য প্রসেসিং চেক
    if (myUid.value.isEmpty || isProcessing.value) return false;

    isProcessing.value = true; // ফাংশন লক
    try {
      await _db.runTransaction((transaction) async {
        final docRef = _db.collection('users').doc(myUid.value);
        final logRef = docRef.collection('coin_transactions').doc();

        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) throw Exception('User not found!');

        final int currentCoins = snapshot.data()?['coins'] ?? 0;

        if (currentCoins < amount) throw Exception('Insufficient coins');

        transaction.update(docRef, {'coins': currentCoins - amount});
        transaction.set(logRef, {
          'type': purpose,
          'amount': -amount,
          'createdAt': FieldValue.serverTimestamp(),
          'source': source,
        });
      });

      return true; // সাকসেস
    } catch (e) {
      if (e.toString().contains('Insufficient coins')) {
        debugPrint('Transaction Failed: Insufficient coins');
      } else {
        Get.snackbar('Error', 'Transaction failed.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
      return false;
    } finally {
      isProcessing.value = false; // ফাংশন আনলক
    }
  }

  @override
  void onClose() {
    _rewardedAd?.dispose();
    super.onClose();
  }
}