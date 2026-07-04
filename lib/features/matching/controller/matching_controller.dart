import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../view/call_view.dart';

class MatchingController extends GetxController {
  // 🔥 আপনার UI এর জন্য প্রয়োজনীয় ভেরিয়েবলগুলো
  var isSearching = false.obs;
  var selectedFilter = 'Global'.obs;

  var myUid = ''.obs;
  var myName = 'User'.obs;

  StreamSubscription? _matchSubscription;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    _loadMyData();
  }

  // 🔥 ফিল্টার সেট করার মেথড
  void setFilter(String value) {
    selectedFilter.value = value;
  }

  // 🔥 বাটনে ক্লিক করলে সার্চ শুরু বা বন্ধ করার মেথড
  void toggleSearch() {
    if (isSearching.value) {
      stopMatching(); // সার্চিং চললে ক্লিক করলে বন্ধ হবে
    } else {
      startMatching(); // সার্চিং না চললে ক্লিক করলে শুরু হবে
    }
  }

  Future<void> _loadMyData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    myUid.value = prefs.getString('uid') ?? '';

    if (myUid.value.isNotEmpty) {
      DocumentSnapshot doc = await _db.collection('users').doc(myUid.value).get();
      if (doc.exists) {
        myName.value = doc['name'] ?? 'Nova User';
      }
    }
  }

  // ফায়ারবেসে ম্যাচ খোঁজার লজিক
  void startMatching() async {
    if (myUid.value.isEmpty) return;

    isSearching.value = true;

    var waitingUsers = await _db
        .collection('searching_users')
        .where('matchedWith', isNull: true)
        .limit(1)
        .get();

    if (waitingUsers.docs.isNotEmpty && waitingUsers.docs.first.id != myUid.value) {
      var targetDoc = waitingUsers.docs.first;
      String targetUid = targetDoc.id;

      String uniqueCallId = '${targetUid}_${myUid.value}';

      await _db.collection('searching_users').doc(targetUid).update({
        'matchedWith': myUid.value,
        'callId': uniqueCallId,
      });

      isSearching.value = false;
      Get.to(() => CallView(callId: uniqueCallId, userId: myUid.value, userName: myName.value));

    } else {
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
            String generatedCallId = data['callId'];

            _matchSubscription?.cancel();
            _db.collection('searching_users').doc(myUid.value).delete();

            isSearching.value = false;
            Get.to(() => CallView(callId: generatedCallId, userId: myUid.value, userName: myName.value));
          }
        }
      });
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