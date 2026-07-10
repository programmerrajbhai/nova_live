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

  // ⏰ ১০০% পারফেক্ট টাইম কনভার্টার
  String getTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';

    DateTime date = timestamp.toDate();
    Duration diff = DateTime.now().difference(date);

    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays >= 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';

    return 'Just now';
  }

  // 🔥 মাস্টার ফিক্স: Bulletproof Firebase Update Logic
  Future<void> sendMessage(String roomId, String targetUid, String targetName, String targetAvatar) async {
    String text = messageController.text.trim();
    if (text.isEmpty || myUid.value.isEmpty) return;

    messageController.clear(); // UI সাথে সাথে ক্লিয়ার হবে

    try {
      // ১. সাব-কালেকশনে মেসেজ সেভ করা (এটা আপনার আগে থেকেই ঠিক ছিল)
      await _db.collection('chat_rooms').doc(roomId).collection('messages').add({
        'senderId': myUid.value,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // ২. মেইন ইনবক্স ডকুমেন্টে শুধু লাস্ট মেসেজ এবং টাইম ফোর্স আপডেট করা
      final roomRef = _db.collection('chat_rooms').doc(roomId);

      try {
        // চেষ্টা করবে সরাসরি আপডেট করার (সবচেয়ে ফাস্ট এবং সিকিউরড)
        await roomRef.update({
          'lastMessage': text,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        // যদি চ্যাট রুম না থাকে (প্রথম মেসেজ), তাহলে নতুন করে Set করবে
        await roomRef.set({
          'participants': [myUid.value, targetUid],
          'lastMessage': text,
          'lastUpdated': FieldValue.serverTimestamp(),
          'usersData': {
            myUid.value: {'name': myName.value.isNotEmpty ? myName.value : 'User', 'avatar': myAvatar.value},
            targetUid: {'name': targetName.isNotEmpty ? targetName : 'User', 'avatar': targetAvatar},
          }
        });
      }
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