import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../auth/view/login_view.dart';
import '../../auth/controller/auth_controller.dart';

class ProfileController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var myUid = ''.obs;

  var userName = 'Loading...'.obs;
  var userAvatar = ''.obs;
  var userBio = 'Hello! I am using Nova Live.'.obs;
  var userLevel = 1.obs;

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

  // 🔥 ডেটাবেস থেকে যেকোনো টাইপের ডেটা আসুক না কেন, এটি ক্র্যাশ করা ঠেকাবে
  int _parseCount(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is List) return value.length; // যদি ভুল করে অ্যারে সেভ হয়ে থাকে, তবে তার সাইজ দেখাবে
    return 0;
  }

  void fetchUserRealData() {
    isProcessing.value = true;
    try {
      if (myUid.value.isNotEmpty) {
        _db.collection('users').doc(myUid.value).snapshots().listen((doc) {
          if (doc.exists && doc.data() != null) {
            final data = doc.data() as Map<String, dynamic>;

            userName.value = data['name'] ?? 'Nova User';
            userAvatar.value = data['avatar'] ?? '';
            userBio.value = data['bio'] ?? 'Hello! I am using Nova Live.';

            userLevel.value = _parseCount(data['level']) == 0 ? 1 : _parseCount(data['level']);
            receivedDiamonds.value = _parseCount(data['receivedDiamonds']);

            // 🔥 BUG FIXED: এখন আর টাইপ এরর খেয়ে কাউন্টার ক্র্যাশ করবে না
            followersCount.value = _parseCount(data['followers']);
            followingCount.value = _parseCount(data['following']);
          }
        }, onError: (e) {
          debugPrint("Snapshot Error: $e");
        });
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    } finally {
      isProcessing.value = false;
    }
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

    if (myUid.value.isNotEmpty) {
      try {
        await _db.collection('users').doc(myUid.value).update({'isOnline': false});
      } catch (e) {
        debugPrint("Status update failed: $e");
      }
    }

    String savedDeviceUid = prefs.getString('device_linked_uid') ?? '';
    await prefs.clear();

    if (savedDeviceUid.isNotEmpty) {
      await prefs.setString('device_linked_uid', savedDeviceUid);
    }

    User? currentUser = _auth.currentUser;
    if (currentUser != null && !currentUser.isAnonymous) {
      await _auth.signOut();
    }

    if (Get.isRegistered<AuthController>()) {
      Get.find<AuthController>().isAgreed.value = false;
    }

    Get.offAll(() => LoginView(), transition: Transition.fadeIn);
    isProcessing.value = false;
  }

  // =========================================
  // 🛑 COMPLETE ACCOUNT DELETION FLOW (Client-Side)
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

      Future<void> commitBatchIfNeeded() async {
        if (operationCount >= 450) {
          await batch.commit();
          batch = _db.batch();
          operationCount = 0;
        }
      }

      // 🧹 ১. Matchmaking/Searching Data
      DocumentReference searchRef = _db.collection('searching_users').doc(uid);
      batch.delete(searchRef);
      operationCount++;
      await commitBatchIfNeeded();

      // 🧹 ২. Blocked Users Subcollection
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

      // 🧹 ৪. Followers/Following Cleanup
      QuerySnapshot myFollowersDocs = await _db.collection('users').doc(uid).collection('followers').get();
      for (var doc in myFollowersDocs.docs) {
        String targetId = doc.id;
        batch.delete(_db.collection('users').doc(targetId).collection('following').doc(uid));
        batch.update(_db.collection('users').doc(targetId), {'following': FieldValue.increment(-1)});
        operationCount += 2;
        await commitBatchIfNeeded();
      }

      QuerySnapshot myFollowingDocs = await _db.collection('users').doc(uid).collection('following').get();
      for (var doc in myFollowingDocs.docs) {
        String targetId = doc.id;
        batch.delete(_db.collection('users').doc(targetId).collection('followers').doc(uid));
        batch.update(_db.collection('users').doc(targetId), {'followers': FieldValue.increment(-1)});
        operationCount += 2;
        await commitBatchIfNeeded();
      }

      // 🧹 ৫. Chat Rooms & Messages
      QuerySnapshot chats = await _db.collection('chat_rooms').where('participants', arrayContains: uid).get();
      for (var roomDoc in chats.docs) {
        QuerySnapshot messages = await roomDoc.reference.collection('messages').get();
        for (var msgDoc in messages.docs) {
          batch.delete(msgDoc.reference);
          operationCount++;
          await commitBatchIfNeeded();
        }
        batch.delete(roomDoc.reference);
        operationCount++;
        await commitBatchIfNeeded();
      }

      // 🧹 ৬. Firebase Storage Cleanup
      try {
        if (userAvatar.value.isNotEmpty && userAvatar.value.contains('firebasestorage.googleapis.com')) {
          final exactImageRef = FirebaseStorage.instance.refFromURL(userAvatar.value);
          await exactImageRef.delete();
        }
        final storageRef = FirebaseStorage.instance.ref().child('uploads/$uid');
        final listResult = await storageRef.listAll();
        for (var item in listResult.items) {
          await item.delete();
        }
      } catch (e) {
        debugPrint('Storage Cleanup skipped.');
      }

      // 🧹 ৭. Main User Document Delete
      DocumentReference userRef = _db.collection('users').doc(uid);
      batch.delete(userRef);
      operationCount++;

      if (operationCount > 0) {
        await batch.commit();
      }

      // 🧹 ৮. Firebase Auth & Local Data Cleanup
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await currentUser.delete();
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (Get.isRegistered<AuthController>()) {
        Get.find<AuthController>().isAgreed.value = false;
      }

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