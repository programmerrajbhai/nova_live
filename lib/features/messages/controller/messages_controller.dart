import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessagesController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  var myUid = ''.obs;
  var myName = ''.obs;
  var myAvatar = ''.obs;

  final messageController = TextEditingController();

  // 🔥 Search System Variables
  var isSearching = false.obs;
  var searchQuery = ''.obs;
  final searchController = TextEditingController();

  // 🚫 Blocked Users Tracking
  var blockedUsers = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMyData();
  }

  Future<void> _loadMyData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    myUid.value = prefs.getString('uid') ?? '';

    if (myUid.value.isNotEmpty) {
      DocumentSnapshot doc = await _db.collection('users').doc(myUid.value).get();
      if (doc.exists) {
        myName.value = doc['name'] ?? 'User';
        myAvatar.value = doc['avatar'] ?? '';
      }

      // 🔥 রিয়েল-টাইমে ব্লক করা ইউজারদের লিস্ট ফেচ করবে
      _db.collection('users').doc(myUid.value).collection('blocked_users').snapshots().listen((snapshot) {
        blockedUsers.value = snapshot.docs.map((d) => d.id).toList();
      });
    }
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchController.clear();
      searchQuery.value = '';
    }
  }

  Stream<QuerySnapshot> getInboxStream() {
    return _db.collection('chat_rooms').where('participants', arrayContains: myUid.value).snapshots();
  }

  Stream<QuerySnapshot> getChatMessages(String roomId) {
    return _db.collection('chat_rooms').doc(roomId).collection('messages').orderBy('timestamp', descending: true).snapshots();
  }

  String getTimeAgo(dynamic timeData) {
    if (timeData == null) return 'Just now';

    DateTime date;
    if (timeData is Timestamp) {
      date = timeData.toDate();
    } else if (timeData is int) {
      date = DateTime.fromMillisecondsSinceEpoch(timeData);
    } else {
      return 'Just now';
    }

    Duration diff = DateTime.now().difference(date);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays >= 30 && diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays >= 365) return '${(diff.inDays / 365).floor()}y ago';

    return 'Just now';
  }

  String formatMessageTime(dynamic timeData) {
    if (timeData == null) return 'Sending...';

    DateTime date;
    if (timeData is Timestamp) {
      date = timeData.toDate();
    } else if (timeData is int) {
      date = DateTime.fromMillisecondsSinceEpoch(timeData);
    } else {
      return '';
    }

    int hour = date.hour;
    int minute = date.minute;
    String ampm = hour >= 12 ? 'PM' : 'AM';

    hour = hour % 12;
    if (hour == 0) hour = 12;

    String minStr = minute < 10 ? '0$minute' : '$minute';
    return '$hour:$minStr $ampm';
  }

  Future<void> sendMessage(String roomId, String targetUid, String targetName, String targetAvatar) async {
    String text = messageController.text.trim();
    if (text.isEmpty || myUid.value.isEmpty) return;

    // 🔥 যদি কোনোভাবে ব্লক করা ইউজারকে মেসেজ দিতে চায়, তাহলে আটকে দিবে
    if (blockedUsers.contains(targetUid)) {
      Get.snackbar('Blocked', 'You cannot send messages to a blocked user.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    messageController.clear();
    int exactTime = DateTime.now().millisecondsSinceEpoch;

    try {
      WriteBatch batch = _db.batch();

      DocumentReference messageRef = _db.collection('chat_rooms').doc(roomId).collection('messages').doc();
      batch.set(messageRef, {
        'senderId': myUid.value,
        'text': text,
        'timestamp': exactTime,
      });

      DocumentReference roomRef = _db.collection('chat_rooms').doc(roomId);
      batch.set(roomRef, {
        'participants': FieldValue.arrayUnion([myUid.value, targetUid]),
        'lastMessage': text,
        'lastUpdated': exactTime,
        'usersData': {
          myUid.value: {'name': myName.value.isNotEmpty ? myName.value : 'User', 'avatar': myAvatar.value},
          targetUid: {'name': targetName.isNotEmpty ? targetName : 'User', 'avatar': targetAvatar},
        }
      }, SetOptions(merge: true));

      await batch.commit();
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: $e');
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    searchController.dispose();
    super.onClose();
  }
}