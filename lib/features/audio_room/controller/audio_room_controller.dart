import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../view/active_audio_room_view.dart';

class AudioRoomController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  var myUid = ''.obs;
  var myName = ''.obs;
  var myAvatar = ''.obs;
  var isCreatingRoom = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
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

  Stream<QuerySnapshot> getLiveRoomsStream() {
    return _db.collection('live_audio_rooms').orderBy('createdAt', descending: true).snapshots();
  }

  // 🔥 মাস্টার ফিক্স ১: ZIM সার্ভারের জন্য ইউজার আইডি সেফ করার লজিক (শুধুমাত্র বর্ণ ও সংখ্যা থাকবে)
  String get safeUserId => myUid.value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

  Future<void> startMyRoom(String customRoomName) async {
    if (myUid.value.isEmpty) return;

    isCreatingRoom.value = true;
    String roomId = 'room_$safeUserId';
    String finalRoomName = customRoomName.isEmpty ? "${myName.value}'s Adda 🎙️" : customRoomName;

    try {
      await _db.collection('live_audio_rooms').doc(roomId).set({
        'roomId': roomId,
        'hostId': safeUserId,
        'hostName': myName.value,
        'hostAvatar': myAvatar.value,
        'roomName': finalRoomName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      isCreatingRoom.value = false;

      Get.to(() => ActiveAudioRoomView(
        roomId: roomId,
        roomName: finalRoomName,
        isHost: true,
        userId: safeUserId, // সেফ আইডি পাঠানো হচ্ছে
        userName: myName.value,
        userAvatar: myAvatar.value,
      ));

    } catch (e) {
      isCreatingRoom.value = false;
      Get.snackbar('Database Error', e.toString(), backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  void joinRoom(String roomId, String roomName) {
    Get.to(() => ActiveAudioRoomView(
      roomId: roomId,
      roomName: roomName,
      isHost: false,
      userId: safeUserId, // সেফ আইডি পাঠানো হচ্ছে
      userName: myName.value,
      userAvatar: myAvatar.value,
    ));
  }
}