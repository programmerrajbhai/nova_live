import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // 🔥 Firebase Storage Import

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
  var receivedDiamonds = 0.obs;

  var isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUidAndFetchData();
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
  // ⚙️ Core Profile Operations
  // =========================================
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
    if (myUid.value.isNotEmpty) {
      await _db.collection('users').doc(myUid.value).update({'isOnline': false});
    }
    await prefs.clear();
    await _auth.signOut();
    if (Get.isRegistered<AuthController>()) {
      Get.find<AuthController>().isAgreed.value = false;
    }
    Get.offAll(() => LoginView(), transition: Transition.fadeIn);
    isProcessing.value = false;
  }

  // =========================================
  // 🛑 100% COMPLETE ACCOUNT DELETION FLOW
  // =========================================
  Future<void> deleteUserAccount() async {
    String uid = myUid.value;
    if (uid.isEmpty) return;

    isProcessing.value = true;

    Get.snackbar(
      'Processing...',
      'Permanently deleting your account and data. This may take a moment.',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 8),
    );

    try {
      WriteBatch batch = _db.batch();
      int operationCount = 0;

      // 🔥 Batch Limit Handler (প্রতি ৪৫০ টি অপারেশনে একবার ফায়ারবেসে কমিট করবে)
      Future<void> commitBatchIfNeeded() async {
        if (operationCount >= 450) {
          await batch.commit();
          batch = _db.batch(); // নতুন ব্যাচ শুরু
          operationCount = 0;
        }
      }

      // 🧹 ১. Matchmaking/Searching Data ডিলিট
      DocumentReference searchRef = _db.collection('searching_users').doc(uid);
      batch.delete(searchRef);
      operationCount++;
      await commitBatchIfNeeded();

      // 🧹 ২. Blocked Users Subcollection ডিলিট
      QuerySnapshot blockedDocs = await _db.collection('users').doc(uid).collection('blocked_users').get();
      for (var doc in blockedDocs.docs) {
        batch.delete(doc.reference);
        operationCount++;
        await commitBatchIfNeeded();
      }

      // 🧹 ৩. Reports Anonymization
      QuerySnapshot reportsGiven = await _db.collection('reports').where('reporterId', isEqualTo: uid).get();
      for (var doc in reportsGiven.docs) {
        batch.update(doc.reference, {'reporterId': 'deleted_user'});
        operationCount++;
        await commitBatchIfNeeded();
      }
      QuerySnapshot reportsReceived = await _db.collection('reports').where('reportedUserId', isEqualTo: uid).get();
      for (var doc in reportsReceived.docs) {
        batch.update(doc.reference, {'reportedUserId': 'deleted_user'});
        operationCount++;
        await commitBatchIfNeeded();
      }

      // 🧹 ৪. Followers/Following Cleanup (অন্যদের লিস্ট থেকে এই আইডি রিমুভ)
      QuerySnapshot followingMe = await _db.collection('users').where('followers', arrayContains: uid).get();
      for (var doc in followingMe.docs) {
        batch.update(doc.reference, {'followers': FieldValue.arrayRemove([uid])});
        operationCount++;
        await commitBatchIfNeeded();
      }
      QuerySnapshot followedByMe = await _db.collection('users').where('following', arrayContains: uid).get();
      for (var doc in followedByMe.docs) {
        batch.update(doc.reference, {'following': FieldValue.arrayRemove([uid])});
        operationCount++;
        await commitBatchIfNeeded();
      }

      // 🧹 ৫. Chat Rooms & Messages Cleanup (Orphan Data রিমুভ)
      QuerySnapshot chats = await _db.collection('chat_rooms').where('participants', arrayContains: uid).get();
      for (var roomDoc in chats.docs) {
        // আগে চ্যাট রুমের ভেতরের সব মেসেজ সাব-কালেকশন ডিলিট করতে হবে
        QuerySnapshot messages = await roomDoc.reference.collection('messages').get();
        for (var msgDoc in messages.docs) {
          batch.delete(msgDoc.reference);
          operationCount++;
          await commitBatchIfNeeded();
        }
        // এরপর মেইন চ্যাট রুম ডিলিট
        batch.delete(roomDoc.reference);
        operationCount++;
        await commitBatchIfNeeded();
      }

      // 🧹 ৬. Firebase Storage Cleanup (Exact URL & Folder)
      try {
        // যদি ইউজারের প্রোফাইল পিকচার ফায়ারবেস স্টোরেজের হয়, তবে সরাসরি সেই লিংকের ছবিটা আগে ডিলিট করবে
        if (userAvatar.value.isNotEmpty && userAvatar.value.contains('firebasestorage.googleapis.com')) {
          final exactImageRef = FirebaseStorage.instance.refFromURL(userAvatar.value);
          await exactImageRef.delete();
        }
        // এরপর ইউজারের ফোল্ডারে থাকা বাকি সব মুছে ফেলবে
        final storageRef = FirebaseStorage.instance.ref().child('uploads/$uid');
        final listResult = await storageRef.listAll();
        for (var item in listResult.items) {
          await item.delete();
        }
      } catch (e) {
        debugPrint('Storage Cleanup skipped (No files found or no permission).');
      }

      // 🧹 ৭. Main User Document Delete
      DocumentReference userRef = _db.collection('users').doc(uid);
      batch.delete(userRef);
      operationCount++;

      // 🔥 ফাইনাল ব্যাচ কমিট (বাকি থাকা অপারেশনগুলো রান করবে)
      if (operationCount > 0) {
        await batch.commit();
      }

      // 🧹 ৮. Firebase Authentication Delete
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await currentUser.delete();
      }

      // 🧹 ৯. Local App Data Cleanup
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (Get.isRegistered<AuthController>()) {
        Get.find<AuthController>().isAgreed.value = false;
      }

      // লগিন পেজে নিয়ে যাওয়া
      Get.offAll(() => LoginView(), transition: Transition.fadeIn);
      Get.snackbar('Account Deleted', 'All your data has been permanently removed from our servers.', backgroundColor: Colors.redAccent, colorText: Colors.white);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        Get.snackbar('Security Alert', 'Please log out, log in again, and retry deleting your account.', backgroundColor: Colors.redAccent, colorText: Colors.white, duration: const Duration(seconds: 6));
      } else {
        Get.snackbar('Error', 'Auth Error: ${e.message}', backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Full Deletion Error: $e");
      Get.snackbar('Error', 'Failed to complete full deletion. Please try again.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isProcessing.value = false;
    }
  }
}