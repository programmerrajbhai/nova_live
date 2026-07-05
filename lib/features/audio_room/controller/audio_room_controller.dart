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
    return _db
        .collection('live_audio_rooms')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // 🔥 কাস্টম রুমের নাম রিসিভ করার জন্য আপডেট করা হলো
  Future<void> startMyRoom(String customRoomName) async {
    if (myUid.value.isEmpty) return;

    isCreatingRoom.value = true;
    String roomId = 'room_${myUid.value}';
    String finalRoomName = customRoomName.isEmpty ? "${myName.value}'s Adda 🎙️" : customRoomName;

    try {
      await _db.collection('live_audio_rooms').doc(roomId).set({
        'roomId': roomId,
        'hostId': myUid.value,
        'hostName': myName.value,
        'hostAvatar': myAvatar.value,
        'roomName': finalRoomName, // ইউজারের দেওয়া নাম সেভ হবে
        'createdAt': FieldValue.serverTimestamp(),
      });

      isCreatingRoom.value = false;

      Get.to(() => ActiveAudioRoomView(
        roomId: roomId,
        roomName: finalRoomName,
        isHost: true,
        userId: myUid.value,
        userName: myName.value,
        userAvatar: myAvatar.value,
      ));

    } catch (e) {
      isCreatingRoom.value = false;
      Get.snackbar('Error', 'Failed to start room: $e', backgroundColor: const Color(0xFFFF5252), colorText: const Color(0xFFFFFFFF));
    }
  }

  void joinRoom(String roomId, String roomName) {
    Get.to(() => ActiveAudioRoomView(
      roomId: roomId,
      roomName: roomName,
      isHost: false,
      userId: myUid.value,
      userName: myName.value,
      userAvatar: myAvatar.value,
    ));
  }
}