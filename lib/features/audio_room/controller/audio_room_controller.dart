import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/audio_room_model.dart';
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

  Stream<List<AudioRoomModel>> getLiveRoomsStream() {
    return _db.collection('live_audio_rooms').orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => AudioRoomModel.fromDocument(doc)).toList(),
    );
  }

  // 100% Safe ID (No Server Crash)
  String get safeUserId {
    String id = myUid.value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return id.isNotEmpty ? id : "user_${DateTime.now().millisecondsSinceEpoch}";
  }

  Future<void> startMyRoom(String customRoomName) async {
    if (safeUserId.isEmpty) return;

    isCreatingRoom.value = true;
    String roomId = 'room_$safeUserId';
    String finalRoomName = customRoomName.trim().isEmpty ? "${myName.value}'s Live Adda" : customRoomName.trim();

    try {
      AudioRoomModel newRoom = AudioRoomModel(
        roomId: roomId,
        hostId: safeUserId,
        hostName: myName.value,
        hostAvatar: myAvatar.value,
        roomName: finalRoomName,
      );

      await _db.collection('live_audio_rooms').doc(roomId).set(newRoom.toMap());

      isCreatingRoom.value = false;

      Get.to(() => ActiveAudioRoomView(
        roomId: roomId,
        roomName: finalRoomName,
        isHost: true, // সে হোস্ট
        userId: safeUserId,
        userName: myName.value.isEmpty ? "Nova Host" : myName.value,
        userAvatar: myAvatar.value,
      ));

    } catch (e) {
      isCreatingRoom.value = false;
      Get.snackbar('Error ⚠️', 'Failed to start room: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  void joinRoom(String roomId, String roomName) {
    if (safeUserId.isEmpty) return;

    Get.to(() => ActiveAudioRoomView(
      roomId: roomId,
      roomName: roomName,
      isHost: false, // সে স্পিকার হিসেবে জয়েন করবে
      userId: safeUserId,
      userName: myName.value.isEmpty ? "Nova Speaker" : myName.value,
      userAvatar: myAvatar.value,
    ));
  }
}