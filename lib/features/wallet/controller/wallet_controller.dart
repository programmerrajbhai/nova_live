import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class WalletController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var myUid = ''.obs;
  var myCoins = 0.obs;
  var isProcessing = false.obs;
  var canClaimDaily = false.obs;

  // অ্যাডমিন প্যানেল থেকে আসা উইথড্র লিমিট
  var minWithdrawalLimit = 5000.obs;

  RewardedAd? _rewardedAd;
  var isAdLoaded = false.obs;
  var isAdLoading = false.obs;
  final String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  @override
  void onInit() {
    super.onInit();
    _initWallet();
    _fetchAdminSettings(); // অ্যাডমিন সেটিংস ফেচ করা
  }

  Future<void> _fetchAdminSettings() async {
    try {
      DocumentSnapshot doc = await _db.collection('settings').doc('app_config').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        minWithdrawalLimit.value = data['minWithdrawal'] ?? 5000;
      }
    } catch (e) {
      debugPrint("Failed to fetch admin settings: $e");
    }
  }

  Future<void> _initWallet() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      myUid.value = currentUser.uid;
      _listenToWalletUpdates();
      loadRewardedAd();
    }
  }

  void _listenToWalletUpdates() {
    if (myUid.value.isNotEmpty) {
      _db.collection('users').doc(myUid.value).snapshots().listen((doc) {
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          myCoins.value = data['coins'] ?? 0;

          Timestamp? lastClaim = data['lastClaimTimestamp'] as Timestamp?;
          if (lastClaim == null) {
            canClaimDaily.value = true;
          } else {
            DateTime lastDate = lastClaim.toDate().toUtc();
            DateTime now = DateTime.now().toUtc();
            canClaimDaily.value = (lastDate.year != now.year || lastDate.month != now.month || lastDate.day != now.day);
          }
        }
      });
    }
  }

  // =========================================
  // Withdrawal (Cashout) Logic
  // =========================================
  Future<void> submitWithdrawRequest(String method, String accountDetails, int amountToWithdraw) async {
    if (myCoins.value < minWithdrawalLimit.value) {
      Get.snackbar('Alert', 'You need at least ${minWithdrawalLimit.value} coins to withdraw.', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (amountToWithdraw > myCoins.value) {
      Get.snackbar('Error', 'Insufficient balance.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isProcessing.value = true;
    try {
      await _db.runTransaction((transaction) async {
        DocumentReference userRef = _db.collection('users').doc(myUid.value);
        DocumentSnapshot userSnap = await transaction.get(userRef);
        if (!userSnap.exists) throw Exception("User not found");

        int currentCoins = userSnap.get('coins') ?? 0;
        if (currentCoins < amountToWithdraw) throw Exception("Insufficient coins");

        // ১. ব্যালেন্স কাটা
        transaction.update(userRef, {'coins': currentCoins - amountToWithdraw});

        // ২. ট্রানজেকশন হিস্ট্রি সেভ করা
        DocumentReference transactionRef = userRef.collection('coin_transactions').doc();
        transaction.set(transactionRef, {
          'type': 'withdrawal',
          'amount': -amountToWithdraw,
          'createdAt': FieldValue.serverTimestamp(),
          'source': 'cashout_request',
        });

        // ৩. অ্যাডমিন প্যানেলের জন্য Withdrawal Request তৈরি করা
        DocumentReference withdrawRef = _db.collection('withdrawals').doc();
        transaction.set(withdrawRef, {
          'uid': myUid.value,
          'amount': amountToWithdraw,
          'method': method,
          'accountDetails': accountDetails,
          'status': 'pending', // অ্যাডমিন পরে এটি actioned বা rejected করবে
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      Get.back(); // ডায়ালগ ক্লোজ
      Get.snackbar('Success', 'Withdrawal request submitted successfully!', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit request: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isProcessing.value = false;
    }
  }

  // ... (আপনার আগের Daily Check-in, AdMob এবং deductCoins এর কোডগুলো এখানে হুবহু থাকবে) ...
  // [যেহেতু আগের কোডে কোনো সমস্যা নেই, তাই ওগুলো অপরিবর্তিত রাখুন]

  Future<void> claimDailyReward() async {
    if (!canClaimDaily.value || myUid.value.isEmpty || isProcessing.value) return;
    isProcessing.value = true;
    try {
      await _db.runTransaction((transaction) async {
        DocumentReference userRef = _db.collection('users').doc(myUid.value);
        DocumentSnapshot userSnap = await transaction.get(userRef);
        if (!userSnap.exists) throw Exception("User not found");
        Timestamp? lastClaim = (userSnap.data() as Map<String, dynamic>).containsKey('lastClaimTimestamp')
            ? userSnap.get('lastClaimTimestamp') as Timestamp?
            : null;
        if (lastClaim != null) {
          DateTime lastDate = lastClaim.toDate().toUtc();
          DateTime now = DateTime.now().toUtc();
          if (lastDate.year == now.year && lastDate.month == now.month && lastDate.day == now.day) {
            throw Exception("Already claimed today");
          }
        }
        DocumentReference transactionRef = userRef.collection('coin_transactions').doc();
        transaction.update(userRef, {
          'coins': FieldValue.increment(30),
          'lastClaimTimestamp': FieldValue.serverTimestamp(),
        });
        transaction.set(transactionRef, {
          'type': 'daily_reward',
          'amount': 30,
          'createdAt': FieldValue.serverTimestamp(),
          'source': 'daily_check_in',
        });
      });
      Get.snackbar('Awesome! 🎁', 'You received 30 Daily Bonus Coins!', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to claim or already claimed today.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isProcessing.value = false;
    }
  }

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
      if (myUid.value.isEmpty || isProcessing.value) return;
      isProcessing.value = true;
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
        isProcessing.value = false;
      }
    });
  }

  Future<bool> deductCoins(int amount, {String purpose = 'gift_spend', String source = 'audio_room'}) async {
    if (myUid.value.isEmpty || isProcessing.value) return false;
    isProcessing.value = true;
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
      return true;
    } catch (e) {
      if (!e.toString().contains('Insufficient coins')) {
        Get.snackbar('Error', 'Transaction failed.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
      return false;
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