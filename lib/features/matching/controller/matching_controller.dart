import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import '../../../core/services/block_service.dart'; // 🔥 BlockService ইম্পোর্ট করা হলো
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
      debugPrint("Chat room error handled safely: $e");
    }
  }

  // ==========================================
  // 🔥 BlockService ব্যবহার করে মিউচুয়াল ব্লক চেক
  // ==========================================
  Future<bool> canMatchWith(String targetUid) async {
    if (myUid.value.isEmpty || targetUid.isEmpty) return false;

    // যদি ব্লক থাকে তাহলে true রিটার্ন করবে, তাই ম্যাচ করতে false রিটার্ন করব
    bool isBlocked = await BlockService.hasBlockBetween(myUid.value, targetUid);
    return !isBlocked;
  }

  void startMatching() async {
    if (myUid.value.isEmpty) return;

    isSearching.value = true;

    try {
      var waitingUsers = await _db
          .collection('searching_users')
          .where('matchedWith', isNull: true)
          .limit(10)
          .get();

      bool matchFound = false;

      for (var targetDoc in waitingUsers.docs) {
        String targetUid = targetDoc.id;
        if (targetUid == myUid.value) continue;

        // 🔥 ব্লক থাকলে ম্যাচ স্কিপ করবে
        bool isSafeToMatch = await canMatchWith(targetUid);
        if (!isSafeToMatch) continue;

        bool success = await _db.runTransaction((transaction) async {
          DocumentReference targetRef = _db.collection('searching_users').doc(targetUid);
          DocumentSnapshot targetSnapshot = await transaction.get(targetRef);

          if (targetSnapshot.exists && targetSnapshot.get('matchedWith') == null) {
            String uniqueCallId = '${targetUid}_${myUid.value}';
            transaction.update(targetRef, {
              'matchedWith': myUid.value,
              'callId': uniqueCallId,
            });
            return true;
          }
          return false;
        });

        if (success) {
          matchFound = true;
          String uniqueCallId = '${targetUid}_${myUid.value}';

          Future.microtask(() => _createChatRoomSafe(targetUid));

          isSearching.value = false;
          Get.to(() => CallView(callId: uniqueCallId, userId: myUid.value, userName: myName.value));
          break;
        }
      }

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
      Get.snackbar('Error', 'Matching failed. Check your internet connection.');
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