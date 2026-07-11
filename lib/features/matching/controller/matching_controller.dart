import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../view/call_view.dart';

class MatchingController extends GetxController {
  var isSearching = false.obs;
  var selectedFilter = 'Global'.obs;

  var myUid = ''.obs;
  var myName = 'User'.obs;
  var myAvatar = ''.obs;

  StreamSubscription? _matchSubscription;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    _loadMyData();
  }

  void setFilter(String value) {
    selectedFilter.value = value;
  }

  void toggleSearch() {
    if (isSearching.value) {
      stopMatching();
    } else {
      startMatching();
    }
  }

  Future<void> _loadMyData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    myUid.value = prefs.getString('uid') ?? '';

    if (myUid.value.isNotEmpty) {
      DocumentSnapshot doc = await _db.collection('users').doc(myUid.value).get();
      if (doc.exists) {
        myName.value = doc['name'] ?? 'Nova User';
        myAvatar.value = doc['avatar'] ?? '';
      }
    }
  }

  // 🔥 মাস্টার সলিউশন: ব্যাকগ্রাউন্ডে সেফলি চ্যাট রুম তৈরি করবে
  Future<void> _createChatRoomSafe(String targetUid) async {
    try {
      DocumentSnapshot targetDoc = await _db.collection('users').doc(targetUid).get();
      if (targetDoc.exists) {
        String targetName = targetDoc['name'] ?? 'User';
        String targetAvatar = targetDoc['avatar'] ?? '';

        List<String> ids = [myUid.value, targetUid];
        ids.sort();
        String roomId = ids.join('_');

        await _db.collection('chat_rooms').doc(roomId).set({
          'participants': [myUid.value, targetUid],
          'lastUpdated': FieldValue.serverTimestamp(),
          'usersData': {
            myUid.value: {'name': myName.value, 'avatar': myAvatar.value},
            targetUid: {'name': targetName, 'avatar': targetAvatar},
          }
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print("Chat room error handled safely: $e");
    }
  }

  // 🚫 প্লে স্টোর পলিসি: ব্লক করা ইউজারদের ফিল্টার করার লজিক
  Future<bool> canMatchWith(String targetUid) async {
    if (myUid.value.isEmpty || targetUid.isEmpty) return false;

    try {
      // চেক ১: আমি তাকে ব্লক করেছি কিনা?
      final iBlocked = await _db
          .collection('users')
          .doc(myUid.value)
          .collection('blocked_users')
          .doc(targetUid)
          .get();

      // চেক ২: সে আমাকে ব্লক করেছে কিনা?
      final theyBlockedMe = await _db
          .collection('users')
          .doc(targetUid)
          .collection('blocked_users')
          .doc(myUid.value)
          .get();

      // যদি দুজনের কেউই ব্লক না করে থাকে, তবেই true রিটার্ন করবে
      return !iBlocked.exists && !theyBlockedMe.exists;
    } catch (e) {
      print("Error checking block status: $e");
      return false; // সেফটির জন্য এরর হলে ইউজারকে স্কিপ করবে
    }
  }

  // 🔄 স্মার্ট ম্যাচিং সিস্টেম
  void startMatching() async {
    if (myUid.value.isEmpty) return;
    isSearching.value = true;

    try {
      // একসাথে ১০ জনকে খুঁজবে, যাতে ব্লক করা ইউজার থাকলে স্কিপ করা যায়
      var waitingUsers = await _db
          .collection('searching_users')
          .where('matchedWith', isNull: true)
          .limit(10)
          .get();

      bool matchFound = false;

      // লুপ চালিয়ে একজন সেফ (আনব্লকড) ইউজার বের করা
      for (var targetDoc in waitingUsers.docs) {
        String targetUid = targetDoc.id;

        // নিজেকে নিজের সাথে কানেক্ট করা বন্ধ
        if (targetUid == myUid.value) continue;

        // 🔥 কানেক্ট করার আগে ব্লক লিস্ট চেক করা হচ্ছে!
        bool isSafeToMatch = await canMatchWith(targetUid);

        if (isSafeToMatch) {
          matchFound = true;
          String uniqueCallId = '${targetUid}_${myUid.value}';

          await _db.collection('searching_users').doc(targetUid).update({
            'matchedWith': myUid.value,
            'callId': uniqueCallId,
          });

          // ফায়ারবেসে চ্যাট রুম বানাচ্ছে ব্যাকগ্রাউন্ডে
          Future.microtask(() => _createChatRoomSafe(targetUid));

          isSearching.value = false;
          Get.to(() => CallView(callId: uniqueCallId, userId: myUid.value, userName: myName.value));

          break; // সেফ ইউজার পেলেই লুপ বন্ধ হয়ে যাবে
        }
      }

      // যদি সেফ কোনো ইউজার না পাওয়া যায়, তবে নিজেকে সার্চিং পুলে অ্যাড করবে
      if (!matchFound) {
        await _db.collection('searching_users').doc(myUid.value).set({
          'uid': myUid.value,
          'matchedWith': null,
          'callId': null,
          'timestamp': FieldValue.serverTimestamp(),
        });

        _matchSubscription = _db.collection('searching_users').doc(myUid.value).snapshots().listen((snapshot) {
          if (snapshot.exists) {
            var data = snapshot.data()!;
            if (data['matchedWith'] != null && data['callId'] != null) {
              String targetUid = data['matchedWith'];
              String generatedCallId = data['callId'];

              _matchSubscription?.cancel();
              _db.collection('searching_users').doc(myUid.value).delete();

              if (targetUid.isNotEmpty) {
                Future.microtask(() => _createChatRoomSafe(targetUid));
              }

              isSearching.value = false;
              Get.to(() => CallView(callId: generatedCallId, userId: myUid.value, userName: myName.value));
            }
          }
        });
      }
    } catch (e) {
      isSearching.value = false;
      Get.snackbar('Error', 'Matching failed. Check internet.');
    }
  }

  void stopMatching() {
    isSearching.value = false;
    _matchSubscription?.cancel();
    if (myUid.value.isNotEmpty) {
      _db.collection('searching_users').doc(myUid.value).delete();
    }
  }

  @override
  void onClose() {
    stopMatching();
    super.onClose();
  }
}