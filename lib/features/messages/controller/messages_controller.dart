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

  // 🔥 মাস্টার ফিক্স: Index Error এড়ানোর জন্য orderBy সরিয়ে ক্লায়েন্ট সাইডে সর্ট করব ভিউ-তে
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

  Future<void> sendMessage(String roomId, String targetUid, String targetName, String targetAvatar) async {
    String text = messageController.text.trim();
    if (text.isEmpty || myUid.value.isEmpty) return;

    messageController.clear();

    try {
      await _db.collection('chat_rooms').doc(roomId).collection('messages').add({
        'senderId': myUid.value,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _db.collection('chat_rooms').doc(roomId).set({
        'participants': [myUid.value, targetUid],
        'lastMessage': text,
        'lastUpdated': FieldValue.serverTimestamp(),
        'usersData': {
          myUid.value: {'name': myName.value, 'avatar': myAvatar.value},
          targetUid: {'name': targetName, 'avatar': targetAvatar},
        }
      }, SetOptions(merge: true));

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