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
    }
  }

  Stream<QuerySnapshot> getInboxStream() {
    return _db
        .collection('chat_rooms')
        .where('participants', arrayContains: myUid.value)
        .snapshots();
  }

  Stream<QuerySnapshot> getChatMessages(String roomId) {
    return _db
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // 🔥 Multi-Logic Time Converter (Handle both old Timestamp and new Integer)
  String getTimeAgo(dynamic timeData) {
    if (timeData == null) return 'Just now';

    DateTime date;

    // পুরনো মেসেজ হলে Timestamp ডিকোড করবে
    if (timeData is Timestamp) {
      date = timeData.toDate();
    }
    // নতুন মেসেজ হলে Integer (Epoch) ডিকোড করবে
    else if (timeData is int) {
      date = DateTime.fromMillisecondsSinceEpoch(timeData);
    } else {
      return 'Just now';
    }

    Duration diff = DateTime.now().difference(date);

    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays >= 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';

    return 'Just now';
  }

  // 🔥 Master Send Message Function (Bypassing Firebase Null Delay)
  Future<void> sendMessage(String roomId, String targetUid, String targetName, String targetAvatar) async {
    String text = messageController.text.trim();
    if (text.isEmpty || myUid.value.isEmpty) return;

    messageController.clear(); // UI সাথে সাথে ক্লিয়ার

    // serverTimestamp এর বদলে Exact Device Time নিচ্ছি, যাতে null না হয়
    int exactCurrentTime = DateTime.now().millisecondsSinceEpoch;

    try {
      WriteBatch batch = _db.batch();

      // ১. মেসেজ সাব-কালেকশনে সেভ করা
      DocumentReference messageRef = _db.collection('chat_rooms').doc(roomId).collection('messages').doc();
      batch.set(messageRef, {
        'senderId': myUid.value,
        'text': text,
        'timestamp': exactCurrentTime, // Exact Time
      });

      // ২. ইনবক্স ডকুমেন্টে আপডেট করা
      DocumentReference roomRef = _db.collection('chat_rooms').doc(roomId);
      batch.set(roomRef, {
        'participants': FieldValue.arrayUnion([myUid.value, targetUid]),
        'lastMessage': text,
        'lastUpdated': exactCurrentTime, // 🔥 Exact Time (এটাই ম্যাজিক করবে)
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
    super.onClose();
  }
}